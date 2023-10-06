-- Async FIFO wrapper for the FT232H synchronous FIFO interface allowing
-- other logic to push data to the FT232H at an arbitrary clock speed

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ft232h_fifo is
	port (
		-- FT232H interface signals
		data: inout std_logic_vector(7 downto 0);
		rx_full_n: in std_logic; -- low when data available to read
		read_n: out std_logic;
		tx_empty_n: in std_logic; -- low when space available to write
		write_n: out std_logic;
		ft232_clk : in std_logic; -- Fixed at 60 MHz
		output_en_n: out std_logic; -- low to read from ft232
		send_immediate_n: out std_logic;

		-- async buffer write channel signals
		wr_data : in std_logic_vector(7 downto 0);
		wr_clk : in std_logic; -- arbitrary
		wr_en : in std_logic;
		full : out std_logic;

		reset_fifo : in std_logic
	);
end ft232h_fifo;

architecture Behavioral of ft232h_fifo is
	signal bus_turnaround : std_logic := '0';
	signal write_n_s : std_logic := '0';
	signal fifo_empty : std_logic := '0';
	signal fifo_read : std_logic := '0';
begin
	buffer_inst: entity work.fifo_buf(Behavioral)
		generic map (
			fifo_width => 8,
			fifo_depth => 16384
		)
		port map (
			rd_data => data,
			rd_clk => ft232_clk,
			rd_en => fifo_read,
			almost_empty => open,
			empty => fifo_empty,

			wr_data => wr_data,
			wr_clk => wr_clk,
			wr_en => wr_en,
			almost_full => open,
			full => full,

			reset => reset_fifo
		);
	output_en_n <= '1';
	send_immediate_n <= '1';
	write_n_s <= not (bus_turnaround and not tx_empty_n and not fifo_empty);
	write_n <= not fifo_read;
	fifo_read <= not write_n_s;
	read_n <= '1';
	process (ft232_clk)
	begin
		if rising_edge(ft232_clk) then
			if bus_turnaround = '0' then
				bus_turnaround <= '1';
			else
				bus_turnaround <= bus_turnaround;
			end if;
		end if;
	end process;
end Behavioral;

