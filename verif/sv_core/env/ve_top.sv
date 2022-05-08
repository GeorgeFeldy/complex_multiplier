
module top();

localparam DWIDTH = 8;
localparam NO_MULT = 4;

wire                         clk          ; // system clock 
wire                         rst_n        ; // hw async reset, active low 
wire                         sw_rst       ; // sw  sync reset, active high  
wire                         op_val       ; // operands valid 
wire                         op_rdy       ; // operands ready 
wire [      2*2*DWIDTH -1:0] op_data      ; // operands {x1,y1,y1,y2}          
wire                         res_val      ; // result valid 
wire                         res_rdy      ; // result ready 
wire [2*2*(DWIDTH + 1) -1:0] res_data     ; // result {xr,yr}

// DUT 
comp_mult_wrapper #(
.DWIDTH  (DWIDTH  ), // data width
.NO_MULT (NO_MULT )  // number of multipliers used (1, 2 or 4)
) DUT_comp_mult_wrapper (
// system IF 
.clk      (clk     ), // [i] system clock 
.rst_n    (rst_n   ), // [i] hw async reset, active low 
.sw_rst   (sw_rst  ), // [i] sw  sync reset, active high  
.op_val   (op_val  ), // [i] input operands valid 
.op_rdy   (op_rdy  ), // [o] input operands ready 
.op_data  (op_data ), // [i] input operands {x1,x2,y1,y2}
.res_val  (res_val ), // [o] output result valid 
.res_rdy  (res_rdy ), // [i] output result ready 
.res_data (res_data)  // [o] output result {xr,yr}
); 
               
rst_intf i_rst_intf(
.clk    (clk   ),
.rst_n  (rst_n ),
.sw_rst (sw_rst)
);

op_intf i_op_intf #(
.DWIDTH (DWIDTH)
)(
.clk     (clk    ),
.op_val  (op_val ),
.op_rdy  (op_rdy ),
.op_data (op_data)
);

res_intf i_res_intf #(
.DWIDTH (DWIDTH)
)(
.clk      (clk     ),
.res_val  (res_val ),
.res_rdy  (res_rdy ),
.res_data (res_data)
);

ve_environment i_ve_environment(10, "env", 0, i_rst_intf, i_op_intf, i_res_intf);
                                              
clk_rst_tb#(                                  
.PERIOD (5) // clock period / 2   
) i_clk_rst_tb  (   
.clk   (clk  ), // [o] system clock    
.rst_n ()  // [o] async hw reset active low    
);   
   
   
endmodule