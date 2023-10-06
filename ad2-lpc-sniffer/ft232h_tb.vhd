library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ft232h_tb is
end entity;

architecture Behavioral of ft232h_tb is
    signal data_s: std_logic_vector(7 downto 0);
    signal rx_full_n_s: std_logic := '1';
    signal read_n_s: std_logic;
    signal tx_empty_n_s: std_logic := '1';
    signal write_n_s: std_logic;
    signal ft232_clk_s: std_logic := '0';
    signal output_en_n_s: std_logic;
    signal send_immediate_n_s: std_logic;
    
    signal wr_data_s: std_logic_vector(7 downto 0) := (others => '0');
    signal wr_clk_s: std_logic := '0';
    signal wr_en_s: std_logic := '0';
    signal full_s: std_logic;
    signal reset_fifo_s: std_logic := '0';
begin
    ft232h_inst: entity work.ft232h_fifo(Behavioral)
        port map (
            data => data_s,
            rx_full_n => rx_full_n_s,
            read_n => read_n_s,
            tx_empty_n => tx_empty_n_s,
            write_n => write_n_s,
            ft232_clk => ft232_clk_s,
            output_en_n => output_en_n_s,
            send_immediate_n => send_immediate_n_s,

            wr_data => wr_data_s,
            wr_clk => wr_clk_s,
            wr_en => wr_en_s,
            full => full_s,
            reset_fifo => reset_fifo_s
        );
    process
    begin
        ft232_clk_s <= not ft232_clk_s;
        wait for 10 ns;
    end process;

    process
    begin
        wr_clk_s <= not wr_clk_s;
        wait for 15 ns;
    end process;

    process
    begin
        wait for 20 ns;
        tx_empty_n_s <= '0';
        wait for 209 ns;
        tx_empty_n_s <= '1';
        wait;
    end process;

    process
    begin
        wait for 2 * 30 ns;
        wr_en_s <= '1';
        wr_data_s <= X"de";
        wait for 30 ns;
        wr_data_s <= X"ad";
        wait for 30 ns;
        wr_data_s <= X"be";
        wait for 30 ns;
        wr_data_s <= X"ef";
        wait for 30 ns;
        wr_en_s <= '0';
        wait;
    end process;
end Behavioral;
