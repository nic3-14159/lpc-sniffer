----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2021 11:43:03 AM
-- Design Name: 
-- Module Name: lpc - Behavioral
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

entity lpc is
    Port ( lpc_ad : in STD_LOGIC_VECTOR (3 downto 0);
           lpc_frame : in STD_LOGIC;
           lpc_reset : in STD_LOGIC;
           lpc_clk : in STD_LOGIC;
           lpc_data_out : out STD_LOGIC_VECTOR (7 downto 0);
           lpc_have_data : out STD_LOGIC;
           lpc_cycle_addr : out STD_LOGIC_VECTOR (31 downto 0);
           lpc_cycle_data : out STD_LOGIC_VECTOR (31 downto 0)
         );
end lpc;

architecture Behavioral of lpc is
    TYPE LPC_STATE IS (IDLE, START, CTDIR, SIZE, BM_TAR, TAR_A, TAR_B, ADDR_CHANNEL, DATA, SYNC);
    signal state : LPC_STATE := IDLE;
    signal cyc_start : std_logic_vector (3 downto 0) := "0000";
    signal cyc_type_dir : std_logic_vector (3 downto 0) := "0000";
    signal counter : integer range 0 to 8;
    signal TAR_continue : std_logic := '1';
    signal lpc_data : std_logic_vector (7 downto 0) := (others => '0');
    signal have_data : std_logic := '0';
    signal cycle_data : std_logic_vector (31 downto 0) := (others => '0');
    signal cycle_addr : std_logic_vector (31 downto 0) := (others => '0');

    function cycle_type_to_clk(
        cycle_type : std_logic_vector(1 downto 0))
        return integer is       
        variable addr_clks : integer range 0 to 8;
    begin
        case cycle_type is
            when "00" => addr_clks := 4; -- IO
            when "01" => addr_clks := 8; -- Memory
            when "10" => addr_clks := 1; -- DMA
            when others => addr_clks := 0;
        end case;
        return addr_clks;
    end;

    function lad_to_ascii(
        lad : std_logic_vector(3 downto 0))
        return std_logic_vector is
        variable letter : std_logic_vector (7 downto 0);
    begin
        case lad is
            when "0000" => letter := "00110000";
            when "0001" => letter := "00110001";
            when "0010" => letter := "00110010";
            when "0011" => letter := "00110011";
            when "0100" => letter := "00110100";
            when "0101" => letter := "00110101";
            when "0110" => letter := "00110110";
            when "0111" => letter := "00110111";
            when "1000" => letter := "00111000";
            when "1001" => letter := "00111001";
            when "1010" => letter := "01000001";
            when "1011" => letter := "01000010";
            when "1100" => letter := "01000011";
            when "1101" => letter := "01000100";
            when "1110" => letter := "01000101";
            when "1111" => letter := "01000110";
            when others => letter := "00000000";
        end case;
        return letter;
    end;
    
    function state_to_ascii(
        state_in : LPC_STATE)
        return std_logic_vector is
        variable letter : std_logic_vector (7 downto 0);
    begin
        case state_in is
            when IDLE => letter := "00110000";
            when START => letter := "00110001";
            when CTDIR => letter := "00110010";
            when SIZE => letter := "00110011";
            when BM_TAR => letter := "00110100";
            when TAR_A => letter := "00110101";
            when TAR_B => letter := "00110110";
            when ADDR_CHANNEL => letter := "00110111";
            when DATA => letter := "00111000";
            when SYNC => letter := "00111001";
            when others => letter := "00000000";
        end case;
        return letter;
    end;

begin
    readLPC : process(lpc_clk, lpc_reset)
    begin
        if rising_edge(lpc_clk) then
            if lpc_reset = '0' then
                state <= IDLE;
                if lpc_data /= "00001010" then
                    lpc_data <= "00001010";
                    have_data <= '1';
                end if;
            else
                lpc_data <= lad_to_ascii(lpc_ad);
                --lpc_data <= state_to_ascii(state);
                case state is
                    when IDLE =>
                        if have_data = '1' then
                            have_data <= '0';
                        end if;
                        if lpc_frame = '1' then
                            state <= IDLE;
                            have_data <= '0';
                        else
                            cyc_start <= lpc_ad;
                            case lpc_ad is
                                when "0000" | "0010" | "0011" =>
                                    state <= START;
                                    have_data <= '1';
                                when others =>
                                    state <= IDLE;
                                    have_data <= '0';
                            end case;
                            --have_data <= '1';
                        end if;

                    when START =>
                        if lpc_frame = '0' then
                            cyc_start <= lpc_ad;
                            state <= START;
                        else
                            -- Combined START + CTDIR/TAR state to handle multiple START frames
                            -- while maintaining state synchronization with actual bus
                            case cyc_start is
                                when "0000" => -- IO, Memory, or DMA
                                    cyc_type_dir <= lpc_ad;
                                    counter <= cycle_type_to_clk(lpc_ad(3 downto 2));
                                    state <= ADDR_CHANNEL;
                                when "0010" | "0011" => -- Bus Mastering
                                    state <= BM_TAR;
                                when others =>
                                    -- TODO Fix abort mechanism 
                                    state <= IDLE;
                            end case;
                        end if;

                    when CTDIR =>
                        cyc_type_dir <= lpc_ad;
                        counter <= cycle_type_to_clk(lpc_ad(3 downto 2));
                        state <= ADDR_CHANNEL;

                    when SIZE =>
                        case lpc_ad (1 downto 0) is
                            when "00" => counter <= 2;
                            when "01" => counter <= 4;
                            when "11" => counter <= 8;
                            when others => counter <= 0;
                        end case;
                        if lpc_ad (1 downto 0) = "10" then
                            state <= IDLE;
                        else
                            if cyc_type_dir(3) = '1' then -- DMA
                                if cyc_type_dir(1) = '0' then
                                    state <= DATA;
                                else
                                    state <= TAR_A;
                                end if;
                            else
                                if cyc_type_dir(1) = '0' then --Bus Mastering Memory/IO R
                                    state <= TAR_A;
                                else
                                    state <= DATA; --Bus Mastering Memory/IO W
                                end if;
                            end if;
                        end if;
                        TAR_continue <= '1';

                    when BM_TAR =>
                        state <= CTDIR;

                    when TAR_A =>
                        if TAR_continue = '1' then
                            state <= TAR_A;
                            TAR_continue <= '0';
                        else
                            state <= SYNC;
                        end if;

                    when TAR_B =>
                        if TAR_continue = '1' then
                            state <= TAR_B;
                            TAR_continue <= '0';
                        else
                            if counter = 0 then
                                state <= IDLE;
                                lpc_data <= "00001010";
                            else -- only case this occurs is DMA Reads
                                state <= DATA;
                            end if;
                        end if;

                    when ADDR_CHANNEL =>
                        cycle_addr(31 downto 4) <= cycle_addr(27 downto 0);
                        cycle_addr(3 downto 0) <= lpc_ad;
                        -- read addr/channel nibbles from lad
                        if not(counter = 1) then
                            state <= ADDR_CHANNEL;
                            counter <= counter - 1;
                        else
                            if cyc_type_dir(3) = '0' and cyc_start = "0000" then -- IO or Memory
                                counter <= 2; -- IO and Memory cycles require clock cycles for data
                                if cyc_type_dir(1) = '0' then -- Read
                                    state <= TAR_A;
                                else -- Write
                                    state <= DATA;
                                end if;
                                TAR_continue <= '1';
                            else -- DMA or Bus Mastering
                                case lpc_ad(1 downto 0) is -- Size of transfer
                                    when "00" => counter <= 2;
                                    when "01" => counter <= 4;
                                    when "11" => counter <= 8;
                                    when others => counter <= 0; --Assume never driven
                                end case;
                                state <= SIZE;
                            end if;
                        end if;

                    when DATA =>
                        cycle_data(31 downto 4) <= cycle_data(27 downto 0);
                        cycle_data(3 downto 0) <= lpc_ad;
                        if counter rem 2 = 0 then
                            state <= DATA;
                        else
                            if cyc_type_dir(3 downto 2) = "10" then -- DMA
                                if cyc_type_dir(1) = '0' then -- Read
                                    state <= TAR_A;
                                else
                                    if counter = 1 then
                                        state <= TAR_B;
                                    else
                                        state <= SYNC;
                                    end if;
                                end if;
                            else -- Not DMA
                                if counter = 1 then -- Last data clock cycle
                                    if cyc_type_dir(1) = '0' then -- Read
                                        state <= TAR_B;
                                    else -- Write
                                        state <= TAR_A;
                                    end if;
                                else -- Account for multiple Bus Master data cycles
                                    state <= DATA;
                                end if;
                            end if;
                        end if;
                        counter <= counter - 1;
                        TAR_continue <= '1';

                    when SYNC =>
                        case lpc_ad is
                            when "0000" | "1001" | "1010" =>
                                if cyc_type_dir(3 downto 2) = "10" then --DMA
                                    if cyc_type_dir(1) = '0' then
                                        state <= TAR_B;
                                    else
                                        state <= DATA;
                                    end if;
                                else
                                    if cyc_type_dir(1) = '0' then
                                        state <= DATA;
                                    else
                                        state <= TAR_B;
                                    end if;
                                end if;
                                TAR_continue <= '1';
                            when "0101" | "0110" =>
                                state <= SYNC;
                            when others =>
                                state <= IDLE;
                                lpc_data <= "00100001";
                        end case;
                end case; 
            end if;
        end if;
    end process;
    lpc_output : process (lpc_clk)
    begin
        if falling_edge(lpc_clk) then
            lpc_data_out <= lpc_data;
            lpc_have_data <= have_data;
            lpc_cycle_data <= cycle_data;
            lpc_cycle_addr <= cycle_addr;
        end if;
    end process;
end Behavioral;
