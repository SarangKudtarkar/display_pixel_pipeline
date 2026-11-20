`timescale 1ns/1ps

module display_subsystem_top #(
    parameter int FIFO_DEPTH = 16
) (
    input  logic        pclk,
    input  logic        presetn,

    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [7:0]  paddr,
    input  logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic        pready,
    output logic        pslverr,

    input  logic        pixel_wr_en,
    input  logic [23:0] pixel_data,

    output logic        pixel_ready,
    output logic [15:0] pixel_x,
    output logic [15:0] pixel_y,
    output logic [23:0] pixel_out,
    output logic        hsync,
    output logic        vsync,
    output logic        active_video,
    output logic        frame_start,
    output logic        display_enable
);

    logic [1:0]  pixel_format;

    logic [15:0] h_active, h_front, h_sync_cfg, h_back;
    logic [15:0] v_active, v_front, v_sync_cfg, v_back;

    logic raw_active_video;

    // APB is instantiated exactly once, at subsystem level.
    apb_regs u_apb_regs (
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
        .display_enable(display_enable),
        .pixel_format  (pixel_format),
        .h_active      (h_active),
        .h_front       (h_front),
        .h_sync        (h_sync_cfg),
        .h_back        (h_back),
        .v_active      (v_active),
        .v_front       (v_front),
        .v_sync        (v_sync_cfg),
        .v_back        (v_back)
    );

    display_top #(
        .FIFO_DEPTH(FIFO_DEPTH)
    ) u_display_top (
        .pclk        (pclk),
        .rst_n       (presetn),
        .h_active    (h_active),
        .h_front     (h_front),
        .h_sync_cfg  (h_sync_cfg),
        .h_back      (h_back),
        .v_active    (v_active),
        .v_front     (v_front),
        .v_sync_cfg  (v_sync_cfg),
        .v_back      (v_back),
        .pixel_wr_en (pixel_wr_en),
        .pixel_data  (pixel_data),
        .format_sel  (pixel_format),
        .pixel_ready (pixel_ready),
        .pixel_x     (pixel_x),
        .pixel_y     (pixel_y),
        .pixel_out   (pixel_out),
        .hsync       (hsync),
        .vsync       (vsync),
        .active_video(raw_active_video),
        .frame_start (frame_start)
    );

    assign active_video = raw_active_video && display_enable;

endmodule
