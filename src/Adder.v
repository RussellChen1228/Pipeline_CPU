module Adder (
input [4:0] opcode,
input [2:0] func3,
input func7,
input [31:0] operand1,
input [31:0] operand2,
output reg [31:0] alu_out
);

wire signed [31:0] operand1_signed;
wire signed [31:0] operand2_signed;

assign operand1_signed = operand1;
assign operand2_signed = operand2;


always @(*) begin
    case (opcode)
        //  lui
        5'b01101: begin
            alu_out = operand2;
        end
        // auipc
        5'b00101: begin
            alu_out = operand1 + operand2;
        end
        // jal 
        5'b11011: begin 
            alu_out = operand1 + 32'd4;
        end
         // jalr 
        5'b11001: begin 
            alu_out = operand1 + 32'd4;
        end
        // B type
        5'b11000: begin
            case (func3)
                3'b000:  alu_out = (operand1_signed == operand2_signed) ? 32'd1 : 32'd0;       // beq
                3'b001:  alu_out = (operand1_signed != operand2_signed) ? 32'd1 : 32'd0;       // bne
                3'b100:  alu_out = (operand1_signed < operand2_signed) ? 32'd1 : 32'd0;        // blt
                3'b101:  alu_out = (operand1_signed >= operand2_signed) ? 32'd1 : 32'd0;       // bge
                3'b110:  alu_out = (operand1 < operand2) ? 32'd1 : 32'd0;                      // bltu
                3'b111:  alu_out = (operand1 >= operand2) ? 32'd1 : 32'd0;                     // bgeu
                default: 
                    alu_out = 32'd0;
            endcase
        end
        // load
        5'b00000: begin
            alu_out = operand1 + operand2;
        end
        // store
        5'b01000: begin
            alu_out = operand1 + operand2;
        end
        // I type 
        5'b00100: begin
            case (func3)
                // addi
                3'b000: begin 
                    alu_out = operand1_signed + operand2_signed;
                end
                // slti
                3'b010: begin
                    alu_out = (operand1_signed < operand2_signed) ? 32'b1 : 32'b0;
                end
                // sltiu
                3'b011:  begin
                   alu_out = (operand1 < operand2) ? 32'b1 : 32'b0;
                end
                // xori
                3'b100: begin
                    alu_out = operand1 ^ operand2;
                end
                // ori
                3'b110: begin
                    alu_out = operand1 | operand2;
                end
                // andi
                3'b111: begin
                    alu_out = operand1 & operand2;
                end
                // slli
                3'b001: begin
                    alu_out = $signed(operand1) << operand2[4:0];
                end
                // srli or srai
                3'b101:  begin
                    case (func7) 
                        // srli
                        1'b0: begin
                            alu_out = $signed(operand1_signed) >> operand2[4:0];
                        end
                        // srai
                        1'b1: begin
                            alu_out = operand1_signed >>> operand2[4:0];
                        end
                    endcase   
                end
                default: begin
                    alu_out = 32'b0;
                end
            endcase        
        end 
        // R type
        5'b01100: begin
            case (func3)
                // add or sub
                3'b000 : begin
                    // sub
                    if (func7) begin
                        alu_out = operand1_signed - operand2_signed;
                    end
                    // add
                    else begin
                        alu_out = operand1_signed + operand2_signed;
                    end
                end
                // sll
                3'b001: begin
                    alu_out = operand1 << operand2[4:0];
                end
                // slt 
                3'b010: begin 
                    alu_out = (operand1_signed < operand2_signed) ? 32'b1 : 32'b0;
                end
                // sltu
                3'b011: begin
                    alu_out = (operand1 < operand2) ? 32'd1 : 32'd0;
                end
                // xor
                3'b100: begin
                    alu_out = operand1 ^ operand2;
                end
                // srl or sra
                3'b101 : begin 
                    // sra
                    if (func7) begin
                        alu_out = $signed(operand1_signed) >>> operand2[4:0];
                    end
                    // srl
                    else begin
                        alu_out = $signed(operand1_signed) >> operand2[4:0];
                    end
                end
                // or
                3'b110: begin
                    alu_out = operand1 | operand2;
                end
                // and
                3'b111: begin
                    alu_out = operand1 & operand2;
                end
            endcase
        end 
    endcase
end
endmodule