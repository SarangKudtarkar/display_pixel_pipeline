module vga_timing_gen (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        enable,

    input  logic [15:0] h_active,
    input  logic [15:0] h_total,
    input  logic [15:0] v_active,
    input  logic [15:0] v_total,
    input  logic [15:0] h_sync,
    input  logic [15:0] v_sync,

    output logic        hsync,
    output logic        vsync,
    output logic        hblank,
    output logic        vblank,
    output logic        active_video,
    output logic        pixel_valid,
    output logic [15:0] pixel_x,
    output logic [15:0] pixel_y
);

    logic [15:0] h_count;
    logic [15:0] v_count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_count <= '0;
            v_count <= '0;
        end else if (!enable) begin
            h_count <= '0;
            v_count <= '0;
        end else begin
            if (h_count == h_total - 1'b1) begin
                h_count <= '0;
                if (v_count == v_total - 1'b1)
                    v_count <= '0;
                else
                    v_count <= v_count + 1'b1;
            end else begin
                h_count <= h_count + 1'b1;
            end
        end
    end

    always_comb begin
        pixel_x = h_count;
        pixel_y = v_count;

        hsync = (h_count < h_sync);
        vsync = (v_count < v_sync);

        hblank = (h_count >= h_active);
        vblank = (v_count >= v_active);

        active_video = !hblank && !vblank && enable;
        pixel_valid  = active_video;
    end

endmodule
