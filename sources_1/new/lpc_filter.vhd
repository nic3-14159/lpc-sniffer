library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.lpc_types.all;

entity lpc_filter is
    port(
        cycle_addr : in std_logic_vector(31 downto 0);
        cycle_data : in std_logic_vector(31 downto 0);
        cycle_type : in LPC_TYPE;
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
    type pass_array is array (4095 downto 0) of std_logic;
    signal cycle_pass : pass_array;
    signal rdaddr : std_logic_vector(11 downto 0) := (others => '0');
    signal wraddr : std_logic_vector(11 downto 0) := (others => '0');
    signal read_ok : std_logic := '0';
    signal cycle_rdaddr : std_logic_vector(11 downto 0) := (others => '0');
    signal cycle_wraddr : std_logic_vector(11 downto 0) := (others => '0');
    signal cycle_start_addr : std_logic_vector(11 downto 0) := (others => '0');
    signal data_out : std_logic_vector(7 downto 0);
    signal data_available : std_logic := '0';
    signal pass_count : std_logic_vector(3 downto 0);

begin
    process (CLK, WREN, RST)
        impure function pass_data(
            addr : std_logic_vector(31 downto 0);
            data : std_logic_vector(31 downto 0);
            cycle_type : LPC_TYPE)
            return std_logic is
            variable pass : std_logic;
        begin
            if addr(15 downto 0) /= X"0910" and addr(15 downto 0) /= X"0911" then
                pass := '0';
                pass_count <= (others => '0');
            elsif cycle_type = IO_W and addr(15 downto 0) = X"0910" and data(7 downto 0) = X"00" then
                if conv_integer(pass_count) < 5 then
                    pass := '1';
                    pass_count <= pass_count + 1;
                else
                    pass := '0';
                end if;
            elsif cycle_type = IO_R and addr(15 downto 0) = X"0911" and data(7 downto 0) /= X"00" then
                if conv_integer(pass_count) < 5 then
                    pass := '1';
                else
                    pass := '0';
                end if;
            else
                pass := '1';
                pass_count <= (others => '0');
            end if;
            return pass;
        end;
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
                    read_ok <= '1';
                else
                    FULL <= '0';
                end if;
                if rdaddr = wraddr then
                    data_available <= '0';
                end if;
                if rdaddr = cycle_start_addr then
                    read_ok <= '0';
                end if;
                if WREN = '1' then
                    RAM(conv_integer(wraddr)) <= DI;
                    if DI = X"0A" or DI = X"21" then
                        read_ok <= '1';
                        if pass_data(cycle_addr, cycle_data, cycle_type) = '1' then
                            cycle_pass(conv_integer(cycle_wraddr)) <= '1';
                        else
                            cycle_pass(conv_integer(cycle_wraddr)) <= '0';
                        end if;
                        
                        if conv_integer(wraddr) = 4095 then
                            cycle_start_addr <= (others => '0');
                        else
                            cycle_start_addr <= wraddr + 1;
                        end if;
                        if conv_integer(cycle_wraddr) = 4095 then
                            cycle_wraddr <= (others => '0');
                        else
                            cycle_wraddr <= cycle_wraddr + 1;
                        end if;
                    end if;
                    if conv_integer(wraddr) = 4095 then
                        wraddr <= (others => '0');
                    else
                        wraddr <= wraddr + 1;
                    end if;
                end if;
                if RDEN = '1' and rdaddr /= wraddr and read_ok = '1' then
                    data_out <= RAM(conv_integer(rdaddr));
                    data_available <= cycle_pass(conv_integer(cycle_rdaddr));
                    if RAM(conv_integer(rdaddr)) = X"0A" or RAM(conv_integer(rdaddr)) = X"21" then
                        if conv_integer(cycle_rdaddr) = 4095 then
                            cycle_rdaddr <= (others => '0');
                        else
                            cycle_rdaddr <= cycle_rdaddr + 1;
                        end if;
                    end if;
                    if conv_integer(rdaddr) = 4095 then
                        rdaddr <= (others => '0');
                    else
                        rdaddr <= rdaddr + 1;
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
