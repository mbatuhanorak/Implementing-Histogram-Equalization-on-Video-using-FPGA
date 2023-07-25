LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pattern_generator_r2 IS
	GENERIC (
		v_sync : INTEGER := 240;
		h_sync : INTEGER := 160;
		RAM_WIDTH : NATURAL := 72;
		RAM_DEPTH : NATURAL := 255
	);
	PORT (
		clk_i         : IN STD_LOGIC;
		rst_i         : IN STD_LOGIC;
		--------------------------------------------------------------------------
		--in
		t_in_data_i   : IN STD_LOGIC_VECTOR(RAM_WIDTH-1 DOWNTO 0);
		t_in_valid_i  : IN STD_LOGIC;
		t_in_ready_o  : OUT STD_LOGIC;
		--------------------------------------------------------------------------
		--out
		t_out_ready_i : IN STD_LOGIC;
		t_out_data_o  : OUT STD_LOGIC_VECTOR(RAM_WIDTH-1 DOWNTO 0);
		t_out_valid_o : OUT STD_LOGIC;
		--------------------------------------------------------------------------
		t_last_o      : OUT STD_LOGIC;
		--t_test_o  : out std_logic;
		t_user_o      : OUT STD_LOGIC
	);
END ENTITY; -- pattern_generator

ARCHITECTURE arch OF pattern_generator_r2 IS
	SIGNAL h_count_r       : INTEGER RANGE 0 TO h_sync := 0;
	SIGNAL v_count_r       : INTEGER RANGE 0 TO v_sync := 0;
	SIGNAL pixel_count     : INTEGER;
	SIGNAL valid_r         : STD_LOGIC;
	SIGNAL wr_en           : STD_LOGIC;
	SIGNAL empty_r         : STD_LOGIC;
	--------------------------------------------------------------------------------
	SIGNAL t_in_data_i_r   : STD_LOGIC_VECTOR(RAM_WIDTH-1 DOWNTO 0);
	SIGNAL t_in_valid_i_r  : STD_LOGIC;
	SIGNAL t_out_ready_i_r : STD_LOGIC;
	--------------------------------------------------------------------------------
	SIGNAL t_in_ready_o_r  : STD_LOGIC;
	SIGNAL t_out_data_o_r  : STD_LOGIC_VECTOR(RAM_WIDTH-1 DOWNTO 0);
	SIGNAL t_out_valid_o_r : STD_LOGIC;
	--------------------------------------------------------------------------
	SIGNAL t_last_o_r      : STD_LOGIC;
	SIGNAL t_user_o_r      : STD_LOGIC;
	SIGNAL test_r          : STD_LOGIC;
	--signal t_test_r:std_logic; 

BEGIN
	--t_in_ready_o <= empty_r or t_out_ready_i; ---
	t_in_ready_o  <= empty_r OR t_out_ready_i;
	t_out_data_o  <= t_out_data_o_r;
	t_out_valid_o <= NOT empty_r; --
	t_last_o      <= t_last_o_r;
	t_user_o      <= test_r;
	--t_test_o    <=test_r;
	sync_process : PROCESS (clk_i, rst_i) IS
	BEGIN
		IF (rst_i = '1') THEN
			h_count_r       <= 0;
			v_count_r       <= 0;
			t_last_o_r      <= '0';
			t_user_o_r      <= '0';
			empty_r         <= '1';
			valid_r         <= '0';
			t_in_data_i_r   <= (OTHERS => '0');
			t_in_valid_i_r  <= '0';
			t_out_ready_i_r <= '0';
			t_out_valid_o_r <= '0';
			pixel_count     <= 0;
			--t_in_ready_o_r<='0';
			test_r          <= '0';
		ELSIF (rising_edge(clk_i)) THEN
			t_in_data_i_r   <= t_in_data_i;
			t_in_valid_i_r  <= t_in_valid_i;
			t_out_ready_i_r <= t_out_ready_i;
			t_out_valid_o_r <= NOT empty_r;

			wr_en           <= empty_r OR t_out_ready_i;

			------------------------------------------------------------------------
			IF ((empty_r = '1' OR t_out_ready_i = '1')) THEN --and t_in_valid_i_r='1' bunu değiştirdin (empty_r='1' or t_out_ready_i_r='1')
				IF (t_in_valid_i_r = '1') THEN                   -- 
					empty_r        <= '0';                           --0
					t_out_data_o_r <= t_in_data_i_r;                 --t_in_data_i_r
					valid_r        <= '1';

					IF (h_count_r = h_sync - 1) THEN
						IF (v_count_r = v_sync - 1) THEN
							v_count_r  <= 0;
							t_user_o_r <= '1';
							--empty_r        <= '1';  
						ELSE
							t_user_o_r <= '0';
							v_count_r  <= v_count_r + 1;
						END IF;
						t_last_o_r  <= '1';
						--empty_r        <= '1';
						h_count_r   <= 0;
						pixel_count <= pixel_count + 1;
					ELSE
						t_user_o_r  <= '0';
						h_count_r   <= h_count_r + 1;
						pixel_count <= pixel_count + 1;

						IF (v_count_r = 0 AND h_count_r = 0) THEN
							test_r      <= '1';
							pixel_count <= 1;
							
						ELSE
							test_r <= '0';

						END IF;
						t_last_o_r <= '0';
					END IF;
					

				ELSE
					t_last_o_r <= '0';
					test_r     <= '0';
					t_user_o_r <= '0';
					empty_r    <= '1';
				END IF;

			ELSE
				valid_r    <= '0';
				test_r     <= '0';
				empty_r    <= '0';
				t_user_o_r <= '0';
				t_last_o_r <= '0';
			END IF;
			------------------------------------------------------------------------
		END IF;
	END PROCESS;      -- sync_process
END ARCHITECTURE; -- arch
