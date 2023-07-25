LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY bram_cntrl IS
	GENERIC (
		RAM_WIDTH : NATURAL := 72;
		RAM_DEPTH : NATURAL := 255
	);
	PORT (
		clk_i             : IN STD_LOGIC;
		rst_i             : IN STD_LOGIC;
		--in
		his_ready_start_i : IN STD_LOGIC;
		his_ready_stop_i  : IN STD_LOGIC;
		bram_ready_o      : OUT STD_LOGIC;
		--------------------------------------------------------------------------------
		his_wr_addr_i     : IN INTEGER RANGE 0 TO RAM_DEPTH;
		his_rd_addr_i     : IN INTEGER RANGE 0 TO RAM_DEPTH;
		his_wr_data_i     : IN STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
		his_rd_data_o     : OUT STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
		his_wr_en_i       : IN STD_LOGIC;
		--------------------------------------------------------------------------------
		eq_start_o        : OUT STD_LOGIC;
		eq_ready_i        : IN STD_LOGIC;
		eq_rd_addr_i      : IN INTEGER RANGE 0 TO RAM_DEPTH;
		eq_rd_data_o      : OUT STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
		-----ram 0 ram---------------------------------------------------------------

		we_0_a_o          : OUT STD_LOGIC;
		wr_addr_0_a_o     : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		wr_data_0_a_o     : OUT STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
		rd_addr_0_a_o     : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		rd_data_0_a_i     : IN STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
		we_0_b_o          : OUT STD_LOGIC := '0';
		wr_addr_0_b_o     : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		wr_data_0_b_o     : OUT STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
		rd_addr_0_b_o     : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		rd_data_0_b_i     : IN STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
		------------------------------------------------------------------------
		addr_0_a_o        : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		addr_0_b_o        : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		addr_1_a_o        : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		addr_1_b_o        : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		-----ram 1 ram---------------------------------------------------------------
		we_1_a_o          : OUT STD_LOGIC := '0';
		wr_addr_1_a_o     : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		wr_data_1_a_o     : OUT STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
		rd_addr_1_a_o     : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		rd_data_1_a_i     : IN STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
		we_1_b_o          : OUT STD_LOGIC := '0';
		wr_addr_1_b_o     : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		wr_data_1_b_o     : OUT STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
		rd_addr_1_b_o     : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		rd_data_1_b_i     : IN STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0)
	);
END ENTITY; -- 

ARCHITECTURE arch OF bram_cntrl IS

	TYPE bram_clear_State IS (idle_s, write0ram_s, write1ram_s);
	SIGNAL bram_State    : bram_clear_State;
	SIGNAL ram_0_1       : STD_LOGIC := '0';
	--------------------------------------------------------------------------------

	SIGNAL clear_counter : INTEGER RANGE 0 TO RAM_DEPTH;
	-------------------------------------------------------------------------------
	-----ram 0 ram---------------------------------------------------------------
	SIGNAL we_0_a        : STD_LOGIC := '0';
	SIGNAL wr_addr_0_a   : INTEGER RANGE 0 TO RAM_DEPTH;

	SIGNAL wr_data_0_a   : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL rd_addr_0_a   : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL rd_data_0_a   : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL we_0_b        : STD_LOGIC := '0';
	SIGNAL wr_addr_0_b   : INTEGER RANGE 0 TO RAM_DEPTH;

	SIGNAL wr_data_0_b   : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL rd_addr_0_b   : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL rd_data_0_b   : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	--------------------------------------------------------------------------------	
	SIGNAL addr_0_a      : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL addr_0_b      : INTEGER RANGE 0 TO RAM_DEPTH;
	--------------------------------------------------------------------------------
	-----ram 1 ram---------------------------------------------------------------
	SIGNAL we_1_a        : STD_LOGIC := '0';
	SIGNAL wr_addr_1_a   : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL wr_data_1_a   : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL rd_addr_1_a   : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL rd_data_1_a   : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);

	SIGNAL we_1_b        : STD_LOGIC := '0';
	SIGNAL wr_addr_1_b   : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL wr_data_1_b   : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	SIGNAL rd_addr_1_b   : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL rd_data_1_b   : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	--------------------------------------------------------------------------------	
	SIGNAL addr_1_a      : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL addr_1_b      : INTEGER RANGE 0 TO RAM_DEPTH;
	--------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	SIGNAL clear_ctrl    : STD_LOGIC := '0';
	SIGNAL bram_ready    : STD_LOGIC := '0';
	SIGNAL ram_0_active  : STD_LOGIC := '0';
	SIGNAL ram_1_active  : STD_LOGIC := '0';
	SIGNAL s_w0          : STD_LOGIC := '0';
	SIGNAL s_w1          : STD_LOGIC := '0';
	SIGNAL s_0_c         : STD_LOGIC := '0';
	SIGNAL s_1_c         : STD_LOGIC := '0';

BEGIN
	----------------------------------------------------------------------------
	we_0_a_o      <= we_0_a;
	wr_data_0_a_o <= wr_data_0_a;
	rd_data_0_a   <= rd_data_0_a_i;
	we_0_b_o      <= we_0_b;
	wr_data_0_b_o <= wr_data_0_b;
	----------------------------------------------------------------------------
	wr_addr_0_a_o <= wr_addr_0_a;
	rd_addr_0_a   <= his_rd_addr_i;
	rd_addr_0_a_o <= rd_addr_0_a;
	rd_addr_0_b_o <= eq_rd_addr_i;
	wr_addr_0_b_o <= wr_addr_0_b;
	addr_0_a_o    <= addr_0_a;
	addr_0_b_o    <= addr_0_b;
	addr_1_a_o    <= addr_1_a;
	addr_1_b_o    <= addr_1_b;
	----------------------------------------------------------------------------
	addr_0_a      <= wr_addr_0_a;
	addr_0_b      <=his_rd_addr_i WHEN ram_0_active = '1' ELSE
		eq_rd_addr_i WHEN ram_1_active = '1' ELSE
		(0);
	----------------------------------------------------------------------------
	addr_1_a <= wr_addr_1_a;
	addr_1_b <= eq_rd_addr_i WHEN ram_0_active = '1' ELSE
		his_rd_addr_i WHEN ram_1_active = '1' ELSE
		(0);--eq_ready_i = '0'
	--------------------------------------------------------------------------------
	eq_rd_data_o <= rd_data_1_b_i WHEN ram_0_active = '1' ELSE
		rd_data_0_b_i WHEN ram_1_active = '1' ELSE
		(OTHERS => '0');
	his_rd_data_o <= rd_data_0_b_i WHEN ram_0_active = '1' ELSE
		rd_data_1_b_i WHEN ram_1_active = '1' ELSE
		(OTHERS => '0');
		--we_0_a_o      <= his_wr_en_i WHEN ram_0_active = '1' ELSE '0' ;
		--we_1_a_o      <= his_wr_en_i WHEN ram_1_active = '1' ELSE '0' ;
	----------------------------------------------------------------------------
	wr_addr_1_a_o <= wr_addr_1_a;
	rd_addr_1_a   <= his_rd_addr_i;
	rd_addr_1_a_o <= rd_addr_1_a;
	wr_addr_1_b_o <= wr_addr_1_b;
	rd_addr_1_b_o <= eq_rd_addr_i;
	----------------------------------------------------------------------------
	----------------------------------------------------------------------------
	we_1_a_o      <= we_1_a;
	wr_data_1_a_o <= wr_data_1_a;
	rd_data_1_a   <= rd_data_1_a_i;
	we_1_b_o      <= we_1_b;
	wr_data_1_b_o <= wr_data_1_b;
	----------------------------------------------------------------------------
	bram_ready_o  <= bram_ready;
	bram_reset : PROCESS (clk_i) IS
	BEGIN
		IF (rising_edge(clk_i)) THEN
			IF (rst_i = '1') THEN
				bram_State   <= idle_s;
				ram_0_1      <= '0';
				clear_ctrl   <= '0';
				bram_ready   <= '0';
				ram_0_active <= '0';
				ram_1_active <= '0';
				s_w0         <= '0';
				s_w1         <= '0';
			ELSE
				CASE(bram_State) IS
					--------------------------------------------------------------------------
					--------------------------------------------------------------------------------				
					WHEN idle_s =>
					clear_counter <= 0;
					bram_ready    <= '0';
					ram_0_active  <= '0';
					ram_1_active  <= '0';
					eq_start_o    <= '0';
					we_1_b        <= '0';
					s_w0          <= '0';
					s_w1          <= '0';
					wr_data_1_b   <= (OTHERS => '0');
					wr_data_1_a   <= (OTHERS => '0');
					wr_data_0_b   <= (OTHERS => '0');
					wr_data_0_a   <= (OTHERS => '0');

					IF (ram_0_1 = '0' AND his_ready_start_i = '1') THEN
						bram_State   <= write0ram_s;
						clear_ctrl   <= '1';
						we_0_a       <= '0';
						we_0_b       <= '0';
						we_1_a       <= '0';
						we_1_b       <= '0';
						eq_start_o   <= '1';
						ram_0_active <= '1';
						ram_1_active <= '0';
						s_w0         <= '0';
						s_w1         <= '0';

					ELSIF (ram_0_1 = '1' AND his_ready_start_i = '1') THEN
						bram_State   <= write1ram_s;
						clear_ctrl   <= '1';
						we_0_a       <= '0';
						we_0_b       <= '0';
						eq_start_o   <= '1';
						we_1_a       <= '0';
						we_1_b       <= '0';
						ram_0_active <= '0';
						ram_1_active <= '1';
						s_w0         <= '0';
						s_w1         <= '0';
					END IF;
					--------------------------------------------------------------------------
					--------------------------------------------------------------------------------
					WHEN write0ram_s =>
					bram_ready  <= '1';
					eq_start_o  <= '0';
					we_0_a      <= his_wr_en_i;
					wr_addr_0_a <= his_wr_addr_i;
					wr_data_0_a <= his_wr_data_i;
					s_w0        <= '1';
					--------------------------------------------------------------------------
					we_0_b      <= '0';
					we_1_b      <= '0';
					wr_addr_0_b <= 0;
					wr_data_0_b <= (OTHERS => '0');
					rd_addr_0_b <= 0;
					rd_data_0_b <= (OTHERS => '0');
					--------------------------------------------------------------------------						
					IF (clear_counter = RAM_DEPTH) THEN
						we_1_b     <= '0';
						we_1_a     <= '0';
						clear_ctrl <= '0';
					ELSIF eq_ready_i = '0' AND clear_ctrl = '1' AND s_w0 = '1' THEN
						we_1_a        <= '1';
						wr_addr_1_a   <= clear_counter;
						wr_data_1_a   <= (OTHERS => '0');
						we_1_b        <= '1';
						wr_addr_1_b   <= (RAM_DEPTH - clear_counter);
						wr_data_1_b   <= (OTHERS => '0');
						s_0_c         <= '1';
						clear_counter <= clear_counter + 1;
					END IF;
					--------------------------------------------------------------------------
					IF (his_ready_stop_i = '1') THEN
						ram_0_1      <= '1';
						bram_State   <= idle_s;
						ram_0_active <= '0';
						ram_1_active <= '0';
					END IF;
					---------------------------------------------------------------------------------
					---------------------------------------------------------------------------------
					WHEN write1ram_s =>
					bram_ready  <= '1';
					eq_start_o  <= '0';
					s_w1        <= '1';
					we_1_a      <= his_wr_en_i;
					wr_addr_1_a <= his_wr_addr_i;
					wr_data_1_a <= his_wr_data_i;
					--------------------------------------------------------------------
					we_0_b      <= '0';
					we_0_a      <= '0';
					we_1_b      <= '0';
					wr_addr_1_b <= 0;
					wr_data_1_b <= (OTHERS => '0');
					rd_addr_1_b <= 0;
					rd_data_1_b <= (OTHERS => '0');
					IF (clear_counter = RAM_DEPTH/2) THEN
						we_0_b     <= '0';
						we_0_a     <= '0';
						clear_ctrl <= '0';
					ELSIF eq_ready_i = '0' AND clear_ctrl = '1' AND s_w1 = '1' THEN
						we_0_a        <= '1';
						wr_addr_0_a   <= clear_counter;
						wr_data_0_a   <= (OTHERS => '0');
						we_0_b        <= '1';
						wr_addr_0_b   <= (RAM_DEPTH - clear_counter);
						wr_data_0_b   <= (OTHERS => '0');
						s_0_c         <= '0';
						s_1_c         <= '1';
						clear_counter <= clear_counter + 1;
					END IF;
					--------------------------------------------------------------------------
					IF (his_ready_stop_i = '1') THEN
						ram_0_1      <= '0';
						bram_State   <= idle_s;
						ram_0_active <= '0';
						ram_1_active <= '0';
					END IF;
					--------------------------------------------------------------------------------
					--------------------------------------------------------------------------------
					WHEN OTHERS =>
					NULL;
				END CASE;
			END IF;

		END IF;

	END PROCESS;      -- bram_reset
END ARCHITECTURE; -- arch
