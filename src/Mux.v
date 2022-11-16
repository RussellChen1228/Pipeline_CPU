module Mux (
    input sel, 
    input [31:0] in1 ,
    input [31:0] in2, 
    output[31:0] result 
);

// if sel == 0 =>  result = in1 ,else result = in2 
assign result = (sel == 0) ? in1 :  in2;

    
endmodule