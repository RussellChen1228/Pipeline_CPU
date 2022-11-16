module Mux_t (
    input [1:0] sel, 
    input [31:0] in1 ,
    input [31:0] in2, 
    input [31:0] in3, 
    output[31:0] result 
);

assign result = (sel == 2'd0) ? in1 :  
                (sel == 2'd1) ? in2 : in3;

    
endmodule