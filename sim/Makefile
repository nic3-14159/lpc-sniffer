run_tb: import_vhdl
	ghdl -r Pxilinx-vivado -fsynopsys -v top_tb --wave=lpc.ghw --stop-time=15ns

import_vhdl:
	ghdl -i ../../sources_1/new/lpc.vhd
	ghdl -i ../../sources_1/new/uart.vhd
	ghdl -i ../../sources_1/new/ps_stub.vhd
	ghdl -i ../../sources_1/new/top.vhd
	ghdl -i top_tb.vhd
