//---------------------------------------------------------------------------------------
// Project     : Complex numbers multiplier
// Module Name : comp_mult_ref_model
// Author      : Dan NICULA (DN)
// Created     : Mar, 2, 2021
//---------------------------------------------------------------------------------------
// Description : Multiplies 2 complex number.
//               operands and result on valid/ready interface
//---------------------------------------------------------------------------------------
// Modification history :
// Mar 2, 2021 (DN): Initial 
//---------------------------------------------------------------------------------------

module comp_mult_ref_model (
input                        clk       , // Semnal de ceas.
input                        rst_n     , // Reset asincron activ în 0. 
// Interfata cu operatorii   
input                        op_val    , // Operanzi valizi.
output reg                   op_rdy    , // Este permisă primirea operanzilor.
input      [2 * 2 * 8 - 1:0] op_data   , // Operanzi (x1, y1, x2, y2).
// Interfata cu rezultatul   
output reg                   res_val   , // Rezultat valid.
input                        res_rdy   , // Este acceptat rezultatul.
output reg [2 * 18    - 1:0] res_data    // Rezultatul (xr, yr)
);

wire signed [8  - 1:0] x1, y1, x2, y2 ;
wire signed [18 - 1:0] re;
wire signed [18 - 1:0] im;
assign {x1, y1, x2, y2} = op_data;
assign re = x1 * x2 - y1 * y2;
assign im = x1 * y2 + y1 * x2;
  
always @(posedge clk)
op_rdy <= 1'b1;

always @(posedge clk)
if (op_val & op_rdy) begin
  res_val <= 1'b1;
  res_data <= {re, im};
end
else begin
  res_val <= 1'b0;
  res_data <= 'bx;
end

endmodule // comp_mult_ref_model
