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
  	his_wr_addr_o : out integer range 0 to 255;
  	his_rd_addr_o : out integer range 0 to 255;
  	his_wr_data_o	:out std_logic_vector((7) downto 0);	
  	his_rd_data_i	:in std_logic_vector((7) downto 0);	
  	his_wr_en     :out std_logic
--------------------------------------------------------------------------------

  ) ;
end entity ; -- 

architecture arch of histogram_r is
	constant DATA_WIDTH : integer := 8;
	constant ADDR_WIDTH : integer := 8;

	signal t_out_ready_o_r   : std_logic := '0';

	type t_State is (idle_s , valid_s, clear_s );

  signal State : t_State;
  signal  wr_data : std_logic_vector((7) downto 0);	
  signal  rd_data : std_logic_vector((7) downto 0);	
  signal  data_r : std_logic_vector((7) downto 0);	
	signal wr_addr : integer range 0 to 255;
	signal tmp_addr : integer range 0 to 255;
	signal rd_addr : integer range 0 to 255;
	signal we_i   : std_logic := '0';
	signal we_r  : std_logic := '0';
	signal we_r_r  : std_logic := '0';
	signal empty_r   : std_logic := '0';
begin
t_out_ready_o   <= not empty_r;
his_wr_addr_o 	<= wr_addr ;
his_rd_addr_o 	<= to_integer(unsigned(t_out_data_i));
rd_addr 	<= to_integer(unsigned(t_out_data_i));
rd_data        <=std_logic_vector(to_unsigned(to_integer(unsigned(his_rd_data_i)), 8));
his_wr_data_o	 <= wr_data;
his_wr_en  			<= we_i  ;
write_pr : process( clk_i )
variable data_v :std_logic_vector((7) downto 0);	
		begin
			if (rising_edge(clk_i)) then
				if (rst_i='1') then
					State <= idle_s ;
					wr_addr  <= 0      ;
				  t_out_ready_o_r<='0';
				  we_i<='0';
				else
 					t_out_ready_o_r<=not empty_r;
 					we_r     <=we_i;--
 					--we_r_r<=we_r;--
 					--data_v:=rd_data;
					case  State is
---------------------------------------------------------------------------
						when idle_s => 
						wr_addr<=0;
						we_i<='0';
						empty_r<='1';
						if (t_user_i='1') then
							State<=clear_s;
						else
							State<=idle_s;		
						end if;
--------------------------------------------------------------------------						
						when clear_s =>
						
						if (wr_addr =(255)) then
 							State<=valid_s;
 							empty_r<='1';
 							 we_i <='0';
						else
						   we_i <='1';
							 wr_addr<=wr_addr+1;
							 wr_data<=x"00";
							
							State <=  clear_s;
						end if;
--------------------------------------------------------------------------						
						when valid_s =>	
		            if ((empty_r='1' or t_out_ready_o_r='1') ) then--and t_in_valid_i_r='1'
		            	
		            	if (t_out_valid_i='1'  ) then-- 
		            		 empty_r           <= '0' ;--0
		            		 we_i <='1';
		            		  wr_addr          <= to_integer(unsigned(t_out_data_i));
		            		
								
		            	   wr_data <=std_logic_vector(to_unsigned(to_integer(unsigned(his_rd_data_i))+1, 8));
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
		            		wr_addr<=0;
		            		wr_data<=x"00";
		            		we_i <='1';
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