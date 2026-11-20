module power_properties (
    input logic clk,
    input logic rst_n,
    input logic [1:0] state,
    input logic clock_enable,
    input logic wake_req
);

    default clocking cb @(posedge clk); endclocking

    assert property (@(posedge clk) disable iff (!rst_n)
        state == 2'b10 |-> !clock_enable);

    assert property (@(posedge clk) disable iff (!rst_n)
        state == 2'b11 |-> clock_enable);

    // Wake request should cause progress from GATED to WAKE.
    assert property (@(posedge clk) disable iff (!rst_n)
        (state == 2'b10 && wake_req) |=> state == 2'b11);

endmodule
