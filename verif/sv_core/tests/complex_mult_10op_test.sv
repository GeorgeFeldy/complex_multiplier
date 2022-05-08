// `include "../env/ve_package.sv"

import ve_package::*;


program complex_mult_10op_test(rst_intf  i_rst_intf ,
                               op_intf   i_op_intf  ,
                               res_intf  i_res_intf );
             
   ve_environment i_env;
   initial begin
     // Update the environment constructor call to pass interfaces from the TB-TOP
     i_env=new(10,"Environment", 0, i_rst_intf, i_op_intf, i_res_intf );
     i_env.run();                       
   end                               
endprogram // complex_mult_10op_test                       
                                   