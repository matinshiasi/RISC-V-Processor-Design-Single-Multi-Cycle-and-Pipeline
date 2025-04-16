`timescale 1ns/1ns

module HazardUnit (
    input  [4:0] Rs1DO,
    input  [4:0] Rs2DO,
    input  [4:0] Rs1EO,
    input  [4:0] Rs2EO,
    input  [4:0] RdEO,
    input  [4:0] RdMO,
    input  [4:0] RdWO,
    input        PCSrcEO,
    input        RegWriteMO,
    input        RegWriteWO,
    input  [1:0] ResultSrcEO,
    input        clk,
    output [1:0] forwardAE,
    output [1:0] forwardBE,
    output       stallF,
    output       stallD,
    output       flushD,
    output       flushE
);

    wire lwStall;

    ForwardingUnit ForwardingUnitUUT (Rs1EO, Rs2EO, RdMO, RdWO, RegWriteMO, RegWriteWO, forwardAE, forwardBE);
    DataHazardUnit DataHazardUnitUUT (clk, Rs1DO, Rs2DO, RdEO, ResultSrcEO, stallF, stallD, lwStall);
    ControlHazardUnit ControlHazardUnitUUT (clk, PCSrcEO, lwStall, flushD, flushE);

endmodule

module ForwardingUnit (
    input  [4:0] Rs1E,
    input  [4:0] Rs2E,
    input  [4:0] RdM,
    input  [4:0] RdW,
    input        RegWriteM,
    input        RegWriteW,
    output reg [1:0] forwardAE,
    output reg [1:0] forwardBE
);

    always @(*) begin
        if ((Rs1E == RdM) && RegWriteM && (Rs1E != 5'b0)) begin
            forwardAE = 2'b10;
        end else if ((Rs1E == RdW) && RegWriteW && (Rs1E != 5'b0)) begin
            forwardAE = 2'b01;
        end else begin
            forwardAE = 2'b00;
        end

        if ((Rs2E == RdM) && RegWriteM && (Rs2E != 5'b0)) begin
            forwardBE = 2'b10;
        end else if ((Rs2E == RdW) && RegWriteW && (Rs2E != 5'b0)) begin
            forwardBE = 2'b01;
        end else begin
            forwardBE = 2'b00;
        end
    end

endmodule

module DataHazardUnit(input clk , input [4:0] Rs1D , Rs2D , RdE , input [1:0] ResultSrcE , output stallF , stallD ,output lwStall);
    assign lwStall = ((Rs1D == RdE) || (Rs2D == RdE)) && (ResultSrcE == 2'b01);
    assign stallD = ~lwStall;
    assign stallF = ~lwStall;
endmodule

module ControlHazardUnit(input clk , PCSrcE , lwStall , output  flushD , flushE);
    assign flushD = PCSrcE;
    assign flushE = (lwStall | PCSrcE);
endmodule

