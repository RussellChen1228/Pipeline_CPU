module Reg_E(
    input jb,
    input clk,
    input stall,
    input rst,
    input [31:0] pc,
    input [31:0] imm_ext,
    input [31:0] operand1,
    input [31:0] operand2,
    output reg [31:0] Pc,
    output reg [31:0] imm_ext_out,
    output reg [31:0] Operand1,
    output reg [31:0] Operand2
);



always @(posedge clk or posedge rst) begin
    if (rst) begin
        Pc <= 32'd0;
        Operand1 <= 32'd0;
        Operand2 <= 32'd0;
        imm_ext_out <= 32'd0;
    end
    else if(stall) begin
            Pc <= pc;
            Operand1 <= 32'd0;
            Operand2 <= 32'd0;
            imm_ext_out <= 32'd0;
    end
    else begin
        Pc <= pc;
        Operand1 <= operand1;
        Operand2 <= operand2;
        imm_ext_out <= imm_ext;
    end

end

endmodule