`include "./src/Adder.v"
`include "./src/Controller.v"
`include "./src/Decoder.v"
`include "./src/Imme_Ext.v"
`include "./src/JB_Unit.v"
`include "./src/LD_Filter.v"
`include "./src/Mux.v"
`include "./src/Mux_t.v"
`include "./src/Reg_PC.v"
`include "./src/RegFile.v"
`include "./src/SRAM.v"
`include "./src/Reg_D.v"
`include "./src/Reg_E.v"
`include "./src/Reg_M.v"
`include "./src/Reg_W.v"

module Top (
    input clk,
    input rst
);

Mux pcmux(
    .sel(ctlr.next_pc_sel),
    .in1(pc.current_pc + 32'd4),
    .in2(jb_unit.jb_out)
);

Reg_PC pc(
    .clk(clk),
    .rst(rst),
    .stall(ctlr.stall),
    .next_pc(pcmux.result)
);

SRAM im (
    .clk(clk),
    .w_en(ctlr.F_im_w_en),
    .address(pc.current_pc[15:0])
);

Reg_D reg_d(
    .clk(clk),
    .rst(rst),
    .pc(pc.current_pc),
    .jb(ctlr.next_pc_sel),
    .stall(ctlr.stall),
    .inst(im.read_data)
);

Decoder decoder(
    .inst(reg_d.Inst)
);


RegFile regfile(
    .clk(clk), 
    .wb_en(ctlr.W_wb_en),
    .wb_data(lstmux.result),
    .rs1_index(decoder.dc_out_rs1_index),
    .rs2_index(decoder.dc_out_rs2_index),
    .rd_index(ctlr.W_rd_index)
);

Mux d_rs1(
    .in1(regfile.rs1_data_out),
    .in2(lstmux.result),
    .sel(ctlr.D_rs1_data_sel)
);

Mux d_rs2(
    .in1(regfile.rs2_data_out),
    .in2(lstmux.result),
    .sel(ctlr.D_rs2_data_sel)
);

Imm_Ext ime(
    .inst(reg_d.Inst)// jb.operand2
);

Reg_E reg_e(
    .clk(clk),
    .rst(rst),
    .jb(ctlr.next_pc_sel),
    .stall(ctlr.stall),
    .pc(reg_d.Pc),
    .imm_ext(ime.imm_ext_out),
    .operand1(d_rs1.result),
    .operand2(d_rs2.result)
);

Mux_t e_rs1mux(
    .in1(lstmux.result),
    .in2(reg_m.Alu_out),
    .in3(reg_e.Operand1),
    .sel(ctlr.E_rs1_data_sel)
);
Mux_t e_rs2mux(
    .in1(lstmux.result),
    .in2(reg_m.Alu_out),
    .in3(reg_e.Operand2),
    .sel(ctlr.E_rs2_data_sel)
);

Mux aluonemux(
    .sel(ctlr.E_alu_op1_sel),
    .in1(e_rs1mux.result),
    .in2(reg_e.Pc)
);

Mux alutwomux(
    .sel(ctlr.E_alu_op2_sel),
    .in1(e_rs2mux.result),
    .in2(reg_e.imm_ext_out)
);

Mux jbmux(
    .sel(ctlr.E_jb_op1_sel),
    .in1(e_rs1mux.result),
    .in2(reg_e.Pc)
);

JB_Unit jb_unit (
    .operand1(jbmux.result),
    .operand2(reg_e.imm_ext_out)
);

Adder alu(
    .opcode(ctlr.E_op),
    .func3(ctlr.E_f3),
    .func7(ctlr.E_f7),
    .operand1(aluonemux.result),
    .operand2(alutwomux.result)
);

Controller ctlr(
    .clk(clk),
    .rst(rst),
    .alu_result(alu.alu_out),
    .opcode(decoder.dc_out_opcode),
    .func3(decoder.dc_out_func3),
    .func7(decoder.dc_out_func7),
    .rs1(decoder.dc_out_rs1_index),
    .rs2(decoder.dc_out_rs2_index),
    .rd(decoder.dc_out_rd_index)
);

Reg_M reg_m(
    .clk(clk),
    .rst(rst),
    .alu_out(alu.alu_out),
    .operand2(e_rs2mux.result)
);

SRAM dm (
    .clk(clk),
    .w_en(ctlr.M_dm_w_en),
    .address(reg_m.Alu_out[15:0]),
    .write_data(reg_m.Operand2)
);

Reg_W reg_w(
    .clk(clk),
    .rst(rst),
    .alu_out(reg_m.Alu_out),
    .ld_data(dm.read_data)
);


LD_Filter ld (
    .func3(ctlr.W_f3),
    .ld_data(reg_w.Ld_data)
);

Mux lstmux(
    .sel(ctlr.W_wb_data_sel),
    .in1(reg_w.Alu_out),
    .in2(ld.ld_data_f)
);

endmodule