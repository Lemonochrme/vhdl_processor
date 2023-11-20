library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_cpu is
end test_cpu;

architecture bench of test_cpu is
    component cpu
        Port (
            clk : in STD_LOGIC;
            pc_out : out STD_LOGIC_VECTOR(7 downto 0);
            op_out : out STD_LOGIC_VECTOR(3 DOWNTO 0);
            a_out : out STD_LOGIC_VECTOR(7 DOWNTO 0);
            b_out : out STD_LOGIC_VECTOR(7 DOWNTO 0);
            c_out : out STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    signal inClock : STD_LOGIC := '0';  
    
    -- Signals for monitoring internal states
    signal int_PC, int_re_A, int_re_B, int_re_C : STD_LOGIC_VECTOR(7 downto 0);
    signal int_re_OP : STD_LOGIC_VECTOR(3 downto 0);
    
begin
    uut: cpu PORT MAP( 
        inClock,
        int_PC,
        int_re_OP,
        int_re_A,
        int_re_B,
        int_re_C
    );

    -- Clock generation
    inClock <= not inClock after 10 ns; -- Adjust clock period as necessary

end bench;
