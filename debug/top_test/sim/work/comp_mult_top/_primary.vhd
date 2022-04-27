library verilog;
use verilog.vl_types.all;
entity comp_mult_top is
    generic(
        DWIDTH          : integer := 8;
        NO_MULT         : integer := 4;
        RF_BADDR        : integer := 0;
        SYS_AW          : integer := 32;
        REG_DW          : integer := 32
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        sw_rst          : in     vl_logic;
        rf_addr         : in     vl_logic_vector;
        rf_wr           : in     vl_logic;
        rf_cfg          : in     vl_logic_vector;
        rf_sts          : out    vl_logic_vector;
        mem_ce          : out    vl_logic;
        mem_we          : out    vl_logic;
        mem_addr        : out    vl_logic_vector;
        mem_wr_data     : out    vl_logic_vector;
        mem_rd_data     : in     vl_logic_vector
    );
end comp_mult_top;
