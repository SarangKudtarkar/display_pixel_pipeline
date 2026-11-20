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

    logic [15:0] h_count;
    logic [15:0] v_count;

    logic [16:0] h_total;
    logic [16:0] v_total;

    always_comb begin
        h_total = {1'b0,h_active} + {1'b0,h_front}
                + {1'b0,h_sync} + {1'b0,h_back};

        v_total = {1'b0,v_active} + {1'b0,v_front}
                + {1'b0,v_sync} + {1'b0,v_back};
    end

    always_ff @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            h_count <= 16'd0;
            v_count <= 16'd0;
        end
        else if ((h_total == 0) || (v_total == 0)) begin
            h_count <= 16'd0;
            v_count <= 16'd0;
        end
        else if ({1'b0,h_count} >= h_total - 1'b1) begin
            h_count <= 16'd0;

            if ({1'b0,v_count} >= v_total - 1'b1)
                v_count <= 16'd0;
            else
                v_count <= v_count + 1'b1;
        end
        else begin
            h_count <= h_count + 1'b1;
        end
    end

    always_comb begin
        pixel_x = h_count;
        pixel_y = v_count;

        active_video =
            (h_count < h_active) &&
            (v_count < v_active);

        hsync =
            !((h_count >= (h_active + h_front)) &&
              (h_count <  (h_active + h_front + h_sync)));

        vsync =
            !((v_count >= (v_active + v_front)) &&
              (v_count <  (v_active + v_front + v_sync)));

        frame_start = (h_count == 0) && (v_count == 0);
    end

endmodule
