library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity lpc_filter is
    port(
        lpc_addr : in std_logic_vector(31 downto 0);
        lpc_data : in std_logic_vector(31 downto 0);
        have_data : out std_logic;
        DO : out std_logic_vector(7 downto 0);
        FULL : out std_logic;
        DI : in std_logic_vector(7 downto 0);
        CLK : in std_logic;
        RST : in std_logic;
        WREN : in std_logic;
        RDEN : in std_logic
    );
    attribute RAM_STYLE : string;
    attribute RAM_STYLE of lpc_filter: entity is "BLOCK";
end lpc_filter;

architecture Behavioral of lpc_filter is
    type data_array is array (4095 downto 0) of std_logic_vector(7 downto 0);
    signal RAM : data_array;
    signal cycle_start : data_array;
    signal rdaddr : std_logic_vector(11 downto 0) := (others => '0');
    signal wraddr : std_logic_vector(11 downto 0) := (others => '0');
    signal read_ok : std_logic := '0';
    signal cycle_rdaddr : std_logic_vector(11 downto 0) := (others => '0');
    signal cycle_wraddr : std_logic_vector(11 downto 0) := (others => '0');
    signal cycle_size : std_logic_vector(7 downto 0) := (others => '0');
    signal finished_cycle : std_logic := '1';
    signal data_out : std_logic_vector(7 downto 0);
    signal data_available : std_logic := '0';
    
    function pass_data(
        addr : std_logic_vector(31 downto 0);
        data : std_logic_vector(31 downto 0))
        return std_logic is
        variable pass : std_logic;
    begin
        if addr(15 downto 0) = X"0910" and data(7 downto 0) = X"00" then
            pass := '0';
        elsif addr(15 downto 0) = X"0911" and data(7 downto 0) /= X"00" then
            pass := '0';
        else
            pass := '1';
        end if;
        return pass;
    end;

begin
    process (CLK, WREN, RST)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                wraddr <= (others => '0');
                rdaddr <= (others => '0');
                cycle_wraddr <= (others => '0');
                cycle_rdaddr <= (others => '0');
            else
                if conv_integer(wraddr) = conv_integer(rdaddr - 1) then
                    FULL <= '1';
                else
                    FULL <= '0';
                    if WREN = '1' then
                        RAM(conv_integer(wraddr)) <= DI;
                        cycle_size <= cycle_size + 1;
                        if DI = X"0A" then
                            read_ok <= '1';
                            if pass_data(lpc_addr, lpc_data) = '1' then
                                cycle_start(conv_integer(cycle_wraddr)) <= X"00";         
                            else
                                cycle_start(conv_integer(cycle_wraddr)) <= cycle_size + 1;
                            end if;
                            cycle_wraddr <= cycle_wraddr + 1;
                            cycle_size <= (others => '0');
                        end if;
                        if conv_integer(wraddr) = 4095 then
                            wraddr <= (others => '0');
                        else
                            wraddr <= wraddr + 1;
                        end if;
                    end if;
                    if rdaddr /= wraddr then
                        if read_ok = '1' and RDEN = '1' then
                            if finished_cycle <= '1' then
                                rdaddr <= rdaddr + cycle_start(conv_integer(cycle_rdaddr));
                                cycle_rdaddr <= cycle_rdaddr + 1;
                                finished_cycle <= '0';
                            end if;
                            if RAM(conv_integer(rdaddr)) /= X"0A" then
                                data_out <= RAM(conv_integer(rdaddr));
                                data_available <= '1';
                                if conv_integer(rdaddr) = 4095 then
                                    rdaddr <= (others => '0');
                                else
                                    rdaddr <= rdaddr + 1;
                                end if;
                            else
                                finished_cycle <= '1';
                            end if;
                        end if;
                    else
                        read_ok <= '0';
                        data_available <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
    process (CLK)
    begin
        if falling_edge(CLK) then
            DO <= data_out;
            have_data <= data_available;
        end if;
    end process;
end Behavioral;
