//--------------------------------------------------------------------------------------------------------------------------------
// Project     : HDL - Complex Multiplier
// Module Name : comp_mult_top
// Author      : Feldioreanu George-Aurelian (FG)
// Created     : Mar 12, 2022
//--------------------------------------------------------------------------------------------------------------------------------
// Description : Configurable system for complex number multiplication 
//--------------------------------------------------------------------------------------------------------------------------------

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
input                        rf_wr       , // register file write enable 
input      [    REG_DW -1:0] rf_cfg      , // register file cfg data write 
output     [    REG_DW -1:0] rf_sts      , // register file sts data read 

// memory interface 
output reg                   mem_ce      , // chip enable (activ 1)
output reg                   mem_we      , // write enable (activ 1)
output reg [    SYS_AW -1:0] mem_addr    , // adresa
output reg [    DWIDTH -1:0] mem_wr_data , // date scrise 
input      [    DWIDTH -1:0] mem_rd_data   // date citite 
);

// ------------------------------------------------ local parameters -------------------------------------------------------------

// FSM states 
localparam IDLE   = 2'b00; // idle state 
localparam RD_OPS = 2'b01; // read ops from mem 
localparam WORK   = 2'b10; // wait for result 
localparam WR_RES = 2'b11; // write result


// ---------------------------------------- internal signal declaration ----------------------------------------------------------

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
wire                      sel_no_op     ; // number of operations                          
wire                      sel_cfg_start ; // filled start register (start: 'h0..01)
wire                      sel_sts_stop  ; // filled status         (done:  'h0..01) 
                          
// multiplier interface 
reg                       op_val        ; // operands valid 
wire                      op_rdy        ; // operands ready  
wire [   2*2*DWIDTH -1:0] op_data       ; // operands {x1,x2,y1,y2}          
wire                      res_val       ; // result valid                                            
reg                       res_rdy       ; // result ready                                            
wire [2*2*(DWIDTH+1)-1:0] res_data      ; // result {xr,yr}   

wire                      set_res_rdy   ; // res rdy set condition 

reg  [     3*DWIDTH -1:0] data_reg      ; // operands {x1,x2,y1}                  

// FSM signals
reg  [            2 -1:0] ctrl_state    ; // control FSM state 

wire                      byte_rd_done  ; // all bytes read 
wire                      byte_wr_done  ; // all bytes written                           
wire                      finish        ; // finish flag 
wire                      next_op       ; // next operand flag 


reg                       mem_ce_d      ; // delayed mem chip enable 
reg                       mem_we_d      ; // delayed mem write enable 

wire                      set_mem_ce    ; // mem chip enable s/r set condition 
wire                      set_mem_we    ; // mem write enable s/r set condition

reg  [            3 -1:0] byte_cnt      ; // offset byte counter 
                          
reg  [       REG_DW -1:0] op_cnt        ; // total operations counter
                          
                       
// ----------------------------------------- complex multiplier instance ---------------------------------------------------------

comp_mult_wrapper #(
.DWIDTH  (8       ), // data width
.NO_MULT (NO_MULT )  // number of multipliers used (1, 2 or 4)
) i_comp_mult_wrapper (
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


// ------------------------------------------------- reg logic -------------------------------------------------------------------


// register write selection based on offset from base address 
assign sel_op1_addr  = rf_wr & (rf_addr == RF_BADDR + 0); 
assign sel_op2_addr  = rf_wr & (rf_addr == RF_BADDR + 1); 
assign sel_res_addr  = rf_wr & (rf_addr == RF_BADDR + 2); 
assign sel_no_op     = rf_wr & (rf_addr == RF_BADDR + 3); 
assign sel_cfg_start = rf_wr & (rf_addr == RF_BADDR + 4); 
assign sel_sts_stop  = rf_wr & (rf_addr == RF_BADDR + 5);  

// op1 address register  
always @(posedge clk or negedge rst_n)
if(~rst_n)        op1_addr  <= 'd0            ; else  // hw async reset, active low 
if(sw_rst)        op1_addr  <= 'd0            ; else  // sw  sync reset, active high  
if(sel_op1_addr)  op1_addr  <= rf_cfg         ; else  // load data on register select 
if(byte_rd_done)  op1_addr  <= op1_addr + 'd2 ;

// op2 address register  
always @(posedge clk or negedge rst_n)
if(~rst_n)        op2_addr  <= 'd0            ; else // hw async reset, active low 
if(sw_rst)        op2_addr  <= 'd0            ; else // sw  sync reset, active high  
if(sel_op2_addr)  op2_addr  <= rf_cfg         ; else // load data on register select 
if(byte_rd_done)  op2_addr  <= op2_addr + 'd2 ;

// result address register  
always @(posedge clk or negedge rst_n)
if(~rst_n)        res_addr  <= 'd0            ; else // hw async reset, active low 
if(sw_rst)        res_addr  <= 'd0            ; else // sw  sync reset, active high  
if(sel_res_addr)  res_addr  <= rf_cfg         ; else // load data on register select 
if(byte_wr_done)  res_addr  <= res_addr + 'd6 ;

// operations number register
always @(posedge clk or negedge rst_n)
if(~rst_n)        no_op     <= 'd0    ; else        // hw async reset, active low 
if(sw_rst)        no_op     <= 'd0    ; else        // sw  sync reset, active high  
if(sel_no_op)     no_op     <= rf_cfg ;             // load data on register select 
                                                    
                                                    
always @(posedge clk or negedge rst_n)              
if(~rst_n)        cfg_start <= 'd0    ; else        // hw async reset, active low 
if(sw_rst)        cfg_start <= 'd0    ; else        // sw  sync reset, active high  
if(finish)        cfg_start <= 'd0    ; else        // clear on finish    
if(sel_cfg_start) cfg_start <= rf_cfg ;             // load data on register select 


always @(posedge clk or negedge rst_n)
if(~rst_n)        sts_stop <= 'd0                      ; else // hw async reset, active low 
if(sw_rst)        sts_stop <= 'd0                      ; else // sw  sync reset, active high  
if(sel_sts_stop)  sts_stop <= 'd0                      ; else // load data on register select (clear from CPU)
if(finish)        sts_stop <= {{REG_DW-1{1'b0}}, 1'b1} ;      // set LSB on finish 

// 1 status register, no need for addressing 
assign rf_sts = sts_stop;

// ---------------------------------------------------- FSM ----------------------------------------------------------------------

always @(posedge clk or negedge rst_n)
if(~rst_n) 
    ctrl_state <= IDLE;     // IDLE state on hw reset
else if(sw_rst)             
    ctrl_state <= IDLE;     // IDLE state on sw reset 
else begin 
    case(ctrl_state)
        IDLE    : if(cfg_start[0])         // transition to read operands on start bit 
                    ctrl_state <= RD_OPS;   
                  else
                    ctrl_state <= IDLE;
                    
        RD_OPS  : if(byte_rd_done)  
                    ctrl_state <= WORK;    // transition to wait result state on op read 
                  else 
                    ctrl_state <= RD_OPS;
                        
        WORK    : if(res_val)
                    ctrl_state <= WR_RES;  // transition to write result state on result val & rdy 
                  else 
                    ctrl_state <= WORK;
     // WR_RES                          
        default : if(finish) 
                    ctrl_state <= IDLE;    // transition to idle state when done 
                  else if(next_op)
                    ctrl_state <= RD_OPS;  // else transition to read operands for the next cycle
                  else 
                    ctrl_state <= WR_RES;
    endcase 
end   

// FSM inputs
assign byte_rd_done = (ctrl_state == RD_OPS) & (byte_cnt == 3'd3);  // flag active when all operands have been read 
assign byte_wr_done = (ctrl_state == WR_RES) & (byte_cnt == 3'd5);  // flag active when all result bytes have been written      
assign next_op      = byte_wr_done & (op_cnt != (no_op - 'd1));     // operation done, initiate next                                          
assign finish       = byte_wr_done & (op_cnt == (no_op - 'd1));     // all operations done


// read/write byte counter (TODO: parametrizable) 
always @(posedge clk or negedge rst_n)
if(~rst_n)          byte_cnt <= 3'd0            ; else // hw async reset, active low 
if(sw_rst)          byte_cnt <= 3'd0            ; else // sw  sync reset, active high  
if(byte_rd_done)    byte_cnt <= 3'd0            ; else // reset on all operands read 
if(byte_wr_done)    byte_cnt <= 3'd0            ; else // reset on all result bytes written 
if(mem_ce)          byte_cnt <= byte_cnt + 3'd1 ;      // increment on r/w 


// operations counter 
always @(posedge clk or negedge rst_n)
if(~rst_n)          op_cnt <= 'd0          ; else // hw async reset, active low 
if(sw_rst)          op_cnt <= 'd0          ; else // sw  sync reset, active high  
if(finish)          op_cnt <= 'd0          ; else // reset op count on done (all operations done)
if(next_op)         op_cnt <= op_cnt + 'd1 ;      // increment on operation done otherwise 



// ------------------------------------------- complex multiplier interface ------------------------------------------------------

// operands valid registers 
always @(posedge clk or negedge rst_n)
if(~rst_n)          op_val <= 1'b0; else  // hw async reset, active low 
if(sw_rst)          op_val <= 1'b0; else  // sw  sync reset, active high  
if(byte_rd_done)    op_val <= 1'b1; else  // set operand valid on read done 
if(op_val & op_rdy) op_val <= 1'b0;       // reset when operands are sampled 


// store first 3 operand bytes 
always @(posedge clk or negedge rst_n)
if(~rst_n)          data_reg <= 'd0; else  // hw async reset, active low 
if(sw_rst)          data_reg <= 'd0; else  // sw  sync reset, active high  
if(mem_ce_d & ~mem_we_d) begin             // on read 
    case(byte_cnt)
        3'b001 :    data_reg[3*DWIDTH-1 : 2*DWIDTH] <= mem_rd_data; // x1
        3'b010 :    data_reg[2*DWIDTH-1 : 1*DWIDTH] <= mem_rd_data; // y1
        3'b011 :    data_reg[1*DWIDTH-1 : 0       ] <= mem_rd_data; // x2
        default:    data_reg                        <= data_reg; 
    endcase 
end 

// operand data 
assign op_data = {data_reg, mem_rd_data}; // stored data concat with last byte {(x1, y1, x2), y2}


assign set_res_rdy = (ctrl_state == WR_RES) & (byte_cnt == 3'd4); // result ready set condition 

always @(posedge clk or negedge rst_n)
if(~rst_n)       res_rdy <= 1'b0; else  // hw async reset, active low 
if(sw_rst)       res_rdy <= 1'b0; else  // sw  sync reset, active high  
if(set_res_rdy)  res_rdy <= 1'b1; else  // set on above condition 
if(byte_wr_done) res_rdy <= 1'b0;       // reset when write done (next cycle)


// -------------------------------------------------- memory interface -----------------------------------------------------------

// compute memory address (TODO: parametrizable) 
// LITTLE ENDIAN 
always @(*) 
    if(ctrl_state == RD_OPS)
        if(byte_cnt < 3'd2) mem_addr = op1_addr + byte_cnt       ; else // if cnt  < 2, start from op1 base addr  
                            mem_addr = op2_addr + byte_cnt - 'd2 ;      // if cnt >= 2, start from op2 base addr, adjust offset 
    else // ctrl_state == WR_RES
                            mem_addr = res_addr + byte_cnt;             // start from res base addr (6 bytes)


// write data selection logic {xr, yr} (TODO: parametrizable) 
// data write begins on valid, result ready is asserted on last byte 
// LITTLE ENDIAN
always @(*)
    case(byte_cnt)
        3'b000  : mem_wr_data <= res_data[25:18];        // yr[ 7:0 ]         
        3'b001  : mem_wr_data <= res_data[33:26];        // yr[15:8 ]         
        3'b010  : mem_wr_data <= res_data[35:34] + 8'd0; // yr[17:16] filled  
        3'b011  : mem_wr_data <= res_data[ 7:0 ];        // xr[ 7:0 ]
        3'b100  : mem_wr_data <= res_data[15:8 ];        // xr[15:8 ]
        default : mem_wr_data <= res_data[17:16] + 8'd0; // xr[17:16] filled 
    endcase 


// mem chip enable set condition 
assign set_mem_ce = ((ctrl_state == IDLE)   & cfg_start[0]) |  // on   IDLE -> RD_OPS
                    ((ctrl_state == WR_RES) & next_op     ) |  // or WR_RES -> RD_OPS
                    ((ctrl_state == WORK)   & res_val     ) ;  // or   WORK -> WR_RES 

// mem chip enable set/reset register  
always @(posedge clk or negedge rst_n)
if(~rst_n)        mem_ce <= 1'b0; else // hw async reset, active low 
if(sw_rst)        mem_ce <= 1'b0; else // sw  sync reset, active high   
if(set_mem_ce)    mem_ce <= 1'b1; else // reset on above logic 
if(byte_rd_done | byte_wr_done) 
                  mem_ce <= 1'b0;      // reset on both read / write state done 


// mem write enable set condition
assign set_mem_we = (ctrl_state == WORK) & res_val; // set on WORK -> WR_RES 

always @(posedge clk or negedge rst_n)
if(~rst_n)        mem_we <= 1'b0; else    // hw async reset, active low 
if(sw_rst)        mem_we <= 1'b0; else    // sw  sync reset, active high   
if(set_mem_we)    mem_we <= 1'b1; else    // set on above condition
if(byte_wr_done)  mem_we <= 1'b0;         // reset when write done 


// mem chip enable delayed 1 cycle 
// (used in read data selection 1 cycle after read request)
always @(posedge clk or negedge rst_n)
if(~rst_n) mem_ce_d <= 1'b0   ; else      // hw async reset, active low 
if(sw_rst) mem_ce_d <= 1'b0   ; else      // sw  sync reset, active high   
           mem_ce_d <= mem_ce ;        
           
// mem write enable delayed 1 cycle 
// (used in read data selection to take place only on reads) 
always @(posedge clk or negedge rst_n)    
if(~rst_n) mem_we_d <= 1'b0   ; else      // hw async reset, active low 
if(sw_rst) mem_we_d <= 1'b0   ; else      // sw  sync reset, active high   
           mem_we_d <= mem_we ;


endmodule // comp_mult_top
