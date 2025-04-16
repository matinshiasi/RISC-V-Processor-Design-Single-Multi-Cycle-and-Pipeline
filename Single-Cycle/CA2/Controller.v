
module controller(input zero, input [31:0] I, output [1:0] PCSrc, output [2:0] ALUfunc, 
                  output [1:0] ResultSrc, output MemWrite, output ALUSrc, output [2:0] ImmSrc, 
                  output RegWrite);

    wire [1:0] aluOp, jump;
    wire branch;

    ALU_ctrl ALU_ctrl (aluOp, I[14:12], I[31:25], ALUfunc);
    OPC_dec OPC_dec (I[6:0], ResultSrc, MemWrite, ALUSrc, ImmSrc, RegWrite, aluOp, branch, jump);
    Branch_ctrl Branch_ctrl (jump, branch, zero, I[14:12], PCSrc);

endmodule


module ALU_ctrl (input [1:0] aluOp, input [2:0] f3, input [6:0] f7, output reg [2:0] ALUfunc);

    localparam FUNC1 = 2'b00, FUNC2 = 2'b01, FUNC3 = 2'b10, FUNC4 = 2'b11;

    always @(*) begin
        if (aluOp == FUNC1) begin
            ALUfunc = 3'b000;
        end else if (aluOp == FUNC2) begin
            ALUfunc = 3'b001;
        end else if (aluOp == FUNC3) begin
            case ({f7, f3})
                10'b0000000000: ALUfunc = 3'b000;
                10'b0100000000: ALUfunc = 3'b001;
                10'b0000000111: ALUfunc = 3'b010;
                10'b0000000110: ALUfunc = 3'b011;
                10'b0000000010: ALUfunc = 3'b100;
                default: ALUfunc = 3'b000;
            endcase
        end else if (aluOp == FUNC4) begin
            case (f3)
                3'b000: ALUfunc = 3'b000;
                3'b100: ALUfunc = 3'b110;
                3'b110: ALUfunc = 3'b011;
                3'b010: ALUfunc = 3'b100;
                default: ALUfunc = 3'b000;
            endcase
        end else begin
            ALUfunc = 3'b000;
        end
    end

endmodule


module OPC_dec(
    input [6:0] opcode,
    output reg [1:0] ResultSrc, 
    output reg MemWrite, 
    output reg ALUSrc,
    output reg [2:0] ImmSrc,
    output reg RegWrite, 
    output reg [1:0] ALUOp, 
    output reg branch, 
    output reg [1:0] jump
);

    parameter 
        RType  = 7'b0110011, IType1 = 7'b0000011, IType2 = 7'b0010011,
        IType3 = 7'b1100111, SType  = 7'b0100011, JType  = 7'b1101111, 
        BType  = 7'b1100011, UType  = 7'b0110111;

    always @(opcode) begin
        case (opcode)
            RType: begin 
                {RegWrite, ALUSrc, MemWrite, ResultSrc, ALUOp, branch, jump} = {1'b1, 1'b0, 1'b0, 2'b00, 2'b10, 1'b0, 2'b00};
            end
            IType1: begin 
                {RegWrite, ALUSrc, MemWrite, ResultSrc, ALUOp, branch, jump, ImmSrc} = {1'b1, 1'b1, 1'b0, 2'b01, 2'b00, 1'b0, 2'b00, 3'b000};
            end
            IType2: begin 
                {RegWrite, ALUSrc, MemWrite, ResultSrc, ALUOp, branch, jump, ImmSrc} = {1'b1, 1'b1, 1'b0, 2'b00, 2'b11, 1'b0, 2'b00, 3'b000};
            end
            IType3: begin 
                {RegWrite, ALUSrc, MemWrite, ResultSrc, ALUOp, branch, jump, ImmSrc} = {1'b1, 1'b1, 1'b0, 2'b11, 2'b00, 1'b0, 2'b01, 3'b000};
            end
            SType: begin 
                {RegWrite, ALUSrc, MemWrite, ResultSrc, ALUOp, branch, jump, ImmSrc} = {1'b0, 1'b1, 1'b1, 2'b00, 2'b00, 1'b0, 2'b00, 3'b001};
            end
            JType: begin 
                {RegWrite, ALUSrc, MemWrite, ResultSrc, ALUOp, branch, jump, ImmSrc} = {1'b1, 1'b0, 1'b0, 2'b11, 2'b00, 1'b0, 2'b10, 3'b010};
            end
            BType: begin 
                {RegWrite, ALUSrc, MemWrite, ResultSrc, ALUOp, branch, jump, ImmSrc} = {1'b0, 1'b0, 1'b0, 2'b00, 2'b01, 1'b1, 2'b00, 3'b011};
            end
            UType: begin 
                {RegWrite, ALUSrc, MemWrite, ResultSrc, ALUOp, branch, jump, ImmSrc} = {1'b1, 1'b0, 1'b0, 2'b10, 2'b00, 1'b0, 2'b00, 3'b100};
            end
            default: begin
                {RegWrite, ALUSrc, MemWrite, ResultSrc, ALUOp, branch, jump, ImmSrc} = {1'b0, 1'b0, 1'b0, 2'b00, 2'b00, 1'b0, 2'b00, 3'b000};
            end
        endcase
    end
endmodule


module Branch_ctrl(input [1:0] jump, input branch, input zero, input [2:0] f3, output reg [1:0] PCSrc);
    parameter beq = 3'b000, bne = 3'b001;

    always @(jump, branch, zero, f3) begin
        if (branch) begin
            case (f3)
                beq: PCSrc = zero ? 2'b01 : 2'b00;
                bne: PCSrc = ~zero ? 2'b01 : 2'b00;
                default: PCSrc = 2'b00;
            endcase
        end else
            PCSrc = (jump == 2'b01) ? 2'b10 :
                    (jump == 2'b10) ? 2'b01 : 2'b00;
    end
endmodule
