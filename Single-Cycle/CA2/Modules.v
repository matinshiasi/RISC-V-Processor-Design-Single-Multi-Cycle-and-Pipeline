`timescale 1ns/1ns

module ALU (
    input [31:0] A, B,
    input [2:0] ALUControl,
    output reg [31:0] result,
    output zero
);
    parameter ADD = 0, SUB = 1, AND = 2, OR = 3, SLT = 4, SLTU = 5, XOR = 6;

    assign zero = ~(|result);

    always @(A, B, ALUControl) begin
        case (ALUControl)
            ADD: result = A + B;
            SUB: result = A - B;
            AND: result = A & B; 
            OR: result = A | B; 
            SLT, SLTU: result = (A < B) ? 32'b1 : 32'b0;
            XOR: result = A ^ B;
            default: result = 32'b0;
        endcase
    end
endmodule

module Extend (
    input [2:0] immSrc,
    input [31:7] instr,
    output reg [31:0] immOut
);

    parameter  ITYPE = 3'b000,
               STYPE = 3'b001,
               JTYPE = 3'b010,
               BTYPE = 3'b011,
               UTYPE = 3'b100;

    always @(*) begin
        case (immSrc)
            ITYPE: immOut = {{20{instr[31]}}, instr[31:20]};
            STYPE: immOut = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            JTYPE: immOut = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            BTYPE: immOut = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            UTYPE: immOut = {instr[31:12], 12'b0};
            default: immOut = 32'b0;
        endcase
    end

endmodule

module RegisterFile (
    input clk,
    input rst,
    input [4:0] readRegister1,
    input [4:0] readRegister2,
    input [4:0] writeRegister,
    input [31:0] writeData,
    input regWrite,
    output [31:0] readData1,
    output [31:0] readData2
);
    reg [31:0] registers [31:0];

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (regWrite && (writeRegister != 5'b0)) begin
            registers[writeRegister] <= writeData;
        end
    end

    assign readData1 = registers[readRegister1];
    assign readData2 = registers[readRegister2];

endmodule

module PC_Counter (input clk, input rst, input [31:0] PC_in, output reg [31:0] PC_out);

    reg [31:0] current_PC;

    always @(posedge clk or posedge rst) begin
        current_PC <= rst ? 32'b0 : PC_in;
    end

    always @(*) begin
        PC_out = current_PC;
    end

endmodule

module Data_mem (
    input clk,
    input [31:0] address, writeData,
    input memWrite,
    output [31:0] readData
);

    reg [7:0] memory [0:16383];

    assign readData = {memory[address], memory[address+1], memory[address+2], memory[address+3]};

    always @(posedge clk) if (memWrite) begin
        {memory[address], memory[address+1], memory[address+2], memory[address+3]} <= writeData;
    end

endmodule

module Instr_mem #(parameter MEMSIZE = 16384)( input  [31:0] address , output [31:0] readData );

    reg [7:0] memory [0:MEMSIZE-1];
    
    initial begin
        $readmemb("Data.mem" , memory); 
    end

    assign readData = {memory[address] , memory[address+1] , memory[address+2] , memory[address+3]};

endmodule
