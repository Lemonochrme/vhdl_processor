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
    
    
begin


END cpu_arch;