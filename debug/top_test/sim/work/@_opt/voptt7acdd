library verilog;
use verilog.vl_types.all;
entity mem_1rw is
    generic(
        ADDR_WIDTH      : integer := 8;
        MEM_DEPTH       : integer := 256;
        WORD_BYTES      : integer := 8
    );
    port(
        clk             : in     vl_logic;
        ce              : in     vl_logic;
        we              : in     vl_logic;
        addr            : in     vl_logic_vector;
        wr_data         : in     vl_logic_vector;
        be              : in     vl_logic_vector;
        rd_data         : out    vl_logic_vector
    );
end mem_1rw;
