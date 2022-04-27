//---------------------------------------------------------------------------------------
// Project     : Complex numbers multiplier
// Module Name : complex_multiplier_test
// Author      : Dan NICULA (DN)
// Created     : Mar, 2, 2021
//---------------------------------------------------------------------------------------
// Description : Test environemnt for complex_multiplier
//---------------------------------------------------------------------------------------
// Modification history :
// Mar 2, 2021 (DN): Initial 
//---------------------------------------------------------------------------------------

module complex_multiplier_test ;
reg                     clk       ; // Semnal de ceas.
reg                     rst_n     ; // Reset asincron activ în 0. 
// Interfata cu operatorii
reg                     op_val    ; // Operanzi valizi.
wire                    op_rdy    ; // Este permisă primirea operanzilor.
reg   [2 * 2 * 8 - 1:0] op_data   ; // Operanzi (x1, y1, x2, y2) 2 * 2 * 8
// Interfata cu rezultatul
wire                    res_val   ; // Rezultat valid.
reg                     res_rdy   ; // Este acceptat rezultatul.
wire  [2 * 18    - 1:0] res_data  ; // Rezultatul (xr, yr)


reg        [2 * 2 * 8 - 1:0] operands_fifo [16   -1      :0];
reg        [3            :0] wr_ptr; 
reg        [3            :0] rd_ptr; 
reg signed [8         - 1:0] x1, y1, x2, y2 ;
reg signed [18        - 1:0] re;
reg signed [18        - 1:0] im;

initial begin
  clk <=  1'b0; 
  forever #5 clk <=  ~clk;
end

initial begin
  rst_n <=  1'b1;  
  @(posedge clk);
  rst_n <=  1'b0;
  @(posedge clk);
  @(posedge clk);
  rst_n <=  1'b1;  
  @(posedge clk);
end

task single_rq;
input [2 * 2 * 8  -1:0]  data_p     ;
input [10         -1:0]  break_p    ;
begin
  op_val      <=  1'b1;  
  op_data     <=  data_p;  
  operands_fifo[wr_ptr] <=  data_p;
  wr_ptr      <=  wr_ptr + 1; 
  @(posedge clk);
  while (~op_rdy)
    @(posedge clk);
  if (break_p != 'd0) begin
    op_val    <=  1'b0;  
    op_data   <=  'bx;  
    repeat (break_p)
      @(posedge clk);
  end
end
endtask

initial begin
  res_rdy    <=  1'b1;
  wr_ptr     <=  4'b0; 
  rd_ptr     <=  4'b0; 
  op_val     <=  1'b0;  
  op_data    <=  'bx;  
  @(posedge rst_n);
  
  // single_rq({x1, y1, x2, y2}, break);
  repeat (10) @(posedge clk);
  single_rq({8'd2, 8'd3, 8'd4, 8'd2}, 10) ; 
  repeat (1000) 
  single_rq($urandom, $urandom%5) ; 
    
  repeat (50) @(posedge clk);
  $display ("%M INFO: End of stimulus.");
  $stop;
end

always @(posedge clk)
if (res_val & res_rdy) begin
  {x1, y1, x2, y2} = operands_fifo[rd_ptr];
  re = x1 * x2 - y1 * y2;
  im = x1 * y2 + y1 * x2;
  rd_ptr <=  rd_ptr + 1;
  if (res_data !== {re, im}) begin
    $display("%M %0t ERROR: (%0d + %0di) * (%0d + %0di) = (%0d + %0di), expected (%0d + %0di)", $time,
    x1, y1, x2, y2, res_data[18+:18], res_data[0+:18], re, im);
    $stop;
  end
  else
    $display("%M %0t GOOD: (%0d + %0di) * (%0d + %0di) = (%0d + %0di)", $time,
      x1, y1, x2, y2, re, im);
end

vld_rdy_checker #(
.DATA_WIDTH       (2 * 2 * 8)
) i_src (     
.clk              (clk      ),
.rst_n            (rst_n    ),
.valid            (op_val   ),               
.ready            (op_rdy   ),               
.data             (op_data  )
);
vld_rdy_checker #(
.DATA_WIDTH       (2 * 18   )
) i_dst (     
.clk              (clk      ),
.rst_n            (rst_n    ),
.valid            (res_val  ),               
.ready            (res_rdy  ),               
.data             (res_data )
);

complex_multiplier i_complex_multiplier (
.clk       (clk     ),
.rst_n     (rst_n   ),
.op_val    (op_val  ),
.op_rdy    (op_rdy  ),
.op_data   (op_data ),
.res_val   (res_val ),
.res_rdy   (res_rdy ),
.res_data  (res_data)
);

endmodule // complex_multiplier_test