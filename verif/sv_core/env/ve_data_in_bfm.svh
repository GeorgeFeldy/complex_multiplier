class ve_data_in_bfm extends ve_base_unit;

   op_mbox_t op_mbox; //the mailbox between the generator and the BFM
   
   virtual op_intf.drv  op_drv  ;
   virtual rst_intf.rcv rst_drv ;
   
   function new(op_mbox_t            op_mbox ,
                virtual op_intf.drv  op_drv  ,
                virtual rst_intf.rcv rst_drv ,
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
      bit empty = 1'b0; // mailbox empty  

      $display("[%0t] %s Starting to drive operand transactions...", $time, super.name);

      forever begin   
 
         curent_trans = new();
         next_trans   = new();
      
         op_mbox.get(curent_trans); // get current transaction from mailbox 
         if(op_mbox.try_peek(next_trans)) begin // get from mailbox next transaction 
            // next_trans.display(""); 
            b2b = (next_trans.delay == 0); 
         end 
         empty = (op_mbox.num() == 0);
        
         drive_trans(curent_trans, b2b, empty); // drive transactions 
      end
   endtask : run


   task drive_trans(ve_operands trans, bit b2b, bit empty);
        
      op_drv.drv_cb.op_val  <= 1'b0;  
        
      while(~(rst_drv.rcv_cb.rst_n) | rst_drv.rcv_cb.sw_rst) @(op_drv.drv_cb); // wait for end of reset 
         
      repeat (trans.delay) @(op_drv.drv_cb); //wait a number of cycles equal to the generated delay 

      //drive the transaction
      op_drv.drv_cb.op_val  <= 1'b1;
      op_drv.drv_cb.op_data <= {trans.x1, trans.y1, trans.x2, trans.y2};
      @(op_drv.drv_cb);
      
      while(~op_drv.drv_cb.op_rdy) @(op_drv.drv_cb); // wait for rdy 
      
      //if(empty | b2b) begin 
          op_drv.drv_cb.op_val <= 1'b0;
          @(op_drv.drv_cb);
      //end 
      
   endtask : drive_trans

endclass : ve_data_in_bfm
