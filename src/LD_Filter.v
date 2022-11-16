module LD_Filter (
input [2:0] func3,
input [31:0] ld_data,
output reg [31:0] ld_data_f
);

always @(*) begin
    // decide on func3
    case(func3)
        // lb
        3'b000 : begin
            ld_data_f = {{24{ld_data[31]}}, ld_data[7:0]};
        end
        // lh
        3'b001 : begin
            ld_data_f = {{16{ld_data[31]}}, ld_data[15:0]};
        end
        // lw
        3'b010 : begin
            ld_data_f = ld_data;
        end
        // lbu
        3'b100 : begin
            ld_data_f = {24'b0 , ld_data[7:0]};
        end
        // lhu
        3'b101 : begin
            ld_data_f = {16'b0 , ld_data[15:0]};
        end
    endcase
end

endmodule