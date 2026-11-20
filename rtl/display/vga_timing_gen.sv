`timescale 1ns/1ps

module vga_timing_gen (
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
    output logic [15:0] pixel_x,
    output logic [15:0] pixel_y,
    output logic        hsync,
    output logic        vsync,
    output logic        active_video,
    output logic        frame_start
);

    logic [16:0] h_total;
    logic [16:0] v_total;

    assign h_total = {1'b0,h_active} + {1'b0,h_front} +
                     {1'b0,h_sync} + {1'b0,h_back};
    assign v_total = {1'b0,v_active} + {1'b0,v_front} +
                     {1'b0,v_sync} + {1'b0,v_back};

    always_ff @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_x <= 0;
            pixel_y <= 0;
        end else if (h_total == 0 || v_total == 0) begin
            pixel_x <= 0;
            pixel_y <= 0;
        end else if ({1'b0,pixel_x} >= h_total - 1'b1) begin
            pixel_x <= 0;
            if ({1'b0,pixel_y} >= v_total - 1'b1)
                pixel_y <= 0;
            else
                pixel_y <= pixel_y + 1'b1;
        end else begin
            pixel_x <= pixel_x + 1'b1;
        end
    end

    always_comb begin
        active_video = (pixel_x < h_active) && (pixel_y < v_active);

        hsync = !((pixel_x >= (h_active + h_front)) &&
                  (pixel_x <  (h_active + h_front + h_sync)));

        vsync = !((pixel_y >= (v_active + v_front)) &&
                  (pixel_y <  (v_active + v_front + v_sync)));

        frame_start = (pixel_x == 0) && (pixel_y == 0);
    end

endmodule
