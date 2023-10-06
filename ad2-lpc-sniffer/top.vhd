library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.lpc_types.all;

entity top is
	port (
        -- FT232H signals
	adbus : inout std_logic_vector(7 downto 0);
        rx_full_n: in std_logic; -- low when data available to read
        read_n: out std_logic;
        tx_empty_n: in std_logic; -- low when space available to write
        write_n: out std_logic;
        ft232_clk : in std_logic; -- Fixed at 60 MHz
        output_en_n: out std_logic; -- low to read from ft232
        send_immediate_n: out std_logic;
        jtag_en : in std_logic;
        lpc_clk : in STD_LOGIC;
        lpc_ad : in STD_LOGIC_VECTOR (3 downto 0);
        lpc_frame : in STD_LOGIC;
        lpc_reset : in STD_LOGIC;
        --external_reset : in STD_LOGIC;
        fifo_full_led : out STD_LOGIC
	);
end top;

architecture Behavioral of top is
    signal ft232_data : std_logic_vector(7 downto 0);
    -- LPC State Machine signals
    signal lpc_have_data : std_logic := '0';
    signal lpc_data : std_logic_vector(7 downto 0);
    signal cycle_data : std_logic_vector(31 downto 0);
    signal cycle_addr : std_logic_vector(31 downto 0);
    signal cycle_type : LPC_TYPE;

    signal reset : std_logic := '1';
    signal fifo_write_en : std_logic := '0';
    signal fifo_full : std_logic := '0';

    signal filter_have_data : std_logic := '0';
    signal filter_data : std_logic_vector(7 downto 0);
    signal filter_full : std_logic := '0';
    signal filter_read_en : std_logic := '0';
    signal filter_write_en : std_logic := '0';
    signal fifo_reset : std_logic := '0';
    signal external_reset : std_logic := '1';
begin
    ft232h_inst: entity work.ft232h_fifo(Behavioral)
        port map (
            data => ft232_data,
            rx_full_n => rx_full_n,
            read_n => read_n,
            tx_empty_n => tx_empty_n,
            write_n => write_n,
            ft232_clk => ft232_clk,
            output_en_n => output_en_n,
            send_immediate_n => send_immediate_n,

            wr_data => filter_data,
            wr_clk => lpc_clk,
            wr_en => fifo_write_en,
            full => fifo_full,
            reset_fifo => fifo_reset
        );
    lpc_inst: entity work.lpc(Behavioral)
        port map(
            lpc_ad => lpc_ad,
            lpc_frame => lpc_frame,
            lpc_clk => lpc_clk,
            lpc_reset => reset,
            lpc_data_out => lpc_data,
            lpc_have_data => lpc_have_data,
            lpc_cycle_addr => cycle_addr,
            lpc_cycle_data => cycle_data,
            lpc_cycle_type => cycle_type,
            lpc_debug_state => open
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
            RST => reset, --in std_logic;
            WREN => filter_write_en, --in std_logic;
            RDEN => filter_read_en --in std_logic
        );

    process (jtag_en, ft232_data)
    begin
        if jtag_en = '0' then
            adbus <= ft232_data;
        else
            adbus <= (others => 'Z');
        end if;
    end process;
    fifo_write_en <= filter_have_data and not fifo_full and reset;
    filter_write_en <= lpc_have_data and not filter_full and reset;
    filter_read_en <= not fifo_full and reset;
    fifo_reset <= not reset;
    reset <= lpc_reset and external_reset;
    fifo_full_led <= fifo_full;
end Behavioral;
