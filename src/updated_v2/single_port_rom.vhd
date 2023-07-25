
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;
ENTITY single_port_rom IS

	GENERIC (
		ROM_WIDTH : INTEGER := 72;
		ROM_DEPTH : INTEGER := 240*160
	);

	PORT (
		clk  : IN STD_LOGIC;
		addr : IN INTEGER RANGE 0 TO ROM_DEPTH - 1;
		q    : OUT STD_LOGIC_VECTOR((ROM_WIDTH - 1) DOWNTO 0)
	);

END ENTITY;

ARCHITECTURE rtl OF single_port_rom IS

	-- Build a 2-D array type for the ROM
	SUBTYPE word_t IS STD_LOGIC_VECTOR((ROM_WIDTH - 1) DOWNTO 0);
	TYPE memory_t IS ARRAY(ROM_DEPTH - 1 DOWNTO 0) OF word_t;

	FUNCTION init_rom RETURN memory_t IS
		FILE text_file       : text OPEN read_mode IS "C:\Users\mbatu\Desktop\work_artron\vivado\updated_v2\rom.txt";
		VARIABLE text_line   : line;
		VARIABLE r_number    : INTEGER;
		VARIABLE ram_content : memory_t;
	BEGIN
		FOR i IN 0 TO ROM_DEPTH - 1 LOOP
			readline(text_file, text_line);
			read(text_line, r_number);
			ram_content(i) := STD_LOGIC_VECTOR(to_unsigned(r_number, ROM_WIDTH));
		END LOOP;
		RETURN ram_content;
	END FUNCTION;

	-- Declare the ROM signal and specify a default value.	Quartus Prime
	-- will create a memory initialization file (.mif) based on the 
	-- default value.
	SIGNAL rom : memory_t := init_rom;

BEGIN

	PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			q <= rom(addr);
		END IF;
	END PROCESS;

END rtl;
