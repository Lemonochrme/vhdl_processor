library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mux_mem_ldr is
    PORT (
        mux_op: IN STD_LOGIC_VECTOR(3 downto 0);
        mux_a_in: IN STD_LOGIC_VECTOR(7 downto 0);
        mux_b_in: IN STD_LOGIC_VECTOR(7 downto 0);
        mux_sortie: OUT STD_LOGIC_VECTOR(7 downto 0)
    );
end mux_mem_ldr;

architecture Behavioral of mux_mem_ldr is
begin
    with mux_op select
        mux_sortie <=   mux_a_in when X"8", -- store @a
                        mux_b_in when others;
end Behavioral;