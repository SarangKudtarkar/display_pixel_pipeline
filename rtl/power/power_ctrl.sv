module power_ctrl (
    input  logic clk,
    input  logic rst_n,

    input  logic idle_req,
    input  logic wake_req,

    output logic clock_enable,
    output logic busy,
    output logic [1:0] power_state
);

    localparam ACTIVE = 2'b00;
    localparam IDLE   = 2'b01;
    localparam GATED  = 2'b10;
    localparam WAKE   = 2'b11;

    logic [1:0] state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= ACTIVE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;

        case (state)
            ACTIVE: if (idle_req) next_state = IDLE;

            IDLE: begin
                if (wake_req)
                    next_state = WAKE;
                else
                    next_state = GATED;
            end

            GATED: if (wake_req) next_state = WAKE;

            WAKE: next_state = ACTIVE;

            default: next_state = ACTIVE;
        endcase
    end

    always_comb begin
        power_state = state;
        clock_enable = (state != GATED);
        busy = (state == ACTIVE) || (state == WAKE);
    end

endmodule
