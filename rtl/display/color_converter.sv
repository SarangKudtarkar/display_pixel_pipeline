`timescale 1ns/1ps

module color_converter (
    input  logic [23:0] pixel_in,
    input  logic [1:0]  format_sel,
    output logic [23:0] pixel_out
);

    logic [7:0] r, g, b;

    always_comb begin
        r = pixel_in[23:16];
        g = pixel_in[15:8];
        b = pixel_in[7:0];

        case (format_sel)
            2'd0: pixel_out = {r,g,b};
            2'd1: pixel_out = {b,g,r};
            2'd2: pixel_out = {g,r,b};
            2'd3: pixel_out = {r,b,g};
            default: pixel_out = pixel_in;
        endcase
    end

endmodule
