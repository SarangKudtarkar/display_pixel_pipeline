module display_top (
    input logic pclk,
    input logic presetn,

    input logic psel,
    input logic penable,
    input logic pwrite,
    input logic [7:0] paddr,
    input logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic pready,
    output logic pslverr,

    input logic idle_req,
    input logic wake_req,

    output logic hsync,
    output logic vsync,
    output logic hblank,
    output logic vblank,
    output logic active_video,
    output logic pixel_valid,
    output logic [15:0] pixel_x,
    output logic [15:0] pixel_y,
    output logic clock_enable,
    output logic [1:0] power_state
);

    logic [15:0] h_active, h_total;
    logic [15:0] v_active, v_total;
    logic [15:0] h_sync, v_sync;
    logic [1:0] pixel_format;
    logic enable;
    logic busy;

    apb_regs u_apb_regs (
        .pclk, .presetn,
        .psel, .penable, .pwrite, .paddr, .pwdata,
        .prdata, .pready, .pslverr,
        .h_active, .h_total, .v_active, .v_total,
        .h_sync, .v_sync, .pixel_format, .enable
    );

    power_ctrl u_power_ctrl (
        .clk(pclk),
        .rst_n(presetn),
        .idle_req,
        .wake_req,
        .clock_enable,
        .busy,
        .power_state
    );

    vga_timing_gen u_timing (
        .clk(pclk),
        .rst_n(presetn),
        .enable(enable && clock_enable),
        .h_active, .h_total, .v_active, .v_total,
        .h_sync, .v_sync,
        .hsync, .vsync, .hblank, .vblank,
        .active_video, .pixel_valid,
        .pixel_x, .pixel_y
    );

endmodule
