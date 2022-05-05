//---------------------------------------------------------------------------------------
// Project     : General purpose
// Module Name : vld_rdy_checker
// Author      : Dan NICULA (DN)
// Created     : Mar, 2, 2021
//---------------------------------------------------------------------------------------
// Description : Valid-ready checker
//---------------------------------------------------------------------------------------
// Modification history :
// Mar 2, 2021 (DN): Initial 
//---------------------------------------------------------------------------------------

module vld_rdy_checker #(
parameter  DATA_WIDTH       = 24    // Data width;
)     
(     
input                     clk     , // System clock;                                                  
input                     rst_n   , // Asynchronous reset, active low;                                
                          
input                     ready   , // frame ready                                                                          
input                     valid   , // frame valid                                                                          
input [DATA_WIDTH - 1: 0] data      // cfg nr of bits using DATA_WIDTH parameter, Pixel read chanel bus;  
);

reg                             ready_del                 ;
reg                             valid_del                 ;
reg [DATA_WIDTH - 1: 0]         data_del                  ;

wire                            initialize                ;
reg                             before_hw_rst             ;

assign initialize = before_hw_rst ? 1'b1 : (~rst_n) ;


initial begin
before_hw_rst = 1'b1;
@(negedge rst_n);
@(posedge rst_n);
@(posedge clk);
before_hw_rst = 1'b0;
end

// 1 cycle delayed
always @(posedge clk)
if (initialize) begin
  ready_del <=  1'b0                 ;
  valid_del <=  1'b0                 ;
  data_del  <=  {DATA_WIDTH{1'b0}}   ;
end
else begin
  ready_del <=  ready    ;
  valid_del <=  valid    ;
  data_del  <=  data     ;
end

always @(posedge clk or negedge rst_n)
if (~before_hw_rst) begin
  // [ ] valid != 0 or 1
  if ((valid !== 1'b0) & (valid !== 1'b1)) begin
    $display("%M %0t VLD-RDY ERROR: VLD = x.", $time);
    $stop;
  end
  // [ ] ready != 0 or 1
  if ((ready !== 1'b0) & (ready !== 1'b1)) begin
    $display("%M %0t VLD-RDY ERROR: READY = x.", $time);
    $stop;
  end
  
  // [ ] vld    --|__
  //     ready  __|xx
  if (valid_del & ~valid & ~ready_del ) begin
    $display("%M %0t VLD-RDY ERROR: VALID deactivated wrong.", $time);
    $stop;
  end
  
  // [ ] vld    -----
  //     ready  _____
  //     data    __|--
  if (valid_del & valid & ~ready_del & (data !== data_del)) begin
    $display("%M %0t VLD-RDY ERROR: DATA changed during VALID without RDY.", $time);
    $stop;
  end  
end

endmodule // vld_rdy_checker
