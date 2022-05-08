class ve_data_out_generator extends ve_base_unit;

   rand int delay;
   //constraint delay_prob {delay dist {0:=50, [1:30]:=50}; }; // 50% chance of b2b

   function new(string name,int id);
     super.new(name,id);
     this.id=id;
   endfunction: new

   //LAB: implement a function 'generate_delay()' that randomizes and returns the 'delay'
   function int generate_delay(int unsigned zero_prob, int unsigned max_delay);
        if(zero_prob > 100) zero_prob = 100; // limit probability 
        void'(std::randomize(delay) with {delay dist {0:=zero_prob, [1:max_delay]:=100-zero_prob}; }); // cast to void, randomize variable
        return delay;
   endfunction: generate_delay

endclass: ve_data_out_generator