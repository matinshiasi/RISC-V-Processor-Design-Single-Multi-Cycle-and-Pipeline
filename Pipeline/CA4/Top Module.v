
`timescale 1ns/1ns

module proccesor(input clk, rst);
    wire zero;
    wire [31:0] I;
    wire PCSrc;
    wire [2:0] ALUfunc;
    wire [1:0] ResultSrc;
    wire [2:0] ImmSrc;
    wire MemWrite, RegWrite, ALUSrc, AddMuxSel;
    wire stallF, stallD, flushD, flushE;
    wire [1:0] forwardAE, forwardBE;
    wire [4:0] Rs1DO, Rs2DO, Rs1EO, Rs2EO, RdEO, RdMO, RdWO;
    wire PCSrcEO, RegWriteMO, RegWriteWO;
    wire [1:0] ResultSrcEO;
    wire jump, branch, jumpE, branchE;

    DP DPUUT (
        RegWrite, MemWrite, ALUSrc, jump, branch, PCSrc, AddMuxSel, ResultSrc,
        ALUfunc, ImmSrc, clk, rst, stallF, stallD, flushD, flushE, forwardAE,
        forwardBE, zero, I, Rs1DO, Rs2DO, Rs1EO, Rs2EO, RdEO, PCSrcEO,
        ResultSrcEO, RdMO, RegWriteMO, RdWO, RegWriteWO, jumpE, branchE
    );

    HazardUnit HazardUnitUUT (
        Rs1DO, Rs2DO, Rs1EO, Rs2EO, RdEO, RdMO, RdWO, PCSrcEO, RegWriteMO,
        RegWriteWO, ResultSrcEO, clk, forwardAE, forwardBE, stallF, stallD,
        flushD, flushE
    );

    controller controllerUUT (
        zero, I, branch, jump, ALUfunc, ResultSrc, MemWrite, ALUSrc, ImmSrc,
        RegWrite, AddMuxSel
    );

    branchController branchControllerUUT (
        jumpE, branchE, zero, I[14:12], PCSrc
    );
endmodule
