LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY histogram_r2 IS
GENERIC (
    RAM_WIDTH : NATURAL := 72;
    RAM_DEPTH : NATURAL := 255
  );
	PORT (
		clk_i             : IN STD_LOGIC;
		rst_i             : IN STD_LOGIC;
		----------------------------------------------------------------------------
		his_ready_start_o : OUT STD_LOGIC;
		his_ready_stop_o  : OUT STD_LOGIC;
		bram_ready_i      : IN STD_LOGIC;
		-----------------------------------------------------------------------------
		--in
		t_last_i          : IN STD_LOGIC;
		t_user_i          : IN STD_LOGIC;
		clear_enable      : OUT STD_LOGIC;
		-------------------------------------------------------------------------------
		t_out_data_i      : IN STD_LOGIC_VECTOR(RAM_WIDTH-1 DOWNTO 0);
		t_out_valid_i     : IN STD_LOGIC;
		t_out_ready_o     : OUT STD_LOGIC;
		--------------------------------------------------------------------------------
		his_wr_addr_o     : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		his_rd_addr_o     : OUT INTEGER RANGE 0 TO RAM_DEPTH;
		his_wr_data_o     : OUT STD_LOGIC_VECTOR((RAM_WIDTH-1) DOWNTO 0);
		his_rd_data_i     : IN STD_LOGIC_VECTOR((RAM_WIDTH-1) DOWNTO 0);
		his_wr_en         : OUT STD_LOGIC
		--------------------------------------------------------------------------------

	);
END ENTITY; -- 

ARCHITECTURE arch OF histogram_r2 IS
	CONSTANT DATA_WIDTH    : INTEGER   := 72;
	CONSTANT ADDR_WIDTH    : INTEGER   := 8;

	SIGNAL t_out_ready_o_r : STD_LOGIC := '0';

	TYPE t_State IS (idle_s, valid_s, clear_s);

	SIGNAL State                : t_State;
	SIGNAL wr_data              : STD_LOGIC_VECTOR((RAM_WIDTH-1) DOWNTO 0);
	SIGNAL wr_data_r            : STD_LOGIC_VECTOR((RAM_WIDTH-1) DOWNTO 0);
	SIGNAL data_r               : STD_LOGIC_VECTOR((RAM_WIDTH-1) DOWNTO 0);
	SIGNAL tmp_data             : STD_LOGIC;
	SIGNAL data_r_r             : STD_LOGIC_VECTOR((RAM_WIDTH-1) DOWNTO 0);
	SIGNAL his_rd_data_r        : STD_LOGIC_VECTOR((RAM_WIDTH-1) DOWNTO 0);

	SIGNAL temp_write_read_addr : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL wr_addr              : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL wr_addr_r1           : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL wr_addr_r2           : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL tmp_addrs            : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL v_counter             : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL tmp_sis              : STD_LOGIC := '0';

	SIGNAL enable               : STD_LOGIC := '0';
	SIGNAL rd_addr              : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL rd_addr_r            : INTEGER RANGE 0 TO RAM_DEPTH;
	SIGNAL we_i                 : STD_LOGIC := '0';
	SIGNAL we_i_r1              : STD_LOGIC := '0';
	SIGNAL we_i_r2              : STD_LOGIC := '0';
	SIGNAL t_user_r1            : STD_LOGIC := '0';
	SIGNAL t_user_r2            : STD_LOGIC := '0';

	SIGNAL state_ctrl           : STD_LOGIC := '0';
	SIGNAL ctrl                 : STD_LOGIC := '0';
	SIGNAL empty_r              : STD_LOGIC := '0';

BEGIN
	t_out_ready_o <= NOT empty_r;
	we_i          <= NOT empty_r AND t_out_valid_i;
	his_wr_addr_o <= wr_addr_r2;
	his_rd_addr_o <= rd_addr;
	his_wr_data_o <= wr_data;
	his_wr_en     <= tmp_data;

	write_pr : PROCESS (clk_i)
	BEGIN
		IF (rising_edge(clk_i)) THEN
			IF (rst_i = '1') THEN
				State                <= idle_s;
				state_ctrl           <= '0';
				empty_r              <= '1';
				v_counter<=0;
				t_out_ready_o_r      <= '0';
				data_r_r             <= (OTHERS => '0');
				temp_write_read_addr <= 0;
				clear_enable         <= '0';
				his_ready_start_o    <= '0';
				his_ready_stop_o     <= '0';
			ELSE
				t_out_ready_o_r <= NOT empty_r;
				we_i_r1         <= we_i; --
				we_i_r2         <= we_i_r1;
				wr_addr_r1      <= wr_addr;
				wr_addr_r2      <= wr_addr_r1;
				t_user_r1       <= t_user_i;
				t_user_r2       <= t_user_r1;
				his_rd_data_r   <= his_rd_data_i;

				--we_r_r<=we_r;--
				--data_v:=rd_data;
				CASE State IS
						---------------------------------------------------------------------------
					WHEN idle_s =>
						tmp_data          <= '0';
						empty_r           <= '1';
						enable            <= '0';
						v_counter<=0;
						ctrl              <= '0';
						data_r            <= (OTHERS => '0');
						clear_enable      <= '0';
						his_ready_start_o <= '0';
						his_ready_stop_o  <= '0';
						--rd_addr       <=temp_write_read_addr;
						--wr_addr       <=temp_write_read_addr;
						rd_addr           <= to_integer(unsigned(t_out_data_i));
						wr_addr           <= to_integer(unsigned(t_out_data_i));
						IF (t_user_r2 = '1' OR state_ctrl = '1') THEN
							State             <= clear_s;
							his_ready_start_o <= '1';
							his_ready_stop_o  <= '0';
							state_ctrl        <= '0';
							empty_r           <= '1';
							enable            <= '1';
							clear_enable      <= '1';
							wr_data           <= (OTHERS => '0');
						ELSE
							State <= idle_s;
						END IF;
						--------------------------------------------------------------------------						
					WHEN clear_s =>
						his_ready_start_o <= '0';
						IF (bram_ready_i = '1') THEN
							his_ready_start_o <= '0';
							his_ready_stop_o  <= '0';
							clear_enable      <= '0';
							State             <= valid_s;
							data_r_r          <= (OTHERS => '0');
							data_r            <= (OTHERS => '0');
							tmp_data          <= '0';
							ctrl              <= '1';
							empty_r           <= '1';

						END IF;
						--rd_addr         <=temp_write_read_addr;
						--wr_addr         <=temp_write_read_addr;
						--rd_addr       <= to_integer(unsigned(t_out_data_i));
						--wr_addr       <= to_integer(unsigned(t_out_data_i));
						--------------------------------------------------------------------------						
					WHEN valid_s =>
						rd_addr <= to_integer(unsigned(t_out_data_i));
						wr_addr <= to_integer(unsigned(t_out_data_i));
						IF (rd_addr = wr_addr_r1) THEN
							tmp_data <= '0';
						ELSE
							tmp_data <= '1';
						END IF;

						wr_data <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(data_r_r)) + to_integer(unsigned(his_rd_data_i)), 72));
						------------------------------------------------------------------
						IF ((empty_r = '1' OR t_out_ready_o_r = '1')) THEN --and t_in_valid_i_r='1'
							IF (t_out_valid_i = '1') THEN                      -- 
								empty_r <= '0';                                    --0 
							ELSE
								empty_r <= '1';
							END IF;
						ELSE
							empty_r <= '0';
						END IF;
						-----------------------------------------------------------------

						IF rd_addr = wr_addr_r1 THEN
							IF (we_i_r1 = '1') THEN
								data_r_r <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(data_r_r) + 1), 72));
							END IF;
						ELSIF rd_addr /= wr_addr_r1 THEN
							IF we_i_r1 = '1' THEN
								data_r_r <= STD_LOGIC_VECTOR(to_unsigned(1, 72));--x"01"
							ELSE
								data_r_r <= (OTHERS => '0');
							END IF;
						END IF;
						IF (we_i = '1') AND (rd_addr /= wr_addr_r1) AND (rd_addr = wr_addr_r2 AND we_i_r1 = '1') THEN
							tmp_addrs <= wr_addr_r2;
							tmp_sis   <= '1';
							data_r_r  <= STD_LOGIC_VECTOR(to_unsigned(2, 72));--x"01"--x"02";
						ELSE
							tmp_sis <= '0';
						END IF;
						--------------------------------------------------------------------------------
						if t_last_i='1' then
							--empty_r              <= '1';
							v_counter<=v_counter+1;
						end if ;
						----------------------------------------------------------------
						IF (t_user_i = '1') THEN
							empty_r              <= '1';
							v_counter<=v_counter+1;
							temp_write_read_addr <= to_integer(unsigned(t_out_data_i));
						END IF;
						----------------------------------------------------------------
						IF (t_user_r1 = '1') THEN
							tmp_data <= '1';
							empty_r  <= '1';
						END IF;
						----------------------------------------------------------------
						IF (t_user_r2 = '1') THEN
							State            <= idle_s;
							empty_r          <= '1';
							enable           <= '0';
							state_ctrl       <= '1';
							tmp_data         <= '0';
							data_r_r         <= (OTHERS => '0');
							empty_r          <= '1';
							his_ready_stop_o <= '1';
						ELSE
							State <= valid_s;
						END IF;
						----------------------------------------------------------------
						--------------------------------------------------------------------------						
					WHEN OTHERS =>
						NULL;
				END CASE;

			END IF;
		END IF;
	END PROCESS;      -- write_pr

END ARCHITECTURE; -- arch
