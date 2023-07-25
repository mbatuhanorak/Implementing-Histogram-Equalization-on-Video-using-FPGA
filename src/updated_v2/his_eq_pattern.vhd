LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY his_eq_pattern IS
  GENERIC (
    v_sync : INTEGER ;
		h_sync : INTEGER ;
    RAM_WIDTH : NATURAL := 72;
    RAM_DEPTH : NATURAL := 255
  );
  PORT (
    clk_i              : IN STD_LOGIC;
    rst_i              : IN STD_LOGIC;
    t_user_o           : IN STD_LOGIC;
    fifo_rd_en_o       : OUT STD_LOGIC;
    fifo_rd_valid_i    : IN STD_LOGIC;
    fifo_rd_data_i     : IN STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
    h_bram_rd_addr_o   : OUT INTEGER RANGE 0 TO RAM_DEPTH;
    h_bram_rd_data_i   : IN STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
    pixel_data_o       : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
    pixel_valid_o      : OUT STD_LOGIC;
    eq_read_finished_i : IN STD_LOGIC;
    empty              : IN STD_LOGIC;
    full               : IN STD_LOGIC
  );
END his_eq_pattern;

ARCHITECTURE arch OF his_eq_pattern IS

  TYPE t_state IS (idle_s, pixel_cal_s, wait_s);
  constant mulc: natural :=255/(24 * 16);
  SIGNAL p_state          : t_state;
  SIGNAL fifo_rd_en_r     : STD_LOGIC;
  SIGNAL fifo_rd_valid_r  : STD_LOGIC;
  SIGNAL fifo_rd_data_r   : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL h_bram_rd_addr_r : INTEGER RANGE 0 TO RAM_DEPTH;
  SIGNAL count            : INTEGER RANGE 0 TO 2;
  SIGNAL counter          : INTEGER;

  SIGNAL h_bram_rd_data_r : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL rd_ctrl_p        : STD_LOGIC;
  SIGNAL rd_ctrl_p_r      : STD_LOGIC;
  SIGNAL rd_ctrl_p_r_r    : STD_LOGIC;
  SIGNAL start            : STD_LOGIC;
  SIGNAL pixel_data_r     : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
BEGIN
  fifo_rd_en_o     <= fifo_rd_en_r;
  fifo_rd_valid_r  <= fifo_rd_valid_i;
  fifo_rd_data_r   <= fifo_rd_data_i;
  pixel_data_o     <= pixel_data_r;
  h_bram_rd_addr_o <= h_bram_rd_addr_r;
  h_bram_rd_data_r <= h_bram_rd_data_i;
  PROCESS (clk_i)
  BEGIN
    IF rising_edge(clk_i) THEN
      IF rst_i = '1' THEN
        fifo_rd_en_r <= '0';
        rd_ctrl_p    <= '0';
        start        <= '0';
        count        <= 0;
        counter      <= 0;
      ELSE
        rd_ctrl_p_r   <= rd_ctrl_p;
        rd_ctrl_p_r_r <= rd_ctrl_p_r;
        CASE(p_state) IS

          WHEN idle_s =>
          fifo_rd_en_r     <= '0';
          h_bram_rd_addr_r <= 0;
          count            <= 0;
          rd_ctrl_p        <= '0';
          IF (eq_read_finished_i = '1') THEN
            start <= '1';
          END IF;
          IF eq_read_finished_i = '1' AND empty = '0' AND start = '1'THEN
            p_state <= pixel_cal_s;
          END IF;
          WHEN pixel_cal_s =>
          fifo_rd_en_r     <= '1';
          rd_ctrl_p        <= '0';
          h_bram_rd_addr_r <= to_integer(unsigned(fifo_rd_data_r));
        
          IF fifo_rd_valid_r = '1' THEN
          
            rd_ctrl_p <= '1';
            counter   <= counter + 1;
          END IF;
          IF counter = v_sync * h_sync  - 2 THEN
            fifo_rd_en_r <= '0';
          END IF;
          IF counter = v_sync * h_sync - 1 THEN
            fifo_rd_en_r <= '0';
            rd_ctrl_p    <= '1';
            p_state      <= wait_s;
            counter      <= 0;
          END IF;
          WHEN wait_s =>
          IF counter = 1 THEN
            rd_ctrl_p <= '0';
          END IF;
          counter          <= counter + 1;
          h_bram_rd_addr_r <= to_integer(unsigned(fifo_rd_data_r));
          IF rd_ctrl_p_r = '0' THEN
            p_state <= idle_s;
            counter <= 0;
          END IF;
          WHEN OTHERS =>
          NULL;

        END CASE;

      END IF;
    END IF;
  END PROCESS;
  PROCESS (clk_i)
  BEGIN
    IF rising_edge(clk_i) THEN
      pixel_data_r  <= (OTHERS => '0');
      pixel_valid_o <= '0';
      IF rd_ctrl_p_r = '1'THEN
        pixel_data_r <= h_bram_rd_data_r(RAM_WIDTH - 9 DOWNTO 0) & "00000000";--* RAM_DEPTH)/(24 * 16--STD_LOGIC_VECTOR(to_unsigned((((to_integer(unsigned(h_bram_rd_data_r))) )), 72))
      END IF;
      IF rd_ctrl_p_r = '1' THEN
        pixel_valid_o <= '1';
      END IF;
      IF rd_ctrl_p = '0' THEN
        pixel_valid_o <= '0';
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE;
