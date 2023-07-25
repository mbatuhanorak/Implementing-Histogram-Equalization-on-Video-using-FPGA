library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bram is

	generic 
	(
		DATA_WIDTH : integer := 8;
		ADDR_WIDTH : integer := 8
	);

	port 
	(
		clk		: in std_logic;
		addr	: in integer range 0 to 2**ADDR_WIDTH - 1;
		data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic ;
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end bram;

architecture rtl of bram is
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of std_logic_vector((DATA_WIDTH-1) downto 0);

	function init_ram
		return memory_t is 
		variable tmp : memory_t := (others => (others => '0'));
	begin 
		for addr_pos in 0 to 2**ADDR_WIDTH - 1 loop 
			-- Initialize each address with the address itself
			tmp(addr_pos) := std_logic_vector(to_unsigned(0, DATA_WIDTH));
		end loop;
		return tmp;
	end init_ram;	 

	signal ram : memory_t := init_ram;
	signal addr_reg : integer range 0 to 2**ADDR_WIDTH-1;

begin

	process(clk)
	begin
	if(rising_edge(clk)) then
		if(we = '1') then
			ram(addr) <= data;
		end if;

		-- Register the address for reading
		addr_reg <= addr;
	end if;
	end process;

	q <= ram(addr_reg);

end rtl;
