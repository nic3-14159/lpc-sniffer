----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/15/2021 11:07:48 AM
-- Design Name: 
-- Module Name: uart_tb - Behavioral
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

entity uart_tb is
--  Port ( );
end uart_tb;

architecture Behavioral of uart_tb is
    signal clk: std_logic := '0';
    signal tx: std_logic := '1';
begin
    uart_inst: entity work.uart(Behavioral)
        port map(
            txd => tx,
            clk => clk
        );
    process
    begin
        clk <= not clk;
        wait for 200ps;
    end process;    
end Behavioral;
