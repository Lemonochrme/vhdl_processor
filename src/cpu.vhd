library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu is
    Port (
        clk : in STD_LOGIC;
        instruction_pointer : in STD_LOGIC_VECTOR(7 downto 0)
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
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;
		RW_ENABLE : IN STD_LOGIC;
		ADDR : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		DATA_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
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

    signal li_A, di_A, ex_A, mem_A, re_A  : STD_LOGIC_VECTOR(7 downto 0);
    signal li_B, di_B, ex_B, mem_B, re_B : STD_LOGIC_VECTOR(7 downto 0);
    signal li_C, di_C, ex_C, mem_C, re_C : STD_LOGIC_VECTOR(7 downto 0);
    signal di_OP, ex_OP, mem_OP, re_OP : STD_LOGIC_VECTOR(3 downto 0);
    signal li_OP : STD_LOGIC_VECTOR(31 downto 0);
    ---signal main_clk : STD_LOGIC;
    
    signal empty_8 : STD_LOGIC_VECTOR(7 downto 0);
    signal empty_4 : STD_LOGIC_VECTOR(3 downto 0);
    
begin
    step1_lidi  : pipeline_step PORT MAP(li_A, li_B, li_C, li_OP(7 downto 4), clk, di_A, di_B, di_C, di_OP);
    step2_diex  : pipeline_step PORT MAP(di_A, di_B, di_C, di_OP, clk, ex_A, ex_B, ex_C, ex_OP);
    step3_exmem : pipeline_step PORT MAP(ex_A, ex_B, ex_C, ex_OP, clk, mem_A, mem_B, mem_C, mem_OP);
    step4_memre : pipeline_step PORT MAP(mem_A, mem_B, mem_C, mem_OP, clk, re_A, re_B, re_C, re_OP);
    
    instruction_memory_inst : instruction PORT MAP(instruction_pointer, li_OP , clk);
    memory_register_inst    : reg PORT MAP(empty_4, empty_4, re_A(3 downto 0), re_OP(0), re_B, '0', clk, empty_8, empty_8);
    -- alu_inst                : alu PORT MAP();
    -- data_memory_inst        : data_memory PORT MAP();

END cpu_arch;