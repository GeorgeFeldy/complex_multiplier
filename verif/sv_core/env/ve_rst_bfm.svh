class ve_rst_bfm extends ve_base_unit;

virtual rst_intf.drv rst_drv;

function new(virtual rst_intf.drv rst_drv,
	          string name, 
	          int id);
  super.new(name,id);
  this.rst_drv = rst_drv;
endfunction : new

task run();
  rst_drv.drv_cb.rst_n <= 1'b1;
  rst_drv.drv_cb.sw_rst <= 1'b0;
  repeat(5) @(rst_drv.drv_cb);
  
  // build rst_n
  rst_drv.drv_cb.rst_n <= 1'b0;
  repeat(2) @(rst_drv.drv_cb);
  
  rst_drv.drv_cb.rst_n <= 1'b1;
  repeat(3) @(rst_drv.drv_cb);
  
  
  // build sw_rst
  rst_drv.drv_cb.sw_rst <= 1'b1;
  repeat(5) @(rst_drv.drv_cb);
  
  rst_drv.drv_cb.sw_rst <= 1'b0;
  
 
endtask: run

endclass : ve_rst_bfm
