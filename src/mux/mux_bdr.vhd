library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mux_bdr is
    PORT (
        mux_op: IN STD_LOGIC_VECTOR(3 downto 0);
        mux_b_in: IN STD_LOGIC_VECTOR(7 downto 0);
        mux_qa_in: IN STD_LOGIC_VECTOR(7 downto 0);
        mux_sortie: OUT STD_LOGIC_VECTOR(7 downto 0)
    );
end mux_bdr;

architecture Behavioral of mux_bdr is
begin
    with mux_op select
        mux_sortie <=   mux_qa_in when X"5",
                        mux_qa_in when X"1",
                        mux_qa_in when X"2",
                        mux_qa_in when X"3",
                        mux_qa_in when X"8",
                        mux_b_in when others;
end Behavioral;