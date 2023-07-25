library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity top is
  port (
  	clk_i	  : in std_logic;
  	rst_i	  : in std_logic;
  	--in
  	t_in_data_i  : in std_logic_vector(7 downto 0 );
  	ram_datao  : out std_logic_vector(7 downto 0 );
    ram_wr_addr_o:out integer range 0 to 255;
  	ram_data_en  : out std_logic;
  	t_in_valid_i : in std_logic;
  	ram_do  : out std_logic_vector(7 downto 0 );
  	t_in_ready_o : out std_logic

  ) ;
end entity ; -- pattern_generator

architecture arch of top is
	---
	signal t_out_ready_i_w : std_logic;
	signal t_out_data_o_w  : std_logic_vector(7 downto 0 );
	signal t_out_valid_o_w : std_logic;
	signal t_last_o_w      : std_logic;
	signal t_user_o_w      : std_logic;
	signal clear_enable      : std_logic;
	-- Other constants
	constant C_CLK_PERIOD : time:=1 ns; -- NS
------------------------------------------------------------------------------ 
 signal his_addr_o    : integer range 0 to 255;
 signal his_wr_addr_o    : integer range 0 to 255;
 signal his_rd_addr_o    : integer range 0 to 255;  
 signal his_wr_data_o		: std_logic_vector(7 downto 0);	
 signal his_wr_en     : std_logic;
 signal q_o           :  std_logic_vector(7 downto 0);	
-------------------------------------------------------------------------------	
begin
	ram_do<=q_o;
	ram_data_en<=his_wr_en;
	ram_datao  <=his_wr_data_o;
	ram_wr_addr_o<=his_wr_addr_o;
pattern_generator_r_1 : entity work.pattern_generator_r
		generic map (
			v_sync => 24,
			h_sync => 16
		)
		port map (
			clk_i         => clk_i,
			rst_i         => rst_i,
			t_in_data_i   => t_in_data_i,
			t_in_valid_i  => t_in_valid_i,
			t_in_ready_o  => t_in_ready_o,
			t_out_ready_i => t_out_ready_i_w,
			t_out_data_o  => t_out_data_o_w,
			t_out_valid_o => t_out_valid_o_W,
			t_last_o      => t_last_o_W,
			t_user_o      => t_user_o_W
		);	
------------------------------------------------------------------------------		
	histogram : entity work.histogram_r
	port map (
			clk_i         => clk_i,
			rst_i         => rst_i,
			t_last_i      => t_last_o_W,
			t_user_i      => t_user_o_W,
			clear_enable  => clear_enable,
			t_out_data_i  => t_out_data_o_w,
			t_out_valid_i => t_out_valid_o_W,
			t_out_ready_o => t_out_ready_i_w,
  	  his_wr_addr_o => his_wr_addr_o,
  	  his_rd_addr_o => his_rd_addr_o,
  	  his_wr_data_o	=> his_wr_data_o,
  	  his_rd_data_i	=> q_o,
  	  his_wr_en     => his_wr_en

		);

	bram_dual_port_1 : entity work.bram_dual_port
		generic map (
			DATA_WIDTH => 8,
			ADDR_WIDTH => 8
		)
		port map (
			clk   => clk_i,
			clear_enable => clear_enable,
			raddr => his_rd_addr_o,
			waddr => his_wr_addr_o,
			data  => his_wr_data_o,
			we    => his_wr_en,
			q     => q_o
		);


end architecture ; -- arch