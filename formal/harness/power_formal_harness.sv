module power_formal_harness;

    (* gclk *) logic clk;

    logic rst_n;
    (* anyseq *) logic idle_req;
    (* anyseq *) logic wake_req;

    logic clock_enable;
    logic busy;
    logic [1:0] power_state;

    power_ctrl dut (
        .clk,
        .rst_n,
        .idle_req,
        .wake_req,
        .clock_enable,
        .busy,
        .power_state
    );

    always_ff @(posedge clk)
        rst_n <= 1'b1;

    // State encoding checks
    always_comb begin
        assert (power_state inside {2'b00, 2'b01, 2'b10, 2'b11});
        assert (clock_enable == (power_state != 2'b10));
    end

endmodule
