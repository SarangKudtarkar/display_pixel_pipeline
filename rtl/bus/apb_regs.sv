`timescale 1ns/1ps

module apb_regs (
    input  logic        pclk,
    input  logic        presetn,
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [7:0]  paddr,
    input  logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic        pready,
    output logic        pslverr,

    output logic        display_enable,
    output logic [1:0]  pixel_format,

    output logic [15:0] h_active,
    output logic [15:0] h_front,
    output logic [15:0] h_sync,
    output logic [15:0] h_back,

    output logic [15:0] v_active,
    output logic [15:0] v_front,
    output logic [15:0] v_sync,
    output logic [15:0] v_back
);

    localparam logic [7:0] ADDR_CTRL     = 8'h00;
    localparam logic [7:0] ADDR_H_ACTIVE = 8'h04;
    localparam logic [7:0] ADDR_H_FRONT  = 8'h08;
    localparam logic [7:0] ADDR_H_SYNC   = 8'h0C;
    localparam logic [7:0] ADDR_H_BACK   = 8'h10;
    localparam logic [7:0] ADDR_V_ACTIVE = 8'h14;
    localparam logic [7:0] ADDR_V_FRONT  = 8'h18;
    localparam logic [7:0] ADDR_V_SYNC   = 8'h1C;
    localparam logic [7:0] ADDR_V_BACK   = 8'h20;

    logic valid_addr;

    always_comb begin
        valid_addr = 1'b1;

        case (paddr)
            ADDR_CTRL,
            ADDR_H_ACTIVE, ADDR_H_FRONT,
            ADDR_H_SYNC, ADDR_H_BACK,
            ADDR_V_ACTIVE, ADDR_V_FRONT,
            ADDR_V_SYNC, ADDR_V_BACK: ;
            default: valid_addr = 1'b0;
        endcase
    end

    assign pready  = 1'b1;
    assign pslverr = psel && penable && !valid_addr;

    always_comb begin
        prdata = 32'h00000000;

        case (paddr)
            ADDR_CTRL:
                prdata = {29'b0, pixel_format, display_enable};
            ADDR_H_ACTIVE: prdata = {16'b0, h_active};
            ADDR_H_FRONT:  prdata = {16'b0, h_front};
            ADDR_H_SYNC:   prdata = {16'b0, h_sync};
            ADDR_H_BACK:   prdata = {16'b0, h_back};
            ADDR_V_ACTIVE: prdata = {16'b0, v_active};
            ADDR_V_FRONT:  prdata = {16'b0, v_front};
            ADDR_V_SYNC:   prdata = {16'b0, v_sync};
            ADDR_V_BACK:   prdata = {16'b0, v_back};
            default:       prdata = 32'h00000000;
        endcase
    end

    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            display_enable <= 1'b0;
            pixel_format   <= 2'b00;

            h_active <= 16'd640;
            h_front  <= 16'd16;
            h_sync   <= 16'd96;
            h_back   <= 16'd48;

            v_active <= 16'd480;
            v_front  <= 16'd10;
            v_sync   <= 16'd2;
            v_back   <= 16'd33;
        end
        else if (psel && penable && pwrite && valid_addr) begin
            case (paddr)
                ADDR_CTRL: begin
                    display_enable <= pwdata[0];
                    pixel_format   <= pwdata[2:1];
                end

                ADDR_H_ACTIVE: h_active <= pwdata[15:0];
                ADDR_H_FRONT:  h_front  <= pwdata[15:0];
                ADDR_H_SYNC:   h_sync   <= pwdata[15:0];
                ADDR_H_BACK:   h_back   <= pwdata[15:0];

                ADDR_V_ACTIVE: v_active <= pwdata[15:0];
                ADDR_V_FRONT:  v_front  <= pwdata[15:0];
                ADDR_V_SYNC:   v_sync   <= pwdata[15:0];
                ADDR_V_BACK:   v_back   <= pwdata[15:0];

                default: ;
            endcase
        end
    end

endmodule
