`timescale 1ns/1ps

module power_fsm (
    input  logic clk,
    input  logic rst_n,
    input  logic idle_req,
    input  logic wake_req,
    output logic active,
    output logic idle,
    output logic gated
);

    typedef enum logic [1:0] {
        ACTIVE_ST,
        IDLE_ST,
        GATED_ST,
        WAKE_ST
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= ACTIVE_ST;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;

        case (state)
            ACTIVE_ST:
                if (idle_req)
                    next_state = IDLE_ST;

            IDLE_ST:
                if (idle_req)
                    next_state = GATED_ST;
                else
                    next_state = ACTIVE_ST;

            GATED_ST:
                if (wake_req)
                    next_state = WAKE_ST;

            WAKE_ST:
                next_state = ACTIVE_ST;

            default:
                next_state = ACTIVE_ST;
        endcase
    end

    always_comb begin
        active = 1'b0;
        idle   = 1'b0;
        gated  = 1'b0;

        case (state)
            ACTIVE_ST, WAKE_ST: active = 1'b1;
            IDLE_ST:             idle   = 1'b1;
            GATED_ST:            gated  = 1'b1;
            default: ;
        endcase
    end

endmodule
