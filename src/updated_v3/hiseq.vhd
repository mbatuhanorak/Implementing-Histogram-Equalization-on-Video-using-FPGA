LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hiseq IS
    GENERIC (
        v_sync : INTEGER := 240;
        h_sync : INTEGER := 160;
        RAM_WIDTH : NATURAL := 72;
        RAM_DEPTH : NATURAL := 255
    );
    PORT (
        clk_i : IN STD_LOGIC;
        rst_i : IN STD_LOGIC;
        -----------------------------------------
        eq_rd_addr_o : OUT INTEGER RANGE 0 TO RAM_DEPTH;
        eq_rd_data_i : IN STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
       -- p_stop_i : IN STD_LOGIC;

        eq_wr_addr_o : OUT INTEGER RANGE 0 TO RAM_DEPTH;
        eq_wr_data_o : OUT STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
        eq_wr_en : OUT STD_LOGIC;
        eq_start_i : IN STD_LOGIC;
        eq_read_finished_o : OUT STD_LOGIC;
        eq_ready_o : OUT STD_LOGIC
    );
END hiseq;

ARCHITECTURE rtl OF hiseq IS
    TYPE t_rec_state IS (idle_s, rec_s);
    SIGNAL r_state : t_rec_state;
    SIGNAL count : INTEGER RANGE 0 TO RAM_DEPTH := 0;
    SIGNAL eq_rd_data_r : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
    SIGNAL ctrl_sa : STD_LOGIC;
    SIGNAL ctrl_pxl : STD_LOGIC;
    SIGNAL eq_wr_addr_r : INTEGER RANGE 0 TO RAM_DEPTH;
    SIGNAL ctrl : INTEGER RANGE 0 TO 3;
    SIGNAL eq_wr_addr_r_r : INTEGER RANGE 0 TO RAM_DEPTH;
    SIGNAL eq_wr_addr_r_r_r : INTEGER RANGE 0 TO RAM_DEPTH;
    SIGNAL eq_wr_en_r : STD_LOGIC;
    SIGNAL eq_wr_en_r_r : STD_LOGIC;
    SIGNAL eq_wr_en_r_r_r : STD_LOGIC;
    SIGNAL eq_read_finished_r : STD_LOGIC;
BEGIN
    eq_rd_addr_o <= count;
    eq_wr_addr_o <= eq_wr_addr_r_r;
    eq_wr_en <= eq_wr_en_r_r;
    eq_read_finished_o <= eq_read_finished_r;

    rec_p : PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            IF rst_i = '1' THEN
                r_state <= idle_s;
                count <= 0;
                eq_ready_o <= '0';
                eq_wr_en_r <= '0';
                eq_read_finished_r <= '0';
                ctrl_pxl <= '1';
            ELSE
                eq_wr_addr_r <= count;
                eq_wr_addr_r_r <= eq_wr_addr_r;
                eq_wr_addr_r_r_r <= eq_wr_addr_r_r;
                eq_wr_en_r_r <= eq_wr_en_r;
                eq_wr_en_r_r_r <= eq_wr_en_r_r;
                CASE(r_state) IS

                    WHEN idle_s =>
                    eq_wr_en_r <= '0';
                    eq_read_finished_r <= '0';
                    ctrl <= 0;
                    ctrl_sa <= '0';
                    eq_rd_data_r <= (OTHERS => '0');
                    eq_wr_data_o <= (OTHERS => '0');
                    IF eq_start_i = '1' THEN
                        r_state <= rec_s;
                        count <= 0;
                        eq_wr_en_r <= '0';
                        ctrl_sa <= '1';
                        eq_ready_o <= '1';
                        eq_rd_data_r <= (OTHERS => '0');
                    END IF;
                    WHEN rec_s =>
                    ctrl_pxl <= '0';
                    eq_ready_o <= '1';
                    IF ctrl_sa = '1' THEN
                        eq_rd_data_r <= (OTHERS => '0');
                        ctrl_sa <= '0';
                    ELSE
                        eq_rd_data_r <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(eq_rd_data_r)) + to_integer(unsigned(eq_rd_data_i)), 72));
                    END IF;
                    eq_wr_data_o <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(eq_rd_data_r)) + to_integer(unsigned(eq_rd_data_i)), 72));
                    -- eq_rd_data_r <= eq_rd_data_i;
                    IF count = RAM_DEPTH THEN
                        --eq_wr_en_r <= '0';

                        IF ctrl = 3 THEN
                            eq_ready_o <= '0';
                            ctrl <= 0;
                            eq_read_finished_r <= '1';
                            r_state <= idle_s;
                        ELSIF ctrl = 2 THEN

                            ctrl <= ctrl + 1;
                        ELSIF ctrl = 1 THEN
                            eq_wr_en_r <= '0';
                            ctrl <= ctrl + 1;
                        ELSE
                            ctrl <= ctrl + 1;
                            eq_wr_en_r <= '1';
                        END IF;

                    ELSE
                        eq_wr_en_r <= '1';

                        count <= count + 1;
                    END IF;
                    WHEN OTHERS =>
                    NULL;
                END CASE;

            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;