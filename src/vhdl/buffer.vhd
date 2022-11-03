library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity fifo_buf is
    port(            
        DO : out std_logic_vector(7 downto 0);
        EMPTY : out std_logic;
        FULL : out std_logic;
        DI : in std_logic_vector(7 downto 0);
        RDCLK : in std_logic;
        RDEN : in std_logic;
        RST : in std_logic;
        WRCLK : in std_logic;
        WREN : in std_logic
    );
    attribute RAM_STYLE : string;
    attribute RAM_STYLE of fifo_buf: entity is "BLOCK";
end fifo_buf;

architecture Behavioral of fifo_buf is
    type data_array is array (229375 downto 0) of std_logic_vector(7 downto 0);
    signal RAM: data_array;
    signal rdaddr : std_logic_vector(17 downto 0) := (others => '0');
    signal wraddr : std_logic_vector(17 downto 0) := (others => '0');
begin
    process (WRCLK, WREN, RST)
    begin
        if rising_edge(WRCLK) then
            if RST = '1' then
                wraddr <= (others => '0');
            else
                if conv_integer(wraddr) = conv_integer(rdaddr - 1) then
                    FULL <= '1';
                else
                    FULL <= '0';
                    if WREN = '1' then
                        RAM(conv_integer(wraddr)) <= DI;
                        if conv_integer(wraddr) = 229375 then
                            wraddr <= (others => '0');
                        else
                            wraddr <= wraddr + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    process (RDCLK, RDEN, RST)
    begin
        if rising_edge(RDCLK) then
            if RST = '1' then
                rdaddr <= (others =>'0');
            else
                if rdaddr = wraddr then
                    EMPTY <= '1';
                else
                    EMPTY <= '0';
                    if RDEN = '1' then
                        DO <= RAM(conv_integer(rdaddr));
                        if conv_integer(rdaddr) = 229375 then
                            rdaddr <= (others => '0');
                        else
                            rdaddr <= rdaddr + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
