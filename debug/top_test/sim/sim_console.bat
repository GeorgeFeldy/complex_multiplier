vlib work

vlog ../deb_src/*.v
vlog ../../../hdl/*.v
vsim -c work.comp_mult_top_test -do run.do