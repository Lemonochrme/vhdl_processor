library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemory_TB is
end DataMemory_TB;

architecture Behavioral of DataMemory_TB is
    signal CLK : STD_LOGIC := '0';
    signal RST : STD_LOGIC := '0';
    signal RW_ENABLE : STD_LOGIC := '0';
    signal ADDR : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal DATA_IN : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal DATA_OUT : STD_LOGIC_VECTOR(7 downto 0);

    constant CLOCK_PERIOD : time := 10 ns;  -- Define your clock period here
begin
    -- Instantiate the DataMemory component
    UUT: entity work.DataMemory
        port map (
            CLK => CLK,
            RST => RST,
            RW_ENABLE => RW_ENABLE,
            ADDR => ADDR,
            DATA_IN => DATA_IN,
            DATA_OUT => DATA_OUT
        );

    -- Clock generation process
    CLK_GEN: process
    begin
        while now < 1000 ns loop
            CLK <= not CLK;
            wait for CLOCK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    STIMULUS: process
    begin
        RST <= '1';  -- Reset the memory
        wait for 20 ns;
        RST <= '0';
        wait for 10 ns;
        
        -- Write to memory
        RW_ENABLE <= '0';
        ADDR <= "00000001";
        DATA_IN <= "01010101";
        wait for 20 ns;
        
        -- Read from memory
        RW_ENABLE <= '1';
        ADDR <= "00000001";
        wait for 20 ns;
        
        wait;
    end process;
end Behavioral;
