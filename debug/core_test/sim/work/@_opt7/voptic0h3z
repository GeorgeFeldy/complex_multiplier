library verilog;
use verilog.vl_types.all;
entity comp_mult_ref_model is
    generic(
        DWIDTH          : integer := 8
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        sw_rst          : in     vl_logic;
        op_val          : in     vl_logic;
        op_rdy          : in     vl_logic;
        op_data         : in     vl_logic_vector;
        res_val         : in     vl_logic;
        res_rdy         : in     vl_logic;
        res_data        : in     vl_logic_vector;
        exp_res_data    : out    vl_logic_vector
    );
end comp_mult_ref_model;
