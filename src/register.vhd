library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
    -- Array of STD_LOGIC_VECTOR
    type memory_array is array(0 to 15) of
        STD_LOGIC_VECTOR(7 downto 0);
    -- Memory variable
    signal memory: memory_array;
begin
    
    -- Convert address_A and address_B to integers
    -- Using Bypass to avoid delay between Read Data and Write Data if they are at the same time called (WEnable = 1)
    A_Data <= memory(CONV_INTEGER(unsigned(address_A))) when (W_Enable = '0' or address_A /= address_W)
        else W_Data;
    
    B_Data <= memory(CONV_INTEGER(unsigned(address_B))) when (W_Enable = '0' or address_B /= address_W)
        else W_Data;
    
    -- Write data synchronously
    process(clk) is
    begin
        -- Reset the memory if shutdown
        if reset = '0' then
            memory <= (others => "00000000");
        end if;
        -- Else Doing writing routine at each clock tick
        if reset = '1' then
            if W_Enable = '1' then
                memory(CONV_INTEGER(unsigned(address_W))) <= W_Data;
            end if;
        end if;
    end process;
end behavior_reg;