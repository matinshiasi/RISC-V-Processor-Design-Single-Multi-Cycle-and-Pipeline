`timescale 1ns/1ns

module controller (
    input        zero,
    input [31:0] I,
    output       branch,
    output       jump,
    output [2:0] ALUfunc,
    output [1:0] ResultSrc,
    output       MemWrite,
    output       ALUSrc,
    output [2:0] ImmSrc,
    output       RegWrite,
    output       AddMuxSel
);
    wire [1:0] aluOp;

    ALUcontroller ALUcontrollerUUT (aluOp, I[14:12], I[31:25], ALUfunc);
    OPCDecoder OPCDecoderUUT (I[6:0], ResultSrc, MemWrite, ALUSrc, ImmSrc, RegWrite, aluOp, branch, jump, AddMuxSel);

endmodule

module ALUcontroller (
    input  [1:0] aluOp,
    input  [2:0] f3,
    input  [6:0] f7,
    output reg [2:0] ALUfunc
);
    parameter func1 = 2'b00; // lw, sw, jalr
    parameter func2 = 2'b01; // beq, bne
    parameter func3 = 2'b10; // R-type
    parameter func4 = 2'b11; // I-type

    always @(*) begin
        case (aluOp)
            func1: ALUfunc = 3'b000; // lw, sw, jalr: ADD
            func2: ALUfunc = 3'b001; // beq, bne: SUB
            func3: begin // R-type instructions
                if (f7 == 7'b0000000 && f3 == 3'b000) ALUfunc = 3'b000; // ADD
                else if (f7 == 7'b0100000 && f3 == 3'b000) ALUfunc = 3'b001; // SUB
                else if (f7 == 7'b0000000 && f3 == 3'b111) ALUfunc = 3'b010; // AND
                else if (f7 == 7'b0000000 && f3 == 3'b110) ALUfunc = 3'b011; // OR
                else if (f7 == 7'b0000000 && f3 == 3'b010) ALUfunc = 3'b100; // SLT
                else ALUfunc = 3'b000; // Default
            end
            func4: begin // I-type instructions
                if (f3 == 3'b000) ALUfunc = 3'b000; // ADDI
                else if (f3 == 3'b100) ALUfunc = 3'b110; // XORI
                else if (f3 == 3'b110) ALUfunc = 3'b011; // ORI
                else if (f3 == 3'b010) ALUfunc = 3'b100; // SLTI
                else ALUfunc = 3'b000; // Default
            end
            default: ALUfunc = 3'b000; // Default operation
        endcase
    end
endmodule

module OPCDecoder (
    input  [6:0] opcode,
    output reg [1:0] ResultSrc,
    output reg       MemWrite,
    output reg       ALUSrc,
    output reg [2:0] ImmSrc,
    output reg       RegWrite,
    output reg [1:0] ALUOp,
    output reg       branch,
    output reg       jump,
    output reg       AddMuxSel
);
    parameter RType = 7'b0110011, IType1 = 7'b0000011, IType2 = 7'b0010011, IType3 = 7'b1100111, 
              SType = 7'b0100011, JType = 7'b1101111, BType = 7'b1100011, UType = 7'b0110111;

    always @(opcode) begin
        jump = 1'b0; branch = 1'b0; AddMuxSel = 1'b0;
        case (opcode)
            RType  : begin RegWrite = 1; ALUSrc = 0; MemWrite = 0; ResultSrc = 2'b00; ALUOp = 2'b10; branch = 0; jump = 0; end
            IType1 : begin RegWrite = 1; ImmSrc = 3'b000; ALUSrc = 1; MemWrite = 0; ResultSrc = 2'b01; ALUOp = 2'b00; branch = 0; jump = 0; end
            IType2 : begin RegWrite = 1; ImmSrc = 3'b000; ALUSrc = 1; MemWrite = 0; ResultSrc = 2'b00; ALUOp = 2'b11; branch = 0; jump = 0; end
            IType3 : begin RegWrite = 1; ImmSrc = 3'b000; ALUSrc = 1; MemWrite = 0; ResultSrc = 2'b10; ALUOp = 2'b00; AddMuxSel = 1'b1; branch = 0; jump = 1; end
            SType  : begin RegWrite = 0; ImmSrc = 3'b001; ALUSrc = 1; MemWrite = 1; ALUOp = 2'b00; ResultSrc = 2'b00; branch = 0; jump = 0; end
            JType  : begin RegWrite = 1; ImmSrc = 3'b010; MemWrite = 0; ResultSrc = 2'b10; ALUOp = 2'b00; AddMuxSel = 1'b0; branch = 0; jump = 1; end
            BType  : begin RegWrite = 0; ImmSrc = 3'b011; ALUSrc = 0; MemWrite = 0; ALUOp = 2'b01; ResultSrc = 2'b00; AddMuxSel = 1'b0; branch = 1; jump = 0; end
            UType  : begin RegWrite = 1; ImmSrc = 3'b100; MemWrite = 0; ResultSrc = 2'b11; branch = 0; jump = 0; end
            default: begin RegWrite = 0; ALUSrc = 0; MemWrite = 0; ResultSrc = 2'b00; ALUOp = 2'b00; ImmSrc = 3'b000; end
        endcase
    end
endmodule

module branchController (
    input        jump,
    input        branch,
    input        zero,
    input  [2:0] f3,
    output reg   PCSrc
);
    parameter beq = 3'b000, bne = 3'b001, blt = 3'b100, bge = 3'b101;

    always @(*) begin
        PCSrc = 1'b0;
        if (branch) begin
            case (f3)
                beq: PCSrc = zero ? 1'b1 : 1'b0;
                bne: PCSrc = ~zero ? 1'b1 : 1'b0;
                default: PCSrc = 1'b0;
            endcase
        end else if (jump) begin
            PCSrc = 1'b1;
        end
    end

endmodule
