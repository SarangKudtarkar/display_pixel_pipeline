`timescale 1ns/1ps

module phase5_uvm_tb;

    import uvm_pkg::*;
    import display_uvm_pkg::*;

    apb_if apb_vif();

    logic pixel_wr_en;
    logic [23:0] pixel_data;

    logic pixel_ready;
    logic [15:0] pixel_x;
    logic [15:0] pixel_y;
    logic [23:0] pixel_out;

    logic hsync;
    logic vsync;
    logic active_video;
    logic frame_start;
    logic display_enable;

    // Clock generation
    initial begin
        apb_vif.pclk = 0;
        forever #5 apb_vif.pclk = ~apb_vif.pclk;
    end

    // Reset generation
    initial begin
        apb_vif.presetn = 0;

        repeat (5)
            @(negedge apb_vif.pclk);

        apb_vif.presetn = 1;
    end

    // Pixel input stimulus
    initial begin
        pixel_wr_en = 0;
        pixel_data = 24'h123456;
    end

    // Connect virtual interface to UVM components.
    initial begin
        uvm_config_db#(virtual apb_if)::set(
            null, "*", "vif", apb_vif);

        run_test("display_base_test");
    end

    // Integrated DUT
    display_subsystem_top #(
        .FIFO_DEPTH(16)
    ) dut (
        .pclk           (apb_vif.pclk),
        .presetn        (apb_vif.presetn),

        .psel           (apb_vif.psel),
        .penable        (apb_vif.penable),
        .pwrite          (apb_vif.pwrite),
        .paddr          (apb_vif.paddr),
        .pwdata         (apb_vif.pwdata),
        .prdata         (apb_vif.prdata),
        .pready         (apb_vif.pready),
        .pslverr         (apb_vif.pslverr),

        .pixel_wr_en    (pixel_wr_en),
        .pixel_data     (pixel_data),

        .pixel_ready    (pixel_ready),
        .pixel_x        (pixel_x),
        .pixel_y        (pixel_y),
        .pixel_out      (pixel_out),
        .hsync          (hsync),
        .vsync          (vsync),
        .active_video   (active_video),
        .frame_start    (frame_start),
        .display_enable (display_enable)
    );

endmodule
