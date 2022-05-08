
typedef mailbox #(ve_operands) op_mbox_t;

class ve_data_in_generator extends ve_base_unit;

   int no_op;  // number of input operands transactions
   int op_cnt; // input operands transaction counter

   op_mbox_t    op_mbox   ; //mailbox between the generator and the BFM     
   ve_operands  curent_op ; // current operand transaction 

   function new(op_mbox_t op_mbox,
                int       no_op  ,
                string    name   ,
                int       id
               );
   super.new(name,id);
   
   this.op_mbox   = op_mbox;
   this.curent_op = new();
   this.no_op     = no_op;
   
   endfunction : new

   task run();
      ve_operands operand_trans;

      $display("[%0t] %s Starting to generate %0d operand transactions...", $time,
            super.name, no_op);

      while (op_cnt < no_op) begin
         get_trans(op_cnt, operand_trans);
         op_mbox.put(operand_trans);
         op_cnt++;
      end

   endtask : run

   task get_trans(input int op_cnt, output ve_operands operand_trans);
   
        operand_trans = new;
        operand_trans.randomize();
        operand_trans.id = op_cnt;
        
   endtask : get_trans

endclass : ve_data_in_generator
