library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity instruction is
    port(
      instruction:  in  STD_LOGIC_VECTOR(7 downto 0);
      code:         out STD_LOGIC_VECTOR(31 downto 0);
      clk:          in  STD_LOGIC
    );
    
    -- Array of STD_LOGIC_VECTOR
    type code_array is array(0 to 256) of
        STD_LOGIC_VECTOR(31 downto 0);
    
    -- Initialize the code memory
    function init return code_array is
        variable init_result: code_array;
    begin
        --do something (e.g. read data from a file, perform some initialization calculation, ...)
        -- Exemple :
        for i in code_array'range loop
            init_result(i) := std_logic_vector(conv_unsigned(0, 32));
        end loop;
        init_result(0) := X"0600AA00";
        init_result(1) := X"0601BB00";
        init_result(2) := X"0602CC00";
        init_result(3) := X"0603DD00";
        init_result(4) := X"0604EE00";
        init_result(5) := X"0605FF00";
        init_result(6) := X"00000000";
        init_result(7) := X"00000000";
        init_result(8) := X"00000000";
        init_result(9) := X"00000000";
        init_result(10) := X"00000000";
        init_result(11) := X"00000000";
        init_result(12) := X"00000000";
        -- Copy
        init_result(13) := X"05000300"; -- Copier ce qu'il y a à @03 à @00
        
        -- init_result(6) := X"0502010F";
        return init_result;
    end function init;
end instruction;

architecture behavior_instr of instruction is
    -- Memory variable
    signal code_memory: code_array := init;
begin
    process(clk) is
    begin
        if rising_edge(clk) then
            code <= code_memory(CONV_INTEGER(UNSIGNED(instruction)));
        end if;
    end process;
end behavior_instr;