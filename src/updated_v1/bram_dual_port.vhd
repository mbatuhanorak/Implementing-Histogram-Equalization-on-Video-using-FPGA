
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
		clk			: in std_logic;
		raddr		: in integer range 0 to 2**ADDR_WIDTH - 1;
		clear_enable: in std_logic;

		waddr		: in integer range 0 to 2**ADDR_WIDTH - 1;
		data		: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we			: in std_logic := '1';
		q			: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end bram_dual_port;

architecture rtl of bram_dual_port is
	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;
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


	-- Declare the RAM signal.	
	
	
	signal ram : memory_t := init_ram;

begin

	process(clk)
	begin
	if(rising_edge(clk)) then 
		if(clear_enable ='1') then
            ram <= (OTHERS => (OTHERS => '0'));
           -- ram (117)<=x"05";
           -- ram (69)<=x"07";
        elsif we = '1' then
        	ram(waddr) <= data;		
        end if;        	        
		q <= ram(raddr);	
		-- On a read during a write to the same address, the read will
		-- return the OLD data at the address
 					
	end if;

	end process;

end rtl;
