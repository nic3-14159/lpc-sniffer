----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/15/2021 11:07:48 AM
-- Design Name: 
-- Module Name: lpc_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_tb is
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is
    signal lpc_clk: std_logic := '0';
    signal lpc_frame: std_logic := '1';
    signal lpc_reset: std_logic := '1';
    signal lpc_ad: std_logic_vector(3 downto 0) := "0000";
    signal uart_tx : std_logic := '1';
    signal uart_clk : std_logic := '0';

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
        --('1', "0000"),
        --('1', "0000"),
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
    top_inst: entity work.top(Behavioral)
        port map(
            lpc_ad => lpc_ad,
            lpc_frame => lpc_frame,
            lpc_reset => lpc_reset,
            lpc_clk => lpc_clk,
            clk => uart_clk,
            tx => uart_tx
        );
    uart_interface : process
    begin
        uart_clk <= not uart_clk;
        wait for 200 ps;
    end process;

    lpc_clk_gen : process
    begin
        lpc_clk <= not lpc_clk;
        wait for 15 ps;
    end process;
    
    lpc_bus : process
    begin
        wait for 4 ns;
        for i in lpc_io_read'range loop
            lpc_frame <= lpc_io_read(i).lframe;
            lpc_ad <= lpc_io_read(i).lad;
            -- lpc_clk <= not -- lpc_clk;
            wait for 15 ps;
            -- lpc_clk <= not -- lpc_clk;
            wait for 15 ps;
        end loop;
        
        for i in lpc_io_write'range loop
            lpc_frame <= lpc_io_write(i).lframe;
            lpc_ad <= lpc_io_write(i).lad;
            -- lpc_clk <= not -- lpc_clk;
            wait for 15 ps;
            -- lpc_clk <= not -- lpc_clk;
            wait for 15 ps;
        end loop;
--        
--        for i in lpc_mem_read'range loop
--            lpc_frame <= lpc_mem_read(i).lframe;
--            lpc_ad <= lpc_mem_read(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_mem_write'range loop
--            lpc_frame <= lpc_mem_write(i).lframe;
--            lpc_ad <= lpc_mem_write(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--
--        for i in lpc_dma_r8'range loop
--            lpc_frame <= lpc_dma_r8(i).lframe;
--            lpc_ad <= lpc_dma_r8(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--
--        for i in lpc_dma_r16'range loop
--            lpc_frame <= lpc_dma_r16(i).lframe;
--            lpc_ad <= lpc_dma_r16(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--
--        for i in lpc_dma_r32'range loop
--            lpc_frame <= lpc_dma_r32(i).lframe;
--            lpc_ad <= lpc_dma_r32(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_dma_w8'range loop
--            lpc_frame <= lpc_dma_w8(i).lframe;
--            lpc_ad <= lpc_dma_w8(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--
--        for i in lpc_dma_w16'range loop
--            lpc_frame <= lpc_dma_w16(i).lframe;
--            lpc_ad <= lpc_dma_w16(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--
--        for i in lpc_dma_w32'range loop
--            lpc_frame <= lpc_dma_w32(i).lframe;
--            lpc_ad <= lpc_dma_w32(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_bm_io_r8'range loop
--            lpc_frame <= lpc_bm_io_r8(i).lframe;
--            lpc_ad <= lpc_bm_io_r8(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_bm_io_r16'range loop
--            lpc_frame <= lpc_bm_io_r16(i).lframe;
--            lpc_ad <= lpc_bm_io_r16(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_bm_io_r32'range loop
--            lpc_frame <= lpc_bm_io_r32(i).lframe;
--            lpc_ad <= lpc_bm_io_r32(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_bm_io_w8'range loop
--            lpc_frame <= lpc_bm_io_w8(i).lframe;
--            lpc_ad <= lpc_bm_io_w8(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_bm_io_w16'range loop
--            lpc_frame <= lpc_bm_io_w16(i).lframe;
--            lpc_ad <= lpc_bm_io_w16(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_bm_io_w32'range loop
--            lpc_frame <= lpc_bm_io_w32(i).lframe;
--            lpc_ad <= lpc_bm_io_w32(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_bm_mem_r8'range loop
--            lpc_frame <= lpc_bm_mem_r8(i).lframe;
--            lpc_ad <= lpc_bm_mem_r8(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_bm_mem_r16'range loop
--            lpc_frame <= lpc_bm_mem_r16(i).lframe;
--            lpc_ad <= lpc_bm_mem_r16(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_bm_mem_r32'range loop
--            lpc_frame <= lpc_bm_mem_r32(i).lframe;
--            lpc_ad <= lpc_bm_mem_r32(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_bm_mem_w8'range loop
--            lpc_frame <= lpc_bm_mem_w8(i).lframe;
--            lpc_ad <= lpc_bm_mem_w8(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_bm_mem_w16'range loop
--            lpc_frame <= lpc_bm_mem_w16(i).lframe;
--            lpc_ad <= lpc_bm_mem_w16(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
--        
--        for i in lpc_bm_mem_w32'range loop
--            lpc_frame <= lpc_bm_mem_w32(i).lframe;
--            lpc_ad <= lpc_bm_mem_w32(i).lad;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--            -- lpc_clk <= not -- lpc_clk;
--            wait for 15 ps;
--        end loop;
        wait for 1 ms;
    end process;    
end Behavioral;
