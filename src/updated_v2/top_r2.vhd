LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top_r2 IS
	GENERIC (
	v_sync : INTEGER := 240;
	h_sync : INTEGER := 160;
		RAM_WIDTH : NATURAL := 72;
		ADDR_WIDTH : INTEGER := 8;
		RAM_DEPTH_fifo : NATURAL := 255;
		RAM_DEPTH : NATURAL := 255

	);
	PORT (
		clk_i         : IN STD_LOGIC;
		rst_i         : IN STD_LOGIC;
		--in
		t_in_data_i   : IN STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
		ram_datao     : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
		ram_wr_addr_o : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		ram_data_en   : OUT STD_LOGIC;
		t_in_valid_i  : IN STD_LOGIC;
		pixel_data_o  : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
		pixel_valid_o : OUT STD_LOGIC;
		ram_do        : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
		m_axis_dout_tvalid : OUT STD_LOGIC;
    	m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(71 DOWNTO 0) ;
		t_in_ready_o  : OUT STD_LOGIC

	);
END ENTITY; -- pattern_generator

ARCHITECTURE arch OF top_r2 IS
COMPONENT div_gen_0
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_divisor_tvalid : IN STD_LOGIC;
    s_axis_divisor_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    s_axis_dividend_tvalid : IN STD_LOGIC;
    s_axis_dividend_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axis_dout_tvalid : OUT STD_LOGIC;
    m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(71 DOWNTO 0) 
  );
END COMPONENT;
	-- COMP_TAG_END ------ End COMPONENT Declaration ------------
	constant  s_axis_divisor_tdata   : STD_LOGIC_VECTOR(23 DOWNTO 0):=STD_LOGIC_VECTOR(to_unsigned( v_sync*h_sync,24));
	SIGNAL s_axis_divisor_tvalid  : STD_LOGIC;
	SIGNAL s_axis_divisor_tready  : STD_LOGIC;
	SIGNAL s_axis_dividend_tvalid : STD_LOGIC;
	SIGNAL s_axis_dividend_tready : STD_LOGIC;
	SIGNAL s_axis_dividend_tdata  : STD_LOGIC_VECTOR(63 DOWNTO 0);
	SIGNAL t_out_ready_i_w        : STD_LOGIC;
	SIGNAL t_out_data_o_w         : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
	SIGNAL t_out_valid_o_w        : STD_LOGIC;
	SIGNAL t_last_o_w             : STD_LOGIC;
	SIGNAL t_user_o_w             : STD_LOGIC;
	SIGNAL clear_enable           : STD_LOGIC;
	-- Other constants
	CONSTANT C_CLK_PERIOD         : TIME := 1 ns; -- NS
	------------------------------------------------------------------------------ 
	SIGNAL his_addr_o             : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL his_wr_addr_o          : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL his_rd_addr_o          : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL his_wr_data_o          : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
	SIGNAL his_wr_en              : STD_LOGIC;
	SIGNAL his_rd_data_i          : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
	-------------------------------------------------------------------------------	
	SIGNAL his_ready_start_i      : STD_LOGIC;
	SIGNAL his_ready_stop_i       : STD_LOGIC;
	SIGNAL bram_ready_o           : STD_LOGIC;
	SIGNAL we_0_a_o               : STD_LOGIC;
	SIGNAL wr_addr_0_a_o          : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL wr_data_0_a_o          : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL rd_addr_0_a_o          : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL rd_data_0_a_i          : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL we_0_b_o               : STD_LOGIC := '0';
	SIGNAL wr_addr_0_b_o          : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL wr_data_0_b_o          : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL rd_addr_0_b_o          : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL rd_data_0_b_i          : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	------------------------------------------------------------------------------
	SIGNAL we_1_a_o               : STD_LOGIC := '0';
	SIGNAL wr_addr_1_a_o          : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL wr_data_1_a_o          : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL rd_addr_1_a_o          : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL rd_data_1_a_i          : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL we_1_b_o               : STD_LOGIC := '0';
	SIGNAL wr_addr_1_b_o          : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL wr_data_1_b_o          : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL rd_addr_1_b_o          : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL rd_data_1_b_i          : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	------------------------------------------------------------------------------
	SIGNAL addr_0_a_o             : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL addr_0_b_o             : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL addr_1_a_o             : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL addr_1_b_o             : INTEGER RANGE 0 TO RAM_DEPTH;
	---------------------------------------------------------------------------
	SIGNAL eq_start_i             : STD_LOGIC;
	SIGNAL eq_ready_o             : STD_LOGIC;

	SIGNAL eq_rd_data_i           : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL eq_wr_addr_o           : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL eq_wr_data_o           : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL eq_wr_en               : STD_LOGIC;
	SIGNAL eq_rd_addr_w           : INTEGER RANGE 0 TO RAM_DEPTH;

	SIGNAL fifo_rd_en_w           : STD_LOGIC;
	SIGNAL fifo_rd_valid_w        : STD_LOGIC;
	SIGNAL fifo_rd_data_w         : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
	SIGNAL h_bram_rd_data_w       : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
	SIGNAL h_bram_rd_addr_w       : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL pixel_data_w           : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
	SIGNAL pixel_valid_w          : STD_LOGIC;
	SIGNAL empty_w                : STD_LOGIC;
	SIGNAL full_w                 : STD_LOGIC;
	SIGNAL eq_read_finished_w     : STD_LOGIC;

BEGIN
	pixel_data_o  <= pixel_data_w;
	pixel_valid_o <= pixel_valid_w;
	ram_do        <= his_rd_data_i;
	ram_data_en   <= his_wr_en;
	ram_datao     <= his_wr_data_o;
	ram_wr_addr_o <= his_wr_addr_o;
	pattern_generator : ENTITY work.pattern_generator_r2
	GENERIC map (
		v_sync 	 =>v_sync 	 ,
		h_sync   =>h_sync   ,
		RAM_WIDTH=>RAM_WIDTH,
		RAM_DEPTH=>RAM_DEPTH
	)
		PORT MAP(
			clk_i         => clk_i,
			rst_i         => rst_i,
			t_in_data_i   => t_in_data_i,
			t_in_valid_i  => t_in_valid_i,
			t_in_ready_o  => t_in_ready_o,
			t_out_ready_i => t_out_ready_i_w,
			t_out_data_o  => t_out_data_o_w,
			t_out_valid_o => t_out_valid_o_w,
			t_last_o      => t_last_o_w,
			t_user_o      => t_user_o_w
		);
	------------------------------------------------------------------------------	
	fifo : ENTITY work.fifo
	GENERIC map (
		RAM_WIDTH=>RAM_WIDTH,
		RAM_DEPTH=>RAM_DEPTH_fifo
	)
		PORT MAP(
			clk_i         => clk_i,
			rst_i         => rst_i,
			t_data_i      => t_out_data_o_w,
			t_valid_i     => t_out_valid_o_w,
			t_ready_i     => t_out_ready_i_w,
			t_user_o      => t_user_o_w,
			fifo_rd_en    => fifo_rd_en_w,
			fifo_rd_valid => fifo_rd_valid_w,
			fifo_rd_data  => fifo_rd_data_w,
			empty         => empty_w,
			empty_next    => OPEN,
			full          => full_w,
			full_next     => OPEN,
			fill_count    => OPEN
		);
	------------------------------------------------------------------------------	
	his_eq_pattern : ENTITY work.his_eq_pattern
	GENERIC map (
		v_sync 	 =>v_sync 	 ,
		h_sync   =>h_sync   ,
		RAM_WIDTH=>RAM_WIDTH,
		RAM_DEPTH=>RAM_DEPTH
	)
		PORT MAP(
			clk_i              => clk_i,
			rst_i              => rst_i,
			t_user_o           => t_user_o_w,
			fifo_rd_en_o       => fifo_rd_en_w,
			fifo_rd_valid_i    => fifo_rd_valid_w,
			fifo_rd_data_i     => fifo_rd_data_w,
			h_bram_rd_addr_o   => h_bram_rd_addr_w,
			h_bram_rd_data_i   => h_bram_rd_data_w,
			eq_read_finished_i => eq_read_finished_w,
			pixel_data_o       => pixel_data_w,
			pixel_valid_o      => pixel_valid_w,
			empty              => empty_w,
			full               => full_w
		);

	histogram : ENTITY work.histogram_r2
	GENERIC map (
		RAM_WIDTH=>RAM_WIDTH,
		RAM_DEPTH=>RAM_DEPTH
	)
		PORT MAP(
			clk_i             => clk_i,
			rst_i             => rst_i,
			his_ready_start_o => his_ready_start_i,
			his_ready_stop_o  => his_ready_stop_i,
			bram_ready_i      => bram_ready_o,
			t_last_i          => t_last_o_w,
			t_user_i          => t_user_o_w,
			clear_enable      => clear_enable,
			t_out_data_i      => t_out_data_o_w,
			t_out_valid_i     => t_out_valid_o_w,
			t_out_ready_o     => t_out_ready_i_w,
			his_wr_addr_o     => his_wr_addr_o,
			his_rd_addr_o     => his_rd_addr_o,
			his_wr_data_o     => his_wr_data_o,
			his_rd_data_i     => his_rd_data_i,
			his_wr_en         => his_wr_en

		);
	bram_cntrl_1 : ENTITY work.bram_cntrl
	GENERIC map (
		RAM_WIDTH=>RAM_WIDTH,
		RAM_DEPTH=>RAM_DEPTH
	)
		PORT MAP(
			clk_i             => clk_i,
			rst_i             => rst_i,
			his_ready_start_i => his_ready_start_i,
			his_ready_stop_i  => his_ready_stop_i,
			bram_ready_o      => bram_ready_o,
			his_wr_addr_i     => his_wr_addr_o,
			his_rd_addr_i     => his_rd_addr_o,
			his_wr_data_i     => his_wr_data_o,
			his_rd_data_o     => his_rd_data_i,
			his_wr_en_i       => his_wr_en,

			eq_start_o        => eq_start_i,
			eq_ready_i        => eq_ready_o,
			eq_rd_addr_i      => eq_rd_addr_w,
			eq_rd_data_o      => eq_rd_data_i,
			we_0_a_o          => we_0_a_o,
			wr_addr_0_a_o     => wr_addr_0_a_o,
			wr_data_0_a_o     => wr_data_0_a_o,
			rd_addr_0_a_o     => rd_addr_0_a_o,
			rd_data_0_a_i     => rd_data_0_a_i,

			we_0_b_o          => we_0_b_o,
			wr_addr_0_b_o     => wr_addr_0_b_o,
			wr_data_0_b_o     => wr_data_0_b_o,
			rd_addr_0_b_o     => rd_addr_0_b_o,
			rd_data_0_b_i     => rd_data_0_b_i,

			we_1_a_o          => we_1_a_o,
			wr_addr_1_a_o     => wr_addr_1_a_o,
			wr_data_1_a_o     => wr_data_1_a_o,
			rd_addr_1_a_o     => rd_addr_1_a_o,
			rd_data_1_a_i     => rd_data_1_a_i,

			we_1_b_o          => we_1_b_o,
			wr_addr_1_b_o     => wr_addr_1_b_o,
			wr_data_1_b_o     => wr_data_1_b_o,
			rd_addr_1_b_o     => rd_addr_1_b_o,
			rd_data_1_b_i     => rd_data_1_b_i,
			addr_0_a_o        => addr_0_a_o,
			addr_0_b_o        => addr_0_b_o,
			addr_1_a_o        => addr_1_a_o,
			addr_1_b_o        => addr_1_b_o

		);

	dual_port_bram_0 : ENTITY work.dual_port_bram
		GENERIC MAP(
			DATA_WIDTH => RAM_WIDTH,
			ADDR_WIDTH =>ADDR_WIDTH
		)
		PORT MAP(
			clk    => clk_i,
			addr_a => addr_0_a_o, --rd_addr_0_a_o --wr_addr_0_a_o
			addr_b => addr_0_b_o, --rd_addr_0_b_o,wr_addr_0_b_o
			--waddr_a => wr_addr_0_a_o,
			--waddr_b => wr_addr_0_b_o,
			data_a => wr_data_0_a_o,
			data_b => wr_data_0_b_o,
			we_a   => we_0_a_o,
			we_b   => we_0_b_o,
			q_a    => rd_data_0_a_i,
			q_b    => rd_data_0_b_i
		);

	dual_port_bram_1 : ENTITY work.dual_port_bram
		GENERIC MAP(
			DATA_WIDTH => RAM_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH
		)
		PORT MAP(
			clk    => clk_i,
			addr_a => addr_1_a_o, --rd_addr_1_a_o, --wr_addr_1_a_o
			addr_b => addr_1_b_o, --rd_addr_1_b_o, --wr_addr_1_b_o
			--waddr_a => wr_addr_1_a_o,
			--waddr_b => wr_addr_1_b_o,
			data_a => wr_data_1_a_o,
			data_b => wr_data_1_b_o,
			we_a   => we_1_a_o,
			we_b   => we_1_b_o,
			q_a    => rd_data_1_a_i,
			q_b    => rd_data_1_b_i
		);
	hiseq : ENTITY work.hiseq
	GENERIC map (
		v_sync 	 =>v_sync 	 ,
		h_sync   =>h_sync   ,
		RAM_WIDTH=>RAM_WIDTH,
		RAM_DEPTH=>RAM_DEPTH
	)
		PORT MAP(
			clk_i              => clk_i,
			rst_i              => rst_i,
			eq_rd_addr_o       => eq_rd_addr_w,
			eq_rd_data_i       => eq_rd_data_i,
			eq_wr_addr_o       => eq_wr_addr_o,
			eq_wr_data_o       => eq_wr_data_o,
			eq_read_finished_o => eq_read_finished_w,
			eq_wr_en           => eq_wr_en,
			eq_start_i         => eq_start_i,
			eq_ready_o         => eq_ready_o
		);
	bram_his_eq : ENTITY work.dual_port_bram
	GENERIC MAP(
		DATA_WIDTH => RAM_WIDTH,
		ADDR_WIDTH =>ADDR_WIDTH
	)
		PORT MAP(
			clk    => clk_i,
			addr_a => eq_wr_addr_o, --
			addr_b => h_bram_rd_addr_w,
			--waddr_a => ,
			--waddr_b => 0,
			data_a => eq_wr_data_o,
			data_b => (OTHERS => '0'),
			we_a   => eq_wr_en,
			we_b   => '0',
			q_a    => OPEN,
			q_b    => h_bram_rd_data_w
		);

	-- divider_gen_ins : div_gen_0
	-- PORT MAP(
	-- 	aclk                   => clk_i,
	-- 	s_axis_divisor_tvalid  => '1',
	-- 	s_axis_divisor_tdata   => s_axis_divisor_tdata,
	-- s_axis_dividend_tvalid => pixel_valid_w,
	-- s_axis_dividend_tdata  => pixel_data_w(63 downto 0),
	-- m_axis_dout_tvalid     => m_axis_dout_tvalid,
	-- m_axis_dout_tdata      => m_axis_dout_tdata
	-- );
END ARCHITECTURE; -- arch
