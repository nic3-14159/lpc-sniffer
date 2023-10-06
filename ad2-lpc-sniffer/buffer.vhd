library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo_buf is
    generic (
        fifo_width : natural := 8;
        fifo_depth : natural := 2048
    );
    port(
        rd_data : out std_logic_vector(fifo_width - 1 downto 0);
        rd_clk : in std_logic;
        rd_en : in std_logic;
        almost_empty : out std_logic;
        empty : out std_logic;

        wr_data : in std_logic_vector(fifo_width - 1 downto 0);
        wr_clk : in std_logic;
        wr_en : in std_logic;
        almost_full : out std_logic;
        full : out std_logic;

        reset : in std_logic
    );
end fifo_buf;

architecture Behavioral of fifo_buf is
    type data_array is array (0 to fifo_depth - 1) of std_logic_vector(fifo_width - 1 downto 0);
    signal RAM: data_array;
    signal rd_addr : natural := 0;
    signal wr_addr : natural := 0;
begin
    process (wr_clk, wr_en, reset)
    begin
        if rising_edge(wr_clk) then
            if reset = '1' then
                wr_addr <= 0;
            else
                if (wr_addr+1) rem fifo_depth = rd_addr then
                    full <= '1';
                else
                    full <= '0';
                    if wr_en = '1' then
                        RAM(wr_addr) <= wr_data;
                        if wr_addr = fifo_depth - 1 then
                            wr_addr <= 0;
                        else
                            wr_addr <= (wr_addr + 1) rem fifo_depth;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    process (rd_clk, rd_en, reset)
    begin
        if rising_edge(rd_clk) then
            if reset = '1' then
                rd_addr <= 0;
            else
                if rd_addr = wr_addr then
                    empty <= '1';
                else
                    empty <= '0';
                    if rd_en = '1' then
                        rd_data <= RAM(rd_addr);
                        if rd_addr = fifo_depth - 1 then
                            rd_addr <= 0;
                        else
                            rd_addr <= (rd_addr + 1) rem fifo_depth;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
