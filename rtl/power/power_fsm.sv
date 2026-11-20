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
        ACTIVE,
        IDLE,
        GATED,
        WAKE
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= ACTIVE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;

        case (state)
            ACTIVE: begin
                if (idle_req)
                    next_state = IDLE;
            end

            IDLE: begin
                if (idle_req)
                    next_state = GATED;
                else
                    next_state = ACTIVE;
            end

            GATED: begin
                if (wake_req)
                    next_state = WAKE;
            end

            WAKE: begin
                next_state = ACTIVE;
            end

            default: next_state = ACTIVE;
        endcase
    end

    always_comb begin
        active = 1'b0;
        idle   = 1'b0;
        gated  = 1'b0;

        case (state)
            ACTIVE: active = 1'b1;
            IDLE:   idle   = 1'b1;
            GATED:  gated  = 1'b1;
            WAKE:   active = 1'b1;
            default: ;
        endcase
    end

endmodule
