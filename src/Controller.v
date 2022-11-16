module Controller (
    input clk,
    input rst,
    input [4:0] opcode,
    input [2:0] func3,
    input func7,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] alu_result,
    output [3:0] F_im_w_en,
    output reg D_rs1_data_sel,
    output reg D_rs2_data_sel,
    output reg [1:0] E_rs1_data_sel,
    output reg [1:0] E_rs2_data_sel,
    output reg E_alu_op1_sel,
    output reg E_alu_op2_sel,
    output reg E_jb_op1_sel,
    output reg [4:0] E_op_out,
    output reg [2:0] E_f3_out,
    output reg E_f7_out,
    output reg [3:0] M_dm_w_en,
    output reg W_wb_en,
    output reg [4:0] W_rd_index,
    output reg [2:0] W_f3,
    output reg W_wb_data_sel,
    output reg stall,
    output reg next_pc_sel
);

reg [4:0] opcode_tmp, rs1_tmp, rs2_tmp, rd_tmp;
reg [2:0] f3_tmp;
reg f7_tmp;


reg [4:0] E_op, E_rd, E_rs1, E_rs2;
reg [2:0] E_f3;
reg E_f7;

reg [4:0] M_op, M_rd;
reg [2:0] M_f3;

reg [4:0] W_op, W_rd;


reg is_D_use_rs1, is_D_use_rs2;
reg is_W_use_rd, is_M_use_rd;
reg is_E_use_rs1, is_E_use_rs2;

reg is_E_rs1_W_rd_overlap;
reg is_E_rs2_W_rd_overlap;
reg is_E_rs2_M_rd_overlap;
reg is_E_rs1_M_rd_overlap;

reg is_D_rs1_W_rd_overlap;
reg is_D_rs2_W_rd_overlap;
reg is_D_rs1_E_rd_overlap;
reg is_D_rs2_E_rd_overlap;

reg is_DE_overlap;

assign F_im_w_en = 4'd0;

always @(*) begin

    E_op_out = E_op;
    E_f3_out = E_f3;
    E_f7_out = E_f7;

    next_pc_sel = 1'd0;
    if (E_op == 5'b01100 || E_op == 5'b00100 || E_op == 5'b00000 || E_op == 5'b01000 || E_op == 5'b11000 || E_op == 5'b11001)
        is_E_use_rs1 = 1'd1;
    else
        is_E_use_rs1 = 1'd0;

    if (E_op == 5'b01100 || E_op == 5'b11000 || E_op == 5'b01000)
        is_E_use_rs2 = 1'd1;
    else
        is_E_use_rs2 = 1'd0;
    

    if (M_op == 5'b01100 || M_op == 5'b00100 || M_op == 5'b00000 || M_op == 5'b00101 || M_op == 5'b01101 || M_op == 5'b11001 || M_op == 5'b11011)
        is_M_use_rd = 1'd1;
    else
        is_M_use_rd = 1'd0;
    
    if (W_op == 5'b01100 || W_op == 5'b00100 || W_op == 5'b00000 || W_op == 5'b00101 || W_op == 5'b01101 || W_op == 5'b11001 || W_op == 5'b11011)
        is_W_use_rd = 1'd1;
    else
        is_W_use_rd = 1'd0;
    

    is_E_rs1_W_rd_overlap = (is_E_use_rs1 && is_W_use_rd && (E_rs1 == W_rd) && W_rd != 0) ? 1:0;
    is_E_rs1_M_rd_overlap = (is_E_use_rs1 && is_M_use_rd && (E_rs1 == M_rd) && M_rd != 0) ? 1:0;

    is_E_rs2_W_rd_overlap = (is_E_use_rs2 && is_W_use_rd && (E_rs2 == W_rd) && W_rd != 0) ? 1:0;
    is_E_rs2_M_rd_overlap = (is_E_use_rs2 && is_M_use_rd && (E_rs2 == M_rd) && M_rd != 0) ? 1:0;

    E_rs1_data_sel = is_E_rs1_M_rd_overlap ? 2'd1 :is_E_rs1_W_rd_overlap ? 2'd0 : 2'd2;
    E_rs2_data_sel = is_E_rs2_M_rd_overlap ? 2'd1 :is_E_rs2_W_rd_overlap ? 2'd0 : 2'd2;
    



    if (E_op == 5'b01100) // Rtype 
    begin
        E_alu_op1_sel = 1'd0;
        E_alu_op2_sel = 1'd0;
        E_jb_op1_sel = 1'd0;
        next_pc_sel = 1'd0;
    end

    else if(E_op == 5'b00100)  // I type others
        begin
        E_alu_op1_sel = 1'd0;
        E_alu_op2_sel = 1'd1;
        E_jb_op1_sel = 1'd0;
        next_pc_sel = 1'd0;
        end
    else if(E_op == 5'b11001)           // I type JALR
        begin
            E_alu_op1_sel = 1'd1;
            E_alu_op2_sel = 1'd1;
            E_jb_op1_sel = 1'd0;
            next_pc_sel = 1'd1;
        end
    else if(E_op == 5'b00000)           // I type LOAD
        begin

            E_alu_op1_sel = 1'd0;
            E_alu_op2_sel = 1'd1;
            E_jb_op1_sel = 1'd0;
            next_pc_sel = 1'd0;
        end
    else if(E_op == 5'b01000)           // I type STORE
        begin
            E_alu_op1_sel = 1'd0;
            E_alu_op2_sel = 1'd1;
            E_jb_op1_sel = 1'd0;
            next_pc_sel = 1'd0;
        end
    else if(E_op == 5'b01101)        // LUI
        begin
            E_alu_op1_sel = 1'd0;
            E_alu_op2_sel = 1'd1;
            E_jb_op1_sel = 1'd0;
            next_pc_sel = 1'd0;
        end
    else if(E_op == 5'b00101)         //auipc
        begin
            E_alu_op1_sel = 1'd1;
            E_alu_op2_sel = 1'd1;
            E_jb_op1_sel = 1'd0;
            next_pc_sel = 1'd0;
        end
    
    else if(E_op == 5'b11000)         //B type
        begin
            E_alu_op1_sel = 1'd0;
            E_alu_op2_sel = 1'd0;
            E_jb_op1_sel = 1'd1;
            case(alu_result[0])
                1'd0:
                    begin
                        next_pc_sel = 1'd0;
                    end 
                    
                1'd1:
                begin
                    next_pc_sel = 1'd1;        
                end   
            endcase
        end
    else if(E_op == 5'b11011)         //  JAL
        begin
            E_alu_op1_sel = 1'd1;
            E_alu_op2_sel = 1'd1;
            E_jb_op1_sel = 1'd1;
            next_pc_sel = 1'd1;
        end

    if(M_op == 5'b01000)           // I type STORE
        begin
            case(M_f3)
                3'b000: M_dm_w_en = 4'b0001;      //sb
                3'b001: M_dm_w_en = 4'b0011;      //sb
                3'b010: M_dm_w_en = 4'b1111;      //sb
                default:
                    M_dm_w_en = 4'b0000;
            endcase
        end
    else
        M_dm_w_en = 4'b0000;
    
    if (opcode == 5'b01100 || opcode == 5'b00100 || opcode == 5'b00000 || opcode == 5'b01000 || opcode == 5'b11000 || opcode == 5'b11001)
        is_D_use_rs1 = 1'd1;
    else
        is_D_use_rs1 = 1'd0;

    if (opcode == 5'b01100 || opcode == 5'b11000 || opcode == 5'b01000 )
        is_D_use_rs2 = 1'd1;
    else
        is_D_use_rs2 = 1'd0;

    is_D_rs1_E_rd_overlap = (is_D_use_rs1 && (rs1 == E_rd) & E_rd != 0) ? 1:0;
    is_D_rs2_E_rd_overlap = (is_D_use_rs2 && (rs2 == E_rd) & E_rd != 0) ? 1:0;
    is_DE_overlap = (is_D_rs1_E_rd_overlap || is_D_rs2_E_rd_overlap);

    is_D_rs1_W_rd_overlap = (is_D_use_rs1 && is_W_use_rd && (rs1 == W_rd) && W_rd != 0) ? 1:0;
    is_D_rs2_W_rd_overlap = (is_D_use_rs2 && is_W_use_rd && (rs2 == W_rd) && W_rd != 0) ? 1:0;

    D_rs1_data_sel = is_D_rs1_W_rd_overlap ? 1'd1 : 1'd0;
    D_rs2_data_sel = is_D_rs2_W_rd_overlap ? 1'd1 : 1'd0;

    if(E_op == 5'b00000 && is_DE_overlap)    // I type LOAD
        begin
        stall = 1'd1;
        end
    else
        stall = 1'd0;


    W_rd_index = W_rd;    
    if (W_op == 5'b01100)     // R type
    begin
        W_wb_en = 1'd1;
        W_wb_data_sel = 1'd0;
    end
    else if(W_op == 5'b00100)  // I type others
        begin
            W_wb_en = 1'd1;
            W_wb_data_sel = 1'd0;
        end
    else if(W_op == 5'b01000)           // I type STORE
        begin
            W_wb_en = 1'd0;
            W_wb_data_sel = 1'd0;
        end
    else if(W_op == 5'b00000)           // I type LOAD
        begin
            W_wb_en = 1'd1;
            W_wb_data_sel = 1'd1;
        end
    else if(W_op == 5'b11001)           // I type JALR
        begin
            W_wb_en = 1'd1;
            W_wb_data_sel = 1'd0;
        end
    else if(W_op == 5'b11011)         //  JAL
        begin
            W_wb_en = 1'd1;
            W_wb_data_sel = 1'd0;
        end
    else if(W_op == 5'b01101)        // LUI
        begin
            W_wb_en = 1'd1;
            W_wb_data_sel = 1'd0;
        end
    else if(W_op == 5'b00101)         //auipc
        begin
            W_wb_en = 1'd1;
            W_wb_data_sel = 1'd0;
        end
    else if(W_op == 5'b11000)         //B type

        begin
            W_wb_en = 1'd0;
            W_wb_data_sel = 1'd0;
        end
end

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
        E_op_out <= 4'd0;
        E_f3_out <= 3'd0;
        E_f7_out <= 0;
        M_dm_w_en <= 4'd0;
        W_wb_en <= 0;
        W_rd_index <= 4'd0;
        W_f3 <= 3'd0;
        W_wb_data_sel <= 0;
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
            W_op <= M_op;
            W_f3 <= M_f3;
            W_rd <= M_rd;

            M_op <= E_op;
            M_f3 <= E_f3;
            M_rd <= E_rd;

            E_op <= opcode;
            E_rd <= rd;
            E_rs1 <= rs1;
            E_rs2 <= rs2;
            E_f7 <= func7;
            E_f3 <= func3;
        end
    end
end


endmodule
