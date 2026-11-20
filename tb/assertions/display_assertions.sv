module display_assertions (
    input logic clk,
    input logic rst_n,
    input logic hsync,
    input logic vsync,
    input logic hblank,
    input logic vblank,
    input logic pixel_valid,
    input logic clock_enable
);

    default clocking cb @(posedge clk); endclocking

    property no_pixel_when_gated;
        !clock_enable |-> !pixel_valid;
    endproperty

    assert property (@(posedge clk) disable iff (!rst_n)
        no_pixel_when_gated);

    property no_pixel_in_blank;
        (hblank || vblank) |-> !pixel_valid;
    endproperty

    assert property (@(posedge clk) disable iff (!rst_n)
        no_pixel_in_blank);

    property pixel_requires_clock;
        pixel_valid |-> clock_enable;
    endproperty

    assert property (@(posedge clk) disable iff (!rst_n)
        pixel_requires_clock);

endmodule
