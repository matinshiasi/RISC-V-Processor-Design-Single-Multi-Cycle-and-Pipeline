`timescale 1ns/1ns
module adder(input [31:0] A, input [31:0] B, output [31:0] w);
    assign w = A + B;
endmodule

module ALU(input [31:0] A, input [31:0] B, input [2:0] ALUControl, output reg [31:0] result, output zero);
    assign zero = ~(|result);
    always @(*) begin
        case (ALUControl)
            3'b000: result = A + B;
            3'b001: result = A - B;
            3'b010: result = A & B;
            3'b011: result = A | B;
            3'b100: result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
            default: result = 32'b0;
        endcase
    end
endmodule

module DM(input clk, input rst, input [31:0] address, input [31:0] writeData, input memWrite, output [31:0] readData);
    reg [7:0] memory [0:16383];
    assign readData = {memory[address], memory[address+1], memory[address+2], memory[address+3]};
    always @(posedge clk) begin
        if (memWrite) begin
            memory[address] <= writeData[31:24];
            memory[address+1] <= writeData[23:16];
            memory[address+2] <= writeData[15:8];
            memory[address+3] <= writeData[7:0];
        end
    end
endmodule

module EXMERegs(input clk, input rst, input [31:0] PCPlus4E, input [4:0] RdE, input [31:0] ALUResultE, input [31:0] WriteDataE, input RegWriteE, input [1:0] ResultSrcE, input MemWriteE, input [31:0] ExtImmE, output reg [31:0] PCPlus4M, output reg [4:0] RdM, output reg [31:0] ALUResultM, output reg [31:0] WriteDataM, output reg [31:0] ExtImmM, output reg RegWriteM, output reg [1:0] ResultSrcM, output reg MemWriteM);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PCPlus4M <= 32'b0;
            RdM <= 5'b0;
            ALUResultM <= 32'b0;
            WriteDataM <= 32'b0;
            ExtImmM <= 32'b0;
            RegWriteM <= 1'b0;
            ResultSrcM <= 2'b0;
            MemWriteM <= 1'b0;
        end else begin
            PCPlus4M <= PCPlus4E;
            RdM <= RdE;
            ALUResultM <= ALUResultE;
            WriteDataM <= WriteDataE;
            ExtImmM <= ExtImmE;
            RegWriteM <= RegWriteE;
            ResultSrcM <= ResultSrcE;
            MemWriteM <= MemWriteE;
        end
    end
endmodule

module immediateExtend(input [2:0] Immsrc, input [31:7] instruction, output reg [31:0] immOut);
    always @(*) begin
        case (Immsrc)
            3'b000: immOut = {{20{instruction[31]}}, instruction[31:20]};
            3'b001: immOut = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            3'b010: immOut = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            3'b011: immOut = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            3'b100: immOut = {instruction[31:12], 12'b0};
            default: immOut = 32'b0;
        endcase
    end
endmodule

module mux2to1(input [31:0] A, input [31:0] B, input select, output [31:0] w);
    assign w = select ? B : A;
endmodule

module mux4to1(input [31:0] A, input [31:0] B, input [31:0] C, input [31:0] D, input [1:0] select, output [31:0] w);
    assign w = (select == 2'b00) ? A : (select == 2'b01) ? B : (select == 2'b10) ? C : (select == 2'b11) ? D : 32'bz;
endmodule

module PC_Counter(input clk, input rst, input Enable, input [31:0] PC_in, output reg [31:0] PC_out);
    always @(posedge clk or posedge rst) begin
        if (rst) PC_out <= 32'b0;
        else if (Enable) PC_out <= PC_in;
    end
endmodule

module RegisterFile(input clk, input rst, input [4:0] readRegister1, input [4:0] readRegister2, input [4:0] writeRegister, input [31:0] writeData, input regWrite, output [31:0] readData1, output [31:0] readData2);
    reg [31:0] registers [0:31];
    integer i;
    assign readData1 = registers[readRegister1];
    assign readData2 = registers[readRegister2];
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) registers[i] <= 32'b0;
        end else if (regWrite && writeRegister != 0) begin
            registers[writeRegister] <= writeData;
        end
    end
endmodule
