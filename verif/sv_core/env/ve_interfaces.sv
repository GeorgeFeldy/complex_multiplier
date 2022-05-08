
interface rst_intf(input wire clk);

    logic rst_n  ;
    logic sw_rst ;

   clocking drv_cb@(posedge clk);
      output rst_n;
      output sw_rst;
   endclocking
   modport drv(clocking drv_cb, input clk);
   
   clocking rcv_cb@(posedge clk);
      input rst_n;
      input sw_rst;
   endclocking
   modport rcv(clocking rcv_cb, input clk);

   clocking mon_cb@(posedge clk);
      input rst_n;
      input sw_rst;
   endclocking
   modport mon(clocking mon_cb, input clk);

endinterface: rst_intf


interface op_intf #(
parameter DWIDTH = 8
)(input wire clk);

   logic                  op_val  ;
   logic                  op_rdy  ;
   logic [2*2*DWIDTH-1:0] op_data ;


   clocking drv_cb @(posedge clk);
       output op_val  ;
       input  op_rdy  ;
       output op_data ;
   endclocking
   modport drv(clocking drv_cb, input clk);


   clocking mon_cb @(posedge clk);
       input  op_val  ;
       input  op_rdy  ;
       input  op_data ;
   endclocking
   modport mon(clocking mon_cb, input clk);

endinterface : op_intf


interface res_intf #(
parameter DWIDTH = 8
)(input wire clk);

   logic                      res_val  ;
   logic                      res_rdy  ;
   logic [2*2*(DWIDTH+1)-1:0] res_data ;


   clocking drv_cb @(posedge clk);
      input  res_val  ; 
      output res_rdy  ; 
      input  res_data ;
   endclocking
   modport drv(clocking drv_cb, input clk);


   clocking mon_cb @(posedge clk);
      input res_val  ;
      input res_rdy  ;
      input res_data ;
   endclocking
   modport mon(clocking mon_cb, input clk);
   
endinterface : res_intf
