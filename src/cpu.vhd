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
    -- Code memory
    COMPONENT instruction IS
		PORT (
			instruction : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Adresse de l'instruction
			code : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Code de l'instruction
			clk : IN STD_LOGIC
		);
	END COMPONENT;

    -- Data memory
    COMPONENT data_memory IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC; -- Reset actif à '1'
		rw_enable : IN STD_LOGIC; -- Lecture: '1' Ecriture: '0'
		addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Adresse de la zone mémoire
		data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data écrite à l'adresse addr
		data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- Data présente à l'adresse addr
	);
    END COMPONENT;    

    -- Register file
    COMPONENT reg IS
	PORT (
		address_A : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Permet de lire le registre à l'address_A sortie sur A_Data
		address_B : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Permet de lire le registre à l'address_B sortie sur B_Data
		address_W : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Permet d'écrire les données de W_Data à l'adresse address_W
		W_Enable : IN STD_LOGIC; -- Si W_Enable='1' alors écriture
		W_Data : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Données à écrire
		reset : IN STD_LOGIC; -- Reset actif à '0'
		clk : IN STD_LOGIC;
		A_Data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Sortie des données présentes à l'address_A 
		B_Data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)  -- Sortie des données présentes à l'address_B 
	);
    END COMPONENT;

    -- Arithmentic Logic Unit
    COMPONENT alu IS
	PORT (
		a : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Opérande a
		b : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Opérande b
		op : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Code de l'operation
		s : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Sortie de l'operation
		flags : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- Flags de l'ALU (C, N, Z, O)
	);
    END COMPONENT;

    -- Signaux internes
    signal PC : STD_LOGIC_VECTOR (7 downto 0)  := "00000000"; -- Program Counter
    signal IR : STD_LOGIC_VECTOR (31 downto 0); -- Instruction Register

    signal OP_LI_DI : STD_LOGIC_VECTOR (7 downto 0);
    signal A_LI_DI  : STD_LOGIC_VECTOR (7 downto 0);
    signal B_LI_DI  : STD_LOGIC_VECTOR (7 downto 0);
    signal C_LI_DI  : STD_LOGIC_VECTOR (7 downto 0);

    signal OP_DI_EX : STD_LOGIC_VECTOR (7 downto 0);
    signal A_DI_EX : STD_LOGIC_VECTOR (7 downto 0);
    signal B_DI_EX  : STD_LOGIC_VECTOR (7 downto 0);
    signal C_DI_EX  : STD_LOGIC_VECTOR (7 downto 0);

    signal OP_EX_MEM : STD_LOGIC_VECTOR (7 downto 0);
    signal A_EX_MEM  : STD_LOGIC_VECTOR (7 downto 0);
    signal B_EX_MEM  : STD_LOGIC_VECTOR (7 downto 0);

    signal OP_MEM_RE: STD_LOGIC_VECTOR (7 downto 0);
    signal A_MEM_RE : STD_LOGIC_VECTOR (7 downto 0);
    signal B_MEM_RE : STD_LOGIC_VECTOR (7 downto 0);




    -- Register file specific signals
    signal R_ADDRESS_A_HANDLE : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal R_ADDRESS_B_HANDLE : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal W_ADDRESS_HANDLE   : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal W_DATA_HANDLE      : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal W_ENABLE_HANDLE    : STD_LOGIC := '0';
    signal A_DATA_OUT_HANDLE  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal B_DATA_OUT_HANDLE  : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- ALU specific signals
    signal ALU_A_OPERAND : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal ALU_B_OPERAND : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal ALU_OP_TYPE   : STD_LOGIC_VECTOR(2 DOWNTO 0); -- Add, Soustraction, etc...
    signal ALU_DATA_OUT  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal ALU_FLAGS     : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- Data Memory specific signals
    signal DATAMEM_RESET     : STD_lOGIC := '0'; -- Reset invactif par defaut
    signal DATAMEM_RW_ENABLE : STD_lOGIC := '1'; -- Lecture par defaut pour éviter les écritures non voulues
    signal DATAMEM_ADDRESS   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal DATAMEM_DATA_IN   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal DATAMEM_DATA_OUT  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    

BEGIN
    -- Instantiation des composants
    RegisterFile_Instance: reg PORT MAP (
        address_A => R_ADDRESS_A_HANDLE,
        address_B => R_ADDRESS_B_HANDLE,
        address_W => W_ADDRESS_HANDLE,
        W_Enable  => W_ENABLE_HANDLE,
        W_Data    => W_DATA_HANDLE,
        reset     => '1', -- Reset unactive
        clk       => clk,
        A_Data    => A_DATA_OUT_HANDLE,
        B_Data    => B_DATA_OUT_HANDLE
    );


    InstructionMemory_Instance: instruction PORT MAP (
		instruction => PC,
        code        => IR,
        clk         => clk
    );

    ALU_Instance: alu PORT MAP (
		a     =>  ALU_A_OPERAND,
		b     =>  ALU_B_OPERAND,
		op    =>  ALU_OP_TYPE,
		s     =>  ALU_DATA_OUT,
		flags =>  ALU_FLAGS
    );

    DataMemory_Instance: data_memory PORT MAP (
        clk         => clk,
		rst         => DATAMEM_RESET, -- Reset actif à '1'
		rw_enable   => DATAMEM_RW_ENABLE, -- Lecture: '1' Ecriture: '0'
		addr        => DATAMEM_ADDRESS, -- Adresse de la zone mémoire
		data_in     => DATAMEM_DATA_IN, -- Data écrite à l'adresse addr
		data_out    => DATAMEM_DATA_OUT -- Data présente à l'adresse addr
    );

    -- Pipeline
    OP_LI_DI <= IR(31 downto 24);
    A_LI_DI  <= IR(23 downto 16);
    B_LI_DI  <= IR(15 downto 8);
    C_LI_DI  <= IR(7 downto 0);
    LI_DI: process(clk)
    begin
        if rising_edge(clk) then
            -- Banc de registre
            if OP_LI_DI = X"06" or OP_LI_DI = X"07" then -- AFC / LOAD
                OP_DI_EX <= OP_LI_DI;
                A_DI_EX  <= A_LI_DI; 
                B_DI_EX  <= B_LI_DI;  
                C_DI_EX  <= C_LI_DI;
            elsif OP_LI_DI = X"05" or OP_LI_DI = X"08" then -- COPY / STORE
                OP_DI_EX <= OP_LI_DI;
                A_DI_EX  <= A_LI_DI;   
                C_DI_EX  <= C_LI_DI; 
                R_ADDRESS_A_HANDLE <= B_LI_DI(3 downto 0);   
            elsif OP_LI_DI = X"01" or OP_LI_DI = X"02" or OP_LI_DI = X"03" then -- ALU
                OP_DI_EX <= OP_LI_DI;
                A_DI_EX  <= A_LI_DI;   
                R_ADDRESS_B_HANDLE <= C_LI_DI(3 downto 0); 
                R_ADDRESS_A_HANDLE <= B_LI_DI(3 downto 0);       
            else
                OP_DI_EX <= X"00";
                A_DI_EX  <= X"00"; 
                B_DI_EX  <= X"00";  
                C_DI_EX  <= X"00";           
            end if;
        end if;
    end process;

    DI_EX: process(clk)
    begin
        if rising_edge(clk) then
            if OP_DI_EX = X"06" then
                OP_EX_MEM <= OP_DI_EX;
                A_EX_MEM  <= A_DI_EX; 
                B_EX_MEM  <= B_DI_EX;  
            elsif OP_DI_EX = X"05" or OP_DI_EX = X"08" then -- COPY / STORE
                OP_EX_MEM <= OP_DI_EX;
                A_EX_MEM  <= A_DI_EX; 
                B_EX_MEM  <= A_DATA_OUT_HANDLE; -- Pour éviter tout décallage temporel on passe directement A_DATA_OUT_HANDLE au lieu de B_DI_EX
            elsif OP_DI_EX = X"01" or OP_DI_EX = X"02" or OP_DI_EX = X"03" then
                -- ALU
                OP_EX_MEM <= OP_DI_EX;
                A_EX_MEM  <= A_DI_EX;
                ALU_A_OPERAND <= A_DATA_OUT_HANDLE;
                ALU_B_OPERAND <= B_DATA_OUT_HANDLE;
                if OP_DI_EX = X"01" then
                    ALU_OP_TYPE <= "000"; -- ADD
                elsif OP_DI_EX = X"02" then
                    ALU_OP_TYPE <= "110"; -- Multiplication
                elsif OP_DI_EX = X"03" then
                    ALU_OP_TYPE <= "001"; -- Soustraction
                end if;
            else
                OP_EX_MEM <= X"00";
                A_EX_MEM  <= X"00"; 
                B_EX_MEM  <= X"00";  
            end if;
        end if;
    end process;

    EX_MEM: process(clk)
    begin
        if rising_edge(clk) then
            -- Ecrire ou lire memoire des données
            if OP_EX_MEM = X"06" or OP_EX_MEM = X"05" then
                OP_MEM_RE <= OP_EX_MEM;
                A_MEM_RE  <= A_EX_MEM; 
                B_MEM_RE  <= B_EX_MEM;  
            elsif OP_EX_MEM = X"01" or OP_EX_MEM = X"02" or OP_EX_MEM = X"03" then
                OP_MEM_RE <= OP_EX_MEM;
                A_MEM_RE  <= A_EX_MEM; 
                B_MEM_RE <= ALU_DATA_OUT;
            elsif OP_EX_MEM = X"08" then -- STORE
                OP_MEM_RE <= OP_EX_MEM;
                DATAMEM_RESET <= '0';
                DATAMEM_RW_ENABLE <= '0'; -- Ecriture
                DATAMEM_DATA_IN <= B_EX_MEM; -- On met ce qu'il y a dans B
                DATAMEM_ADDRESS <= A_EX_MEM; -- A l'adresse de A
            else
                OP_MEM_RE <= X"00";
                A_MEM_RE  <= X"00"; 
                B_MEM_RE  <= X"00";  
            end if;
        end if;
    end process;

    -- Write Back (RE)
    MEM_RE: process(clk)
    begin
        if rising_edge(clk) then          
            -- Ecrire dans les registres
            if OP_MEM_RE = X"06" or OP_MEM_RE = X"05" or OP_MEM_RE = X"01" or OP_MEM_RE = X"02" or OP_MEM_RE = X"03" then
                W_ADDRESS_HANDLE <= A_MEM_RE(3 downto 0);
                W_DATA_HANDLE    <= B_MEM_RE;
            elsif OP_MEM_RE = X"08" then
                null;
            else
                null;
            end if;
        end if;
    end process;


    -- W_ENABLE HANDLING "MUX"
    process(clk)
    begin
        if rising_edge(clk) then
            if OP_MEM_RE = X"06" or OP_MEM_RE = X"05" or OP_MEM_RE = X"01" or OP_MEM_RE = X"02" or OP_MEM_RE = X"03" then
                W_ENABLE_HANDLE <= '1';                
            else            
                W_ENABLE_HANDLE <= '0';
            end if;
        end if;
    end process;

    PC_UPDATE: process(clk)
    begin
        if rising_edge(clk) then
            PC <= PC + 1;
        end if;
    end process;

END cpu_arch;