module TopModule(input clk, input rst);
    wire zero, MemWrite, RegWrite, ALUSrc;
    wire [31:0] I;
    wire [1:0] PCSrc, ResultSrc;
    wire [2:0] ALUfunc, ImmSrc;

    datapath DP (RegWrite, MemWrite, ALUSrc, PCSrc, ResultSrc, ALUfunc, ImmSrc, clk, rst, zero, I);
    controller CTRL (zero, I, PCSrc, ALUfunc, ResultSrc, MemWrite, ALUSrc, ImmSrc, RegWrite);
endmodule

