module DP #(parameter SIZE = 32)(input registerfile_we,
          input data_memory_we,
          input alu_source,
          input jump,
          input branch,
          input PCSrcE,
          input add_mux_sel,
          input [1:0] ResultSrc,
          input [2:0] alu_control,
          input [2:0] imm_src,
          input clk , 
          input rst,
          input stallF , 
          input stallD ,
          input flushD ,
          input flushE ,
          input [1:0] forwardAE , 
          input [1:0] forwardBE ,
          output zero,
          output [SIZE-1:0] I,
          output [4:0] Rs1DO , 
          output [4:0] Rs2DO ,
          output [4:0] Rs1EO , 
          output [4:0] Rs2EO ,
          output [4:0] RdEO , 
          output PCSrcEO ,
          output [1:0] ResultSrcEO , 
          output [4:0] RdMO , 
          output RegWriteMO , 
          output [4:0] RdWO ,
          output RegWriteWO,
          output jumpE , 
          output branchE );
        

        //IF wiring 
        wire [SIZE-1:0] PCF , PCFBar , InF , PCPlus4F;
        //ID wiring
        wire [SIZE-1:0] InD , PCD , PCPlus4D , ExtImmD , RD1D , RD2D;
        wire [4:0] Rs1D , Rs2D , RdD;
        //EX wiring
        wire [SIZE-1 : 0] PCTarget , PCE , PCPlus4E , RD1E , RD2E , ExtImmE , ALUResultE , SrcAE , SrcBE , WriteDataE , addSrc;
        wire [4:0] Rs1E , Rs2E , RdE;
        wire RegWriteE , MemWriteE , ALUSrcE  ;
        wire [1:0] ResultSrcE ;
        wire [2:0] ALUfuncE ;
        // Mem wiring 
        wire [SIZE-1:0] PCPlus4M  , ALUResultM , WriteDataM , ExtImmM , ReadDataM;
        wire RegWriteM ,  MemWriteM ;
        wire [1:0] ResultSrcM;
        wire [4:0] RdM;
        // WB wiring
        wire RegWriteW;
        wire [SIZE-1:0] ResultW , PCPlus4W , ALUResultW , ReadDataW , ExtImmW ;
        wire [4:0] RdW;
        wire [1:0] ResultSrcW;


        // IF
        INMemory INMemoryUUT( .address(PCF) ,  .readData(InF) );
        PC_Counter PCCounterUUT( .clk(clk)  , .rst(rst) , .Enable(stallF) , .PC_in(PCFBar) ,  .PC_out(PCF) );
        adder AdderUUT(.A(PCF), .B({29'b0 , 3'b100}), .w(PCPlus4F));
        mux2to1 PCMux(.A(PCPlus4F) , .B(PCTarget) , .select(PCSrcE) , .w(PCFBar));

        IFIDRegs IFIDRegsUUT( .clk(clk) , .rst({flushD | rst}) , .Enable(stallD) ,  .InF(InF) , .PCF(PCF) , .PCPlus4F(PCPlus4F)
                , .InD(InD) , .PCD(PCD) , .PCPlus4D(PCPlus4D));
        

        // ID
        immediateExtend immediateExtendUUT(.Immsrc(imm_src), .instruction(InD[SIZE-1:7]), .immOut(ExtImmD));
        RegisterFile RegisterFileUUT( .clk(clk) , .rst(rst) , .readRegister1(Rs1D) , .readRegister2(Rs2D) , .writeRegister(RdW)
        , .writeData(ResultW) , .regWrite(RegWriteW) , .readData1(RD1D) , .readData2(RD2D) );
        assign Rs1D = InD[19:15];
        assign Rs2D = InD[24:20];
        assign RdD = InD[11:7];
        assign I = InD;
        assign Rs1DO = Rs1D;
        assign Rs2DO = Rs2D;

        IDEXRegs IDEXRegsUUT( .clk(clk) , .rst({flushE | rst}) , .PCD(PCD) , .PCPlus4D(PCPlus4D) , .RD1D(RD1D) ,
                .RD2D(RD2D) ,  .Rs1D(Rs1D) , .Rs2D(Rs2D) , .RdD(RdD) , .ExtImmD(ExtImmD) ,
                .RegWriteD(registerfile_we) , .ResultSrcD(ResultSrc) , .MemWriteD(data_memory_we) , .jumpD(jump) , .branchD(branch) , 
                .ALUfuncD(alu_control) , .ALUSrcD(alu_source) 
                , .PCE(PCE) , .PCPlus4E(PCPlus4E) , .RD1E(RD1E) , .RD2E(RD2E) , .Rs1E(Rs1E) , .Rs2E(Rs2E) ,
                .RdE(RdE) , .ExtImmE(ExtImmE) , .RegWriteE(RegWriteE) , .ResultSrcE(ResultSrcE) , .MemWriteE(MemWriteE) , .jumpE(jumpE) , .branchE(branchE),
                .ALUfuncE(ALUfuncE) , .ALUSrcE(ALUSrcE));

        // EX
        ALU ALUUUT(.A(SrcAE) , .B(SrcBE) , .ALUControl(ALUfuncE) , .result(ALUResultE) , .zero(zero) );
        mux4to1 mux4to1A(.A(RD1E), .B(ResultW) , .C(ALUResultM) , .D({32'b0}), .select(forwardAE), .w(SrcAE));
        mux4to1 mux4to1B(.A(RD2E), .B(ResultW) , .C(ALUResultM) , .D({32'b0}), .select(forwardBE), .w(WriteDataE));
        mux2to1 mux2to1B(.A(WriteDataE), .B(ExtImmE), .select(ALUSrcE), .w(SrcBE));
        mux2to1 mux2to1A(.A(PCE), .B(RD1E), .select(add_mux_sel), .w(addSrc));
        adder AdderUUT2(.A(addSrc), .B(ExtImmE), .w(PCTarget));
        assign Rs1EO = Rs1E;
        assign Rs2EO = Rs2E;
        assign RdEO = RdE;
        assign PCSrcEO = PCSrcE;
        assign ResultSrcEO = ResultSrcE;

        EXMERegs EXMERegsUUT( .clk(clk) , .rst(rst)  , .PCPlus4E(PCPlus4E) , .RdE(RdE) , .ALUResultE(ALUResultE) , 
                .WriteDataE(WriteDataE) , .RegWriteE(RegWriteE) , .ResultSrcE(ResultSrcE) , .MemWriteE(MemWriteE) , .ExtImmE(ExtImmE) ,
                .PCPlus4M(PCPlus4M) , .RdM(RdM) , .ALUResultM(ALUResultM) , .WriteDataM(WriteDataM) , .ExtImmM(ExtImmM) ,
                .RegWriteM(RegWriteM) , .ResultSrcM(ResultSrcM) , .MemWriteM(MemWriteM) );




        // ME
        DM DMUUT( .clk(clk) , .rst(rst) , .address(ALUResultM) , .writeData(WriteDataM) , .memWrite(MemWriteM) , .readData(ReadDataM) );
        assign RdMO = RdM;
        assign RegWriteMO = RegWriteM;


        MEWBRegs MEWBRegsUUT( .clk(clk) , .rst(rst)  , .PCPlus4M(PCPlus4M) , .RdM(RdM) , .ALUResultM(ALUResultM) , 
                .ReadDataM(ReadDataM) , .RegWriteM(RegWriteM) , .ResultSrcM(ResultSrcM) , .ExtImmM(ExtImmM) ,
                .PCPlus4W(PCPlus4W) , .RdW(RdW) , .ALUResultW(ALUResultW) , .ReadDataW(ReadDataW) , .ExtImmW(ExtImmW) ,
                .RegWriteW(RegWriteW) , .ResultSrcW(ResultSrcW)  );

        // WB
        mux4to1 mux4to1Res(.A(ALUResultW), .B(ReadDataW) , .C(PCPlus4W) , .D(ExtImmW), .select(ResultSrcW), .w(ResultW));
        assign RdWO = RdW;
        assign RegWriteWO = RegWriteW;

endmodule