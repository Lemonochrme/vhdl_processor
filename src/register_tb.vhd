library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_reg is
end test_reg;

architecture bench of test_reg is
  component reg is
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
  end component;

  for all : reg use entity work.reg;

  signal inA, inB, inW : STD_LOGIC_VECTOR(3 downto 0);
  signal outA, outB, inDataW : STD_LOGIC_VECTOR(7 downto 0);
  signal inWenabler, inReset, inClock : STD_LOGIC := '0';
  
begin
    testeur: reg PORT MAP(inA, inB, inW, inWenabler, inDataW, inReset, inClock, outA, outB);
    
    inClock <= not inClock after 1ns;
    inReset <= '0', '1' after 1ns, '0' after 200ns, '1' after 202ns;
    
    inA <= "0000", "0001" after 48ns, "0010" after 64ns, "0000" after 70ns, "0001" after 80ns;
    inB <= "0000", "0010" after 48ns, "0001" after 64ns, "1111" after 70ns;
    inW <= "0000", "0001" after 24ns, "0010" after 32ns, "0000" after 56ns;
    inWenabler <= '0', '1' after 24ns, '0' after 56ns;
    inDataW <= "00000000", "01010101" after 24ns, "10101010" after 32ns, "11111111" after 48ns, "00000000" after 56ns;
end bench;
