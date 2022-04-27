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

assign result = op1 * op2;  // combinatorial multiplier

endmodule // uint8_mult