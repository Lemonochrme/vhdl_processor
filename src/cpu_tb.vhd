library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_cpu is
end test_cpu;

architecture bench of test_cpu is
    component cpu
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC
        );
    end component;

    signal inClock, inReset : STD_LOGIC := '0';  
    
begin
    uut: cpu PORT MAP( 
        inClock,
        inReset
    );

    -- Clock generation
    inClock <= not inClock after 10 ns; -- Adjust clock period as necessary
    inReset <= '1', '0' after 20ns;

end bench;


