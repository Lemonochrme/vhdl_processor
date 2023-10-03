library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemory is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           RW_ENABLE : in STD_LOGIC;
           ADDR : in STD_LOGIC_VECTOR(7 downto 0);
           DATA_IN : in STD_LOGIC_VECTOR(7 downto 0);
           DATA_OUT : out STD_LOGIC_VECTOR(7 downto 0));
end DataMemory;

architecture Behavioral of DataMemory is
    type MemoryArray is array (0 to 255) of STD_LOGIC_VECTOR(7 downto 0);
    signal Memory : MemoryArray := (others => X"00");
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            Memory <= (others => X"00");  -- Reset the memory to 0x00
        elsif rising_edge(CLK) then 
            if RW_ENABLE = '1' then -- Read
                DATA_OUT <= Memory(to_integer(unsigned(ADDR)));
            else -- Write
                Memory(to_integer(unsigned(ADDR))) <= DATA_IN;
            end if;
        end if;
    end process;
end Behavioral;
