module clk_rst_tb#(
parameter PERIOD = 5
)(
output reg clk  ,
output reg rst_n
);

initial begin 
    clk = 0;
    forever begin 
    #5 clk <= ~clk; 
    end 
end 

initial begin 
        rst_n = 1'b1;
        @(posedge clk);
        rst_n = 1'b0;
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
end 

endmodule // clk_rst_tb


//    clk_rst_tb#(
//    .PERIOD (PERIOD) // clock period / 2
//    ) i_clk_rst_tb  (
//    .clk   (clk  ), // [o] system clock 
//    .rst_n (rst_n)  // [o] async hw reset active low 
//    );