module RegFile (
input clk,
input wb_en,
input [31:0] wb_data,
input [4:0] rd_index,
input [4:0] rs1_index,
input [4:0] rs2_index,
output [31:0] rs1_data_out,
output [31:0] rs2_data_out
);
// 32 reg
reg [31:0] registers [0:31];

always @(posedge clk) begin
    // if wb_en == 1
    if(wb_en) begin
        // if rd_index != 0 => write data to registers[rb_index]
        if (rd_index == 5'b0)begin
            // reg[rb_index] = wb_data
            registers[rd_index] <= 5'd0;
        end
        else begin
            registers[rd_index] <= wb_data;
        end

    end
end

// data of rs1 = registers[res1_index]
assign rs1_data_out = registers[rs1_index];
// data of rs2 = registers[res2_index]
assign rs2_data_out = registers[rs2_index];

endmodule