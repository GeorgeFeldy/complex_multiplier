//---------------------------------------------------------------------
// Project     : HDL - Complex Multiplier
// Module Name :  comp_mult_top_test
// Author      : Feldioreanu George-Aurelian (FG)
//---------------------------------------------------------------------
// 
//---------------------------------------------------------------------

module comp_mult_top_test; 

localparam DWIDTH   = 8    ; // operand element data width
localparam NO_MULT  = 4    ; // number of multipliers used (1, 2 or 4)
localparam RF_BADDR = 0    ; // register file base address in system  
localparam SYS_AW   = 16   ; // system address width 
localparam REG_DW   = 32   ; // register file data width 

localparam OP1_BA   = 100 ;
localparam OP2_BA   = 200 ;
localparam RES_BA   = 300 ;
localparam NR_OP    = 10  ;
                    
localparam EXP_RES_BA = 400;

localparam VERBOSE = 1;

wire                clk         ; // system clock 
wire                rst_n       ; // hw async reset, active low 
reg                 sw_rst      ; // sw  sync reset, active high                
reg   [SYS_AW -1:0] rf_addr     ; // register file r/w address
reg                 rf_wr       ; // register file write enable (0 for read)
reg   [REG_DW -1:0] rf_cfg      ; // register file cfg data write 
wire  [REG_DW -1:0] rf_sts      ; // register file sts data read 
wire                mem_ce      ; // chip enable (activ 1)
wire                mem_we      ; // write enable (activ 1)
wire  [SYS_AW -1:0] mem_addr    ; // adresa
wire  [DWIDTH -1:0] mem_wr_data ; // date scrise 
wire  [DWIDTH -1:0] mem_rd_data ; // date citite 

integer i;  // iter idx 
integer fb; // file binary


initial begin 
    rf_addr <= 'd0;
    rf_wr   <= 'd0;
    rf_cfg  <= 'd0;
end 


initial begin 
    sw_rst = 1'b0;
    @(posedge rst_n);
    @(posedge clk);
    repeat(3) @(posedge clk);
    sw_rst = 1'b1; 
    repeat(5) @(posedge clk);
    sw_rst = 1'b0;
end 

initial begin 
    @(negedge sw_rst);
    repeat(2) @(posedge clk);
    
    rf_wr   <= 1'b1;
    
    rf_addr <= RF_BADDR; // op1 addr 
    rf_cfg  <= OP1_BA;
    @(posedge clk);
    
    rf_addr <= RF_BADDR+1; // op2 addr 
    rf_cfg  <= OP2_BA;
    @(posedge clk);
    
    rf_addr <= RF_BADDR+2; // res addr 
    rf_cfg  <= RES_BA;
    @(posedge clk);
    
    rf_addr <= RF_BADDR+3; // res addr 
    rf_cfg  <= NR_OP;
    @(posedge clk);
    
    rf_addr <= RF_BADDR+4; // res addr 
    rf_cfg  <= 32'd1;
    @(posedge clk);
    
    rf_wr <= 1'b0;
    
    @(posedge rf_sts[0]);
    
    for(i = 0; i < NR_OP*6; i = i + 1) begin 
        if(i_mem_1rw.mem[RES_BA + i] == i_mem_1rw.mem[EXP_RES_BA + i])
            $display("OP %0d ----- OK    , %0h == %0h", i/6, i_mem_1rw.mem[RES_BA + i], i_mem_1rw.mem[EXP_RES_BA + i]);
        else 
            $display("OP %0d ----- FAILED, %0h != %0h", i/6, i_mem_1rw.mem[RES_BA + i], i_mem_1rw.mem[EXP_RES_BA + i]);
    end 
    
    fb = $fopen("../deb_src/mem.raw", "rb+");
    if($fseek(fb, RES_BA, 0) == -1) $display("ERROR: fseek");
    
    for(i = RES_BA; i < RES_BA + NR_OP*6; i = i + 1) begin 
        
        $fwrite(fb, "%c", i_mem_1rw.mem[i]);
    
    end 

    $fclose(fb);
    
    $display("END SIM");
    $stop;
    
end 

comp_mult_top #(
.DWIDTH      (DWIDTH     ), // [p] operand element data width
.NO_MULT     (NO_MULT    ), // [p] number of multipliers used (1, 2 or 4)
.RF_BADDR    (RF_BADDR   ), // [p] register file base address in system  
.SYS_AW      (SYS_AW     ), // [p] system address width 
.REG_DW      (REG_DW     )  // [p] register file data width 
) DUT_comp_mult_top (
.clk         (clk        ), // [i] system clock 
.rst_n       (rst_n      ), // [i] hw async reset, active low 
.sw_rst      (sw_rst     ), // [i] sw  sync reset, active high                                   
.rf_addr     (rf_addr    ), // [i] register file r/w address
.rf_wr       (rf_wr      ), // [i] register file write enable (0 for read)
.rf_cfg      (rf_cfg     ), // [i] register file cfg data write 
.rf_sts      (rf_sts     ), // [o] register file sts data read 
.mem_ce      (mem_ce     ), // [o] chip enable (activ 1)
.mem_we      (mem_we     ), // [o] write enable (activ 1)
.mem_addr    (mem_addr   ), // [o] adresa
.mem_wr_data (mem_wr_data), // [o] date scrise 
.mem_rd_data (mem_rd_data)  // [i] date citite 
);


mem_1rw #(
.ADDR_WIDTH  (SYS_AW      ),
.MEM_DEPTH   (2 ** SYS_AW ),  // MEM_DEPTH <= 2^ADDR_WIDTH
.WORD_BYTES  (1           )   // latimea datelor (biti) = 8 * WORD_BYTES
) i_mem_1rw (
.clk         (clk         ), // ceas (front pozitiv)
.ce          (mem_ce      ), // chip enable (activ 1)
.we          (mem_we      ), // write enable (activ 1)
.addr        (mem_addr    ), // adresa
.wr_data     (mem_wr_data ), // date scrise
.be          (1'b1        ), // byte enable, (activ 1)
.rd_data     (mem_rd_data )  // date citite
);

comp_mult_ref_model #(
.DWIDTH  (DWIDTH  ), // data width
.VERBOSE (VERBOSE )  // display passed 
) i_comp_mult_ref_model (
// system IF 
.clk          (clk                                            ), // [i] system clock 
.rst_n        (rst_n                                          ), // [i] hw async reset, active low 
.sw_rst       (sw_rst                                         ), // [i] sw  sync reset, active high  
.op_val       (DUT_comp_mult_top.i_comp_mult_wrapper.op_val   ), // [i] input operands valid 
.op_rdy       (DUT_comp_mult_top.i_comp_mult_wrapper.op_rdy   ), // [i] input operands ready 
.op_data      (DUT_comp_mult_top.i_comp_mult_wrapper.op_data  ), // [i] input operands {x1,x2,y1,y2}
.res_val      (DUT_comp_mult_top.i_comp_mult_wrapper.res_val  ), // [i] output result valid 
.res_rdy      (DUT_comp_mult_top.i_comp_mult_wrapper.res_rdy  ), // [i] output result ready 
.res_data     (DUT_comp_mult_top.i_comp_mult_wrapper.res_data ), // [i] output result {xr,yr}
.exp_res_data (                                               )  // [o] expected output result {xr,yr}
); 

clk_rst_tb #(
.PERIOD (5) // clock period / 2
) i_clk_rst_tb (
.clk   (clk  ), // [o] system clock 
.rst_n (rst_n)  // [o] async hw reset active low 
);



endmodule // comp_mult_top_test