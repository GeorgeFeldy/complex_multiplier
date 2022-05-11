//---------------------------------------------------------------------
// Project     : HDL - Complex Multiplier
// Module Name : comp_mult_data_checker 
// Author      : Feldioreanu George-Aurelian (FG)
// Created     : Mar 12, 2022
//---------------------------------------------------------------------
// Description : Reference model for complex multiplier, based on DN  
//---------------------------------------------------------------------

module comp_mult_data_checker #(
parameter DWIDTH = 8
)(
// system IF                       
input                         clk          , // system clock 
input                         rst_n        , // hw async reset, active low 
input                         sw_rst       , // sw  sync reset, active high  
                                                 
// input operands val-rdy IF                     
input                         op_val       , // input operands valid 
input                         op_rdy       , // input operands ready 
input [      2*2*DWIDTH -1:0] op_data      , // input operands {x1, y1, x2, y2}
                                               
// output results val-rdy IF                   
input                         sample       , // output result valid 
                                           
input [2*2*(DWIDTH + 1) -1:0] res_data_4   ,  // output result {xr,yr}
input [2*2*(DWIDTH + 1) -1:0] res_data_2   ,  // output result {xr,yr}
input [2*2*(DWIDTH + 1) -1:0] res_data_1      // output result {xr,yr}
// input [2*2*(DWIDTH + 1) -1:0] res_data_ref ,  // output result {xr,yr}


// output  [2*2*(DWIDTH + 1) -1:0] exp_res_data   // expected output result {xr,yr}
); 

reg         [  2*2*DWIDTH -1:0] operands_fifo [64-1:0];
reg         [           6 -1:0] wr_ptr; 
reg         [           6 -1:0] rd_ptr;


wire signed [2*(DWIDTH+1) -1:0] dut_xr_4;
wire signed [2*(DWIDTH+1) -1:0] dut_yr_4;

wire signed [2*(DWIDTH+1) -1:0] dut_xr_2;
wire signed [2*(DWIDTH+1) -1:0] dut_yr_2;

wire signed [2*(DWIDTH+1) -1:0] dut_xr_1;
wire signed [2*(DWIDTH+1) -1:0] dut_yr_1;
                    
reg signed  [      DWIDTH -1:0] l_x1, l_y1, l_x2, l_y2 ; //local operands 
reg signed  [2*(DWIDTH+1) -1:0] l_xr; // local real result 
reg signed  [2*(DWIDTH+1) -1:0] l_yr; // local imaginary result 

assign dut_xr_4 = res_data_4[2*(DWIDTH+1)+:2*(DWIDTH+1)];
assign dut_yr_4 = res_data_4[           0+:2*(DWIDTH+1)];

assign dut_xr_2 = res_data_2[2*(DWIDTH+1)+:2*(DWIDTH+1)];
assign dut_yr_2 = res_data_2[           0+:2*(DWIDTH+1)];

assign dut_xr_1 = res_data_1[2*(DWIDTH+1)+:2*(DWIDTH+1)];
assign dut_yr_1 = res_data_1[           0+:2*(DWIDTH+1)];


always @(posedge clk or negedge rst_n)
if(~rst_n) begin 
    wr_ptr <= 'd0;
    rd_ptr <= 'd0;
end else 
if(sw_rst) begin 
    wr_ptr <= 'd0;
    rd_ptr <= 'd0;
end 

always @(posedge clk)
if(op_val & op_rdy) begin 
    operands_fifo[wr_ptr] <= op_data;
    wr_ptr <= wr_ptr + 'd1;
end 

always @(posedge clk)
if(sample) begin 
    {l_x1, l_y1, l_x2, l_y2} = operands_fifo[rd_ptr]; // blocking assignment 
    l_xr = l_x1 * l_x2 - l_y1 * l_y2;
    l_yr = l_x1 * l_y2 + l_y1 * l_x2;
    rd_ptr <= rd_ptr + 'd1;
    if ((dut_xr_4 !== l_xr) | (dut_yr_4 !== l_yr)) begin
        $display("%M %0t COMP_MULT_4 ERROR: (%0d + %0di) * (%0d + %0di) = (%0d + %0di), expected (%0d + %0di)", $time,
        l_x1, l_y1, l_x2, l_y2, dut_xr_4, dut_yr_4, l_xr,l_yr);     
        $stop;
    end 
    else if ((dut_xr_2 !== l_xr) | (dut_yr_2 !== l_yr)) begin
        $display("%M %0t COMP_MULT_2 ERROR: (%0d + %0di) * (%0d + %0di) = (%0d + %0di), expected (%0d + %0di)", $time,
        l_x1, l_y1, l_x2, l_y2, dut_xr_2, dut_yr_2, l_xr,l_yr);     
        $stop;
    end 
    else if ((dut_xr_1 !== l_xr) | (dut_yr_1 !== l_yr)) begin
        $display("%M %0t COMP_MULT_1 ERROR: (%0d + %0di) * (%0d + %0di) = (%0d + %0di), expected (%0d + %0di)", $time,
        l_x1, l_y1, l_x2, l_y2, dut_xr_1, dut_yr_1, l_xr,l_yr);     
        $stop;
    end 
    else
        $display("%M %0t GOOD: (%0d + %0di) * (%0d + %0di) = (%0d + %0di), same as expected (%0d + %0di)", $time,
         l_x1, l_y1, l_x2, l_y2, dut_xr_4, dut_yr_4, l_xr,l_yr);
end 




endmodule // comp_mult_data_checker