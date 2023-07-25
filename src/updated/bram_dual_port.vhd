
library ieee;
use ieee.std_logic_1164.all;
	use ieee.numeric_std.all ;
entity bram_dual_port is

	generic 
	(
		DATA_WIDTH : integer := 8;
		ADDR_WIDTH : integer := 6
	);
	port 
	(
		clk		: in std_logic;
		raddr	: in integer range 0 to 2**ADDR_WIDTH - 1;
		waddr	: in integer range 0 to 2**ADDR_WIDTH - 1;
		data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic := '1';
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end bram_dual_port;

architecture rtl of bram_dual_port is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

	-- Declare the RAM signal.	
	
	signal ram : memory_t;

begin

	process(clk)
	begin
	if(rising_edge(clk)) then 
		if(we = '1') then
			ram(waddr) <= data;
		else
						
		end if;

		-- On a read during a write to the same address, the read will
		-- return the OLD data at the address
 ---		q <= ram(raddr);	
	end if;
	end process;
	q <= ram(raddr);	
end rtl;
