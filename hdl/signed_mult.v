//---------------------------------------------------------------------
// Project     : HDL - Complex Multiplier
// Module Name : uint8_mult
// Author      : Feldioreanu George-Aurelian (FG)
// Created     : Mar 12, 2022
//---------------------------------------------------------------------
// Description : Unsigned multiplier 
//---------------------------------------------------------------------

module uint8_mult #(
parameter DWIDTH = 8 // data width
)(

input  [  DWIDTH -1:0] op1    , // first operand 
input  [  DWIDTH -1:0] op2    , // second operand 
output [2*DWIDTH -1:0] result   // product 
); 

wire [  DWIDTH -1:0] abs_op1    ;
wire [  DWIDTH -1:0] abs_op2    ;
wire [2*DWIDTH -1:0] abs_result ;

assign abs_op1    = op1[DWIDTH-1] ? (~op1 + 'd1) : op1;
assign abs_op2    = op2[DWIDTH-1] ? (~op2 + 'd1) : op2; 

unsigned_mult #(
.DWIDTH (2*DWIDTH) // data width, doubled for sign extension 
)i_unsigned_mult_1(
 .op1    (abs_op1    ), // [i] sign extended first  operand (x1)
 .op2    (abs_op2    ), // [i] sign extended second operand (y2) 
 .result (abs_result )  // [o] product x1 * y2 
);  

assign result = (op1[DWIDTH-1] ^ op2[DWIDTH-1]) ? (~abs_result + 'd1) : abs_result;


endmodule // uint8_mult