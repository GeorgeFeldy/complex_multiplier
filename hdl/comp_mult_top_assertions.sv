//--------------------------------------------------------------------------------------------------------------------------------
// Project     : HDL - Complex Multiplier
// File Name   : comp_mult_top_assertions.sv
// Author      : Feldioreanu George-Aurelian (FG)
// Created     : May 20, 2022
//--------------------------------------------------------------------------------------------------------------------------------

let max(a,b) = (a  > b) ? a : b;
let min(a,b) = (a <= b) ? a : b;


property res_op1_overlap_prop;
  @(posedge clk) disable iff (~rst_n)
  start |-> max(res_addr + 6 * no_op, op1_addr + 2 * no_op) - min(res_addr, op1_addr) > 0;
endproperty

res_op1_no_overlap: assert property (res_op1_overlap_prop)
else begin 
  $error("\t Result and operand 1 memory sections overlap!");
  $stop;
end

property res_op2_overlap_prop;
   @(posedge clk) disable iff (~rst_n)
   start |-> max(res_addr + 6 * no_op, op2_addr + 2 * no_op) - min(res_addr, op2_addr) > 0;
endproperty

res_op2_no_overlap: assert property (res_op2_overlap_prop)
else begin 
    $error("Result and operand 2 memory sections overlap!");
  	$stop;
end


property op1_op2_overlap_prop;
   @(posedge clk) disable iff (~rst_n)
  start |-> max(op2_addr + 2 * no_op, op2_addr + 2 * no_op) - min(op1_addr, op2_addr) > 0;
endproperty

op1_op2_no_overlap: assert property (op1_op2_overlap_prop)
else begin
    $error("Operand 1 and operand 2 memory sections overlap!");
  	$stop;
end 
        
       