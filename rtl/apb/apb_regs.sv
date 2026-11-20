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

    output logic [15:0] h_active,
    output logic [15:0] h_total,
    output logic [15:0] v_active,
    output logic [15:0] v_total,
    output logic [15:0] h_sync,
    output logic [15:0] v_sync,
    output logic [1:0]  pixel_format,
    output logic        enable
);

    localparam ADDR_H_ACTIVE = 8'h00;
    localparam ADDR_H_TOTAL  = 8'h04;
    localparam ADDR_V_ACTIVE = 8'h08;
    localparam ADDR_V_TOTAL  = 8'h0C;
    localparam ADDR_H_SYNC   = 8'h10;
    localparam ADDR_V_SYNC   = 8'h14;
    localparam ADDR_FORMAT   = 8'h18;
    localparam ADDR_CONTROL  = 8'h1C;

    assign pready  = 1'b1;
    assign pslverr = 1'b0;

    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            h_active     <= 16'd640;
            h_total      <= 16'd800;
            v_active     <= 16'd480;
            v_total      <= 16'd525;
            h_sync       <= 16'd96;
            v_sync       <= 16'd2;
            pixel_format <= 2'b01;
            enable       <= 1'b0;
        end else if (psel && penable && pwrite) begin
            case (paddr)
                ADDR_H_ACTIVE: h_active     <= pwdata[15:0];
                ADDR_H_TOTAL:  h_total      <= pwdata[15:0];
                ADDR_V_ACTIVE: v_active     <= pwdata[15:0];
                ADDR_V_TOTAL:  v_total      <= pwdata[15:0];
                ADDR_H_SYNC:   h_sync       <= pwdata[15:0];
                ADDR_V_SYNC:   v_sync       <= pwdata[15:0];
                ADDR_FORMAT:   pixel_format <= pwdata[1:0];
                ADDR_CONTROL:  enable       <= pwdata[0];
                default: ;
            endcase
        end
    end

    always_comb begin
        prdata = '0;
        if (psel && !pwrite) begin
            case (paddr)
                ADDR_H_ACTIVE: prdata = {16'b0, h_active};
                ADDR_H_TOTAL:  prdata = {16'b0, h_total};
                ADDR_V_ACTIVE: prdata = {16'b0, v_active};
                ADDR_V_TOTAL:  prdata = {16'b0, v_total};
                ADDR_H_SYNC:   prdata = {16'b0, h_sync};
                ADDR_V_SYNC:   prdata = {16'b0, v_sync};
                ADDR_FORMAT:   prdata = {30'b0, pixel_format};
                ADDR_CONTROL:  prdata = {31'b0, enable};
                default:       prdata = '0;
            endcase
        end
    end

endmodule
