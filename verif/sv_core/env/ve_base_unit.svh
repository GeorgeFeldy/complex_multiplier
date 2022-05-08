
// typedef mailbox #(packet) packet_channel;

class ve_base_unit;
  
   string name ;
   int    id   ;

   function new (string name, int id);
      this.name=name;
      this.id=id;
   endfunction: new

   function void print(int id);
     $display("%0d: %s", id, name);
   endfunction: print

   virtual task run();
   endtask: run
 
endclass: ve_base_unit

 
