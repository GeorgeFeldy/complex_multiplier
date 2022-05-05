vlib work
vmap work work

vlog -reportprogress 300 -work work ../deb_src/*.v

vlog -reportprogress 300 -work work ../../../hdl/*.v

vsim -novopt work.comp_mult_top_test

do wave.do
run  -all
