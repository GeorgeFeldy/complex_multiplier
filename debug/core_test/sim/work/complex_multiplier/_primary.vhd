library verilog;
use verilog.vl_types.all;
entity complex_multiplier is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        op_val          : in     vl_logic;
        op_rdy          : out    vl_logic;
        op_data         : in     vl_logic_vector(31 downto 0);
        res_val         : out    vl_logic;
        res_rdy         : in     vl_logic;
        res_data        : out    vl_logic_vector(35 downto 0)
    );
end complex_multiplier;
