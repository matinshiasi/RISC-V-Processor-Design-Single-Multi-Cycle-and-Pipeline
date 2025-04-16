module IFIDRegs(input clk , input rst , input Enable , input [31:0] InF , input [31:0] PCF , input[31:0] PCPlus4F
                , output [31:0] InD , output [31:0] PCD , output [31:0] PCPlus4D);
    reg [31:0] In;
    reg [31:0] PC;
    reg [31:0] PCPlus4;
    always @(posedge  clk ) begin
        if (rst) begin
            In = 32'b0;
        end
        else begin
            if (Enable) begin
               In = InF;
               PC = PCF;
               PCPlus4 = PCPlus4F; 
            end
        end
    end
    assign InD = In;
    assign PCD = PC;
    assign PCPlus4D = PCPlus4;
endmodule

module IDEXRegs(input clk , input rst , input [31:0] PCD , input[31:0] PCPlus4D , input [31:0] RD1D ,
                input [31:0] RD2D , input [4:0] Rs1D , input [4:0] Rs2D , input [4:0] RdD , input [31:0] ExtImmD ,
                input RegWriteD , input [1:0] ResultSrcD , input MemWriteD , input jumpD , input branchD , input [2:0] ALUfuncD ,input  ALUSrcD 
               ,output [31:0] PCE , output [31:0] PCPlus4E , output [31:0] RD1E ,
                output [31:0] RD2E , output [4:0] Rs1E , output [4:0] Rs2E , output [4:0] RdE , output [31:0] ExtImmE ,
                output RegWriteE , output [1:0] ResultSrcE , output MemWriteE , output jumpE , output branchE , output [2:0] ALUfuncE ,output  ALUSrcE);
    reg [31:0] PC;
    reg [31:0] PCPlus4;
    reg [31:0] RD1;
    reg [31:0] RD2;
    reg [4:0] Rs1;
    reg [4:0] Rs2;
    reg [4:0] Rd;
    reg [31:0] ExtImm ;
    reg RegWrite;
    reg [1:0] ResultSrc; 
    reg MemWrite;
    reg jump;
    reg branch; 
    reg [2:0] ALUfunc;
    reg ALUSrc;
    always @(posedge  clk ) begin
        if (rst) begin
            RD1 = 32'b0;
            RD2 = 32'b0;
            Rs1 = 5'b0;
            Rs2 = 5'b0;
            Rd = 5'b0;
            ExtImm = 32'b0;
            RegWrite = 1'b0;
            ResultSrc = 2'b0;
            MemWrite = 1'b0;
            jump = 1'b0;
            branch = 1'b0;
            ALUfunc = 3'b0;
            ALUSrc = 1'b0;
        end
        else begin
            PC = PCD;
            PCPlus4 = PCPlus4D;
            RD1 = RD1D;
            RD2 = RD2D;
            Rs1 = Rs1D;
            Rs2 = Rs2D;
            Rd = RdD;
            ExtImm = ExtImmD;
            RegWrite = RegWriteD;
            ResultSrc = ResultSrcD;
            MemWrite = MemWriteD;
            jump = jumpD;
            branch = branchD;
            ALUfunc = ALUfuncD;
            ALUSrc = ALUSrcD;
        end
    end
    assign PCE = PC;
    assign PCPlus4E = PCPlus4;
    assign RD1E = RD1;
    assign RD2E = RD2;
    assign Rs1E = Rs1;
    assign Rs2E = Rs2;
    assign RdE = Rd;
    assign ExtImmE = ExtImm;
    assign RegWriteE = RegWrite;
    assign ResultSrcE = ResultSrc;
    assign MemWriteE = MemWrite;
    assign jumpE = jump;
    assign branchE = branch;
    assign ALUfuncE = ALUfunc;
    assign ALUSrcE = ALUSrc;
endmodule

module EXMERegs(input clk , input rst  , input[31:0] PCPlus4E , input [4:0] RdE , input [31:0] ALUResultE , input [31:0] WriteDataE ,
                input RegWriteE , input [1:0] ResultSrcE , input MemWriteE , input [31:0] ExtImmE ,
                output [31:0] PCPlus4M , output [4:0] RdM , output [31:0] ALUResultM , output [31:0] WriteDataM , output [31:0] ExtImmM ,
                output RegWriteM , output [1:0] ResultSrcM , output MemWriteM );
    reg [31:0] PCPlus4;
    reg [4:0] Rd;
    reg [31:0] ALUResult;
    reg [31:0] WriteData;
    reg RegWrite;
    reg [1:0] ResultSrc; 
    reg MemWrite;
    reg [31:0] ExtImm;
    always @(posedge  clk , posedge rst) begin
        if (rst) begin
            PCPlus4 = 32'b0;
            Rd = 5'b0;
            ALUResult = 32'b0;
            WriteData = 32'b0;
            RegWrite = 1'b0;
            ResultSrc = 2'b0;
            MemWrite = 1'b0;
            ExtImm = 32'b0;
        end
        else begin
            PCPlus4 = PCPlus4E;
            Rd = RdE;
            ALUResult = ALUResultE;
            WriteData = WriteDataE;
            RegWrite = RegWriteE;
            ResultSrc = ResultSrcE;
            MemWrite = MemWriteE;
            ExtImm = ExtImmE;
        end
    end
    assign PCPlus4M = PCPlus4;
    assign RdM = Rd;
    assign ALUResultM = ALUResult;
    assign WriteDataM = WriteData;
    assign RegWriteM = RegWrite;
    assign ResultSrcM = ResultSrc;
    assign MemWriteM = MemWrite;
    assign ExtImmM = ExtImm;
endmodule

module MEWBRegs(input clk , input rst  , input[31:0] PCPlus4M , input [4:0] RdM , input [31:0] ALUResultM , input [31:0] ReadDataM ,
                input RegWriteM , input [1:0] ResultSrcM , input [31:0] ExtImmM ,
                output [31:0] PCPlus4W , output [4:0] RdW , output [31:0] ALUResultW , output [31:0] ReadDataW , output [31:0] ExtImmW ,
                output RegWriteW , output [1:0] ResultSrcW  );
    reg [31:0] PCPlus4;
    reg [4:0] Rd;
    reg [31:0] ALUResult;
    reg [31:0] ReadData;
    reg RegWrite;
    reg [1:0] ResultSrc; 
    reg [31:0] ExtImm;
    always @(posedge  clk , posedge rst) begin
        if (rst) begin
            PCPlus4 = 32'b0;
            Rd = 5'b0;
            ALUResult = 32'b0;
            ReadData = 32'b0;
            RegWrite = 1'b0;
            ResultSrc = 2'b0;
            ExtImm = 32'b0;
        end
        else begin
            PCPlus4 = PCPlus4M;
            Rd = RdM;
            ALUResult = ALUResultM;
            ReadData = ReadDataM;
            RegWrite = RegWriteM;
            ResultSrc = ResultSrcM;
            ExtImm = ExtImmM;
        end
    end
    assign PCPlus4W = PCPlus4;
    assign RdW = Rd;
    assign ALUResultW = ALUResult;
    assign ReadDataW = ReadData;
    assign RegWriteW = RegWrite;
    assign ResultSrcW = ResultSrc;
    assign ExtImmW = ExtImm;
endmodule

