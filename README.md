# LPC Sniffer

This project captures raw traffic on the [LPC Bus](https://www.intel.com/content/dam/www/program/design/us/en/documents/low-pin-count-interface-specification.pdf) and outputs captured transactions over UART. All cycle types defined in the specification except Firmware Memory Reads and Writes are implemented. The motivation for this project was to develop a tool to assist me in documenting the embedded controller on an old Dell Latitude E6400 laptop, which is connected to the rest of the system through the LPC bus. My work on that project can be found [in this repo](https://github.com/nic3-14159/E6400-EC-research).

## Building
Run the following command from the root of this project:
```
vivado -mode tcl -source build.tcl
```
Make sure Vivado can be found through your PATH environment variable, or specify the full path to the Vivado executable.

## Design notes
The design synchronizes itself to the state of the LPC bus and only outputs data that belongs to a bus transaction. Data is output over a 2500000 baud UART link, and is formatted as ASCII characters from 0-9, A-F where each character represents the raw value of the 4 LPC data lines in a single clock cycle. The value of the last turn-around cycle of a single transaction is not logged and is instead replaced by a newline character to signal the end of a transaction. If a transaction is aborted, a "!" character will be inserted into the ASCII data stream to indicate this.

To work around the bandwidth imbalance of the 33 MHz x 4 bit LPC bus and the 2500000 baud UART link the design incorporates a FIFO buffer to hold incoming transfers until the UART is able to handle them. It also implements a filtering mechanism where transactions are discarded based on the content of the LPC transaction, such as repeated reads to the same address (polling), the address being written to, the value of the data being transferred, the type of LPC cycle, or anything else that can be implemented in VHDL.

A small buffer holds incoming data and prevents it from passing on to the main FIFO. A second buffer holds bits representing the validity of a transaction. If valid, the entire transaction is read out of the buffer and passed to the main FIFO, otherwise it is dropped and the filter moves on to the next transaction in the filter buffer.

This currently targets the Xilinx Zynq-7000 platform on the [EBAZ4205](https://github.com/xjtuecho/EBAZ4205) board. The UART baudrate is fixed at 2500000 baud as the Fast Ethernet Tranceiver on the board in the default 10Mbps mode outputs a 2.5 MHz clock that is accessible from the PL side of the Zynq.