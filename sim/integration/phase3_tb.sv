`timescale 1ns/1ps

module phase3_tb;

    logic pclk = 0;
    logic presetn = 0;

    logic psel = 0;
    logic penable = 0;
    logic pwrite = 0;
    logic [7:0] paddr = 0;
    logic [31:0] pwdata = 0;
    logic [31:0] prdata;
    logic pready;
    logic pslverr;

    logic pixel_wr_en = 0;
    logic [23:0] pixel_data = 0;

    logic pixel_ready;
    logic [15:0] pixel_x, pixel_y;
    logic [23:0] pixel_out;
    logic hsync, vsync, active_video, frame_start;
    logic display_enable;

    int active_count = 0;
    int frame_count = 0;

    always #5 pclk = ~pclk;

    display_subsystem_top #(
        .FIFO_DEPTH(16)
    ) dut (
        .pclk          (pclk),
        .presetn       (presetn),
        .psel          (psel),
        .penable       (penable),
        .pwrite        (pwrite),
        .paddr         (paddr),
        .pwdata        (pwdata),
        .prdata        (prdata),
        .pready        (pready),
        .pslverr       (pslverr),
        .pixel_wr_en   (pixel_wr_en),
        .pixel_data    (pixel_data),
        .pixel_ready   (pixel_ready),
        .pixel_x       (pixel_x),
        .pixel_y       (pixel_y),
        .pixel_out     (pixel_out),
        .hsync         (hsync),
        .vsync         (vsync),
        .active_video  (active_video),
        .frame_start   (frame_start),
        .display_enable(display_enable)
    );

    always @(posedge pclk) begin
        if (presetn) begin
            if (active_video)
                active_count <= active_count + 1;

            if (frame_start)
                frame_count <= frame_count + 1;
        end
    end

    task automatic apb_write(
        input logic [7:0] addr,
        input logic [31:0] data
    );
        begin
            @(negedge pclk);
            psel    = 1;
            penable = 0;
            pwrite  = 1;
            paddr   = addr;
            pwdata  = data;

            @(negedge pclk);
            penable = 1;

            @(negedge pclk);
            psel    = 0;
            penable = 0;
            pwrite  = 0;
            paddr   = 0;
            pwdata  = 0;
        end
    endtask

    task automatic apb_read_check(
        input logic [7:0] addr,
        input logic [31:0] expected
    );
        begin
            @(negedge pclk);
            psel    = 1;
            penable = 0;
            pwrite  = 0;
            paddr   = addr;

            @(negedge pclk);
            penable = 1;
            #1;

            if (prdata !== expected) begin
                $error("APB read mismatch addr=0x%02h expected=0x%08h got=0x%08h",
                       addr, expected, prdata);
                $fatal(1);
            end

            @(negedge pclk);
            psel    = 0;
            penable = 0;
            paddr   = 0;
        end
    endtask

    initial begin
        $display("PHASE3: Starting APB + display integration test");

        repeat (4) @(negedge pclk);
        presetn = 1;

        // Check APB reset defaults.
        apb_read_check(8'h04, 32'd640);
        apb_read_check(8'h08, 32'd16);
        apb_read_check(8'h14, 32'd480);

        // Configure a small timing mode for simulation.
        apb_write(8'h04, 32'd4); // H active
        apb_write(8'h08, 32'd1); // H front
        apb_write(8'h0C, 32'd1); // H sync
        apb_write(8'h10, 32'd1); // H back

        apb_write(8'h14, 32'd3); // V active
        apb_write(8'h18, 32'd1); // V front
        apb_write(8'h1C, 32'd1); // V sync
        apb_write(8'h20, 32'd1); // V back

        // Enable display and select format 2.
        apb_write(8'h00, 32'h0000_0005);

        apb_read_check(8'h00, 32'h0000_0005);
        apb_read_check(8'h04, 32'd4);
        apb_read_check(8'h14, 32'd3);

        if (!display_enable)
            $fatal(1, "Display enable did not assert");

        // Fill the FIFO.
        repeat (12) begin
            @(negedge pclk);
            pixel_wr_en = 1;
            pixel_data = pixel_data + 24'h010203;
        end

        @(negedge pclk);
        pixel_wr_en = 0;

        // Allow several small frames to run.
        repeat (120) @(negedge pclk);

        if (active_count == 0)
            $fatal(1, "No active video cycles observed");

        if (frame_count == 0)
            $fatal(1, "No frame_start observed");

        if ((^pixel_x) === 1'bx || (^pixel_y) === 1'bx)
            $fatal(1, "Pixel coordinates contain X values");

        if ((hsync !== 1'b0) && (hsync !== 1'b1))
            $fatal(1, "HSYNC is unknown");

        if ((vsync !== 1'b0) && (vsync !== 1'b1))
            $fatal(1, "VSYNC is unknown");

        // Disable display through APB.
        apb_write(8'h00, 32'h0000_0004);
        repeat (3) @(negedge pclk);

        if (display_enable !== 1'b0)
            $fatal(1, "Display enable failed to clear");

        if (active_video !== 1'b0)
            $fatal(1, "Active video should be low when display is disabled");

        $display("Active video cycles observed: %0d", active_count);
        $display("Frame start events observed: %0d", frame_count);
        $display("PHASE3_INTEGRATION_PASS");

        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "PHASE3 timeout");
    end

endmodule
