//---------------------------------------------------------------------
// Project     : HDL - Complex Multiplier
// Module Name : comp_mult_1
// Author      : Feldioreanu George-Aurelian (FG)
// Created     : Mar 12, 2022
//---------------------------------------------------------------------
// Description : Complex multiplier, using 1 uint8 multiplier instance 
//---------------------------------------------------------------------

module comp_mult_1 #(
parameter DWIDTH = 8 // data width
)(
input                              clk      , // system clock 
input                              rst_n    , // hw async reset, active low 
input                              sw_rst   , // sw  sync reset, active high  
                                  
// input operands val-rdy IF      
input                              op_val   , // input operands valid 
output reg                         op_rdy   , // input operands ready 
input      [      2*2*DWIDTH -1:0] op_data  , // input operands {x1,y1,x2,y2}

// output results val-rdy IF  
output reg                         res_val  , // output result valid 
input                              res_rdy  , // output result ready 
output     [2*2*(DWIDTH + 1) -1:0] res_data   // output result {xr,yr}
); 

wire op_ld    ; // load products output registers 
reg  op_ld_d1 ; // load products output registers, delayed 1 cycle  
reg  op_ld_d2 ; // load products output registers, delayed 2 cycles
reg  op_ld_d3 ; // load products output registers, delayed 3 cycles
reg  op_ld_d4 ; // load products output registers, delayed 4 cycles

// input operands
reg  [  DWIDTH -1:0] x1 ; // op1, real part, stored in reg 
reg  [  DWIDTH -1:0] x2 ; // op2, real part, stored in reg 
reg  [  DWIDTH -1:0] y1 ; // op1, imaginary part, stored in reg 
reg  [  DWIDTH -1:0] y2 ; // op2, imaginary part, stored in reg 

wire [2*DWIDTH -1:0] x1_ext ; // sign extended op1, real part
wire [2*DWIDTH -1:0] x2_ext ; // sign extended op2, real part 
wire [2*DWIDTH -1:0] y1_ext ; // sign extended op1, imaginary part
wire [2*DWIDTH -1:0] y2_ext ; // sign extended op2, imaginary part


reg  [2*DWIDTH -1:0] mult_op1 ; // multiplier first  operand 
reg  [2*DWIDTH -1:0] mult_op2 ; // multiplier second operand 

wire [4*DWIDTH -1:0] prod_ext ; // extended output of multiplier

wire [2*DWIDTH -1:0] prod     ; // truncated signed output of multiplier 


reg  [2*DWIDTH -1:0] prod_1_reg ; // stores output of   (x1 * x2), ignores overflow 
reg  [2*DWIDTH -1:0] xr         ; // stores (x1 * x2) - (y1 * y2), ignores overflow
reg  [2*DWIDTH -1:0] prod_3_reg ; // stores output of   (x2 * y1), ignores overflow
reg  [2*DWIDTH -1:0] yr         ; // stores (x1 * y2) + (x2 * y1), ignores overflow
                   
// ----------------------------------- control path  ------------------------------

always @(posedge clk or negedge rst_n)
if(~rst_n)            op_rdy <= 1'b1 ; else
if(sw_rst)            op_rdy <= 1'b1 ; else
if(op_val & op_rdy)   op_rdy <= 1'b0 ; else 
if(res_val & res_rdy) op_rdy <= 1'b1 ; 
  
  
assign op_ld = op_val & op_rdy;


always @(posedge clk or negedge rst_n)
if(~rst_n) begin 
    op_ld_d1 <= 1'b0;
    op_ld_d2 <= 1'b0;
    op_ld_d3 <= 1'b0;
    op_ld_d4 <= 1'b0;
end else 
if(sw_rst) begin 
    op_ld_d1 <= 1'b0;
    op_ld_d2 <= 1'b0;
    op_ld_d3 <= 1'b0;
    op_ld_d4 <= 1'b0;
end else begin                        
    op_ld_d1 <= op_ld;    // will compute x1 * x2 
    op_ld_d2 <= op_ld_d1; // will compute y1 * y2 
    op_ld_d3 <= op_ld_d2; // will compute x1 * y2
    op_ld_d4 <= op_ld_d3; // will compute x2 * y1
end 

 
always @(posedge clk or negedge rst_n)
if(~rst_n)    res_val <= 1'b0 ; else // hw reset 
if(sw_rst)    res_val <= 1'b0 ; else // sw reset
if(op_ld_d4)  res_val <= 1'b1 ; else // set on new operand (prioritary)
if(res_rdy)   res_val <= 1'b0 ;      // reset on output transaction (val & rdy) (and no new data) 


// ----------------------------------- data path  ---------------------------------


// {x1 ,y1 x2 ,y2}   
always @(posedge clk or negedge rst_n)
if(~rst_n) begin 
    x1 <= 'd0;
    y1 <= 'd0;
    x2 <= 'd0;
    y2 <= 'd0;
end else 
if(sw_rst) begin 
    x1 <= 'd0;
    y1 <= 'd0;
    x2 <= 'd0;
    y2 <= 'd0;
end else 
if(op_ld) begin                        
    x1 <= op_data[4*DWIDTH -1 -: DWIDTH]; 
    y1 <= op_data[3*DWIDTH -1 -: DWIDTH]; 
    x2 <= op_data[2*DWIDTH -1 -: DWIDTH]; 
    y2 <= op_data[1*DWIDTH -1 -: DWIDTH]; 
end 


assign x1_ext = {{DWIDTH{x1[DWIDTH-1]}},x1}; // extend sign for x1 operand
assign x2_ext = {{DWIDTH{x2[DWIDTH-1]}},x2}; // extend sign for x2 operand
assign y1_ext = {{DWIDTH{y1[DWIDTH-1]}},y1}; // extend sign for y1 operand
assign y2_ext = {{DWIDTH{y2[DWIDTH-1]}},y2}; // extend sign for y2 operand

always @(*)
case({op_ld_d1, op_ld_d2, op_ld_d3, op_ld_d4})
4'b1000: mult_op1 = x1_ext ;
4'b0100: mult_op1 = y1_ext ;
4'b0010: mult_op1 = x1_ext ;
4'b0001: mult_op1 = x2_ext ;
default: mult_op1 = 'd0    ;
endcase 

always @(*)
case({op_ld_d1, op_ld_d2, op_ld_d3, op_ld_d4})
4'b1000: mult_op2 = x2_ext ;
4'b0100: mult_op2 = y2_ext ;
4'b0010: mult_op2 = y2_ext ;
4'b0001: mult_op2 = y1_ext ;
default: mult_op2 = 'd0    ;
endcase

uint8_mult #(
.DWIDTH (2*DWIDTH) // data width, doubled for sign extension 
)i_uint8_mult_0(
 .op1    (mult_op1), // [i] sign extended first  operand 
 .op2    (mult_op2), // [i] sign extended second operand 
 .result (prod_ext)  // [o] product 
);  


assign prod = prod_ext[2*DWIDTH-1:0]; // trucate to 2 x original width for signed product 


// temp reg of prod 1 
always @(posedge clk or negedge rst_n)
if(~rst_n)   prod_1_reg <= 'b0 ; else 
if(sw_rst)   prod_1_reg <= 'b0 ; else 
if(op_ld_d1) prod_1_reg <= prod;          // store x1 * x2 

// real part result (prod1 - prod2) 
always @(posedge clk or negedge rst_n)
if(~rst_n)   xr <= 'b0              ; else 
if(sw_rst)   xr <= 'b0              ; else 
if(op_ld_d2) xr <= prod_1_reg - prod;     // x1 * x2 - y1 * y2

// temp reg of prod 3 
always @(posedge clk or negedge rst_n)
if(~rst_n)   prod_3_reg <= 'b0 ; else 
if(sw_rst)   prod_3_reg <= 'b0 ; else 
if(op_ld_d3) prod_3_reg <= prod;          // store x1 * y2  

// imaginary part result (prod3 - prod4) 
always @(posedge clk or negedge rst_n)
if(~rst_n)   yr <= 'b0              ; else 
if(sw_rst)   yr <= 'b0              ; else 
if(op_ld_d4) yr <= prod_3_reg + prod;      // x1 * y2 + x2 * y1


assign res_data = {{{'d2{xr[2*DWIDTH-1]}},xr},
                   {{'d2{yr[2*DWIDTH-1]}},yr}}; // concatenate with sign extension


endmodule // comp_mult_1