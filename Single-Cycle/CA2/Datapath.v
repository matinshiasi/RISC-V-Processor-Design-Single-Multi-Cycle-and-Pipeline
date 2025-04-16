module datapath (
    input registerfile_we, input data_memory_we, input alu_source, input [1:0] pc_source, 
    input [1:0] wd_source, input [2:0] alu_control, input [2:0] imm_src, input clk, input rst, 
    output zero, output [31:0] I
);

    wire [31:0] pc_out, instr_mem_out, r1_data, r2_data, alu_src_data, alu_result, data_mem_out, wd_data, imm_ext_data, pc_src_data, add_4_result, add_imm_result;

    PC_Counter pc (clk, rst, pc_src_data, pc_out);
    Instr_mem Instr_mem (pc_out, instr_mem_out);
    assign I = instr_mem_out;
    RegisterFile register_file (clk, rst, instr_mem_out[19:15], instr_mem_out[24:20], instr_mem_out[11:7], wd_data, registerfile_we, r1_data, r2_data);
    ALU alu (r1_data, alu_src_data, alu_control, alu_result, zero);

    assign alu_src_data = alu_source ? imm_ext_data : r2_data;

    Data_mem DM (clk, alu_result, r2_data, data_memory_we, data_mem_out);
    
    assign wd_data = (wd_source == 2'b00) ? alu_result : 
                     (wd_source == 2'b01) ? data_mem_out : 
                     (wd_source == 2'b10) ? imm_ext_data : add_4_result;

    assign pc_src_data = (pc_source == 2'b00) ? add_4_result : 
                         (pc_source == 2'b01) ? add_imm_result : alu_result;

    Extend extend (imm_src, instr_mem_out[31:7], imm_ext_data);
    assign add_4_result = pc_out + 32'd4;
    assign add_imm_result = pc_out + imm_ext_data;

endmodule

