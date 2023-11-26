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
    signal A : STD_LOGIC_VECTOR (7 downto 0);
    signal B : STD_LOGIC_VECTOR (7 downto 0);
    signal C : STD_LOGIC_VECTOR (7 downto 0);

    
BEGIN
   -- Instantiation des composants
   RegisterFile_Instance: reg PORT MAP (
    address_A => "0000",
    address_B => "0000",
    address_W => "0000",
    W_Enable  => '0',
    W_Data    => "00000000",
    reset     => '0',
    clk       => clk,
    A_Data    => open,
    B_Data    => open
    );



    -- Pipeline

    -- Lecture Instruction (LI)
    LI: process(clk)
    begin
        if rising_edge(clk) then
            -- Charger les instruction
        end if;
    end process;

    DI: process(clk)
    begin
        if rising_edge(clk) then
            -- Decoder IR et init A B C
        end if;
    end process;

    EX: process(clk)
    begin
        if rising_edge(clk) then
            -- Executer instruction si nécéssaire
        end if;
    end process;

    MEM: process(clk)
    begin
        if rising_edge(clk) then
            -- Ecrire ou lire memoire des données
        end if;
    end process;

    RE: process(clk)
    begin
        if rising_edge(clk) then
            -- Ecrire dans les registres
        end if;
    end process;

    PC_UPDATE: process(clk)
    begin
        if rising_edge(clk) then
            PC <= PC + 1;
        end if;
    end process;

END cpu_arch;