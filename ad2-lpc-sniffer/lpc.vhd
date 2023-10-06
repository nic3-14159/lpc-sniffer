library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.lpc_types.all;

entity lpc is
    Port ( lpc_ad : in STD_LOGIC_VECTOR (3 downto 0);
           lpc_frame : in STD_LOGIC;
           lpc_reset : in STD_LOGIC;
           lpc_clk : in STD_LOGIC;
           lpc_data_out : out STD_LOGIC_VECTOR (7 downto 0);
           lpc_have_data : out STD_LOGIC;
           lpc_cycle_addr : out STD_LOGIC_VECTOR (31 downto 0);
           lpc_cycle_data : out STD_LOGIC_VECTOR (31 downto 0);
           lpc_cycle_type : out LPC_TYPE;
           lpc_debug_state : out STD_LOGIC_VECTOR (3 downto 0)
         );
         
end lpc;

architecture Behavioral of lpc is
    signal state : LPC_STATE := IDLE;
    signal cyc_start : std_logic_vector (3 downto 0) := "0000";
    signal cyc_type_dir : std_logic_vector (3 downto 0) := "0000";
    signal counter : integer range 0 to 256;
    signal state_continue : std_logic := '1';
    signal lpc_ad_reg : std_logic_vector (3 downto 0):= "0000";
    signal lpc_have_data_s : std_logic;
    signal lpc_cycle_addr_s : STD_LOGIC_VECTOR (31 downto 0);
    signal lpc_cycle_data_s : STD_LOGIC_VECTOR (31 downto 0);

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

    function hex_to_ascii(
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

    function state_to_bin(
        state_in : LPC_STATE)
        return std_logic_vector is
        variable hex : std_logic_vector (3 downto 0);
    begin
        case state_in is
            when IDLE => hex := "0000";
            when START => hex := "0001";
            when CTDIR => hex := "0010";
            when SIZE => hex := "0011";
            when BM_TAR => hex := "0100";
            when TAR_A => hex := "0101";
            when TAR_B => hex := "0110";
            when ADDR_CHANNEL => hex := "0111";
            when DATA => hex := "1000";
            when SYNC => hex := "1001";
            when others => hex := "1111";
        end case;
        return hex;
    end;

begin
    readLPC : process(lpc_clk, lpc_reset)
    begin
        if rising_edge(lpc_clk) then
            if lpc_reset = '0' then
                state <= IDLE;
                lpc_data_out <= (others => '0');
                lpc_have_data_s <= '0';
                lpc_cycle_addr_s <= (others => '0');
                lpc_cycle_data_s <= (others => '0');
                lpc_cycle_type <= OTHER;
                lpc_ad_reg <= lpc_ad;
            else
                lpc_data_out <= hex_to_ascii(lpc_ad);
                lpc_ad_reg <= lpc_ad;

                --lpc_data <= state_to_ascii(state);
                case state is
                    when IDLE =>
                        if lpc_have_data_s = '1' then
                            lpc_have_data_s <= '0';
                        end if;
                        if lpc_frame = '1' then
                            state <= IDLE;
                            lpc_have_data_s <= '0';
                        else
                            cyc_start <= lpc_ad;
                            case lpc_ad is
                                when "0000" | "0010" | "0011" | "1101" | "1110" =>
                                    state <= START;
                                    lpc_have_data_s <= '1';
                                    lpc_cycle_addr_s <= (others => '0');
                                    lpc_cycle_data_s <= (others => '0');
                                when others =>
                                    state <= IDLE;
                                    lpc_have_data_s <= '0';
                            end case;
                        end if;

                    when START =>
                        if lpc_frame = '0' then
                            cyc_start <= lpc_ad;
                            state <= START;
                        else
                            case cyc_start is
                                when "0000" => -- IO, Memory, or DMA
                                    state <= CTDIR;
                                when "0010" | "0011" => -- Bus Mastering
                                    state <= BM_TAR;
                                when "1101" =>
                                    state <= ADDR_CHANNEL;
                                    counter <= 8;
                                    cyc_type_dir <= "0100"; -- Fake memory read to reuse logic
                                when "1110" =>
                                    state <= ADDR_CHANNEL;
                                    counter <= 8;
                                    cyc_type_dir <= "0110"; -- Fake memory write to reuse logic
                                when others =>
                                    -- TODO Fix abort mechanism 
                                    state <= IDLE;
                            end case;
                        end if;

                    when CTDIR =>
                        cyc_type_dir <= lpc_ad_reg;
                        case cyc_start is
                            when "0000" => -- IO, Memory, or DMA
                                counter <= cycle_type_to_clk(lpc_ad_reg(3 downto 2));
                                state <= ADDR_CHANNEL;
                            when "0010" | "0011" => -- Bus Mastering
                                state <= ADDR_CHANNEL;
                                counter <= cycle_type_to_clk(lpc_ad_reg(3 downto 2));
                            when "1101" =>
                                state <= ADDR_CHANNEL;
                                counter <= 8;
                                cyc_type_dir <= "0100"; -- Fake memory read to reuse logic
                            when "1110" =>
                                state <= ADDR_CHANNEL;
                                counter <= 8;
                                cyc_type_dir <= "0110"; -- Fake memory write to reuse logic
                            when others =>
                                -- TODO Fix abort mechanism 
                                state <= IDLE;
                        end case;

                    when SIZE =>
                        -- FWH
                        if cyc_start = "1101" or cyc_start = "1110" then
                            case lpc_ad_reg is
                                when "0000" => counter <= 2;
                                when "0001" => counter <= 4;
                                when "0010" => counter <= 8;
                                when "0100" => counter <= 32;
                                when "0111" => counter <= 256;
                                when others => counter <= 0;
                            end case;
                        else
                            case lpc_ad_reg (1 downto 0) is
                                when "00" => counter <= 2;
                                when "01" => counter <= 4;
                                when "11" => counter <= 8;
                                when others => counter <= 0;
                            end case;
                        end if;
                        case cyc_start is
                            when "1101" => -- FWH Read
                                state <= TAR_A;
                            when "1110" => -- FWH Write
                                state <= DATA;
                            when "0000" => -- DMA
                                if lpc_ad_reg (1 downto 0) = "10" then
                                    state <= IDLE;
                                else 
                                    if cyc_type_dir(1) = '0' then
                                        state <= DATA;
                                    else
                                        state <= TAR_A;
                                    end if;
                                end if;
                            when "0010" | "0011" => -- BM Memory/IO
                                if cyc_type_dir(1) = '0' then --Bus Mastering Memory/IO R
                                    state <= TAR_A;
                                else
                                    state <= DATA; --Bus Mastering Memory/IO W
                                end if;
                            when others =>
                                state <= IDLE; -- Should never get here
                        end case;
                        state_continue <= '1';

                    when BM_TAR =>
                        state <= CTDIR;

                    when TAR_A =>
                        if state_continue = '1' then
                            state <= TAR_A;
                            state_continue <= '0';
                        else
                            state <= SYNC;
                            state_continue <= '1';
                        end if;

                    when TAR_B =>
                        if state_continue = '1' then
                            state <= TAR_B;
                            state_continue <= '0';
                        else
                            if counter = 0 then
                                state <= IDLE;
                                lpc_data_out <= "00001010";
                            else -- only case this occurs is DMA Reads
                                state <= DATA;
                            end if;
                        end if;

                    when ADDR_CHANNEL =>
                        lpc_cycle_addr_s <= lpc_cycle_addr_s(27 downto 0) & lpc_ad_reg;
                        -- read addr/channel nibbles from lad
                        if not(counter = 1) then
                            state <= ADDR_CHANNEL;
                            counter <= counter - 1;
                        else
                            if cyc_start = "1101" or cyc_start = "1110" then -- FWH Read/Write
                                state <= SIZE;
                            elsif cyc_type_dir(3) = '0' and cyc_start = "0000" then -- IO or Memory
                                counter <= 2; -- IO and Memory cycles require clock cycles for data
                                if cyc_type_dir(1) = '0' then -- Read
                                    state <= TAR_A;
                                else -- Write
                                    state <= DATA;
                                end if;
                                state_continue <= '1';
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
                        lpc_cycle_data_s <= lpc_cycle_data_s(27 downto 0) & lpc_ad_reg;
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
                                        state_continue <= '1';
                                    end if;
                                end if;
                            else -- Not DMA
                                if counter = 1 then -- Last data clock cycle
                                    if cyc_type_dir(1) = '0' then -- Read
                                        state <= TAR_B;
                                    else -- Write
                                        state <= TAR_A;
                                    end if;
                                else -- Account for multiple Bus Master/FWH data cycles
                                    state <= DATA;
                                end if;
                            end if;
                        end if;
                        counter <= counter - 1;
                        state_continue <= '1';

                    when SYNC =>
                        case lpc_ad_reg is
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
                            when "0101" | "0110" =>
                                state <= SYNC;
                            when "1111" =>
                                if lpc_frame = '1' then
                                    state <= SYNC;
                                    lpc_data_out <= "00100001";
                                else
                                    state <= IDLE;
                                    lpc_data_out <= "00001010";
                                end if;
                            when others =>
                                state <= IDLE;
                                lpc_data_out <= "00100001";
                        end case;
                        state_continue <= '1';
                end case; 
                case cyc_start is
                    when "0000" =>
                        case cyc_type_dir(3 downto 1) is
                            when "000" => lpc_cycle_type <= IO_R;
                            when "001" => lpc_cycle_type <= IO_W;
                            when "010" => lpc_cycle_type <= MEM_R;
                            when "011" => lpc_cycle_type <= MEM_W;
                            when "100" => lpc_cycle_type <= DMA_R;
                            when "101" => lpc_cycle_type <= DMA_W;
                            when others => lpc_cycle_type <= OTHER;
                        end case;
                    when "0010" | "0011" =>
                        case cyc_type_dir(3 downto 1) is
                            when "000" => lpc_cycle_type <= BM_IO_R;
                            when "001" => lpc_cycle_type <= BM_IO_W;
                            when "010" => lpc_cycle_type <= BM_MEM_R;
                            when "011" => lpc_cycle_type <= BM_MEM_W;
                            when others => lpc_cycle_type <= OTHER;
                        end case;
                    when "1101" =>
                        lpc_cycle_type <= FWH_R;
                    when "1110" =>
                        lpc_cycle_type <= FWH_W;
                    when others => lpc_cycle_type <= OTHER;
                end case;
            end if;
        end if;
    end process;
    lpc_debug_state <= state_to_bin(state);
    lpc_have_data <= lpc_have_data_s;
    lpc_cycle_addr <= lpc_cycle_addr_s;
    lpc_cycle_data <= lpc_cycle_data_s;
end Behavioral;
