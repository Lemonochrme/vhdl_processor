library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_alu is
end test_alu;

architecture bench of test_alu is
  component alu is
    port(
      a:  in  STD_LOGIC_VECTOR(7 downto 0);
      b:  in  STD_LOGIC_VECTOR(7 downto 0);
      op: in  STD_LOGIC_VECTOR(2 downto 0);
      s:  out STD_LOGIC_VECTOR(7 downto 0);
      flags : out STD_LOGIC_VECTOR(3 downto 0)
    );
  end component;

  for all : alu use entity work.alu;

  signal in1, in2, out1 : STD_LOGIC_VECTOR(7 downto 0);
  signal out2 : STD_LOGIC_VECTOR(3 downto 0);
  signal operation : STD_LOGIC_VECTOR(2 downto 0);

-- Test ADD ->  4+(-16)/4+240, then 128+156 -> C = 1
-- Test SUB ->  32-6 then 4-10 -> N =1
-- Test AND ->  0b00001111 & 0b11110000 then 0b01010000 & 0b11110001
-- Test OR ->   0b00001111 | 0b11110000 then 0b01010000 | 0b11110001
-- Test XOR ->  0b00001111 ^ 0b11110000 then 0b01010000 ^ 0b11110001
-- Test NOT ->  0b00001111 
-- Test MUL ->  6*3 then 128*3 O = 1

begin
    testeur: alu PORT MAP(in1, in2, operation, out1, out2);
    in1 <= "00000100", "10000000" after 2 ns,
    "00100000" after 4 ns, "00000100" after 6 ns,
    "00001111" after 8 ns, "01010000" after 10 ns,
    "00001111" after 12 ns, "01010000" after 14 ns,
    "00001111" after 16 ns, "01010000" after 18 ns,
    "00001111" after 20ns,
    "00000110" after 24ns, "10000000" after 26ns;
    
    in2 <= "11110000", "10011100" after 2 ns,
    "00000110" after 4 ns, "00001010" after 6 ns,
    "11110000" after 8 ns, "11110001" after 10 ns,
    "11110000" after 12 ns, "11110001" after 14 ns,
    "11110000" after 16 ns, "11110001" after 18 ns,
    -- in2 is not used for not
    "00000011" after 24ns, "00000011" after 26ns;
    
    operation <= "000", "001" after 4ns, "010" after 8ns, "011" after 12ns, "100" after 16ns, "101" after 20ns, "110" after 24ns;
end bench;
