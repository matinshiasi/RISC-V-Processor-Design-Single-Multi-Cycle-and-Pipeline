module controller (input clk, input rst, input zero, input sign, input [31:0] I, output IRWrite, output adrSrc, output [1:0] ALUSrcA, output [1:0] ALUSrcB, output PCWrite, output [2:0] ALUfunc, output [1:0] ResultSrc, output MemWrite, output [2:0] ImmSrc, output RegWrite);
    
    wire [1:0] aluOp; wire branch; wire jump; wire PCUpdate;
    
    ALUcontroller ALUcontrollerUUT (aluOp, I[14:12], I[31:25], ALUfunc);
    mainController mainControllerUUT (clk, rst, I[6:0], IRWrite, adrSrc, ALUSrcA, ALUSrcB, ResultSrc, MemWrite, ImmSrc, RegWrite, aluOp, branch, jump, PCUpdate);
    branchController branchControllerUUT (clk, rst, jump, branch, zero, sign, PCUpdate, I[14:12], PCWrite);

endmodule

module mainController(
    input clk,
    input rst,
    input [6:0] opcode,
    output reg IRWrite,
    output reg adrSrc,
    output reg [1:0] ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [1:0] ResultSrc,
    output reg MemWrite,
    output reg [2:0] ImmSrc,
    output reg RegWrite,
    output reg [1:0] ALUOp,
    output reg branch,
    output reg jump,
    output reg PCUpdate
);

// State Definitions
parameter IF = 0, ID = 1, EXLW = 2, EXSW = 3, EXR = 4, EXB = 5, EXI = 6, EXJALR = 7, EXJ = 8, EXU = 9,
          MEMLW = 10, MEMSW = 11, MEMR = 12, MEMI = 13, MEMJALR = 14, MEMJ = 15, MEMU = 16, WBLW = 17,
          PCUpdateJALR = 18, PCUpdateJ = 19;

parameter RType = 0, IType1 = 1, IType2 = 2, IType3 = 3, SType = 4, JType = 5, BType = 6, UType = 7;

// Registers and Wires
reg [4:0] PS = 5'b0, NS = 5'b0;
wire [2:0] decoded;

// Decoder Instantiation
OPCDecoder OPCDecoderUUT(.opcode(opcode), .decoded(decoded));

// State Register
always @(posedge clk, posedge rst) begin if (rst) PS = IF; else PS = NS; end

// Next State Logic
always @(opcode, PS, decoded) begin
    case (PS)
        IF: NS = ID;
        ID: NS = (decoded == RType)  ? EXR :
                 (decoded == IType1) ? EXLW :
                 (decoded == IType2) ? EXI :
                 (decoded == IType3) ? EXJALR :
                 (decoded == SType)  ? EXSW :
                 (decoded == JType)  ? EXJ :
                 (decoded == BType)  ? EXB :
                 (decoded == UType)  ? EXU : IF;
        EXLW: NS = MEMLW;
        EXSW: NS = MEMSW;
        EXR:  NS = MEMR;
        EXB:  NS = IF;
        EXI:  NS = MEMI;
        EXJALR: NS = MEMJALR;
        EXJ:    NS = MEMJ;
        EXU:    NS = MEMU;
        MEMLW:  NS = WBLW;
        MEMSW:  NS = IF;
        MEMR:   NS = IF;
        MEMI:   NS = IF;
        MEMJALR: NS = PCUpdateJALR;
        MEMJ:    NS = PCUpdateJ;
        MEMU:    NS = IF;
        WBLW:    NS = IF;
        PCUpdateJALR: NS = IF;
        PCUpdateJ: NS = IF;
        default: NS = IF;
    endcase
end

// Output Logic
always @(opcode, PS, decoded, clk) begin
    // Default Values
    IRWrite = 1'b0; adrSrc = 1'b0; ALUSrcA = 2'b00; ALUSrcB = 2'b00; ResultSrc = 2'b00; MemWrite = 1'b0;
    ImmSrc = 3'b000; RegWrite = 1'b0; ALUOp = 2'b00; PCUpdate = 1'b0; jump = 1'b0; branch = 1'b0;
    case (PS)
        IF: begin adrSrc = 1'b0; IRWrite = 1'b1; ALUSrcA = 2'b00; ALUSrcB = 2'b10; ALUOp = 2'b00; PCUpdate = 1'b1; ResultSrc = 2'b10; end
        ID: begin ImmSrc = 3'b011; ALUSrcA = 2'b01; ALUSrcB = 2'b01; ALUOp = 2'b00; end
        EXLW: begin ImmSrc = 3'b000; ALUOp = 2'b00; ALUSrcA = 2'b10; ALUSrcB = 2'b01; end
        EXSW: begin ImmSrc = 3'b001; ALUOp = 2'b00; ALUSrcA = 2'b10; ALUSrcB = 2'b01; end
        EXR: begin ALUOp = 2'b10; ALUSrcA = 2'b10; ALUSrcB = 2'b00; end
        EXB: begin ImmSrc = 3'b011; ALUOp = 2'b01; ALUSrcA = 2'b10; ALUSrcB = 2'b00; branch = 1'b1; end
        EXI: begin ImmSrc = 3'b000; ALUOp = 2'b11; ALUSrcA = 2'b10; ALUSrcB = 2'b01; end
        EXJALR: begin ImmSrc = 3'b000; ALUOp = 2'b00; ALUSrcA = 2'b01; ALUSrcB = 2'b10; end
        EXJ: begin ImmSrc = 3'b010; ALUOp = 2'b00; ALUSrcA = 2'b01; ALUSrcB = 2'b10; end
        EXU: begin ImmSrc = 3'b100; end
        MEMLW: begin ResultSrc = 2'b00; adrSrc = 1'b1; end
        MEMSW: begin ResultSrc = 2'b00; adrSrc = 1'b1; MemWrite = 1'b1; end
        MEMR, MEMI: begin ResultSrc = 2'b00; RegWrite = 1'b1; end
        MEMJALR: begin ResultSrc = 2'b00; RegWrite = 1'b1; ALUSrcA = 1'b10; ALUSrcB = 2'b01; ALUOp = 2'b00; ImmSrc = 3'b000; end
        MEMJ: begin ResultSrc = 2'b00; RegWrite = 1'b1; ALUSrcA = 2'b01; ALUSrcB = 2'b01; ALUOp = 2'b00; ImmSrc = 3'b010; end
        MEMU: begin ResultSrc = 2'b11; RegWrite = 1'b1; end
        WBLW: begin ResultSrc = 2'b01; RegWrite = 1'b1; end
        PCUpdateJALR, PCUpdateJ: begin ResultSrc = 2'b00; jump = 1'b1; end
        default: ;
    endcase
end

endmodule


module OPCDecoder (
    input  [6:0] opcode,
    output reg [2:0] decoded
);
    parameter R_TYPE  = 7'b0110011;
    parameter I_TYPE1 = 7'b0000011;
    parameter I_TYPE2 = 7'b0010011;
    parameter I_TYPE3 = 7'b1100111;
    parameter S_TYPE  = 7'b0100011;
    parameter J_TYPE  = 7'b1101111;
    parameter B_TYPE  = 7'b1100011;
    parameter U_TYPE  = 7'b0110111;

    always @ (opcode) begin
        case (opcode)
            R_TYPE  : decoded = 3'b000; // R-Type: add, sub, and, or, slt
            I_TYPE1 : decoded = 3'b001; // I-Type1: lw
            I_TYPE2 : decoded = 3'b010; // I-Type2: addi, xori, ori, slti
            I_TYPE3 : decoded = 3'b011; // I-Type3: jalr
            S_TYPE  : decoded = 3'b100; // S-Type: sw
            J_TYPE  : decoded = 3'b101; // J-Type: jal
            B_TYPE  : decoded = 3'b110; // B-Type: beq, bne
            U_TYPE  : decoded = 3'b111; // U-Type: lui
            default : decoded = 3'bxxx; // Undefined opcode
        endcase
    end

endmodule


module ALUcontroller(input [1:0] aluOp, input [2:0] f3, input [6:0] f7, output reg [2:0] ALUfunc);
    parameter func1 = 0, func2 = 1, func3 = 2, func4 = 3;

    always @(*) begin
        case (aluOp)
            func1: ALUfunc = 3'b000; // lw, jalr, sw
            func2: ALUfunc = 3'b001; // beq, bne, blt, bge
            func3: casez ({f7, f3})
                      {7'b0000000, 3'b000}: ALUfunc = 3'b000; // add
                      {7'b0100000, 3'b000}: ALUfunc = 3'b001; // sub
                      {7'b0000000, 3'b111}: ALUfunc = 3'b010; // and
                      {7'b0000000, 3'b110}: ALUfunc = 3'b011; // or
                      {7'b0000000, 3'b010}: ALUfunc = 3'b100; // slt
                      {7'b0000000, 3'b011}: ALUfunc = 3'b101; // sltu
                      default: ALUfunc = 3'b000;
                   endcase
            func4: case (f3)
                      3'b000: ALUfunc = 3'b000; // addi
                      3'b100: ALUfunc = 3'b110; // xori
                      3'b110: ALUfunc = 3'b011; // ori
                      3'b010: ALUfunc = 3'b100; // slti
                      3'b011: ALUfunc = 3'b101; // sltui
                      default: ALUfunc = 3'b000;
                   endcase
            default: ALUfunc = 3'b000;
        endcase
    end
endmodule


module branchController(input clk , input rst ,input jump , input branch , input zero , input sign , input PCUpdate , input [2:0] f3 , output reg PCWrite);
        parameter beq = 3'b000  ,  bne = 3'b001 , blt = 3'b100 , bge = 3'b101;
        always @(jump , branch , zero , sign , f3 , PCUpdate , posedge clk , posedge rst) begin
            PCWrite = 1'b0;
            if (PCUpdate) begin
              PCWrite = 1'b1;
            end
            else begin
                if (branch) begin
                  case (f3)
                      beq : PCWrite = zero ? 1'b1 : 1'b0;
                      bne : PCWrite = (~zero) ?  1'b1 : 1'b0;
                      blt : PCWrite = sign ? 1'b1 :1'b0;
                      bge : PCWrite = (~sign) ? 1'b1 :1'b0;
                      default: PCWrite = 1'b0;
                  endcase
                end
                else begin
                  if (jump) begin
                    PCWrite = 1'b1;
                  end
                end 
            end
        end
endmodule