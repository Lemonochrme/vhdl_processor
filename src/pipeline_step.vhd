library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pipeline_step is
port(
  A_in:    in  STD_LOGIC_VECTOR(7 downto 0);
  B_in:    in  STD_LOGIC_VECTOR(7 downto 0);
  C_in:    in  STD_LOGIC_VECTOR(7 downto 0);
  OP_in:   in  STD_LOGIC_VECTOR(3 downto 0);
  clk : in STD_LOGIC;
  A_out:    out  STD_LOGIC_VECTOR(7 downto 0);
  B_out:    out  STD_LOGIC_VECTOR(7 downto 0);
  C_out:    out  STD_LOGIC_VECTOR(7 downto 0);
  OP_out:   out  STD_LOGIC_VECTOR(3 downto 0)
);
end pipeline_step;

architecture behavior_pipeline_step of pipeline_step is
begin
    process(clk)
        begin
            if clk'event and clk='1' then
                A_out <= A_in;
                B_out <= B_in;
                C_out <= C_in;
                OP_out <= OP_in;
            end if;
    end process;
end behavior_pipeline_step;