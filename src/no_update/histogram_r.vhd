library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity histogram_r is
  port (
  	clk_i	  : in std_logic;
  	rst_i	  : in std_logic;
 --in
  	t_last_i  : in std_logic;
  	t_user_i  : in std_logic;
-------------------------------------------------------------------------------
  	t_out_data_i  : in std_logic_vector(7 downto 0 );
  	t_out_valid_i : in std_logic;
  	t_out_ready_o : out std_logic;
--------------------------------------------------------------------------------
  	his_addr_o    : out integer range 0 to 255;
  	his_data_o		:out std_logic_vector((7) downto 0);	
  	his_wr_en     :out std_logic
--------------------------------------------------------------------------------

  ) ;
end entity ; -- pattern_generator

architecture arch of histogram_r is
	constant DATA_WIDTH : integer := 8;
	constant ADDR_WIDTH : integer := 8;

	signal t_out_ready_o_r   : std_logic := '0';

	type t_State is (idle_s , valid_s, clear_s );

  signal State : t_State;
  signal  data_i : std_logic_vector((7) downto 0);	
	signal addr_i : integer range 0 to 255;
	signal we_i   : std_logic := '0';
	signal empty_r   : std_logic := '0';
	signal q_o    : std_logic_vector((7) downto 0);	
begin
t_out_ready_o   <= not empty_r;
his_addr_o 			<= addr_i ;
his_data_o			<= data_i ;
his_wr_en  			<= we_i   ;
write_pr : process( clk_i )
		type memory_t is array(255 downto 0) of std_logic_vector((DATA_WIDTH-1) downto 0);
	  variable tmp_ram: memory_t ;
		begin
			if (rising_edge(clk_i)) then
				if (rst_i='1') then
					State <= idle_s ;
					addr_i  <= 0      ;
				  t_out_ready_o_r<='0';
				else
 					t_out_ready_o_r<=not empty_r;
					case  State is
---------------------------------------------------------------------------
						when idle_s => 
						addr_i<=0;
						empty_r<='1';
						if (t_user_i='1') then
							State<=clear_s;
						else
							State<=idle_s;		
						end if;
--------------------------------------------------------------------------						
						when clear_s =>
						
						if (addr_i =(255)) then
 							State<=valid_s;
 							tmp_ram(addr_i):=x"00";
 							empty_r<='1';
						else
								addr_i<=addr_i+1;
								data_i<=x"00";
								tmp_ram(addr_i):=x"00";
								State <=  clear_s;
						end if;
--------------------------------------------------------------------------						
						when valid_s =>	
		            if ((empty_r='1' or t_out_ready_o_r='1') ) then--and t_in_valid_i_r='1'
		            	if (t_out_valid_i='1'  ) then-- 
		            		empty_r           <= '0' ;--0
		            		 addr_i          <= to_integer(unsigned(t_out_data_i));
		            		 tmp_ram(to_integer(unsigned(t_out_data_i))):= std_logic_vector(to_unsigned(to_integer(unsigned(  tmp_ram(to_integer(unsigned(t_out_data_i)))  ) )+1, 8));		
		            		 we_i <='1';
		            	   data_i          <=std_logic_vector(to_unsigned(to_integer(unsigned(  tmp_ram(to_integer(unsigned(t_out_data_i)))  ) ), 8));
		            	else
		            		empty_r           <='1';	
		            		we_i <='0';
		            	end if;
		            else
		                we_i <='0';
		                empty_r           <='0';		
		            end if;	
		            if (t_user_i='1') then
		            		State <=  clear_s;
		            		addr_i<=0;
		            		data_i<=x"00";
		            		tmp_ram(addr_i):=x"00";
		            		empty_r           <='1';		
		            else
		            		State <=  valid_s;		
		            end if;
--------------------------------------------------------------------------						
						when others =>
							null;
					end case;
							
				end if;
			end if;
end process ; -- write_pr
end architecture ; -- arch