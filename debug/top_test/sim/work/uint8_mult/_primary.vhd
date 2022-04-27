library verilog;
use verilog.vl_types.all;
entity uint8_mult is
    generic(
        DWIDTH          : integer := 8
    );
    port(
        op1             : in     vl_logic_vector;
        op2             : in     vl_logic_vector;
        result          : out    vl_logic_vector
    );
end uint8_mult;
