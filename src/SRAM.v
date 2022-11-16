module SRAM (
input clk,
input [3:0] w_en,
input [15:0] address,
input [31:0] write_data,
output [31:0] read_data
);

// 65535 mem
reg [7:0] mem [0:65535];


always @(posedge clk) begin
    case (w_en)
        // sb
        4'b0001 : begin
            mem[address] <= write_data[7:0];
        end 
        // shw
        4'b0011 : begin
            mem[address] <= write_data[7:0];
            mem[address+1] <= write_data[15:8];
        end 
        // sw
        4'b1111 : begin
            mem[address] <= write_data[7:0];
            mem[address+1] <= write_data[15:8];
            mem[address+2] <= write_data[23:16];
            mem[address+3] <= write_data[31:24];
        end 
    endcase
end

assign read_data = {mem[address+3],mem[address+2],mem[address+1],mem[address]};

endmodule