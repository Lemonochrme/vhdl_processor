library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
port(
  a:  in  STD_LOGIC_VECTOR(7 downto 0);
  b:  in  STD_LOGIC_VECTOR(7 downto 0);
  op: in  STD_LOGIC_VECTOR(2 downto 0);
  s:  out STD_LOGIC_VECTOR(7 downto 0);
  flags : out STD_LOGIC_VECTOR(3 downto 0)
);
end alu;

-- Flags
-- C    -> Carry (bit 0)
-- N    -> Negative (bit 1)
-- Z    -> Zero (bit 2)
-- O    -> Overflow (when using MUL) (bit 3)

-- Operation Bits (OP2, OP1, OP0)    Operation
-- 000                          ADD
-- 001                          SUB
-- 010                          AND
-- 011                          OR
-- 100                          XOR
-- 101                          NOT (return 0x1 if true, else return 0x0)
-- 110                          MUL

architecture behavior_alu of alu is
    -- Internal variables
    shared variable buffer_s_16 :    STD_LOGIC_VECTOR(15 downto 0);
    shared variable buffer_s :      STD_LOGIC_VECTOR(7 downto 0);
    shared variable carry_s :      STD_LOGIC_VECTOR(8 downto 0);
    shared variable buffer_flags :  STD_LOGIC_VECTOR(3 downto 0);

begin
    process(a, b, op) is
    begin
        buffer_flags := "0000";
        case op is
            when "000" =>
                -- calculcating a + b by concatening 8 bits to 9 bits and checking the MSB
                carry_s := ('0' & a) + ('0' & b);
                buffer_s := carry_s(7 downto 0);
                buffer_flags(0) := carry_s(8);
                -- Checking negative
                if (SIGNED(buffer_s) < (0)) then
                    buffer_flags(1) := '1';
                end if;
            when "001" =>
                carry_s := ('0' & a) - ('0' & b);
                buffer_s := carry_s(7 downto 0);
                -- borrowing when negative
                buffer_flags(1) := carry_s(8);
            when "010" =>
                buffer_s := a AND b;
            when "011" =>
                buffer_s := a OR b;
            when "100" =>
                buffer_s := a XOR b;
            when "101" =>
                buffer_s := NOT a;
            when "110" =>
                buffer_s_16 := (a * b);
                buffer_s := buffer_s_16(7 downto 0);
                -- In the context of a multiplication overflow can be interpreted in two manners
                -- A basic overflow for both signed/unsigned. A negative flag for signed.
                if (buffer_s_16 > X"FF") then
                    buffer_flags(3) := '1';
                end if;
            when others =>
                buffer_s := "00000000";
        end case;
        
        -- checking for 0 value
        if (buffer_s = 0) then
            buffer_flags(2) := '1';
        end if;
        
        -- Writing from the buffer to the output
        s <= buffer_s;
        flags <= buffer_flags;
    end process;
end behavior_alu;
