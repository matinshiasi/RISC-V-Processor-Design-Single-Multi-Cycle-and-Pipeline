module DataPath (input clk, input rst, input IRWrite, input adrSrc, input [1:0] ALUSrcA, input [1:0] ALUSrcB, input PCWrite, input [2:0] ALUfunc, input [1:0] ResultSrc, input MemWrite, input [2:0] ImmSrc, input RegWrite, output sign, output zero, output [31:0] I);
    
    reg ONE = 1'b1; reg ZERO = 1'b0; reg [31:0] ZDATA = 32'bz;
    wire [31:0] pc_o, adr_mult_o, mem_o, ir_o, oldpc_o, rd1_o, rd2_o, A_o, B_o, Ainput_o, Binput_o, ALU_o, ALUout_o, imm_ext_o, mdr_o, immout_o, result_o;

    PC_Counter PC_CounterUUT (clk, rst, PCWrite, result_o, pc_o);
    mux2to1 addressInput (pc_o, result_o, adrSrc, adr_mult_o);
    mux4to1 AInput (pc_o, oldpc_o, A_o, ZDATA, ALUSrcA, Ainput_o);
    mux4to1 BInput (B_o, imm_ext_o, {29'b0, 3'b100}, ZDATA, ALUSrcB, Binput_o);
    mux4to1 ResultSelector (ALUout_o, mdr_o, ALU_o, immout_o, ResultSrc, result_o);
    Register A (clk, rst, ONE, rd1_o, A_o); Register B (clk, rst, ONE, rd2_o, B_o);
    Register ALUOUT (clk, rst, ONE, ALU_o, ALUout_o); Register MDR (clk, rst, ONE, mem_o, mdr_o);
    Register IMOUT (clk, rst, ONE, imm_ext_o, immout_o);
    DM DMUUT (clk, rst, adr_mult_o, rd2_o, MemWrite, mem_o);
    PCOLDIR PCOLDIR (clk, rst, IRWrite, pc_o, mem_o, ir_o, oldpc_o);
    RegisterFile RegisterFileUUT (clk, rst, I[19:15], I[24:20], I[11:7], result_o, RegWrite, rd1_o, rd2_o);
    ALU ALUUT (Ainput_o, Binput_o, ALUfunc, ALU_o, zero, sign);
    immediateExtend immediateExtendUUT (ImmSrc, I[31:7], imm_ext_o);

    assign I = ir_o;

endmodule