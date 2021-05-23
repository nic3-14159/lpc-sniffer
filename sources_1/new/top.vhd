----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/29/2020 11:11:38 PM
-- Design Name: 
-- Module Name: test - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;
library UNIMACRO;
use unimacro.Vcomponents.all;

library work;
use work.lpc_types.all;

entity top is
    port(
        uart_txd : out STD_LOGIC;
        uart_clk : in STD_LOGIC;
        lpc_clk : in STD_LOGIC;
        lpc_ad : in STD_LOGIC_VECTOR (3 downto 0);
        lpc_frame : in STD_LOGIC;
        lpc_reset : in STD_LOGIC;
        reset_all : in STD_LOGIC;
        fifo_full_led : out STD_LOGIC;
        led_green : out STD_LOGIC
    );
end top;

architecture Behavioral of top is
-- FIFO signals
signal fifo_out : std_logic_vector(7 downto 0);
signal fifo_read_en : std_logic := '0';
signal fifo_write_en : std_logic := '0';
signal fifo_empty : std_logic := '1';
signal fifo_full : std_logic := '0';
signal fifo_reset : std_logic := '1';

-- LPC State Machine signals
signal lpc_have_data : std_logic := '0';
signal lpc_data : std_logic_vector(7 downto 0);
signal cycle_data : std_logic_vector(31 downto 0);
signal cycle_addr : std_logic_vector(31 downto 0);
signal cycle_type : LPC_TYPE;
signal lpc_combined_rst : std_logic := '0';

-- For UART
signal uart_read : std_logic := '0';
signal fifo_have_data : std_logic := '0';

signal counter : std_logic_vector(3 downto 0) := "0000";

signal filter_have_data : std_logic := '0';
signal filter_data : std_logic_vector(7 downto 0);
signal filter_full : std_logic := '0';
signal filter_read_en : std_logic := '0';
signal filter_write_en : std_logic := '0';

begin
    ps7_stub: entity work.ps7_stub(RTL);
    uart_inst: entity work.uart(Behavioral)
        port map(
            clk => uart_clk,
            txd => uart_txd,
            uart_char => fifo_out,
            uart_read => uart_read,
            data_available => fifo_have_data
        );
    lpc_inst: entity work.lpc(Behavioral)
        port map(
            lpc_ad => lpc_ad,
            lpc_frame => lpc_frame,
            lpc_clk => lpc_clk,
            lpc_reset => lpc_combined_rst,
            lpc_data_out => lpc_data,
            lpc_have_data => lpc_have_data,
            lpc_cycle_addr => cycle_addr,
            lpc_cycle_data => cycle_data,
            lpc_cycle_type => cycle_type
        );
    fifo_inst: entity work.fifo_buf(Behavioral)
        port map(
            DO => fifo_out,
            EMPTY => fifo_empty,
            FULL => fifo_full,
            DI => filter_data,
            RDCLK => uart_clk,
            RDEN => fifo_read_en,
            RST => fifo_reset,
            WRCLK => lpc_clk,
            WREN => fifo_write_en
        );
    lpc_filter_inst: entity work.lpc_filter(Behavioral)
    port map(
        cycle_addr => cycle_addr, --in std_logic_vector(31 downto 0);
        cycle_data => cycle_data, --in std_logic_vector(31 downto 0);
        cycle_type => cycle_type,
        have_data => filter_have_data, --out std_logic;
        DO => filter_data, --out std_logic_vector(7 downto 0);
        FULL => filter_full, --out std_logic;
        DI => lpc_data, --in std_logic_vector(7 downto 0);
        CLK => lpc_clk, --in std_logic;
        RST => fifo_reset, --in std_logic;
        WREN => filter_write_en, --in std_logic;
        RDEN => filter_read_en --in std_logic
    );
    reset : process (uart_clk)
    begin
        if rising_edge(uart_clk) then
            if reset_all = '0' then
                counter <= "0000";
                fifo_reset <= '1';
            else
                if counter(3) = '0' then
                    counter <= counter + '1';
                else
                    counter <= counter;
                    fifo_reset <= '0';
                end if;
            end if;
        end if;
    end process;
    
    fifo_write_en <= filter_have_data and not fifo_full and not fifo_reset;
    filter_write_en <= lpc_have_data and not filter_full and not fifo_reset;
    fifo_read_en <= uart_read and not fifo_reset;
    filter_read_en <= not fifo_full and not fifo_reset;
    fifo_have_data <= not fifo_empty and not fifo_reset;
    lpc_combined_rst <= lpc_reset or not fifo_reset;
    fifo_full_led <= not fifo_full;
    led_green <= not filter_full;
end Behavioral;
