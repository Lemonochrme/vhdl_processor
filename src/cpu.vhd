library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu is
    Port (
        clk : in STD_LOGIC
  );
end cpu;

ARCHITECTURE cpu_arch OF cpu IS
    COMPONENT instruction IS
		PORT (
			instruction : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			code : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			clk : IN STD_LOGIC
		);
	END COMPONENT;

    COMPONENT reg IS
	PORT (
		address_A : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		address_B : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		address_W : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		W_Enable : IN STD_LOGIC;
		W_Data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		reset : IN STD_LOGIC;
		clk : IN STD_LOGIC;
		A_Data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		B_Data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
    END COMPONENT;

    COMPONENT alu IS
	PORT (
		a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		b : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		op : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		s : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		flags : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
    END COMPONENT;
    
    COMPONENT data_memory IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		rw_enable : IN STD_LOGIC;
		addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
    END COMPONENT;
    
    COMPONENT pipeline_step IS
    PORT ( 
      A_in:     in  STD_LOGIC_VECTOR(7 downto 0);
      B_in:     in  STD_LOGIC_VECTOR(7 downto 0);
      C_in:     in  STD_LOGIC_VECTOR(7 downto 0);
      OP_in:    in  STD_LOGIC_VECTOR(3 downto 0);
      clk:      in STD_LOGIC;
      A_out:    out  STD_LOGIC_VECTOR(7 downto 0);
      B_out:    out  STD_LOGIC_VECTOR(7 downto 0);
      C_out:    out  STD_LOGIC_VECTOR(7 downto 0);
      OP_out:   out  STD_LOGIC_VECTOR(3 downto 0)
    );
    END COMPONENT;

    signal ex_A, mem_A, re_A  : STD_LOGIC_VECTOR(7 downto 0);
    signal ex_B, mem_B, re_B : STD_LOGIC_VECTOR(7 downto 0);
    signal di_C, ex_C, mem_C, re_C : STD_LOGIC_VECTOR(7 downto 0);
    signal ex_OP, mem_OP, re_OP : STD_LOGIC_VECTOR(3 downto 0);
    -- Banc de registres
    signal di_A_in, di_A_out, di_B_in, di_B_out, qA : STD_LOGIC_VECTOR(7 downto 0);
    signal di_OP_in, di_OP_out : STD_LOGIC_VECTOR(3 downto 0);
    signal write_enable : STD_LOGIC;

    --- internal component of cpu
    signal inst : STD_LOGIC_VECTOR(31 downto 0);
    signal PC : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    ---signal main_clk : STD_LOGIC;
    
    signal empty_8 : STD_LOGIC_VECTOR(7 downto 0);
    signal empty_4 : STD_LOGIC_VECTOR(3 downto 0);
    
begin
    step1_lidi  : pipeline_step PORT MAP(inst(23 downto 16), inst(15 downto 8), inst(7 downto 0), inst(27 downto 24), clk, di_A_out, di_B_out, di_C, di_OP_out);
    step2_diex  : pipeline_step PORT MAP(di_A_in, di_B_in, di_C, di_OP_in, clk, ex_A, ex_B, ex_C, ex_OP);
    step3_exmem : pipeline_step PORT MAP(ex_A, ex_B, ex_C, ex_OP, clk, mem_A, mem_B, mem_C, mem_OP);
    step4_memre : pipeline_step PORT MAP(mem_A, mem_B, mem_C, mem_OP, clk, re_A, re_B, re_C, re_OP);
    
    instruction_memory_inst : instruction PORT MAP(PC, inst , clk);
    memory_register_inst    : reg PORT MAP(di_B_out(3 downto 0), empty_4, re_A(3 downto 0), re_OP(0), re_B, '1', clk, qA, empty_8);
    
    -- alu_inst                : alu PORT MAP();
    -- data_memory_inst        : data_memory PORT MAP();

    process(clk)
        begin
            if clk'event and clk='1' then
                -- In this case, copy the content of li_A directly to di_A (just the idea)
                case di_OP_out is
                    -- AFC
                    when X"6" =>
                        di_B_in <= di_B_out;
                        di_A_in <= di_A_out;
                        di_OP_in <= "0001";
                -- In this case, put the content in memory_register_inst and get QA in di_A (just the idea)
                    when X"5" =>
                        di_B_in <= qA;
                        di_A_in <= di_A_out;
                        di_OP_in <= "0001";
                   when others =>
                        di_B_in <= di_B_out;
                        di_A_in <= di_A_out;
                        di_OP_in <= di_OP_out;
                end case;
                PC <= PC+'1';
            end if;
    end process;

END cpu_arch;