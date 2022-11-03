library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lpc_tb is
end lpc_tb;

architecture Behavioral of lpc_tb is
    signal lpc_clk: std_logic := '1';
    signal lpc_frame: std_logic := '1';
    signal lpc_reset: std_logic := '1';
    signal lpc_ad: std_logic_vector(3 downto 0) := "0000";
    signal lpc_data_out : std_logic_vector(7 downto 0) := (others => '0');
    signal lpc_have_data : std_logic;

    type lpc_interface is record
        lframe: std_logic;
        lad: std_logic_vector(3 downto 0);
    end record;
    type LPC_TEST_DATA is array(natural range <>) of lpc_interface;
    constant lpc_io_read : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0000"), -- START
        ('1', "0000"), -- CYCTYPE + DIR : IO Read
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    constant lpc_io_write : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0000"), -- START
        ('1', "0010"), -- CYCTYPE + DIR : IO Write
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0000"), -- SYNC
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    constant lpc_mem_read : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0000"), -- START
        ('1', "0100"), -- CYCTYPE + DIR : Memory Read
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0001"),
        ('1', "0010"),
        ('1', "0011"),
        ('1', "0100"),
        ('1', "0101"),
        ('1', "0110"),
        ('1', "0111"), -- ADDR lease significant nibble
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0110"), -- SYNC Long
        ('1', "0110"), -- SYNC Long
        ('1', "0110"), -- SYNC Long
        ('1', "0110"), -- SYNC Long
        ('1', "0000"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_mem_write : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "1110"), -- START
        ('0', "0000"), -- START
        ('1', "0110"), -- CYCTYPE + DIR : Memory Write
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0001"),
        ('1', "0010"),
        ('1', "0011"),
        ('1', "0100"),
        ('1', "0101"),
        ('1', "0110"),
        ('1', "0111"), -- ADDR lease significant nibble
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0000"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_dma_r8 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0000"), -- START
        ('1', "1000"), -- CYCTYPE + DIR : DMA Read
        ('1', "0011"), -- CHANNEL
        ('1', "0000"), -- SIZE : 8 bit
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1001"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_dma_r16 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0000"), -- START
        ('1', "1000"), -- CYCTYPE + DIR : DMA Read
        ('1', "0010"), -- CHANNEL
        ('1', "0001"), -- SIZE : 16 bit
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1001"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1001"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );

    constant lpc_dma_r32 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0000"), -- START
        ('1', "1000"), -- CYCTYPE + DIR : DMA Read
        ('1', "0111"), -- CHANNEL
        ('1', "0011"), -- SIZE : 32 bit
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1001"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1001"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1001"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0000"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_dma_w8 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0000"), -- START
        ('1', "1010"), -- CYCTYPE + DIR : DMA Write
        ('1', "0011"), -- CHANNEL
        ('1', "0000"), -- SIZE : 8 bit
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1001"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_dma_w16 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0000"), -- START
        ('1', "1010"), -- CYCTYPE + DIR : DMA Write
        ('1', "0011"), -- CHANNEL
        ('1', "0001"), -- SIZE : 16 bit
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1001"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1001"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );

    constant lpc_dma_w32 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0000"), -- START
        ('1', "1010"), -- CYCTYPE + DIR : DMA Write
        ('1', "0011"), -- CHANNEL
        ('1', "0011"), -- SIZE : 32 bit
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "1001"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1001"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1001"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1001"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_bm_io_r8 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0010"), -- START
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0000"), -- CYCTYPE + DIR : IO Read
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "0000"), -- SIZE : 8 bits
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_bm_io_r16 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0011"), -- START
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0000"), -- CYCTYPE + DIR : IO Read
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "0001"), -- SIZE : 16 bits
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    constant lpc_bm_io_r32 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0010"), -- START
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0000"), -- CYCTYPE + DIR : IO Read
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "0011"), -- SIZE : 32 bits
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_bm_io_w8 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0010"), -- START
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0010"), -- CYCTYPE + DIR : IO Write
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "0000"), -- SIZE : 8 bits
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_bm_io_w16 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0011"), -- START
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0010"), -- CYCTYPE + DIR : IO Write
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "0001"), -- SIZE : 16 bits
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    constant lpc_bm_io_w32 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0010"), -- START
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0010"), -- CYCTYPE + DIR : IO Write
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "0011"), -- SIZE : 32 bits
        ('1', "1010"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_bm_mem_r8 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0010"), -- START
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0100"), -- CYCTYPE + DIR : Mem Read
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"),
        ('1', "0000"),
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "0000"), -- SIZE : 8 bits
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_bm_mem_r16 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0011"), -- START
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0100"), -- CYCTYPE + DIR : Mem Read
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"),
        ('1', "0000"),
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "0001"), -- SIZE : 16 bits
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    constant lpc_bm_mem_r32 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0010"), -- START
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0100"), -- CYCTYPE + DIR : Mem Read
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), 
        ('1', "0000"), 
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "0011"), -- SIZE : 32 bits
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1010"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_bm_mem_w8 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0010"), -- START
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0110"), -- CYCTYPE + DIR : Mem Write
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), 
        ('1', "0000"), 
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "0000"), -- SIZE : 8 bits
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    
    constant lpc_bm_mem_w16 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0011"), -- START
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0110"), -- CYCTYPE + DIR : Mem Write
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), 
        ('1', "0000"), 
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "0001"), -- SIZE : 16 bits
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
    constant lpc_bm_mem_w32 : LPC_TEST_DATA := (
        ('1', "0000"),
        ('1', "0000"),
        ('0', "0010"), -- START
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0110"), -- CYCTYPE + DIR : IO Write
        ('1', "0000"), -- ADDR most significant nibble
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), 
        ('1', "0000"), 
        ('1', "0000"),
        ('1', "1000"),
        ('1', "0000"), -- ADDR lease significant nibble
        ('1', "0011"), -- SIZE : 32 bits
        ('1', "1010"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1010"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "0101"), -- DATA
        ('1', "1111"), -- TAR
        ('1', "0000"), -- TAR
        ('1', "0101"), -- SYNC Short Wait
        ('1', "0000"), -- SYNC Ready
        ('1', "1111"), -- TAR
        ('1', "0000") -- TAR
    );
begin
    lpc_inst: entity work.lpc(Behavioral)
        port map(
            lpc_ad => lpc_ad,
            lpc_frame => lpc_frame,
            lpc_reset => lpc_reset,
            lpc_clk => lpc_clk,
            lpc_data_out => lpc_data_out,
            lpc_have_data => lpc_have_data
        );
    lpc_bus : process
    begin
        for i in lpc_io_read'range loop
            lpc_frame <= lpc_io_read(i).lframe;
            lpc_ad <= lpc_io_read(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_io_write'range loop
            lpc_frame <= lpc_io_write(i).lframe;
            lpc_ad <= lpc_io_write(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_mem_read'range loop
            lpc_frame <= lpc_mem_read(i).lframe;
            lpc_ad <= lpc_mem_read(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_mem_write'range loop
            lpc_frame <= lpc_mem_write(i).lframe;
            lpc_ad <= lpc_mem_write(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;

        for i in lpc_dma_r8'range loop
            lpc_frame <= lpc_dma_r8(i).lframe;
            lpc_ad <= lpc_dma_r8(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;

        for i in lpc_dma_r16'range loop
            lpc_frame <= lpc_dma_r16(i).lframe;
            lpc_ad <= lpc_dma_r16(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;

        for i in lpc_dma_r32'range loop
            lpc_frame <= lpc_dma_r32(i).lframe;
            lpc_ad <= lpc_dma_r32(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_dma_w8'range loop
            lpc_frame <= lpc_dma_w8(i).lframe;
            lpc_ad <= lpc_dma_w8(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;

        for i in lpc_dma_w16'range loop
            lpc_frame <= lpc_dma_w16(i).lframe;
            lpc_ad <= lpc_dma_w16(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;

        for i in lpc_dma_w32'range loop
            lpc_frame <= lpc_dma_w32(i).lframe;
            lpc_ad <= lpc_dma_w32(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_bm_io_r8'range loop
            lpc_frame <= lpc_bm_io_r8(i).lframe;
            lpc_ad <= lpc_bm_io_r8(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_bm_io_r16'range loop
            lpc_frame <= lpc_bm_io_r16(i).lframe;
            lpc_ad <= lpc_bm_io_r16(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_bm_io_r32'range loop
            lpc_frame <= lpc_bm_io_r32(i).lframe;
            lpc_ad <= lpc_bm_io_r32(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_bm_io_w8'range loop
            lpc_frame <= lpc_bm_io_w8(i).lframe;
            lpc_ad <= lpc_bm_io_w8(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_bm_io_w16'range loop
            lpc_frame <= lpc_bm_io_w16(i).lframe;
            lpc_ad <= lpc_bm_io_w16(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_bm_io_w32'range loop
            lpc_frame <= lpc_bm_io_w32(i).lframe;
            lpc_ad <= lpc_bm_io_w32(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_bm_mem_r8'range loop
            lpc_frame <= lpc_bm_mem_r8(i).lframe;
            lpc_ad <= lpc_bm_mem_r8(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_bm_mem_r16'range loop
            lpc_frame <= lpc_bm_mem_r16(i).lframe;
            lpc_ad <= lpc_bm_mem_r16(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_bm_mem_r32'range loop
            lpc_frame <= lpc_bm_mem_r32(i).lframe;
            lpc_ad <= lpc_bm_mem_r32(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_bm_mem_w8'range loop
            lpc_frame <= lpc_bm_mem_w8(i).lframe;
            lpc_ad <= lpc_bm_mem_w8(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_bm_mem_w16'range loop
            lpc_frame <= lpc_bm_mem_w16(i).lframe;
            lpc_ad <= lpc_bm_mem_w16(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_bm_mem_w32'range loop
            lpc_frame <= lpc_bm_mem_w32(i).lframe;
            lpc_ad <= lpc_bm_mem_w32(i).lad;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
            lpc_clk <= not lpc_clk;
            wait for 15 ps;
        end loop;
    end process;    
end Behavioral;
