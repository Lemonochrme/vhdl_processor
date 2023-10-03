library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_instr is
end test_instr;

architecture bench of test_instr is
  component instruction is
    port(
      instruction:  in  STD_LOGIC_VECTOR(7 downto 0);
      code:         out STD_LOGIC_VECTOR(31 downto 0);
      clk:          in  STD_LOGIC
    );
  end component;

  for all : instruction use entity work.instruction;

  signal inAddress : STD_LOGIC_VECTOR(7 downto 0);
  signal outCode : STD_LOGIC_VECTOR(31 downto 0);
  signal inClock : STD_LOGIC := '0';
  
begin
    testeur: instruction PORT MAP(inAddress, outCode, inClock);
    inClock <= not inClock after 1ns;
    
    inAddress <= X"00", X"0a" after 10ns;

end bench;
