library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart is
    Port (
        txd : out std_logic;
        clk : in std_logic;
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
    transmit: process(clk)
    begin
        if falling_edge(clk) then
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
