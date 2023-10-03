library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu is
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
    END COMPONENT;

	---FOR ALL : instruction USE ENTITY work.instruction;
begin
    step1_lidi  : pipeline_step PORT MAP();
    step2_diex  : pipeline_step PORT MAP();
    step3_exmem : pipeline_step PORT MAP();
    step4_memre : pipeline_step PORT MAP();
    
    instruction_memory_inst : instruction PORT MAP();
    memory_register_inst    : reg PORT MAP();
    alu_inst                : alu PORT_MAP();
    data_memory_inst        : data_memory PORT MAP();

END cpu_arch;