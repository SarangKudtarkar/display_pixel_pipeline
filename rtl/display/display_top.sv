`timescale 1ns/1ps

module display_top #(
    parameter int FIFO_DEPTH = 16
) (
    input  logic        pclk,
    input  logic        rst_n,

    input  logic [15:0] h_active,
    input  logic [15:0] h_front,
    input  logic [15:0] h_sync_cfg,
    input  logic [15:0] h_back,

    input  logic [15:0] v_active,
    input  logic [15:0] v_front,
    input  logic [15:0] v_sync_cfg,
    input  logic [15:0] v_back,

    input  logic        pixel_wr_en,
    input  logic [23:0] pixel_data,
    input  logic [1:0]  format_sel,

    output logic        pixel_ready,
    output logic [15:0] pixel_x,
    output logic [15:0] pixel_y,
    output logic [23:0] pixel_out,
    output logic        hsync,
    output logic        vsync,
    output logic        active_video,
    output logic        frame_start
);

    logic [23:0] fifo_data;
    logic fifo_full;
    logic fifo_empty;
    logic fifo_rd_en;

    logic [23:0] converted_pixel;

    assign pixel_ready = !fifo_full;

    // Consume one pixel on each active display cycle.
    assign fifo_rd_en = active_video && !fifo_empty;

    pixel_fifo #(
        .DATA_WIDTH(24),
        .DEPTH(FIFO_DEPTH)
    ) u_pixel_fifo (
        .clk   (pclk),
        .rst_n (rst_n),
        .wr_en (pixel_wr_en && !fifo_full),
        .din   (pixel_data),
        .rd_en (fifo_rd_en),
        .dout  (fifo_data),
        .full  (fifo_full),
        .empty (fifo_empty)
    );

    color_converter u_color_converter (
        .pixel_in  (fifo_data),
        .format_sel(format_sel),
        .pixel_out (converted_pixel)
    );

    vga_timing_gen u_vga_timing_gen (
        .pclk        (pclk),
        .rst_n       (rst_n),
        .h_active    (h_active),
        .h_front     (h_front),
        .h_sync      (h_sync_cfg),
        .h_back      (h_back),
        .v_active    (v_active),
        .v_front     (v_front),
        .v_sync      (v_sync_cfg),
        .v_back      (v_back),
        .pixel_x     (pixel_x),
        .pixel_y     (pixel_y),
        .hsync       (hsync),
        .vsync       (vsync),
        .active_video(active_video),
        .frame_start (frame_start)
    );

    assign pixel_out = converted_pixel;

endmodule
