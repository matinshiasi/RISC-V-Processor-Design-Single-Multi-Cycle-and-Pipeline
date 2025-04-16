`timescale 1ns/1ns

module ALU (input [31:0] A , input [31:0] B , input [2:0]  ALUControl , output reg [31:0] result , output zero , output sign);
    parameter ADD = 0 , SUB = 1 ,  AND = 2  , OR = 3 , SLT = 4 , SLTU = 5 , XOR = 6;
    assign zero = ~(|result);
    assign sign = result[31];
    always @(A , B , ALUControl) begin
        case (ALUControl)
            ADD : result = A + B ;
            SUB : result = A - B ;
            AND : result = A &  B ; 
            OR : result = A | B ; 
            SLT : result = (A < B) ? 32'b1 : 32'b0;
            SLTU : result = ({1'b0 , A} < {1'b0 , B}) ? 32'b1 : 32'b0;
            XOR : result = A ^ B;
            default:; 
        endcase
    end
endmodule

module mux2to1 (input [31:0] A, B, input select, output [31:0] w);
    assign w = select ? B : A;
endmodule


module mux4to1 (input [31:0] A, B , C , D, input [1:0] select, output [31:0] w);
    assign w =  (select == 2'b00) ? A : 
                (select == 2'b01) ? B :
                (select == 2'b10) ? C : 
                (select == 2'b11) ? D : 4'bz ;
endmodule


module DM (
    input clk, rst,
    input [31:0] address, writeData,
    input memWrite,
    output [31:0] readData
);
    reg [7:0] memory [0:16383];

    assign readData = {memory[address], memory[address+1], memory[address+2], memory[address+3]};

    integer i;
    initial begin
        if (rst) begin
            for (i = 0; i < 16384; i = i + 1) memory[i] <= 8'b0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            $readmemb("findMin.mem", memory);
        end else if (memWrite) begin
            {memory[address], memory[address+1], memory[address+2], memory[address+3]} <= writeData;
        end
    end
endmodule

module PC_Counter (
    input        clk,
    input        rst,
    input        enable,
    input [31:0] PC_in,
    output reg [31:0] PC_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) 
            PC_out <= 32'b0;
        else if (enable) 
            PC_out <= PC_in;
    end
endmodule

module PCOLDIR (
    input        clk, 
    input        rst, 
    input        enable, 
    input [31:0] PCIn, 
    input [31:0] IIn, 
    output reg [31:0] IOut, 
    output reg [31:0] PCOut
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PCOut <= 32'b0;
            IOut  <= 32'b0;
        end else if (enable) begin
            PCOut <= PCIn;
            IOut  <= IIn;
        end
    end
endmodule

module immediateExtend #(
    parameter SIZE    = 32,
    parameter START   = 7,
    parameter FINISH  = 32,
    parameter SRCSIZE = 3
)(
    input  [SRCSIZE-1:0]         Immsrc,
    input  [FINISH-1:START]      instruction,
    output reg [SIZE-1:0]        immOut
);

    parameter ITYPE = 3'b000, STYPE = 3'b001, 
              JTYPE = 3'b010, BTYPE = 3'b011, 
              UTYPE = 3'b100;


    always @ (Immsrc, instruction) begin
        immOut = {SIZE{1'b0}};
        case (Immsrc)
            ITYPE: immOut = {{20{instruction[SIZE-1]}}, instruction[SIZE-1:20]}; // Immediate type
            STYPE: immOut = {{20{instruction[SIZE-1]}}, instruction[SIZE-1:25], instruction[11:7]}; // Store type
            JTYPE: immOut = {{11{instruction[SIZE-1]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}; // Jump type
            BTYPE: immOut = {{19{instruction[SIZE-1]}}, instruction[SIZE-1], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // Branch type
            UTYPE: immOut = {instruction[SIZE-1:12], 12'b0}; // Upper immediate type
        endcase
    end
endmodule

module Register (
    input        clk,
    input        rst,
    input        enable,
    input  [31:0] dataIn,
    output reg [31:0] dataOut
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            dataOut <= 32'b0;
        else if (enable)
            dataOut <= dataIn;
    end
endmodule

module RegisterFile (
    input             clk,
    input             rst,
    input  [4:0]      readRegister1,
    input  [4:0]      readRegister2,
    input  [4:0]      writeRegister,
    input  [31:0]     writeData,
    input             regWrite,
    output [31:0]     readData1,
    output [31:0]     readData2
);
    reg [31:0] registers [31:0];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) registers[i] = 32'b0;
    end

    assign readData1 = registers[readRegister1];
    assign readData2 = registers[readRegister2];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 1; i < 32; i = i + 1) registers[i] <= 32'b0;
        end else if (regWrite && writeRegister != 0) begin
            registers[writeRegister] <= writeData;
        end
    end
endmodule
