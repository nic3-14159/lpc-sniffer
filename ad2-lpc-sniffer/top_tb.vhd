library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.lpc_vectors.all;

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is
    signal lpc_clk: std_logic := '0';
    signal lpc_frame: std_logic := '0';
    signal lpc_reset: std_logic := '0';
    signal lpc_ad: std_logic_vector(3 downto 0) := "1111";
    signal external_reset : std_logic := '1';
    signal led_red : std_logic := '1';
    signal led_green : std_logic := '1';
    signal clk_en : std_logic := '0';

    signal jtag_en_s: std_logic := '0';
    signal data_s: std_logic_vector(7 downto 0);
    signal rx_full_n_s: std_logic := '1';
    signal read_n_s: std_logic;
    signal tx_empty_n_s: std_logic := '1';
    signal write_n_s: std_logic;
    signal ft232_clk_s: std_logic := '0';
    signal output_en_n_s: std_logic;
    signal send_immediate_n_s: std_logic;

    procedure lpc_transaction (
        constant data : in LPC_TEST_DATA;
        signal clk : in std_logic;
        signal ad : out std_logic_vector(3 downto 0);
        signal frame : out std_logic
    ) is
    begin
        for i in data'range loop
            frame <= data(i).lframe;
            ad <= data(i).lad;
            wait until clk = '0';
        end loop;
    end procedure lpc_transaction;

begin
    top_inst: entity work.top(Behavioral)
        port map(
            adbus => data_s,
            rx_full_n => rx_full_n_s,
            read_n => read_n_s,
            tx_empty_n => tx_empty_n_s,
            write_n => write_n_s,
            ft232_clk => ft232_clk_s,
            output_en_n => output_en_n_s,
            send_immediate_n => send_immediate_n_s,
            jtag_en => jtag_en_s,
            lpc_clk => lpc_clk,
            lpc_ad => lpc_ad,
            lpc_frame => lpc_frame,
            lpc_reset => lpc_reset,
            --external_reset => external_reset,
            fifo_full_led => led_red
        );
    ft232_clk_gen : process
    begin
        ft232_clk_s <= not ft232_clk_s;
        wait for 8.333333 ps;
    end process;

    lpc_clk_gen : process
    begin
        lpc_clk <= not lpc_clk and clk_en;
        wait for 15 ps;
    end process;

    process
    begin
        wait for 20 ps;
        tx_empty_n_s <= '0';
        wait;
    end process;

    lpc_bus : process
    begin
        report "start";
        wait for 2 ns;
        report "raise frame";
        lpc_frame <= '1';
        wait for 2 ns;
        report "lower frame";
        lpc_frame <= '0';
        wait for 2 ns;
        report "raise frame";
        lpc_frame <= '1';
        wait for 9.4 ns;
        report "start lpc clk";
        clk_en <= '1';
        wait for 1.1 ns;
        report "release reset";
        lpc_reset <= '1';
        wait for 2 ns;
        report "start test vectors";
        wait until lpc_clk = '0';
--        report "io test vectors";
--        lpc_transaction(lpc_io_read, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_io_write, lpc_clk, lpc_ad, lpc_frame);
--        report "mem test vectors";
--        lpc_transaction(lpc_mem_read, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_mem_write, lpc_clk, lpc_ad, lpc_frame);
--        report "dma test vectors";
--        lpc_transaction(lpc_dma_r8, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_dma_r16, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_dma_r32, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_dma_w8, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_dma_w16, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_dma_w32, lpc_clk, lpc_ad, lpc_frame);
--        report "bm io test vectors";
--        lpc_transaction(lpc_bm_io_r8, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_bm_io_r16, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_bm_io_r32, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_bm_io_w8, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_bm_io_w16, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_bm_io_w32, lpc_clk, lpc_ad, lpc_frame);
--        report "bm mem test vectors";
--        lpc_transaction(lpc_bm_mem_r8, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_bm_mem_r16, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_bm_mem_r32, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_bm_mem_w8, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_bm_mem_w16, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_bm_mem_w32, lpc_clk, lpc_ad, lpc_frame);
--        report "fwh test vectors";
--        lpc_transaction(fwh_r8, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(fwh_r8, lpc_clk, lpc_ad, lpc_frame);
--        report "ec io test vectors";
--        lpc_transaction(ec_command, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(ec_wait, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(ec_wait, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(ec_wait, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(ec_wait, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(ec_wait, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(ec_wait, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(ec_wait, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(ec_wait, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(ec_wait, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(ec_wait, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(ec_done, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_io_84_write, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_io_84_write, lpc_clk, lpc_ad, lpc_frame);
--        lpc_transaction(lpc_io_84_write, lpc_clk, lpc_ad, lpc_frame);
        report "e6400 test vectors";
        lpc_transaction(e6400_test, lpc_clk, lpc_ad, lpc_frame);
        for i in 1 to 10000 loop
            lpc_transaction(ec_wait, lpc_clk, lpc_ad, lpc_frame);
        end loop;
        wait;
    end process;
end Behavioral;
