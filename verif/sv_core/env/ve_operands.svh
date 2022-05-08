class ve_operands #(parameter DWIDTH = 8);

   int id; // transaction unique id

   // {x1,y1,x2,y2}
   
   rand bit signed [DWIDTH-1:0] x1;
   rand bit signed [DWIDTH-1:0] y1;
   rand bit signed [DWIDTH-1:0] x2;
   rand bit signed [DWIDTH-1:0] y2;
      
   rand int unsigned delay;
   constraint delay_prob {delay dist {0:=50, [1:30]:=50}; }; // 50% chance of b2b
   
   function void post_randomize();
      // $display("ID: %0d -> (%0d + %0di) * (%0d + %0di)",id,x1,y1,x2,y2);
   endfunction : post_randomize

   function ve_operands copy();
      ve_operands op_copy = new();
      
      op_copy.id = this.id;
      op_copy.x1 = this.x1;
      op_copy.y1 = this.y1;
      op_copy.x2 = this.x2;
      op_copy.y2 = this.y2;
      
      return op_copy;
      
   endfunction : copy

   function void display(string prefix);
    $display("%0t %s ID: %0d -> (%0d + %0di) * (%0d + %0di)", $time, prefix, id, x1, y1, x2, y2);
   endfunction : display

endclass : ve_operands