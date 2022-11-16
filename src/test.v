module Controller (
    input clk,
    input rst,
    input alu_out,
    input [4:0] opcode,
    input [2:0] f3,
    input f7,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    output reg stall,
    output reg [3:0] F_im_w_en,
    output reg D_rs1_data_sel,
    output reg D_rs2_data_sel,
    output reg [1:0] E_rs1_data_sel,
    output reg [1:0] E_rs2_data_sel,
    output reg E_jb_op1_sel,
    output reg E_alu_op1_sel,
    output reg E_alu_op2_sel,
    output reg next_pc_sel,
    output reg [4:0] E_op,
    output reg [2:0] E_f3,
    output reg E_f7,
    output reg [3:0] M_dm_w_en,
    output reg W_wb_en,
    output reg [4:0] W_rd_index,
    output reg W_wb_data_sel
);
    reg [4:0] E_rs1;
    reg [4:0] E_rs2;
    reg [4:0] E_rd;
    reg [4:0] M_op;
    reg [2:0] M_f3;
    reg [4:0] M_rd;
    reg [4:0] W_op;
    reg [2:0] W_f3;
    reg [4:0] W_rd;
    reg is_D_use_rs1;
    reg is_D_use_rs2;
    reg is_W_use_rd;
    reg is_D_rs1_E_rd_overlap;
    reg is_D_rs2_E_rd_overlap;
    reg is_D_rs1_W_rd_overlap;
    reg is_D_rs2_W_rd_overlap;
    reg is_E_rs1_M_rd_overlap;
    reg is_E_rs2_M_rd_overlap;
    reg is_E_rs1_W_rd_overlap;
    reg is_E_rs2_W_rd_overlap;
    reg is_DE_overlap;
    reg is_E_use_rs1;
    reg is_E_use_rs2;
    reg is_M_use_rd;
// define opcode
parameter LUI = 5'b01101, AUIPC = 5'b00101 ,JAL = 5'b11011 ,JALR = 5'b11001 , 
Btype = 5'b11000, LOAD = 5'b00000, STORE = 5'b01000, Itype = 5'b00100, Rtype = 5'b01100;

always @(posedge clk or posedge rst) begin
    is_D_use_rs1 <= 1'd0;
    is_D_use_rs2 <= 1'd0;
    is_W_use_rd <= 1'd0;
    is_M_use_rd <= 1'd0;
    is_E_use_rs1 <= 1'd0;
    is_E_use_rs2 <= 1'd0;

    is_E_rs1_W_rd_overlap <= 1'd0;
    is_E_rs2_W_rd_overlap <= 1'd0;
    is_E_rs2_M_rd_overlap <= 1'd0;
    is_E_rs1_M_rd_overlap <= 1'd0;

    is_D_rs1_W_rd_overlap <= 1'd0;
    is_D_rs2_W_rd_overlap <= 1'd0;
    is_D_rs1_E_rd_overlap <= 1'd0;
    is_D_rs2_E_rd_overlap <=  1'd0;

    is_DE_overlap <=  1'd0;
    if (rst) begin
        next_pc_sel <= 0;
        stall <= 0;
        D_rs1_data_sel <= 0;
        D_rs2_data_sel <= 0;
        E_rs1_data_sel <= 0;
        E_rs2_data_sel <= 0;
        E_alu_op1_sel <= 0;
        E_alu_op2_sel <= 0;
        E_jb_op1_sel <= 0;
        M_dm_w_en <= 4'd0;
        W_wb_en <= 0;
        W_rd_index <= 4'd0;
        W_wb_data_sel <= 0;
        E_op <= 5'd0;
        E_f3 <= 3'd0;
        E_rd <= 5'd0;
        E_rs1 <= 5'd0;
        E_rs2 <= 5'd0;
        E_f7 <= 1'd0;
        M_op <= 5'd0;
        M_f3 <= 3'd0;
        M_rd <= 5'd0;
        W_op <= 5'd0;
        W_f3 <= 3'd0;
        W_rd <= 5'd0;
    end
    else begin
        if(stall) begin
            W_op <= M_op;
            W_f3 <= M_f3;
            W_rd <= M_rd;

            M_op <= E_op;
            M_f3 <= E_f3;
            M_rd <= E_rd;

            E_op <= 5'b00100;
            E_rd <= 5'b00000;
            E_rs1 <= 5'b00000;
            E_rs2 <= 5'b00000;
            E_f7 <= 1'b0;
            E_f3 <= 3'b000;
        end
        else if(next_pc_sel) begin
            W_op <= M_op;
            W_f3 <= M_f3;
            W_rd <= M_rd;

            M_op <= E_op;
            M_f3 <= E_f3;
            M_rd <= E_rd;

            E_op <= 5'b00100;
            E_rd <= 5'b00000;
            E_rs1 <= 5'b00000;
            E_rs2 <= 5'b00000;
            E_f7 <= 1'b0;
            E_f3 <= 3'b000;
        end
        else begin
            E_op = opcode;
            E_f3 = f3;
            E_f7 = f7;
            E_rs1 = rs1;
            E_rs2 = rs2;
            E_rd = rd;

            M_op <= E_op;
            M_f3 <= E_f3;
            M_rd <= E_rd;

            W_op <= M_op;
            W_f3 <= M_f3;
            W_rd <= W_rd;
        end
    end
end






always @(*) begin
    // im_w_en always 0
 F_im_w_en = 4'b0;
 W_wb_en = (W_op == Btype) ? 0 :
              (W_op == STORE) ? 0 : 1;

 E_alu_op1_sel = (E_op == AUIPC) ? 1:
                    (E_op == JAL) ? 1 :
                    (E_op == JALR) ? 1 : 0;

 E_alu_op2_sel = (E_op == Rtype) ? 0:
                    (E_op == Btype) ? 0 : 1;

 E_jb_op1_sel = (E_op == JAL) ? 0 : 
                    (E_op == Btype) ? 0 : 1;

 W_wb_data_sel = (W_op == LOAD) ? 0 : 1;

 M_dm_w_en = (M_op != STORE) ? 4'b0000 :
                (M_f3 == 3'b000) ? 4'b0001 :
                (M_f3 == 3'b001) ? 4'b0011 : 4'b1111;
    W_rd_index = W_rd;
    if ((alu_out == 1 & E_op == Btype) | E_op == JALR | E_op == JAL) begin
        next_pc_sel = 1'd1;
    end
    else begin
        next_pc_sel = 1'd0;
    end
    if (opcode == Btype | opcode == LOAD | opcode == STORE | opcode == Itype | opcode == Rtype | opcode == JALR) begin
        is_D_use_rs1 = 1'd1;
    end
    else begin
        is_D_use_rs1 = 1'd0;
    end
    if (opcode == Btype | opcode == LOAD | opcode == STORE | opcode == Rtype) begin
        is_D_use_rs2 = 1'd1;
    end
    else begin
        is_D_use_rs2 = 1'd0;
    end
    if (W_op != STORE | W_op != Btype) begin
        is_W_use_rd = 1'd1;
    end
    else begin
        is_W_use_rd = 1'd0;
    end

    is_D_rs1_W_rd_overlap = is_D_use_rs1 & is_W_use_rd & (rs1 == W_rd) & W_rd != 0;
    D_rs1_data_sel = is_D_rs1_W_rd_overlap ? 1'd1 : 1'd0;
    
    is_D_rs2_W_rd_overlap = is_D_use_rs2 & is_W_use_rd & (rs2 == W_rd) & W_rd != 0;
    D_rs2_data_sel = is_D_rs2_W_rd_overlap ? 1'd1 : 1'd0;
    
    if (E_op == Btype | E_op == LOAD | E_op == STORE | E_op == Itype | E_op == Rtype | E_op == JALR) begin
        is_E_use_rs1 = 1'd1;
    end
    else begin
        is_E_use_rs1 = 1'd0;
    end
    if (E_op == Btype | E_op == STORE | E_op == Rtype) begin
        is_E_use_rs2 = 1'd1;
    end
    else begin
        is_E_use_rs2 = 1'd0;
    end
    if (M_op != STORE | M_op != Btype) begin
        is_M_use_rd = 1'd1;
    end
    else begin
        is_W_use_rd = 1'd0;
    end

    is_E_rs1_W_rd_overlap = (is_E_use_rs1 && is_W_use_rd && (E_rs1 == W_rd) && W_rd != 0) ? 1:0;
    is_E_rs1_M_rd_overlap = (is_E_use_rs1 && is_M_use_rd && (E_rs1 == M_rd) && M_rd != 0) ? 1:0;

    is_E_rs2_W_rd_overlap = (is_E_use_rs2 && is_W_use_rd && (E_rs2 == W_rd) && W_rd != 0) ? 1:0;
    is_E_rs2_M_rd_overlap = (is_E_use_rs2 && is_M_use_rd && (E_rs2 == M_rd) && M_rd != 0) ? 1:0;

    E_rs1_data_sel = is_E_rs1_M_rd_overlap ? 2'd1 :is_E_rs1_W_rd_overlap ? 2'd0 : 2'd2;
    E_rs2_data_sel = is_E_rs2_M_rd_overlap ? 2'd1 :is_E_rs2_W_rd_overlap ? 2'd0 : 2'd2;
    
    if (opcode == Btype | opcode == LOAD | opcode == STORE | opcode == Itype | opcode == Rtype | opcode == JALR) begin
        is_D_use_rs1 = 1'd1;
    end
    else begin
        is_D_use_rs1 = 1'd0;
    end
    if (opcode == Btype | opcode == STORE | opcode == Rtype) begin
        is_D_use_rs2 = 1'd1;
    end
    else begin
        is_D_use_rs2 = 1'd0;
    end

    
    is_D_rs1_E_rd_overlap = (is_D_use_rs1 && (rs1 == E_rd) & E_rd != 0) ? 1:0;
    is_D_rs2_E_rd_overlap = (is_D_use_rs2 && (rs2 == E_rd) & E_rd != 0) ? 1:0;
    is_DE_overlap = (is_D_rs1_E_rd_overlap || is_D_rs2_E_rd_overlap);

    is_D_rs1_W_rd_overlap = (is_D_use_rs1 && is_W_use_rd && (rs1 == W_rd) && W_rd != 0) ? 1:0;
    is_D_rs2_W_rd_overlap = (is_D_use_rs2 && is_W_use_rd && (rs2 == W_rd) && W_rd != 0) ? 1:0;

    D_rs1_data_sel = is_D_rs1_W_rd_overlap ? 1'd1 : 1'd0;
    D_rs2_data_sel = is_D_rs2_W_rd_overlap ? 1'd1 : 1'd0;


    if((E_op == LOAD) & is_DE_overlap) begin
        stall = 1'd1;     
    end
    else begin
        stall = 1'd0;
    end
end

endmodule