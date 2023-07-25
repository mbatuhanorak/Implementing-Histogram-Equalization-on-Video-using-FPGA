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
  	clear_enable  : out std_logic;
-------------------------------------------------------------------------------
  	t_out_data_i  : in std_logic_vector(7 downto 0 );
  	t_out_valid_i : in std_logic;
  	t_out_ready_o : out std_logic;
--------------------------------------------------------------------------------
  	his_wr_addr_o : out integer range 0 to 255;
  	his_rd_addr_o : out integer range 0 to 255;
  	his_wr_data_o	: out std_logic_vector((7) downto 0);	
  	his_rd_data_i	: in std_logic_vector((7) downto 0);	
  	his_wr_en     : out std_logic
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
 	signal wr_data_r : std_logic_vector((7) downto 0);	
  signal  data_r : std_logic_vector((7) downto 0);	
  signal  tmp_data : std_logic;	
  signal  data_r_r : std_logic_vector((7) downto 0);	
  signal  his_rd_data_r : std_logic_vector((7) downto 0);	

  signal temp_write_read_addr : integer range 0 to 255;
	signal wr_addr : integer range 0 to 255;
	signal wr_addr_r1 : integer range 0 to 255;
	signal wr_addr_r2 : integer range 0 to 255;
	signal tmp_addrs : integer range 0 to 255;
	signal tmp_sis : std_logic := '0';

	signal enable   : std_logic := '0';
	signal rd_addr : integer range 0 to 255;
	signal rd_addr_r : integer range 0 to 255;
	signal we_i   : std_logic := '0';
	signal we_i_r1   : std_logic := '0';
	signal we_i_r2   : std_logic := '0';
	signal t_user_r1   : std_logic := '0';
	signal t_user_r2   : std_logic := '0';

	signal state_ctrl   : std_logic := '0';
	signal ctrl   : std_logic := '0';
	signal empty_r   : std_logic := '0';

begin
t_out_ready_o   <= not empty_r ;
we_i   					<= not empty_r and t_out_valid_i;
his_wr_addr_o 	<= wr_addr_r2 ;
his_rd_addr_o 	<= rd_addr;
his_wr_data_o	  <= wr_data;
his_wr_en  			<= tmp_data ;
	
write_pr : process( clk_i )
		begin
			if (rising_edge(clk_i)) then
				if (rst_i='1') then
					State <= idle_s ;
					state_ctrl<='0';
					empty_r  <='1';
				  t_out_ready_o_r<='0';
				  data_r_r<=x"00";
				  temp_write_read_addr<=0;
				  clear_enable<='0';
				else
 					t_out_ready_o_r<=not empty_r;
 					 we_i_r1     	 <=we_i;--
 					we_i_r2        <=we_i_r1;
 					wr_addr_r1     <=wr_addr;
				  wr_addr_r2     <=wr_addr_r1;
				  t_user_r1 		 <=t_user_i;
				  t_user_r2 		 <=t_user_r1; 	
				  his_rd_data_r <=his_rd_data_i;
 					--we_r_r<=we_r;--
 					--data_v:=rd_data;


					case  State is
---------------------------------------------------------------------------
						when idle_s => 
						  tmp_data      <='0';
						  empty_r       <='1';
						  enable        <='0';
						  ctrl          <='0';
						  data_r        <=x"00";
						  clear_enable  <='0';

						  --rd_addr       <=temp_write_read_addr;
						  --wr_addr       <=temp_write_read_addr;
						  rd_addr       <= to_integer(unsigned(t_out_data_i));
						  wr_addr       <= to_integer(unsigned(t_out_data_i));
						  if (t_user_r2='1' or state_ctrl='1') then
						  	State       <=clear_s;
						  	state_ctrl  <='0';
						  	empty_r		  <='1';
						  	enable      <='1';
						  	clear_enable<='1';
						  	wr_data     <=x"00";
						  else
						  	State       <=idle_s;		
						  end if;
--------------------------------------------------------------------------						
						when clear_s =>
						  clear_enable    <='0';
						  State           <=valid_s;
						  --rd_addr         <=temp_write_read_addr;
						  --wr_addr         <=temp_write_read_addr;
						  --rd_addr       <= to_integer(unsigned(t_out_data_i));
						  --wr_addr       <= to_integer(unsigned(t_out_data_i));
						  
						  data_r_r        <=x"00";
						  data_r          <=x"00";
						  tmp_data        <='0';
						  ctrl            <='1';
						  empty_r         <='1';
--------------------------------------------------------------------------						
						when valid_s =>	
							rd_addr       <= to_integer(unsigned(t_out_data_i));
							wr_addr       <= to_integer(unsigned(t_out_data_i));
					 		if (rd_addr=wr_addr_r1) then
 								tmp_data    <='0';
 							else
 								tmp_data    <='1';		
 							end if;
 							
						  wr_data       <=std_logic_vector(to_unsigned(to_integer(unsigned(data_r_r)) + to_integer(unsigned(his_rd_data_i)), 8));
						    ------------------------------------------------------------------
		          if ((empty_r='1' or t_out_ready_o_r='1') ) then--and t_in_valid_i_r='1'
		          	if (t_out_valid_i='1'  ) then-- 
		          		 empty_r  <= '0' ;--0 
		          	else
		          		empty_r   <='1';	
		          	end if;
		          else
		              empty_r   <='0';		
		          end if;	
		          -----------------------------------------------------------------

		          if rd_addr=wr_addr_r1   then
		            if (we_i_r1='1') then
		            		data_r_r    <=std_logic_vector(to_unsigned(to_integer(unsigned(data_r_r)+1), 8));				
		            end if;		
		          elsif rd_addr/=wr_addr_r1 then	
		          		if	we_i_r1='1' then	
		          			data_r_r    <=x"01";					
		              else
		            	  data_r_r    <=x"00";				
		              end if;	
		          end if;
		          if (we_i='1')  and (rd_addr/=wr_addr_r1) and (rd_addr=wr_addr_r2	and we_i_r1='1') then
		          		 tmp_addrs<=wr_addr_r2;
		          		 tmp_sis<='1';
		          		 data_r_r    <=x"02";	
		          else
		            	 tmp_sis<='0';
		          end if;	
--------------------------------------------------------------------------------

		          ----------------------------------------------------------------
		          if (t_user_i='1') then
		          	empty_r     <='1';
		          	temp_write_read_addr<=to_integer(unsigned(t_out_data_i));
		          end if;
		          ----------------------------------------------------------------
		          if (t_user_r1='1') then
		          		tmp_data  <='1';
		          		empty_r     <='1';
		          end if;
		          ----------------------------------------------------------------
		          if (t_user_r2='1') then
		          		State     <=  idle_s;
		          		empty_r     <='1';
		          		enable    <='0';
		          		state_ctrl<='1';
		          		tmp_data  <='0';
		          		data_r_r  <=x"00";	
		          		empty_r   <='1';		
		          else
		          		State     <=  valid_s;		
		          end if;
		          ----------------------------------------------------------------
--------------------------------------------------------------------------						
						when others =>
							null;
					end case;
							
				end if;
			end if;
end process ; -- write_pr




end architecture ; -- arch