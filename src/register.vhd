library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg is
port(
    address_A:    in  STD_LOGIC_VECTOR(3 downto 0);
    address_B:    in  STD_LOGIC_VECTOR(3 downto 0);
    address_W:    in  STD_LOGIC_VECTOR(3 downto 0);
    W_Enable:     in  STD_LOGIC;
    W_Data:       in  STD_LOGIC_VECTOR(7 downto 0);
    reset:        in  STD_LOGIC;
    clk:          in  STD_LOGIC;
    A_Data:       out STD_LOGIC_VECTOR(7 downto 0);
    B_Data:       out STD_LOGIC_VECTOR(7 downto 0)
);
end reg;

architecture behavior_reg of reg is
    type memory_array is array(0 to 15) of STD_LOGIC_VECTOR(7 downto 0);
    signal memory: memory_array;
begin

    -- bypass
    A_Data <= memory(to_integer(unsigned(address_A))) when (W_Enable = '0' or address_A /= address_W)
        else W_Data;

    B_Data <= memory(to_integer(unsigned(address_B))) when (W_Enable = '0' or address_B /= address_W)
        else W_Data;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                memory <= (others => (others => '0'));
            elsif W_Enable = '1' then
                memory(to_integer(unsigned(address_W))) <= W_Data;
            end if;
        end if;
    end process;
end behavior_reg;
