class ve_result #(parameter DWIDTH = 8);

   int id; // transaction unique id
   
   bit signed [2*(DWIDTH+1)-1:0] xr;
   bit signed [2*(DWIDTH+1)-1:0] yr;
   
   function void post_randomize();
      // $display("ID: %0d -> (%0d + %0di) * (%0d + %0di)",id,x1,y1,x2,y2);
   endfunction : post_randomize

   function ve_result copy();
      ve_result op_copy = new();
      
      op_copy.id = this.id;
      op_copy.xr = this.xr;
      op_copy.yr = this.yr;
      
      return op_copy;
      
   endfunction : copy

   function void display(string prefix);
    $display("%0t %s ID: %0d -> (%0d + %0di) ", $time, prefix, id, xr, yr);
   endfunction : display

endclass : ve_result