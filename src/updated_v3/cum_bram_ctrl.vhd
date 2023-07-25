LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY cum_bram_ctrl IS
    GENERIC (
        RAM_WIDTH : NATURAL := 72;
        RAM_DEPTH : NATURAL := 255
    );
    PORT (
        clk_i : IN STD_LOGIC;
        rst_i : IN STD_LOGIC;
        ------------
        eq_patern_rd_addr_i : IN INTEGER RANGE 0 TO RAM_DEPTH;
        eq_patern_rd_data_o : OUT STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);

        eq_wr_addr_i : IN INTEGER RANGE 0 TO RAM_DEPTH;
        eq_wr_data_i : IN STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
        eq_wr_en_i : IN STD_LOGIC;
        eq_start_o : OUT STD_LOGIC;
        eq_start_i : IN STD_LOGIC;
        p_stop_i : IN STD_LOGIC;
        --in
        eq_read_finished_i : IN STD_LOGIC;
        paterm_read_finished_i : IN STD_LOGIC;
        ---------------------------------------------
        addr_0_a_o : OUT INTEGER RANGE 0 TO RAM_DEPTH;
        we_0_a_o : OUT STD_LOGIC;
        wr_data_0_a_o : OUT STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
        ---------------------------------------------------
        addr_0_b_o : OUT INTEGER RANGE 0 TO RAM_DEPTH;
        rd_data_0_b_i : IN STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
        ---------------------------------------------------
        addr_1_a_o : OUT INTEGER RANGE 0 TO RAM_DEPTH;
        we_1_a_o : OUT STD_LOGIC;
        wr_data_1_a_o : OUT STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
        -------------------------------------------------------
        addr_1_b_o : OUT INTEGER RANGE 0 TO RAM_DEPTH;
        rd_data_1_b_i : IN STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0)
        
    );
END ENTITY; -- 

ARCHITECTURE arch OF cum_bram_ctrl IS

    TYPE bram_clear_State IS (idle_s, write0ram_s, write1ram_s);
    SIGNAL bram_State : bram_clear_State;
    SIGNAL ram_0_1 : STD_LOGIC := '0';
    ------------------------------------------------------------------------------
    SIGNAL read_ram : STD_LOGIC := '0';
    SIGNAL ctrl_State : STD_LOGIC := '0';

    SIGNAL we_0_a : STD_LOGIC := '0';
    SIGNAL wr_addr_0_a : INTEGER RANGE 0 TO RAM_DEPTH;
    SIGNAL wr_data_0_a : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);

    SIGNAL we_1_a : STD_LOGIC := '0';
    SIGNAL wr_addr_1_a : INTEGER RANGE 0 TO RAM_DEPTH;
    SIGNAL wr_data_1_a : STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);

BEGIN
    addr_0_b_o <= eq_patern_rd_addr_i;
    addr_1_b_o <= eq_patern_rd_addr_i;
    addr_0_a_o <= wr_addr_0_a;
    addr_1_a_o <= wr_addr_1_a;
    we_1_a_o <= we_1_a;
    we_0_a_o <= we_0_a;
    wr_data_0_a_o <= wr_data_0_a;
    wr_data_1_a_o <= wr_data_1_a;

    eq_patern_rd_data_o <= rd_data_0_b_i WHEN read_ram = '0' ELSE
        rd_data_1_b_i WHEN read_ram = '1';
    ----------------------------------------------------------------------------
    bram_reset : PROCESS (clk_i) IS
    BEGIN
        IF (rising_edge(clk_i)) THEN
            IF (rst_i = '1') THEN
                bram_State <= idle_s;
                ram_0_1 <= '0';
                read_ram <= '0';
                we_1_a <= '0';
                we_0_a <= '0';
                ctrl_State<='0';
            ELSE
                IF p_stop_i = '1' THEN
                    read_ram <= NOT read_ram;
                END IF;
                CASE(bram_State) IS
                    --------------------------------------------------------------------------
                    --------------------------------------------------------------------------------				
                    WHEN idle_s =>
                    we_1_a <= '0';
                    we_0_a <= '0';
                    if eq_start_i='1' then
                        ctrl_State<='1';
                    end if;
                    IF (ram_0_1 = '0' AND eq_start_i = '1' and ctrl_State='1') THEN
                        bram_State <= write0ram_s;
                        eq_start_o <= '1';
                    ELSIF (ram_0_1 = '1' AND eq_start_i = '1' and ctrl_State='1') THEN
                        bram_State <= write1ram_s;
                        eq_start_o <= '1';
                    END IF;
                    --------------------------------------------------------------------------
                    --------------------------------------------------------------------------------
                    WHEN write0ram_s =>
                    we_0_a <= eq_wr_en_i;
                    wr_addr_0_a <= eq_wr_addr_i;
                    wr_data_0_a <= eq_wr_data_i;
                    we_1_a <= '0';
                    --------------------------------------------------------------------------

                    --------------------------------------------------------------------------						
                    --------------------------------------------------------------------------
                    IF (eq_read_finished_i = '1') THEN
                        ram_0_1 <= '1';
                        bram_State <= idle_s;
                        we_1_a <= '0';
                        we_0_a <= '0';
                    END IF;
                    ---------------------------------------------------------------------------------
                    ---------------------------------------------------------------------------------
                    WHEN write1ram_s =>
                    we_1_a <= eq_wr_en_i;
                    wr_addr_1_a <= eq_wr_addr_i;
                    wr_data_1_a <= eq_wr_data_i;
                    we_0_a <= '0';
                    -----------------------------------------------------------------

                    IF (eq_read_finished_i = '1') THEN
                        ram_0_1 <= '0';
                        bram_State <= idle_s;
                        we_1_a <= '0';
                        we_0_a <= '0';
                    END IF;

                    --------------------------------------------------------------------------------
                    --------------------------------------------------------------------------------
                    WHEN OTHERS =>
                    NULL;
                END CASE;
            END IF;

        END IF;

    END PROCESS; -- bram_reset
END ARCHITECTURE; -- arch