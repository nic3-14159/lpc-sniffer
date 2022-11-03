read_vhdl [ glob src/vhdl/*.vhd ]
read_xdc src/constrs/ebaz4205.xdc

synth_design -top top -part xc7z010clg400-1
opt_design
place_design
route_design
write_bitstream -force ./top.bit
