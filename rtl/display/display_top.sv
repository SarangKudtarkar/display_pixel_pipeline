`timescale 1ns/1ps

module display_top #(
    parameter int FIFO_DEPTH = 16
) (
    input  logic        pclk,
    input  logic        rst_n,

    input  logic [15:0] h_active,
    input  logic [15:0] h_front,
    input  logic [15:0] h_sync,
    input  logic [15:0] h_back,
    input  logic [15:0] v_active,
    input  logic [15:0] v_front,
    input  logic [15:0] v_sync,
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

    logic [23:0] fifo_dout;
    logic fifo_full, fifo_empty;
    logic [$clog2(FIFO_DEPTH+1)-1:0] fifo_count;
    logic fifo_rd_en;

    assign pixel_ready = !fifo_full;
    assign fifo_rd_en  = active_video && !fifo_empty;

    pixel_fifo #(
        .DATA_WIDTH(24),
        .DEPTH(FIFO_DEPTH)
    ) u_pixel_fifo (
        .clk(pclk),
        .rst_n(rst_n),
        .wr_en(pixel_wr_en && pixel_ready),
        .din(pixel_data),
        .rd_en(fifo_rd_en),
        .dout(fifo_dout),
        .full(fifo_full),
        .empty(fifo_empty),
        .count(fifo_count)
    );

    color_converter u_color_converter (
        .pixel_in(fifo_dout),
        .format_sel(format_sel),
        .pixel_out(pixel_out)
    );

    vga_timing_gen u_vga_timing_gen (
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
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .hsync(hsync),
        .vsync(vsync),
        .active_video(active_video),
        .frame_start(frame_start)
    );

endmodule
