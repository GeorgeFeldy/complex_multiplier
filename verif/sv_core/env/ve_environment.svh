class ve_environment extends ve_base_unit;

   unsigned int no_op;

   //a smart queue of all the units instantiated in the environment;
   //this is very useful for modularization, because you can take out any
   //environment component and the remaining ones will still work
   ve_base_unit units[$];
   op_mbox_t op_mbox;

   // declare *virtual* interfaces here - they will be linked through the constructor 
   virtual rst_intf  i_rst_intf  ;
   virtual op_intf   i_op_intf   ;
   virtual res_intf  i_res_intf  ;
   
   ve_rst_bfm i_rst_bfm;

   ve_data_in_generator i_data_in_generator;
   ve_data_in_bfm i_data_in_bfm;

   ve_data_out_generator i_data_out_generator;
   ve_data_out_bfm i_data_out_bfm;

   bit force_backpressure;

   function new (

            int unsigned      no_op       ,
            string            name        ,
            int               id          ,
            virtual rst_intf  i_rst_intf  ,
            virtual op_intf   i_op_intf   ,
            virtual res_intf  i_res_intf  
            );
      super.new(name,id);
      this.no_op=no_op;

      this.i_rst_intf = i_rst_intf ;
      this.i_op_intf  = i_op_intf  ;
      this.i_res_intf = i_res_intf ;
      
      //Reset BFM
      i_rst_bfm = new(i_rst_intf, "RESET_BFM", 0);
      units.push_back(i_rst_bfm);

      op_mbox=new();
      i_data_in_generator = new(op_mbox,
                                no_op,
                                "DATA_IN_GENERATOR",
                                1);
                                
      units.push_back(i_data_in_generator);

      //Input channel BFM
      i_data_in_bfm = new(op_mbox,
                        i_op_intf,
                        i_rst_intf,
                        "DATA_IN_BFM", 
						2);
                        
      units.push_back(i_data_in_bfm);

      i_data_out_generator = new("DATA_OUT_GENERATOR", 3);
      
      i_data_out_bfm = new(i_res_intf, 
                           i_data_out_generator,
                           "DATA_OUT_BFM",
                           4);

   endfunction: new

   task run();
   
      i_data_out_bfm.force_backpressure = force_backpressure; 
   
      //this is where the environment resets the DUT
      units[0].run;

      for(int i=1;i<units.size();i++) begin
         fork
            automatic int k=i;
            begin
              units[k].run();
            end
         join_none
      end

      //temporary, until a proper test_end() function is defined
      #30000
      $finish(1);

   endtask: run

endclass: ve_environment