//---------------------------------------------------------------------
// Project     : HDL - Complex Multiplier
// Module Name : comp_mult_top
// Author      : Feldioreanu George-Aurelian (FG)
// Created     : Mar 12, 2022
//---------------------------------------------------------------------------------------------
// Description : Configurable system for complex number multiplication 
//---------------------------------------------------------------------------------------------

module comp_mult_top #(
parameter DWIDTH   = 8     , // operand element data width
parameter NO_MULT  = 4     , // number of multipliers used (1, 2 or 4)
parameter RF_BADDR = 0     , // register file base address in system  
parameter SYS_AW   = 32    , // system address width 
parameter REG_DW   = 32      // register file data width 
)(
input                        clk         , // system clock 
input                        rst_n       , // hw async reset, active low 
input                        sw_rst      , // sw  sync reset, active high  
                                    
// registers interface                                     
input      [    SYS_AW -1:0] rf_addr     , // register file r/w address
input                        rf_wr       , // register file write enable (0 for read)
input      [    REG_DW -1:0] rf_cfg      , // register file cfg data write 
output     [    REG_DW -1:0] rf_sts      , // register file sts data read 

// memory interface 
output                       mem_ce      , // chip enable (activ 1)
output                       mem_we      , // write enable (activ 1)
output reg [    SYS_AW -1:0] mem_addr    , // adresa
output reg [    DWIDTH -1:0] mem_wr_data , // date scrise 
input      [    DWIDTH -1:0] mem_rd_data   // date citite 
);

// ------------------------------ --------------------------------------------

// FSM states 
localparam IDLE   = 2'b00; // idle state 
localparam RD_OPS = 2'b01; // read ops from mem 
localparam WORK   = 2'b10; // wait for result 
localparam WR_RES = 2'b11; // write result


// ---------------------------------- --------------------------------------------

// registers 
reg  [       REG_DW -1:0] op1_addr      ; // operand 1 current read address
reg  [       REG_DW -1:0] op2_addr      ; // operand 2 current read address
reg  [       REG_DW -1:0] res_addr      ; // result current write address
reg  [       REG_DW -1:0] no_op         ; // number of operations (max                                   
reg  [       REG_DW -1:0] cfg_start     ; // filled start register (start: 'h0..01)
reg  [       REG_DW -1:0] sts_stop      ; // filled status         (done:  'h0..01) 
             
// register load flags              
wire                      sel_op1_addr  ; // operand 1 current read address
wire                      sel_op2_addr  ; // operand 2 current read address
wire                      sel_res_addr  ; // result current write address
wire                      sel_no_op     ; // number of operations (max (2^SYS_AW / 4) operations)                                   
wire                      sel_cfg_start ; // filled start register (start: 'h0..01)
wire                      sel_sts_stop  ; // filled status         (done:  'h0..01) 
                          
// multiplier interface 
reg                       op_val        ; // operands valid 
wire                      op_rdy        ; // operands ready  
reg  [   2*2*DWIDTH -1:0] op_data       ; // operands {x1,x2,y1,y2}          
wire                      res_val       ; // result valid                                            
wire                      res_rdy       ; // result ready                                            
wire [2*2*(DWIDTH+1)-1:0] res_data      ; // result {xr,yr}                   

// fsm signals
reg  [            2 -1:0] ctrl_state    ; // control FSM state 

wire                      res_val_rdy   ; // result valid & ready 
wire                      byte_rd_done  ; // all bytes read 
wire                      byte_wr_done  ; // all bytes written                           
wire                      finish        ; // finish flag 
wire                      next_op       ; // next operand flag 

reg  [            3 -1:0] byte_cnt      ;
                          
reg  [       REG_DW -1:0] op_cnt        ; // operations counter
                          
                          
// ---------------------------------complex multiplier instance --------------------

comp_mult_wrapper #(
.DWIDTH  (8       ), // data width
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


// --------------------------------- reg logic ----------------------------------

assign sel_op1_addr  = rf_wr & (rf_addr == RF_BADDR + 0);
assign sel_op2_addr  = rf_wr & (rf_addr == RF_BADDR + 1);
assign sel_res_addr  = rf_wr & (rf_addr == RF_BADDR + 2);
assign sel_no_op     = rf_wr & (rf_addr == RF_BADDR + 3);
assign sel_cfg_start = rf_wr & (rf_addr == RF_BADDR + 4);
assign sel_sts_stop  = rf_wr & (rf_addr == RF_BADDR + 5);  


always @(posedge clk or negedge rst_n)
if(~rst_n)        op1_addr  <= 'd0            ; else 
if(sw_rst)        op1_addr  <= 'd0            ; else 
if(sel_op1_addr)  op1_addr  <= rf_cfg         ; else
if(res_val_rdy)   op1_addr  <= op1_addr + 'd1 ;


always @(posedge clk or negedge rst_n)
if(~rst_n)        op2_addr  <= 'd0            ; else 
if(sw_rst)        op2_addr  <= 'd0            ; else 
if(sel_op2_addr)  op2_addr  <= rf_cfg         ; else
if(res_val_rdy)   op2_addr  <= op1_addr + 'd1 ;


always @(posedge clk or negedge rst_n)
if(~rst_n)        res_addr  <= 'd0            ; else 
if(sw_rst)        res_addr  <= 'd0            ; else 
if(sel_res_addr)  res_addr  <= rf_cfg         ; else
if(res_val_rdy)   res_addr  <= res_addr + 'd1 ;


always @(posedge clk or negedge rst_n)
if(~rst_n)        no_op     <= 'd0    ; else 
if(sw_rst)        no_op     <= 'd0    ; else 
if(sel_no_op)     no_op     <= rf_cfg ; 


always @(posedge clk or negedge rst_n)
if(~rst_n)        cfg_start <= 'd0    ; else 
if(sw_rst)        cfg_start <= 'd0    ; else 
if(finish)        cfg_start <= 'd0    ; else    
if(sel_cfg_start) cfg_start <= rf_cfg ; 


always @(posedge clk or negedge rst_n)
if(~rst_n)        sts_stop <= 'd0                      ; else 
if(sw_rst)        sts_stop <= 'd0                      ; else 
if(sel_sts_stop)  sts_stop <= 'd0                      ; else 
if(finish)        sts_stop <= {{REG_DW-1{1'b0}}, 1'b1} ; 

assign rf_sts = sts_stop;

// --------------------------------- fsm  ----------------------------------

always @(posedge clk or negedge rst_n)
if(~rst_n) 
    ctrl_state <= IDLE; 
else if(sw_rst) 
    ctrl_state <= IDLE; 
else begin 
    case(ctrl_state)
        IDLE    : if(cfg_start[0]) 
                    ctrl_state <= RD_OPS;   
                  else
                    ctrl_state <= IDLE;
                    
        RD_OPS  : if(byte_rd_done)  
                    ctrl_state <= WORK;
                  else 
                    ctrl_state <= RD_OPS;
                        
        WORK    : if(res_val_rdy)
                    ctrl_state <= WR_RES;
                  else 
                    ctrl_state <= WORK;
     // WR_RES                          
        default : if(finish) 
                    ctrl_state <= IDLE;
                  else if(next_op)
                    ctrl_state <= RD_OPS;
                  else 
                    ctrl_state <= WR_RES;
    endcase 
end   

assign res_val_rdy  = res_val & res_rdy;
assign byte_rd_done = (ctrl_state == RD_OPS) & (byte_cnt == 3'd3); 
assign byte_wr_done = (ctrl_state == WR_RES) & (byte_cnt == 3'd5); 
assign next_op      = byte_wr_done & (op_cnt != (no_op - 'd1));                                             
assign finish       = byte_wr_done & (op_cnt == (no_op - 'd1));


// TODO parametrizable 
always @(posedge clk or negedge rst_n)
if(~rst_n)               byte_cnt <= 3'd0            ; else
if(sw_rst)               byte_cnt <= 3'd0            ; else
if((ctrl_state == IDLE) | (ctrl_state == WORK)) 
                         byte_cnt <= 3'd0            ; else 
if((ctrl_state == RD_OPS) | (ctrl_state == WR_RES)) 
                         byte_cnt <= byte_cnt + 3'd1 ; 


always @(posedge clk or negedge rst_n)
if(~rst_n)  op_cnt <= 'd0          ; else
if(sw_rst)  op_cnt <= 'd0          ; else
if(finish)  op_cnt <= 'd0          ; else 
if(next_op) op_cnt <= op_cnt + 'd1 ;


// TODO parametrizable 
always @(*) 
    if(ctrl_state == RD_OPS)
        if(byte_cnt < 3'd2) mem_addr = op1_addr + byte_cnt; else // if cnt  < 2 
                            mem_addr = op2_addr + byte_cnt;      // if cnt >= 2
    else // WR case (+ default)
                            mem_addr = res_addr + byte_cnt; 


// TODO parametrizable 
always @(*)
    case(byte_cnt)
        3'b000  : mem_wr_data <= res_data[ 7:0 ];        //  7:0          
        3'b001  : mem_wr_data <= res_data[15:8 ];        // 15:8
        3'b010  : mem_wr_data <= res_data[17:16] + 8'd0; // 17:16 filled
        3'b011  : mem_wr_data <= res_data[25:18];        // 25:18
        3'b100  : mem_wr_data <= res_data[33:26];        // 33:26
        default : mem_wr_data <= res_data[35:34] + 8'd0; // 35:34 filled 
    endcase 

assign mem_ce = (ctrl_state == RD_OPS) |
                (ctrl_state == WR_RES) ;


assign mem_we = (ctrl_state == WR_RES) ;


always @(posedge clk or negedge rst_n)
if(~rst_n)          op_val <= 1'b0; else 
if(sw_rst)          op_val <= 1'b0; else 
if(byte_rd_done)    op_val <= 1'b1; else 
if(op_val & op_rdy) op_val <= 1'b0; 


always @(posedge clk or negedge rst_n)
if(~rst_n)          op_data <= 'd0; else 
if(sw_rst)          op_data <= 'd0; else 
if(ctrl_state == RD_OPS) begin 
    case(byte_cnt)
        2'b00  :    op_data[4*DWIDTH-1-:DWIDTH] <= mem_rd_data; 
        2'b01  :    op_data[3*DWIDTH-1-:DWIDTH] <= mem_rd_data; 
        2'b10  :    op_data[2*DWIDTH-1-:DWIDTH] <= mem_rd_data; 
        default:    op_data[1*DWIDTH-1-:DWIDTH] <= mem_rd_data; 
    endcase 
end 


assign res_rdy = 1'b1;


endmodule // comp_mult_top
