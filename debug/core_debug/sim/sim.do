vlib work
vmap work work

vlog -reportprogress 300 -work work ../deb_src/clk_rst_tb.v
vlog -reportprogress 300 -work work ../deb_src/comp_mult_ref_model.v
vlog -reportprogress 300 -work work ../deb_src/comp_mult_test.v
vlog -reportprogress 300 -work work ../deb_src/vld_rdy_checker.v

vlog -reportprogress 300 -work work ../../../hdl/comp_mult_1.v
vlog -reportprogress 300 -work work ../../../hdl/comp_mult_2.v
vlog -reportprogress 300 -work work ../../../hdl/comp_mult_4.v
vlog -reportprogress 300 -work work ../../../hdl/comp_mult_wrapper.v
vlog -reportprogress 300 -work work ../../../hdl/uint8_mult.v

vsim -novopt work.comp_mult_test

do wave.do
run  -all
