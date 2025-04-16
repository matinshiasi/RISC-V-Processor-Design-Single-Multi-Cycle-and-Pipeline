
module proccesor(input clk , rst);
        parameter SIZE = 32;
        wire sign , zero;
        wire [SIZE-1 : 0] I;
        wire IRWrite;
        wire adrSrc;
        wire PCWrite;
        wire [2:0] ALUfunc;
        wire [1:0] ResultSrc;
        wire [2:0] ImmSrc;
        wire MemWrite , RegWrite ;
        wire [1:0] ALUSrcA , ALUSrcB;
        DataPath DPUUT(
                .IRWrite(IRWrite) ,  
                .adrSrc(adrSrc) , 
                .ALUSrcA(ALUSrcA) , 
                .ALUSrcB(ALUSrcB) ,  
                .PCWrite(PCWrite) , 
                .ALUfunc(ALUfunc) , 
                .ResultSrc(ResultSrc) , 
                .MemWrite(MemWrite)  , 
                .ImmSrc(ImmSrc) , 
                .RegWrite(RegWrite),
                .clk(clk),
                .rst(rst),
                .sign(sign),
                .zero(zero), 
                .I(I));
                 
        controller controllerUUT(.clk(clk) ,
                   .rst(rst) ,
                   .zero(zero) , 
                   .sign(sign) , 
                   .I(I) , 
                   .IRWrite(IRWrite) ,  
                   .adrSrc(adrSrc) , 
                   .ALUSrcA(ALUSrcA) , 
                   .ALUSrcB(ALUSrcB) ,  
                   .PCWrite(PCWrite) , 
                   .ALUfunc(ALUfunc) , 
                   .ResultSrc(ResultSrc) , 
                   .MemWrite(MemWrite)  , 
                   .ImmSrc(ImmSrc) , 
                   .RegWrite(RegWrite)
                   );
endmodule