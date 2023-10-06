library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.lpc_types.all;

entity lpc_filter is
    generic (
        buffer_depth : natural := 4096
    );
    port(
        cycle_addr : in std_logic_vector(31 downto 0); -- address of cycle, for filter
        cycle_data : in std_logic_vector(31 downto 0); -- cycle data, for filter
        cycle_type : in LPC_TYPE; -- cycle type, for filter
        have_data : out std_logic; -- status signal, filter buffer is not empty
        DO : out std_logic_vector(7 downto 0); -- Data output of filter
        FULL : out std_logic; --Status signal, filter buffer is full
        DI : in std_logic_vector(7 downto 0); -- Data input of filter
        CLK : in std_logic;
        RST : in std_logic; -- reset
        WREN : in std_logic; -- write enable, lpc has data
        RDEN : in std_logic -- read enable, fifo buffer can read data
    );
    attribute RAM_STYLE : string;
    attribute RAM_STYLE of lpc_filter: entity is "BLOCK";
end lpc_filter;

architecture Behavioral of lpc_filter is
    type data_array is array (0 to buffer_depth - 1) of std_logic_vector(7 downto 0);
    signal RAM : data_array := (others => (others => '0')); -- buffer for data
    -- addresses for RAM array
    signal rdaddr : natural range 0 to buffer_depth - 1 := 0;
    signal wraddr : natural range 0 to buffer_depth - 1 := 0;

    type pass_array is array (0 to buffer_depth - 1) of std_logic;
    signal cycle_pass : pass_array := (others => '0'); -- array of bits, each indicating whether the cycle should pass
    -- addresses for cycle_pass array
    signal cycle_rdaddr : natural range 0 to buffer_depth - 1 := 0;
    signal cycle_wraddr : natural range 0 to buffer_depth - 1 := 0;
    signal cycle_start_addr : natural range 0 to buffer_depth - 1 := 0;

    -- For filter function
    signal pass_count : natural range 0 to 7 := 0;
    signal last_addr : std_logic_vector(31 downto 0) := (others => '0');
    signal last_data : std_logic_vector(31 downto 0) := (others => '0');
    signal last_cycle_type : LPC_TYPE := OTHER;
begin
    process (CLK, RST)
        impure function pass_data(
            addr : std_logic_vector(31 downto 0);
            data : std_logic_vector(31 downto 0);
            cyc_type : LPC_TYPE)
            return std_logic is
            variable pass : std_logic;
        begin
            --if addr(15 downto 0) = X"03F8" and cycle_type = IO_W then
                --pass := '1';
            --else
                --pass := '0';
            --end if;
            case cycle_type is
            when IO_W =>
                case addr(15 downto 0) is
                when X"0910" =>
                    if data(7 downto 0) = X"00" then
                        if pass_count < 5 then
                            pass := '1';
                            pass_count <= pass_count + 1;
                        else
                            pass := '0';
                        end if;
                    else
                        pass := '1';
                        pass_count <= 0;
                    end if;
                when X"0084" =>
                    pass := '0';
                    pass_count <= 0;
                when others =>
                    pass := '1';
                end case;
            when IO_R =>
                case addr(15 downto 0) is
                when X"0911" =>
                    if data(7 downto 0) /= X"00" then
                        if pass_count < 5 then
                            pass := '1';
                        else
                            pass := '0';
                        end if;
                    else
                        pass := '1';
                        pass_count <= 0;
                    end if;
                when others =>
                    pass := '1';
                    pass_count <= 0;
                end case;
            when others =>
                pass := '1';
                pass_count <= 0;
            end case;

--            if last_addr = addr and last_data = data and last_cycle_type = cyc_type then
--                if pass_count < 5 then
--                    pass := '1';
--                    pass_count <= pass_count + 1;
--                else
--                    pass := '0';
--                end if;
--            else
--                pass := '1';
--                pass_count <= 0;
--            end if;

            last_addr <= addr;
            last_data <= data;
            last_cycle_type <= cyc_type;
            return pass;
        end;
    begin
        if rising_edge(CLK) then
            if RST = '0' then
                wraddr <= 0;
                rdaddr <= 0;
                cycle_wraddr <= 0;
                cycle_rdaddr <= 0;
                DO <= (others => '0');
                FULL <= '0';
                cycle_start_addr <= 0;
                pass_count <= 0;
                last_addr <= (others => '0');
                last_data <= (others => '0');
                last_cycle_type <= OTHER;
            else
                if (wraddr + 1) rem buffer_depth = rdaddr then
                    FULL <= '1';
                else
                    FULL <= '0';
                end if;
                if WREN = '1' then
                    RAM(wraddr) <= DI;
                    if DI = X"0A" then
                        cycle_pass(cycle_wraddr) <= pass_data(cycle_addr, cycle_data, cycle_type);
                        cycle_wraddr <= (cycle_wraddr + 1) rem buffer_depth;
                        cycle_start_addr <= (wraddr + 1) rem buffer_depth;
                    end if;
                    wraddr <= (wraddr + 1) rem buffer_depth;
                end if;
                if RDEN = '1' then
                    DO <= RAM(rdaddr);
                    if rdaddr = wraddr or rdaddr = cycle_start_addr then -- filter empty
                        have_data <= '0';
                    else
                        have_data <= cycle_pass(cycle_rdaddr);
                        rdaddr <= (rdaddr + 1) rem buffer_depth;
                    end if;
                    if RAM(rdaddr) = X"0A" then
                        cycle_rdaddr <= (cycle_rdaddr + 1) rem buffer_depth;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
