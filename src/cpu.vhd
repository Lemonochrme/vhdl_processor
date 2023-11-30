library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC
  );
end cpu;

ARCHITECTURE cpu_arch OF cpu IS
    -- Multiplexers
    COMPONENT mux_ual IS
        PORT (
            mux_op: IN STD_LOGIC_VECTOR(3 downto 0);
            mux_b_in: IN STD_LOGIC_VECTOR(7 downto 0);
            mux_alu_s_in: IN STD_LOGIC_VECTOR(7 downto 0);
            mux_sortie: OUT STD_LOGIC_VECTOR(7 downto 0)
        );
    END COMPONENT;
    COMPONENT mux_bdr IS
        PORT (
            mux_op: IN STD_LOGIC_VECTOR(3 downto 0);
            mux_b_in: IN STD_LOGIC_VECTOR(7 downto 0);
            mux_qa_in: IN STD_LOGIC_VECTOR(7 downto 0);
            mux_sortie: OUT STD_LOGIC_VECTOR(7 downto 0)
        );
    END COMPONENT;
    COMPONENT mux_mem_str IS
        PORT (
            mux_op: IN STD_LOGIC_VECTOR(3 downto 0);
            mux_b_in: IN STD_LOGIC_VECTOR(7 downto 0);
            mux_mem_out_in: IN STD_LOGIC_VECTOR(7 downto 0);
            mux_sortie: OUT STD_LOGIC_VECTOR(7 downto 0)
        );
    END COMPONENT;
    COMPONENT mux_mem_ldr IS
        PORT (
            mux_op: IN STD_LOGIC_VECTOR(3 downto 0);
            mux_a_in: IN STD_LOGIC_VECTOR(7 downto 0);
            mux_b_in: IN STD_LOGIC_VECTOR(7 downto 0);
            mux_sortie: OUT STD_LOGIC_VECTOR(7 downto 0)
        );
    END COMPONENT;

    -- Logical components and memory
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
    
    -- Banc de registres
    signal di_A, di_B_in, di_B_out, di_C_in, di_C_out, qA : STD_LOGIC_VECTOR(7 downto 0);
    signal di_OP : STD_LOGIC_VECTOR(3 downto 0);
    signal write_enable : STD_LOGIC;
    -- UAL
    signal ex_A, ex_B_out, ex_B_in, ex_C, S_ALU : STD_LOGIC_VECTOR(7 downto 0);
    signal ex_OP : STD_LOGIC_VECTOR(3 downto 0);
    signal OP_ALU : STD_LOGIC_VECTOR(2 downto 0);
    -- Memoire des donnees
    signal mem_A, mem_B_in, mem_B_out, mem_address, mem_data : STD_LOGIC_VECTOR(7 downto 0);
    signal mem_OP: STD_LOGIC_VECTOR(3 downto 0);
    signal RW_MEM: STD_LOGIC;
    -- Step 4
    signal re_A, re_B : STD_LOGIC_VECTOR(7 downto 0);
    signal re_OP : STD_LOGIC_VECTOR(3 downto 0);
    signal W_enable: STD_LOGIC;

    --- internal component of cpu
    signal inst : STD_LOGIC_VECTOR(31 downto 0);
    signal PC : STD_LOGIC_VECTOR(7 downto 0) := X"00";

    -- Aleas handling signals
    signal inst_read, inst_write, alea_handler, alea_li_di : STD_LOGIC := '0';
    
begin
    instruction_memory_inst : instruction PORT MAP(PC, inst , clk);
    
    -- step1 pipeline
    step1_lidi  :           pipeline_step PORT MAP(inst(23 downto 16), inst(15 downto 8), inst(7 downto 0), inst(27 downto 24), clk, di_A, di_B_out, di_C_out, di_OP);
    memory_register_inst :  reg PORT MAP(di_B_out(3 downto 0), di_C_out(3 downto 0), re_A(3 downto 0), W_enable, re_B, '1', clk, qA, di_C_in);
    mux_bdr_inst :          mux_bdr PORT MAP(di_OP,di_B_out,qA,di_B_in);

    -- step2 pipeline
    step2_diex :    pipeline_step PORT MAP(di_A, di_B_in, di_C_in, di_OP, clk, ex_A, ex_B_out, ex_C, ex_OP);
    -- LC step 2
    with ex_OP select
        OP_ALU <=   "000" when X"1",
                    "110" when X"2",
                    "001" when X"3",
                    "111" when others;
    alu_inst :      alu PORT MAP(ex_B_out, ex_C, OP_ALU, S_ALU);
    mux_ual_inst :  mux_ual PORT MAP(ex_OP,ex_B_out,S_ALU,ex_B_in);
    
    -- step 3 pipeline
    step3_exmem :       pipeline_step PORT MAP(ex_A, ex_B_in, ex_C, ex_OP, clk, mem_A, mem_B_in, open, mem_OP);
    mux_mem_ldr_inst :  mux_mem_ldr PORT MAP(mem_OP, mem_A, mem_B_in, mem_address);
    with mem_OP select
    RW_MEM <=   '0' when X"8",
                '1' when others;
    data_memory_inst :  data_memory PORT MAP(clk, '0', RW_MEM, mem_address, mem_B_in, mem_data);
    mux_mem_str_inst :  mux_mem_str PORT MAP(mem_OP, mem_B_in, mem_data, mem_B_out);
    
    -- step4 pipeline
    step4_memre : pipeline_step PORT MAP(mem_A, mem_B_out, X"00", mem_OP, clk, re_A, re_B, open, re_OP);
    -- LC step 4
    with re_OP select
        W_enable <= '1' when X"7",
                    '1' when X"6",
                    '1' when X"5",
                    '1' when X"1",
                    '1' when X"2",
                    '1' when X"3",
                    '0' when others;

    -- Gestion des aleas
    -- Uniquement l'AFC et le LOAD ne pose pas d'aléa de lecture
    with inst(27 downto 24) select
        inst_read <=    '0' when X"6",
                        '0' when X"7",
                        '1' when others;
    -- Uniquement le STORE ne pose pas d'aléa d'écriture
    with di_op select
        inst_write <=   '0' when X"8",
                        '1' when others;
                        
    -- Test d'aléa
    alea_li_di <=   '0' when (alea_handler = '1') else
                    '1' when (inst_read = '1') and (inst_write = '1') and (di_OP = X"06" and inst(27 downto 24) = X"05" and di_A = inst(15 downto 8)) else
                    '0';                

    process --(clk, reset)
        begin
        wait until falling_edge(clk);
        --    if clk'event and clk='1' then 
                -- Fonctionnement sans aleas
                if alea_li_di = '0' and alea_handler='0' then 
                    PC <= PC+'1';
                -- When Quand an alea is detecté, alea gestionnaire gère l'opcode
                elsif alea_li_di = '1' then
                    alea_handler <= '1';
                elsif inst(27 downto 24) = re_OP then
                    alea_handler <= '0';
                elsif reset ='1' then
                    PC <= X"00";
                end if;
        --    end if;
    end process;

END cpu_arch;