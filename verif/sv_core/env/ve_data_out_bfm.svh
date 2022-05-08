class ve_data_out_bfm extends ve_base_unit;

   virtual res_intf.drv res_drv;

   //instance of the generator (since it only generates a delay for
   //the 1 bit value for the read_enb wire, there is no need to declare
   //a mailbox between the generator and the BFM)
   ve_data_out_generator rdy_gen;
   
   bit force_backpressure; // enable backpressure (infinite delay)

   function new(virtual res_intf.drv  res_drv,
                ve_data_out_generator rdy_gen,
                string name,
                int id);
                
      super.new(name,id);
     
      this.res_drv = res_drv;
      this.rdy_gen = rdy_gen;
      
   endfunction : new

   task run();
      int delay, length;
      int idx;

      forever begin
         if(~force_backpressure) begin
         
            delay = rdy_gen.generate_delay(50, 30); // 50% chance of 0, max 30 cycles otherwise; TODO: access via constructor  
            
            res_drv.drv_cb.res_rdy <= 1'b0;
            repeat(delay) @(res_drv.drv_cb);
            
            res_drv.drv_cb.res_rdy <= 1'b1;
            @(res_drv.drv_cb);
       
         end
         else @(smp_drv.drv_cb);
      end
   endtask: run

endclass: ve_data_out_bfm