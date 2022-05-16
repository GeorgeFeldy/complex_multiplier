//---------------------------------------------------------------------
// Project     : HDL - Complex Multiplier
// Module Name : signed_mult
// Author      : Feldioreanu George-Aurelian (FG)
// Created     : Mar 12, 2022
//---------------------------------------------------------------------
// Description : Unsigned multiplier 
//---------------------------------------------------------------------

module signed_mult #(
parameter DWIDTH = 8 // data width
)(

input  [  DWIDTH -1:0] op1    , // first operand 
input  [  DWIDTH -1:0] op2    , // second operand 
output [2*DWIDTH -1:0] result   // product 
); 

wire   [  DWIDTH -1:0] abs_op1    ;  // op1 absolute value 
wire   [  DWIDTH -1:0] abs_op2    ;  // op2 absolute value 
wire   [2*DWIDTH -1:0] abs_result ;  // result absolute value 

assign abs_op1 = op1[DWIDTH-1] ? (~op1 + 'd1) : op1; // get absolute value 
assign abs_op2 = op2[DWIDTH-1] ? (~op2 + 'd1) : op2; // get absolute value 

unsigned_mult #(
.DWIDTH (DWIDTH) // data width, doubled for sign extension 
)i_unsigned_mult_1(
 .op1    (abs_op1    ), // [i] first  operand 
 .op2    (abs_op2    ), // [i] second operand 
 .result (abs_result )  // [o] product 
);  

// convert to negative if operand signs are different 
assign result = (op1[DWIDTH-1] ^ op2[DWIDTH-1]) ? (~abs_result + 'd1) : abs_result; 


endmodule // signed_mult