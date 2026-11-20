module color_convert (
    input  logic [31:0] pixel_in,
    input  logic [1:0]  pixel_format,
    output logic [23:0] pixel_out
);

    always_comb begin
        case (pixel_format)
            2'b00: begin // RGB565 to RGB888
                pixel_out = {
                    pixel_in[15:11], pixel_in[15:13],
                    pixel_in[10:5],  pixel_in[10:9],
                    pixel_in[4:0],   pixel_in[4:2]
                };
            end

            2'b01: pixel_out = pixel_in[23:0]; // RGB888
            2'b10: pixel_out = pixel_in[23:0]; // ARGB8888: discard alpha
            default: pixel_out = '0;
        endcase
    end

endmodule
