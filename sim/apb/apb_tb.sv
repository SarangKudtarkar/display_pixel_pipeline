`timescale 1ns/1ps

module apb_tb;

    logic pclk = 0;
    logic presetn = 0;

    logic psel = 0;
    logic penable = 0;
    logic pwrite = 0;
    logic [7:0] paddr = 0;
    logic [31:0] pwdata = 0;

    logic [31:0] prdata;
    logic pready, pslverr;

    logic display_enable;
    logic [1:0] pixel_format;

    logic [15:0] h_active, h_front, h_sync, h_back;
    logic [15:0] v_active, v_front, v_sync, v_back;

    integer pass_count = 0;

    always #5 pclk = ~pclk;

    apb_regs dut (
        .pclk(pclk),
        .presetn(presetn),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr),
        .display_enable(display_enable),
        .pixel_format(pixel_format),
        .h_active(h_active),
        .h_front(h_front),
        .h_sync(h_sync),
        .h_back(h_back),
        .v_active(v_active),
        .v_front(v_front),
        .v_sync(v_sync),
        .v_back(v_back)
    );

    task automatic apb_write(
        input logic [7:0] addr,
        input logic [31:0] data
    );
        begin
            @(negedge pclk);
            psel = 1;
            penable = 0;
            pwrite = 1;
            paddr = addr;
            pwdata = data;

            @(negedge pclk);
            penable = 1;

            @(posedge pclk);
            if (!pready)
                $fatal(1, "APB write did not complete");

            @(negedge pclk);
            psel = 0;
            penable = 0;
            pwrite = 0;
        end
    endtask

    task automatic apb_read_check(
        input logic [7:0] addr,
        input logic [31:0] expected
    );
        logic [31:0] actual;
        begin
            @(negedge pclk);
            psel = 1;
            penable = 0;
            pwrite = 0;
            paddr = addr;

            @(negedge pclk);
            penable = 1;

            #1;
            actual = prdata;

            if (!pready)
                $fatal(1, "APB read did not complete at address %h", addr);

            if (actual !== expected)
                $fatal(1,
                    "Read mismatch addr=%h expected=%h actual=%h",
                    addr, expected, actual);

            @(negedge pclk);
            psel = 0;
            penable = 0;

            pass_count = pass_count + 1;
            $display("PASS: Read addr=%h data=%h", addr, actual);
        end
    endtask

    initial begin
        $display("----------------------------------------");
        $display(" PHASE 2 APB REGISTER TEST");
        $display("----------------------------------------");

        // Reset
        presetn = 0;
        repeat (4) @(negedge pclk);
        presetn = 1;
        repeat (2) @(negedge pclk);

        // Verify reset defaults
        apb_read_check(8'h04, 32'd640);
        apb_read_check(8'h08, 32'd16);
        apb_read_check(8'h0C, 32'd96);
        apb_read_check(8'h10, 32'd48);
        apb_read_check(8'h14, 32'd480);
        apb_read_check(8'h18, 32'd10);
        apb_read_check(8'h1C, 32'd2);
        apb_read_check(8'h20, 32'd33);
        apb_read_check(8'h00, 32'h00000000);

        // Write new timing values
        apb_write(8'h04, 32'd800);
        apb_write(8'h08, 32'd40);
        apb_write(8'h0C, 32'd128);
        apb_write(8'h10, 32'd88);

        apb_write(8'h14, 32'd600);
        apb_write(8'h18, 32'd5);
        apb_write(8'h1C, 32'd4);
        apb_write(8'h20, 32'd23);

        // Configure display enable and pixel format
        apb_write(8'h00, 32'h00000005);

        // Verify writes
        apb_read_check(8'h04, 32'd800);
        apb_read_check(8'h08, 32'd40);
        apb_read_check(8'h0C, 32'd128);
        apb_read_check(8'h10, 32'd88);

        apb_read_check(8'h14, 32'd600);
        apb_read_check(8'h18, 32'd5);
        apb_read_check(8'h1C, 32'd4);
        apb_read_check(8'h20, 32'd23);
        apb_read_check(8'h00, 32'h00000005);

        if (h_active != 800 || v_active != 600)
            $fatal(1, "Timing output verification failed");

        if (!display_enable || pixel_format != 2'b10)
            $fatal(1, "Control output verification failed");

        $display("PASS: Register output signals verified");

        // Invalid address must assert PSLVERR
        @(negedge pclk);
        psel = 1;
        penable = 0;
        pwrite = 0;
        paddr = 8'hFC;

        @(negedge pclk);
        penable = 1;
        #1;

        if (!pslverr)
            $fatal(1, "Expected PSLVERR for invalid address");

        $display("PASS: Invalid address error detected");

        @(negedge pclk);
        psel = 0;
        penable = 0;

        $display("----------------------------------------");
        $display("PHASE2_APB_PASS");
        $display("Read checks completed: %0d", pass_count);
        $display("----------------------------------------");

        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "APB testbench timeout");
    end

endmodule
