class ve_data_in_bfm extends ve_base_unit;

   op_mbox_t op_mbox; //the mailbox between the generator and the BFM
   
   virtual op_intf.drv  op_drv  ;
   virtual rst_intf.drv rst_drv ;
   
   function new(op_mbox_t            op_mbox ,
                virtual op_intf.drv  op_drv  ,
                virtual rst_intf.drv rst_drv ,
                string               name    ,
                int                  id
                );
      super.new(name,id);

      this.op_mbox = op_mbox ;
      this.op_drv  = op_drv  ;    
      this.rst_drv = rst_drv ; 
      
  endfunction : new

   task run();
      ve_operands curent_trans; // current operand transactions
      ve_operands next_trans; // future transactions
      
      bit b2b = 1'b0; // back to back valid 

      $display("[%0t] %s Starting to drive operand transactions...", $time, super.name);

      forever begin   
         op_mbox.get(curent_trans); // get current transaction from mailbox 
         op_mbox.try_peek(next_trans); // get from mailbox next transaction 
         b2b = (op_mbox.num() == 0) | (next_trans.delay == 0);
         drive_trans(curent_trans, b2b); // drive transactions 
      end
   endtask : run


   task drive_packet(ve_operands trans, bit b2b);
        
      while(~rst_drv.drv_cb.rst_n | rst_drv.drv_cb.sw_rst) @(op_drv.drv_cb); // wait for end of reset 
         
      repeat (trans.delay) @(op_drv.drv_cb); //wait a number of cycles equal to the generated delay 

      //drive the transaction
      op_drv.drv_cb.op_val  <= 1'b1;
      op_drv.drv_cb.op_data <= {trans.x1, trans.y1, trans.x2, trans.y2};
      @(op_drv.drv_cb);
      
      if(~b2b) begin 
          smp_drv.drv_cb.packet_valid <= 1'b0;
          @(op_drv.drv_cb);
      end 
      
   endtask : drive_packet

endclass : ve_data_in_bfm
