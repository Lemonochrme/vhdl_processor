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
        init_result(0) := X"06010A00"; -- AFC 0x0a to R01
        init_result(1) := X"06020B00"; -- AFC 0x0b to R02
        init_result(2) := X"06030200"; -- AFC 0x0c to R03
        init_result(3) := X"06040D00"; -- AFC 0x0d to R04
        init_result(4) := X"06050E00"; -- AFC 0x0e to R05
        init_result(5) := X"05000100"; -- COPY R01 to R00
        init_result(6) := X"01060102"; -- ADD R06=R01+R02
        init_result(7) := X"02070103"; -- MUL R07=R01*R03
        init_result(8) := X"03080201"; -- SOUS R08=R01-R02
        init_result(9) := X"08000100"; -- STORE [@00] <- R01
        init_result(20) := X"07090000"; -- LOAD R09 -< [@00]
        return init_result;
    end function init;
end instruction;

architecture behavior_instr of instruction is
    -- Memory variable
    signal code_memory: code_array := init;
begin
    process(instruction, clk) is
    begin
        if clk'event AND clk = '1' then
            code <= code_memory(CONV_INTEGER(UNSIGNED(instruction)));
        end if;
    end process;
end behavior_instr;