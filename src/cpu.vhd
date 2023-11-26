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
    signal PC : STD_LOGIC_VECTOR (7 downto 0) := "00000000"; -- Program Counter
    signal IR : STD_LOGIC_VECTOR (31 downto 0); -- Instruction Register
    signal OP : STD_LOGIC_VECTOR (7 downto 0);
    signal A : STD_LOGIC_VECTOR (7 downto 0);
    signal B : STD_LOGIC_VECTOR (7 downto 0);
    signal C : STD_LOGIC_VECTOR (7 downto 0);

    signal OP_DI : STD_LOGIC_VECTOR (7 downto 0);
    signal A_DI  : STD_LOGIC_VECTOR (7 downto 0); 
    signal B_DI  : STD_LOGIC_VECTOR (7 downto 0);
    signal C_DI  : STD_LOGIC_VECTOR (7 downto 0);
    
    signal OP_EX : STD_LOGIC_VECTOR (7 downto 0);
    signal A_EX  : STD_LOGIC_VECTOR (7 downto 0);
    signal B_EX  : STD_LOGIC_VECTOR (7 downto 0);
    signal C_EX  : STD_LOGIC_VECTOR (7 downto 0);

    signal OP_MEM: STD_LOGIC_VECTOR (7 downto 0);
    signal A_MEM : STD_LOGIC_VECTOR (7 downto 0);
    signal B_MEM : STD_LOGIC_VECTOR (7 downto 0);
    signal C_MEM : STD_LOGIC_VECTOR (7 downto 0);

    signal OP_RE : STD_LOGIC_VECTOR (7 downto 0);
    signal A_RE  : STD_LOGIC_VECTOR (7 downto 0);
    signal B_RE  : STD_LOGIC_VECTOR (7 downto 0);
    signal C_RE  : STD_LOGIC_VECTOR (7 downto 0);

    signal W_ADDRESS_HANDLE : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal W_DATA_HANDLE    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal W_ENABLE_HANDLE  : STD_LOGIC;

BEGIN
   -- Instantiation des composants
   RegisterFile_Instance: reg PORT MAP (
    address_A => "0000",
    address_B => "0000",
    address_W => W_ADDRESS_HANDLE,
    W_Enable  => W_ENABLE_HANDLE,
    W_Data    => W_DATA_HANDLE,
    reset     => '1',
    clk       => clk,
    A_Data    => open,
    B_Data    => open
    );

    InstructionMemory_Instance: instruction PORT MAP (
		instruction => PC,
        code        => IR,
        clk         => clk
    );



    -- Pipeline

    -- Lecture Instruction (LI)
    LI: process(clk)
    begin
        if rising_edge(clk) then
            -- Charger les instruction
            OP <= IR(31 downto 24);
            A  <= IR(23 downto 16);
            B  <= IR(15 downto 8);
            C  <= IR(7 downto 0);
        end if;
    end process;

    DI: process(clk)
    begin
        if rising_edge(clk) then
            -- Banc de registre
            OP_DI <= OP;
            case OP is
                when X"06" =>
                    A_DI <= A;
                    B_DI <= B;
                    C_DI <= C;
                when others =>
                    null;
            end case;
        end if;
    end process;

    EX: process(clk)
    begin
        if rising_edge(clk) then
            -- Executer instruction si nécéssaire (ALU)
            OP_EX <= OP_DI;
            case OP_DI is
                when X"06" =>
                    A_EX <= A_DI;
                    B_EX <= B_DI;
                    C_EX <= C_DI;
                when others =>
                    null;
            end case;
        end if;
    end process;

    MEM: process(clk)
    begin
        if rising_edge(clk) then
            -- Ecrire ou lire memoire des données
            OP_MEM <= OP_EX;
            case OP_EX is
                when X"06" =>
                    A_MEM <= A_EX;
                    B_MEM <= B_EX;
                    C_MEM <= C_EX;
                when others =>
                    null;
            end case;
        end if;
    end process;

    RE: process(clk)
    begin
        if rising_edge(clk) then
            -- Ecrire dans les registres
            OP_RE <= OP_MEM;
            case OP_MEM is
                when X"06" =>
                    A_RE <= A_MEM;
                    B_RE <= B_MEM;
                    C_RE <= C_MEM;

                    W_ENABLE_HANDLE  <= '1';
                    W_ADDRESS_HANDLE <= A_RE(3 downto 0);
                    W_DATA_HANDLE    <= B_RE;
                when others =>
                    null;
            end case;
        end if;
    end process;

    PC_UPDATE: process(clk)
    begin
        if rising_edge(clk) then
            PC <= PC + 1;
        end if;
    end process;

END cpu_arch;