//---------------------------------------------------------------------
// Project     : HDL - Complex Multiplier
// Module Name : comp_mult_test
// Author      : Feldioreanu George-Aurelian (FG)
// Created     : Mar 12, 2022
//---------------------------------------------------------------------
// Description : Test environment for complex multiplier 
//---------------------------------------------------------------------

module comp_mult_test;

localparam PERIOD  = 5; // clk period / 2
localparam DWIDTH  = 8; // data width

wire                         clk          ; // system clock 
wire                         rst_n        ; // hw async reset, active low 
reg                          sw_rst       ; // sw  sync reset, active high _2
reg                          op_val       ; // operands valid 
wire                         op_rdy       ; // operands ready 
reg  [      2*2*DWIDTH -1:0] op_data      ; // operands {x1,y1,y1,y2}     

// wire                         res_val_ref  ; // result valid 
// wire                         res_rdy_ref  ; // result ready 
// wire [2*2*(DWIDTH + 1) -1:0] res_data_ref ; // result {xr,yr}   

wire                         res_val_1    ; // result valid 
// wire                         res_rdy_1    ; // result ready 
wire [2*2*(DWIDTH + 1) -1:0] res_data_1   ; // result {xr,yr}

wire                         res_val_2    ; // result valid 
// wire                         res_rdy_2    ; // result ready 
wire [2*2*(DWIDTH + 1) -1:0] res_data_2   ; // result {xr,yr}

wire                         res_val_4    ; // result valid 
// wire                         res_rdy_4    ; // result ready 
wire [2*2*(DWIDTH + 1) -1:0] res_data_4   ; // result {xr,yr}

wire                         res_rdy_all;
                                        
reg    [            32 -1:0] rand_nr      ; // random unsigned integer 
wire                         rand_f       ; // random flag, active if rand_nr == xxxxxxxx3
                                          
integer                      idx          ; 


wire test_rdy = 0;


clk_rst_tb #(
.PERIOD (PERIOD) // clock period / 2
) i_clk_rst_tb (
.clk   (clk  ), // [o] system clock 
.rst_n (rst_n)  // [o] async hw reset active low 
);


assign res_rdy_all = res_val_1 & res_val_2 & res_val_4;

// DUT 
comp_mult_wrapper #(
.DWIDTH  (DWIDTH  ), // data width
.NO_MULT (4       )  // number of multipliers used (1, 2 or 4)
) DUT_comp_mult_wrapper_4 (
.clk      (clk        ), // [i] system clock 
.rst_n    (rst_n      ), // [i] hw async reset, active low 
.sw_rst   (sw_rst     ), // [i] sw  sync reset, active high  
.op_val   (op_val     ), // [i] input operands valid 
.op_rdy   (op_rdy     ), // [o] input operands ready 
.op_data  (op_data    ), // [i] input operands {x1,x2,y1,y2}
.res_val  (res_val_4  ), // [o] output result valid 
.res_rdy  (res_rdy_all), // [i] output result ready 
.res_data (res_data_4 )  // [o] output result {xr,yr}
); 

comp_mult_wrapper #(
.DWIDTH  (DWIDTH  ), // data width
.NO_MULT (2       )  // number of multipliers used (1, 2 or 4)
) DUT_comp_mult_wrapper_2 (
// system IF 
.clk      (clk        ), // [i] system clock 
.rst_n    (rst_n      ), // [i] hw async reset, active low 
.sw_rst   (sw_rst     ), // [i] sw  sync reset, active high  
.op_val   (op_val     ), // [i] input operands valid 
.op_rdy   (op_rdy     ), // [o] input operands ready 
.op_data  (op_data    ), // [i] input operands {x1,x2,y1,y2}
.res_val  (res_val_2  ), // [o] output result valid 
.res_rdy  (res_rdy_all), // [i] output result ready 
.res_data (res_data_2 )  // [o] output result {xr,yr}
); 

comp_mult_wrapper #(
.DWIDTH  (DWIDTH  ), // data width
.NO_MULT (1       )  // number of multipliers used (1, 2 or 4)
) DUT_comp_mult_wrapper_1 (
// system IF 
.clk      (clk        ), // [i] system clock 
.rst_n    (rst_n      ), // [i] hw async reset, active low 
.sw_rst   (sw_rst     ), // [i] sw  sync reset, active high  
.op_val   (op_val     ), // [i] input operands valid 
.op_rdy   (op_rdy     ), // [o] input operands ready 
.op_data  (op_data    ), // [i] input operands {x1,x2,y1,y2}
.res_val  (res_val_1  ), // [o] output result valid 
.res_rdy  (res_rdy_all), // [i] output result ready 
.res_data (res_data_1 )  // [o] output result {xr,yr}
); 


comp_mult_data_checker #(
.DWIDTH (DWIDTH)
) i_comp_mult_data_checker (                     
.clk         (clk        ),  // [i] system clock 
.rst_n       (rst_n      ),  // [i] hw async reset, active low 
.sw_rst      (sw_rst     ),  // [i] sw  sync reset, active high              
.op_val      (op_val     ),  // [i] input operands valid 
.op_rdy      (op_rdy     ),  // [i] input operands ready 
.op_data     (op_data    ),  // [i] input operands {x1, y1, x2, y2}
.sample      (res_rdy_all),  // [i] output result valid 
.res_data_4  (res_data_4 ),  // [i] output result {xr,yr}
.res_data_2  (res_data_2 ),  // [i] output result {xr,yr}
.res_data_1  (res_data_1 )   // [i] output result {xr,yr}
); 

// // Reference model 
// comp_mult_ref_model i_comp_mult_ref_model (
// .clk          (clk         ), // [i] system clock 
// .rst_n        (rst_n       ), // [i] hw async reset, active low 
// .sw_rst       (sw_rst      ), // [i] sw  sync reset, active high  
// .op_val       (op_val      ), // [i] input operands valid 
// .op_rdy       (op_rdy      ), // [i] input operands ready 
// .op_data      (op_data     ), // [i] input operands {x1,x2,y1,y2}
// .res_val      (res_val_ref ), // [i] output result valid 
// .res_rdy      (res_rdy_ref ), // [i] output result ready 
// .res_data     (res_data_ref)  // [i] output result {xr,yr}
// ); 

initial begin 
    idx = 0;
    sw_rst = 1'b0;
    @(posedge rst_n);
    @(posedge clk);
    repeat(3) @(posedge clk);
    sw_rst = 1'b1; 
    repeat(5) @(posedge clk);
    sw_rst = 1'b0;
end 

initial begin 
    op_val  = 1'b0;
    op_data =  'b0;

    @(negedge sw_rst);
    
    repeat(5) @(posedge clk);
    send_data(8'd2,8'd3,8'd4,8'd2,1);  // (2 + i*3) * (4 + i*2) = 2 + i*16
    send_data(8'd3,8'd3,8'd4,8'd2,0);  // (3 + 3i) * (4 + 2i) = (6 + 18i)
    send_data(8'd0,8'd0,8'd0,8'd0,0);  
    
    send_data(8'd255,8'd255,8'd255,8'd255,0);  
    send_data(8'd127,8'd127,8'd127,8'd127,0);  
    send_data(8'd129,8'd129,8'd129,8'd129,0);  
    send_data(8'd100,8'd100,8'd100,8'd100,0);  
    send_data(8'd100,8'd101,8'd102,8'd103,0);  
    
    repeat(1000)
    send_data($urandom_range(0,255),
              $urandom_range(0,255),
              $urandom_range(0,255),
              $urandom_range(0,255),
              $urandom_range(0,10));  
     
    send_data(8'd128,8'd128,8'd128,8'd128,0);  // fails 

    $display("DONE");
    $stop;
      
end 


// task to assert valid with some data
task send_data;

input [8 -1:0] t_x1      ;  
input [8 -1:0] t_y1      ;
input [8 -1:0] t_x2      ;
input [8 -1:0] t_y2      ;
input [8 -1:0] break_time;

begin 

    op_val = 1'b1;
    op_data = {t_x1, t_y1, t_x2, t_y2}; // assign parameter data 
    @(posedge clk);
    
    while(~op_rdy) @(posedge clk); // wait for ready 
    if(break_time > 0) begin  
        op_val = 1'b0;
        op_data = 'bx;
        @(posedge clk);
    end 
    repeat(break_time) @(posedge clk); // hold valid 0 for "break_time" cycles 

end 
endtask


// valid-ready checker for operand interface 
vld_rdy_checker #(
.DATA_WIDTH       (2*2*DWIDTH)
) i_vld_rdy_checker_in (     
.clk              (clk       ),
.rst_n            (rst_n     ),
.valid            (op_val    ),               
.ready            (op_rdy    ),               
.data             (op_data   )
);


// valid-ready checker for result interface 
vld_rdy_checker #(
.DATA_WIDTH       (2*2*(DWIDTH + 1))
) i_vld_rdy_checker_out_4 (     
.clk              (clk         ),
.rst_n            (rst_n       ),
.valid            (res_val_4   ),               
.ready            (res_rdy_all ),               
.data             (res_data_4  )
);

// valid-ready checker for result interface 
vld_rdy_checker #(
.DATA_WIDTH       (2*2*(DWIDTH + 1))
) i_vld_rdy_checker_out_2 (     
.clk              (clk         ),
.rst_n            (rst_n       ),
.valid            (res_val_2   ),               
.ready            (res_rdy_all ),               
.data             (res_data_2  )
);

// valid-ready checker for result interface 
vld_rdy_checker #(
.DATA_WIDTH       (2*2*(DWIDTH + 1))
) i_vld_rdy_checker_out_1 (     
.clk              (clk         ),
.rst_n            (rst_n       ),
.valid            (res_val_1   ),               
.ready            (res_rdy_all ),               
.data             (res_data_1  )
);

always @(posedge clk)
if(~rst_n) rand_nr <= 32'd0    ; else 
           rand_nr <= $urandom ;

assign rand_f = &rand_nr[1:0];


endmodule // comp_mult_test

