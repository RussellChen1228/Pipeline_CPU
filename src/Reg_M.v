module Reg_M(
    input clk,
    input rst,
    input [31:0] alu_out,
    input [31:0] operand2, 
    output reg [31:0] Alu_out,
    output reg [31:0] Operand2
);
always @(posedge clk or posedge rst) begin
    if(rst) begin
        Alu_out <= 32'd0;
        Operand2 <= 32'd0;
    end
    else begin
        Alu_out <= alu_out;
        Operand2 <= operand2;
    end
end
endmodule