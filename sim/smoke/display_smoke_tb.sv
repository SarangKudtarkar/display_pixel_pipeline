`timescale 1ns/1ps

module display_smoke_tb;

    logic pclk = 0;
    logic rst_n = 0;

    // Display timing configuration
    logic [15:0] h_active = 16'd8;
    logic [15:0] h_front  = 16'd2;
    logic [15:0] h_sync   = 16'd2;
    logic [15:0] h_back   = 16'd2;

    logic [15:0] v_active = 16'd4;
    logic [15:0] v_front  = 16'd1;
    logic [15:0] v_sync   = 16'd1;
    logic [15:0] v_back   = 16'd1;

    // Pixel input
    logic        pixel_wr_en = 0;
    logic [23:0] pixel_data = 0;
    logic [1:0]  format_sel = 0;

    // DUT outputs
    logic        pixel_ready;
    logic [15:0] pixel_x;
    logic [15:0] pixel_y;
    logic [23:0] pixel_out;
    logic        hsync;
    logic        vsync;
    logic        active_video;
    logic        frame_start;

    // Power FSM signals
    logic idle_req = 0;
    logic wake_req = 0;
    logic power_active;
    logic power_idle;
    logic power_gated;

    integer i;
    integer active_pixel_count = 0;
    integer frame_count = 0;

    always #5 pclk = ~pclk;

    display_top #(
        .FIFO_DEPTH(16)
    ) dut (
        .pclk(pclk),
        .rst_n(rst_n),

        .h_active(h_active),
        .h_front(h_front),
        .h_sync(h_sync),
        .h_back(h_back),

        .v_active(v_active),
        .v_front(v_front),
        .v_sync(v_sync),
        .v_back(v_back),

        .pixel_wr_en(pixel_wr_en),
        .pixel_data(pixel_data),
        .format_sel(format_sel),

        .pixel_ready(pixel_ready),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .pixel_out(pixel_out),
        .hsync(hsync),
        .vsync(vsync),
        .active_video(active_video),
        .frame_start(frame_start)
    );

    power_fsm u_power_fsm (
        .clk(pclk),
        .rst_n(rst_n),
        .idle_req(idle_req),
        .wake_req(wake_req),
        .active(power_active),
        .idle(power_idle),
        .gated(power_gated)
    );

    // Monitor display activity
    always @(posedge pclk) begin
        if (rst_n) begin
            if (active_video)
                active_pixel_count <= active_pixel_count + 1;

            if (frame_start)
                frame_count <= frame_count + 1;
        end
    end

    initial begin
        $display("----------------------------------------");
        $display(" Display Pipeline Phase 1 Smoke Test");
        $display("----------------------------------------");

        // Reset
        rst_n = 0;
        repeat (5) @(negedge pclk);
        rst_n = 1;

        // Check initial power state
        repeat (2) @(negedge pclk);
        if (!power_active) begin
            $fatal(1, "Expected ACTIVE state after reset");
        end
        $display("PASS: Initial power state ACTIVE");

        // Fill FIFO with test pixels
        for (i = 0; i < 12; i = i + 1) begin
            @(negedge pclk);
            if (pixel_ready) begin
                pixel_wr_en = 1;
                pixel_data = {8'(i), 8'(i+16), 8'(i+32)};
            end
        end

        @(negedge pclk);
        pixel_wr_en = 0;

        // Allow display timing and FIFO to run
        repeat (150) @(negedge pclk);

        if (active_pixel_count == 0) begin
            $fatal(1, "No active display pixels observed");
        end
        $display("PASS: Active display pixels observed: %0d",
                 active_pixel_count);

        if (frame_count == 0) begin
            $fatal(1, "No frame start observed");
        end
        $display("PASS: Frame start observed");

        // Check horizontal and vertical sync outputs are known
        if ((^hsync === 1'bx) || (^vsync === 1'bx)) begin
            $fatal(1, "Unknown sync output detected");
        end
        $display("PASS: HSYNC and VSYNC are known");

        // Request low-power transition
        @(negedge pclk);
        idle_req = 1;

        repeat (3) @(negedge pclk);

        if (!power_gated) begin
            $fatal(1, "Expected GATED state");
        end
        $display("PASS: Power FSM entered GATED");

        // Deassert idle request before wake-up
        @(negedge pclk);
        idle_req = 0;
        wake_req = 1;

        repeat (1) @(negedge pclk);
        wake_req = 0;

        repeat (3) @(negedge pclk);

        if (!power_active) begin
            $fatal(1, "Expected ACTIVE state after wake");
        end
        $display("PASS: Power FSM returned to ACTIVE");

        $display("----------------------------------------");
        $display("PHASE1_SMOKE_PASS");
        $display("----------------------------------------");

        $finish;
    end

    // Simulation watchdog
    initial begin
        #100000;
        $fatal(1, "Simulation timeout");
    end

endmodule
