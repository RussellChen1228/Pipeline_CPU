module Reg_W(
    input clk,
    input rst,
    input [31:0] alu_out,
    input [31:0] ld_data,
    output reg [31:0] Alu_out,
    output reg [31:0] Ld_data
);
always @(posedge clk or posedge rst) begin
    if(rst) begin
        Alu_out <= 32'd0;
        Ld_data <= 32'd0;
    end
    else begin
        Alu_out <= alu_out;
        Ld_data <= ld_data;
    end
end

endmodule