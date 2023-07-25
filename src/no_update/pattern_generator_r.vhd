library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity pattern_generator_r is
	generic (
			v_sync : integer:=240;
			h_sync : integer:=160
		);
  port (
  	clk_i	  : in std_logic;
  	rst_i	  : in std_logic;
  	--------------------------------------------------------------------------
  	--in
  	t_in_data_i  : in std_logic_vector(7 downto 0 );
  	t_in_valid_i : in std_logic;
    t_in_ready_o : out std_logic;	
  	--------------------------------------------------------------------------
  	--out
  	t_out_ready_i : in std_logic;
  	t_out_data_o  : out std_logic_vector(7 downto 0 );
  	t_out_valid_o : out std_logic;
  	--------------------------------------------------------------------------
  	t_last_o  : out std_logic;
  	--t_test_o  : out std_logic;
  	t_user_o  : out std_logic
  ) ;
end entity ; -- pattern_generator

architecture arch of pattern_generator_r is
signal h_count_r :integer range 0 to h_sync:=0;
signal v_count_r :integer range 0 to v_sync:=0;
signal valid_r:std_logic; 
signal wr_en     :std_logic; 
signal empty_r     :std_logic;
--------------------------------------------------------------------------------
signal t_in_data_i_r :   std_logic_vector(7 downto 0 );
signal t_in_valid_i_r :   std_logic;
signal t_out_ready_i_r : std_logic;
--------------------------------------------------------------------------------
signal t_in_ready_o_r :   std_logic;	
signal t_out_data_o_r  : std_logic_vector(7 downto 0 );
signal t_out_valid_o_r: std_logic;
--------------------------------------------------------------------------
signal t_last_o_r  :  std_logic;
signal t_user_o_r  :  std_logic;
signal test_r:std_logic; 
--signal t_test_r:std_logic; 

begin
--t_in_ready_o <= empty_r or t_out_ready_i; ---
t_in_ready_o <=  empty_r or t_out_ready_i;
t_out_data_o <=t_out_data_o_r ;
t_out_valid_o<= not empty_r;--
t_last_o    <=t_last_o_r  ;
t_user_o    <=test_r  ;  
--t_test_o    <=test_r;
sync_process : process(clk_i,rst_i) is
begin
	if (rst_i='1') then
	    h_count_r <= 0 ;
	    v_count_r <= 0 ;
	    t_last_o_r  <='0';
	    t_user_o_r  <='0';
      empty_r   <='1';
      valid_r   <='0';
      t_in_data_i_r  <=(others => '0'); 
			t_in_valid_i_r <='0';
			t_out_ready_i_r<='0';
			t_out_valid_o_r<='0';
			--t_in_ready_o_r<='0';
			test_r<='0';
	elsif (rising_edge(clk_i)) then
	   t_in_data_i_r  <=  t_in_data_i;
	   t_in_valid_i_r <= t_in_valid_i;
     t_out_ready_i_r<=t_out_ready_i;
     t_out_valid_o_r<= not empty_r;

     wr_en          <= empty_r or t_out_ready_i;
------------------------------------------------------------------------
		if ((empty_r='1' or t_out_ready_i='1') ) then--and t_in_valid_i_r='1' bunu değiştirdin (empty_r='1' or t_out_ready_i_r='1')
			if (t_in_valid_i_r='1'  ) then-- 
				empty_r           <= '0' ;--0
				t_out_data_o_r      <= t_in_data_i_r;--t_in_data_i_r
				valid_r<='1';

		        if (h_count_r=h_sync-1) then
		             if (v_count_r=v_sync-1) then
		        		v_count_r <= 0 ;
		        		t_user_o_r  <='1';
		        	else
		        	    t_user_o_r  <= '0'       ;
		        	    v_count_r <=v_count_r+1;  												
		        	end if;	
		        	t_last_o_r      <='1';
		        	h_count_r     <= 0 ;	
		        else
		           t_user_o_r       <= '0';
		           h_count_r      <=h_count_r+1;
		           if (v_count_r=0 and h_count_r=0 ) then
		           	test_r<='1';
		           else
		           		test_r<='0';	
		           end if;
		           t_last_o_r       <='0';
		        end if;			
			else
			    t_last_o_r       <='0';
			    test_r<='0';	
			    t_user_o_r       <= '0';
				empty_r           <='1';		
			end if;

		else
			valid_r<='0';
				test_r<='0';	
		    empty_r           <='0';	
		    t_user_o_r       <= '0';
			 t_last_o_r       <='0';	
		end if;	

------------------------------------------------------------------------
	end if;
end process; -- sync_process
end architecture ; -- arch