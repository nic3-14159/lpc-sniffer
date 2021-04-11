----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/15/2021 10:19:45 AM
-- Design Name: 
-- Module Name: uart - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity uart is
    Port (
        txd : out std_logic;
        uart_clk : in std_logic;
        uart_char : in std_logic_vector(7 downto 0);
        uart_read : out std_logic;
        data_available : in std_logic
    );
end uart;

architecture Behavioral of uart is
    signal counter : integer range 0 to 9 := 0;
    signal tx: std_logic := '1';
    signal read : std_logic := '0';
begin
    transmit: process(uart_clk)
    begin
        if falling_edge(uart_clk) then
            if data_available = '1' or not (counter = 0) then
                case counter is
                    when 0 =>
                        tx <= '0';
                        read <= '1';
                        counter <= counter + 1;
                    when 9 =>
                        tx <= '1';
                        counter <= 0;
                    when others => 
                        tx <= uart_char(counter-1);
                        counter <= counter + 1;
                        read <= '0';
                end case;
            else
                tx <= '1';
            end if;
        end if;
    end process;
    txd <= tx;
    uart_read <= read;
end Behavioral;
