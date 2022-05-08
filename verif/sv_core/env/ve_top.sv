
module ve_top();

localparam DWIDTH = 8;
localparam NO_MULT = 4;

wire                         clk          ; // system clock 

// interfaces
rst_intf i_rst_intf(
.clk (clk)
);

op_intf #(
.DWIDTH (DWIDTH)
) i_op_intf (
.clk (clk)
);

res_intf #(
.DWIDTH (DWIDTH)
) i_res_intf (
.clk (clk)
);


// DUT 
comp_mult_wrapper #(
.DWIDTH  (DWIDTH  ), // data width
.NO_MULT (NO_MULT )  // number of multipliers used (1, 2 or 4)
) DUT_comp_mult_wrapper (
// system IF 
.clk      (clk                ), // [i] system clock 
.rst_n    (i_rst_intf.rst_n   ), // [i] hw async reset, active low 
.sw_rst   (i_rst_intf.sw_rst  ), // [i] sw  sync reset, active high  
.op_val   (i_op_intf.op_val   ), // [i] input operands valid 
.op_rdy   (i_op_intf.op_rdy   ), // [o] input operands ready 
.op_data  (i_op_intf.op_data  ), // [i] input operands {x1,x2,y1,y2}
.res_val  (i_res_intf.res_val ), // [o] output result valid 
.res_rdy  (i_res_intf.res_rdy ), // [i] output result ready 
.res_data (i_res_intf.res_data)  // [o] output result {xr,yr}
); 
               

complex_mult_10op_test test(i_rst_intf, i_op_intf, i_res_intf);
                                              
clk_rst_tb#(                                  
.PERIOD (5) // clock period / 2   
) i_clk_rst_tb  (   
.clk   (clk  ), // [o] system clock    
.rst_n ()  // [o] async hw reset active low    
);   
   
   
endmodule // ve_top