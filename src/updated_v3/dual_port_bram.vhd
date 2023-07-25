
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY dual_port_bram IS

	GENERIC (
		DATA_WIDTH : INTEGER := 8;
		ADDR_WIDTH : INTEGER := 6
	);
	PORT (
		clk     : IN STD_LOGIC;
		addr_a : IN INTEGER RANGE 0 TO 2 ** ADDR_WIDTH - 1;
		addr_b : IN INTEGER RANGE 0 TO 2 ** ADDR_WIDTH - 1;

		--waddr_a : IN INTEGER RANGE 0 TO 2 ** ADDR_WIDTH - 1;
		--waddr_b : IN INTEGER RANGE 0 TO 2 ** ADDR_WIDTH - 1;
		data_a  : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
		data_b  : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
		we_a    : IN STD_LOGIC;
		we_b    : IN STD_LOGIC;
		q_a     : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
		q_b     : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0)
	);

END dual_port_bram;

ARCHITECTURE rtl OF dual_port_bram IS
	-- Build a 2-D array type for the RAM
	SUBTYPE word_t IS STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
	TYPE memory_t IS ARRAY(2 ** ADDR_WIDTH - 1 DOWNTO 0) OF word_t;
	FUNCTION init_ram
		RETURN memory_t IS
		VARIABLE tmp : memory_t := (OTHERS => (OTHERS => '0'));
	BEGIN
		FOR addr_pos IN 0 TO 2 ** ADDR_WIDTH - 1 LOOP
			-- Initialize each address with the address itself
			tmp(addr_pos) := STD_LOGIC_VECTOR(to_unsigned(0, DATA_WIDTH));
		END LOOP;
		RETURN tmp;
	END init_ram;
	-- Declare the RAM signal.	
	shared variable ram : memory_t:= init_ram;
	--signal  ram : memory_t := init_ram;
BEGIN
	----MEMORY A----------------------------------------------------------------------
	PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN

			IF we_a = '1' THEN
				ram(addr_a) := data_a;
			END IF;
			q_a <= ram(addr_a);
		END IF;
	END PROCESS;
	----MEMORY B----------------------------------------------------------------------
	PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF we_b = '1' THEN
				ram(addr_b) := data_b;
			END IF;
			q_b <= ram(addr_b);
		END IF;
	END PROCESS;

END rtl;
