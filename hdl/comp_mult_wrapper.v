//---------------------------------------------------------------------
// Project     : HDL - Complex Multiplier
// Module Name : comp_mult_wrapper
// Author      : Feldioreanu George-Aurelian (FG)
// Created     : Mar 12, 2022
//---------------------------------------------------------------------
// Description : Wrapper for complex multiplier, with configurable 
//               number of multiplier instances
//---------------------------------------------------------------------

module comp_mult_wrapper #(
parameter DWIDTH  = 8 , // data width
parameter NO_MULT = 4   // number of multipliers used (1, 2 or 4)
)(
// system IF 
input                          clk      , // system clock 
input                          rst_n    , // hw async reset, active low 
input                          sw_rst   , // sw  sync reset, active high  
                                          
// input operands val-rdy IF              
input                          op_val   , // input operands valid 
output                         op_rdy   , // input operands ready 
input  [      2*2*DWIDTH -1:0] op_data  , // input operands {x1,y1,x2,y2}
                                          
// output results val-rdy IF              
output                         res_val  , // output result valid 
input                          res_rdy  , // output result ready 
output [2*2*(DWIDTH + 1) -1:0] res_data   // output result {xr,yr}
); 

generate 
    if(NO_MULT == 4) begin : GEN_4_MULTS
        comp_mult_4 #(
        .DWIDTH (DWIDTH) // data width
        )i_comp_mult_4 (
        .clk      (clk      ), // [i] system clock 
        .rst_n    (rst_n    ), // [i] hw async reset, active low 
        .sw_rst   (sw_rst   ), // [i] sw  sync reset, active high  
        .op_val   (op_val   ), // [i] input operands valid 
        .op_rdy   (op_rdy   ), // [o] input operands ready 
        .op_data  (op_data  ), // [i] input operands {x1,y1,x2,y2}
        .res_val  (res_val  ), // [o] output result valid 
        .res_rdy  (res_rdy  ), // [i] output result ready 
        .res_data (res_data )  // [o] output result {xr,yr}
        ); 
    end
    else if(NO_MULT == 2) begin : GEN_2_MULTS
        comp_mult_2 #(
        .DWIDTH (DWIDTH) // data width
        )i_comp_mult_2 (
        .clk      (clk      ), // [i] system clock 
        .rst_n    (rst_n    ), // [i] hw async reset, active low 
        .sw_rst   (sw_rst   ), // [i] sw  sync reset, active high  
        .op_val   (op_val   ), // [i] input operands valid 
        .op_rdy   (op_rdy   ), // [o] input operands ready 
        .op_data  (op_data  ), // [i] input operands {x1,y1,x2,y2}
        .res_val  (res_val  ), // [o] output result valid 
        .res_rdy  (res_rdy  ), // [i] output result ready 
        .res_data (res_data )  // [o] output result {xr,yr}
        ); 
    end else if(NO_MULT == 1) begin : GEN_1_MULT
        comp_mult_1 #(
        .DWIDTH (DWIDTH) // data width
        )i_comp_mult_1 (
        .clk      (clk      ), // [i] system clock 
        .rst_n    (rst_n    ), // [i] hw async reset, active low 
        .sw_rst   (sw_rst   ), // [i] sw  sync reset, active high  
        .op_val   (op_val   ), // [i] input operands valid 
        .op_rdy   (op_rdy   ), // [o] input operands ready 
        .op_data  (op_data  ), // [i] input operands {x1,y1,x2,y2}
        .res_val  (res_val  ), // [o] output result valid 
        .res_rdy  (res_rdy  ), // [i] output result ready 
        .res_data (res_data )  // [o] output result {xr,yr}
        ); 
    end
    else begin : ERROR
        initial begin 
            $display("%M ERROR: Invalid number of multipliers, NO_MULT should be 1, 2 or 4 \n");
            $stop;
        end 
    end 
endgenerate 
 



endmodule // comp_mult_wrapper