# LPC Sniffer, Analog Discovery 2 Version
This is a very experimental port of my original LPC sniffer design to the
Xilinx Spartan 6 FPGA in the Analog Discovery 2. It's based on WIP local
commits for the original LPC sniffer that are of questionable functionality.
The source files will need to be manually imported into Xilinx ISE as I haven't
figured out what to version control to easily recreate the project.

Compiling test_ft232_read.c:
`gcc -o test_ft232_read test_ft232_read.c -I/usr/include/libftdi1 -lftdi1`
