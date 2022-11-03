library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_tb is
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
