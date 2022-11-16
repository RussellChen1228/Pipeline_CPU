module Reg_D(
    input jb,
    input clk,
    input rst,
    input stall,
    input reg [31:0] pc,
    input reg [31:0] inst,
    output reg [31:0] Pc,
    output reg [31:0] Inst
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        Pc <= 32'd0;
        Inst <= 32'd0;
    end
   else if (stall) begin
        Pc <= Pc;
        Inst <= Inst;   
    end
    else if(jb)
        begin
            Pc <= pc;
            Inst <= 32'b00000000000000000000000000010011;  //noop -> addi x0,x0,1
    end
    else begin
        Pc <= pc;
        Inst <= inst;
    end
end

endmodule