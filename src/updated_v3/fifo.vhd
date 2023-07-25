LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fifo IS
    GENERIC (
        RAM_WIDTH : NATURAL := 72;
        RAM_DEPTH : NATURAL := 255
    );
    PORT (
        clk_i      : IN STD_LOGIC;
        rst_i      : IN STD_LOGIC;
        --------------------------------------------------------------------------
        --in
        t_data_i   : IN STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
        t_valid_i  : IN STD_LOGIC;
        t_ready_i  : IN STD_LOGIC;
        t_user_o   : IN STD_LOGIC;
        -- Read port
        fifo_rd_en     : IN STD_LOGIC;
        fifo_rd_valid   : OUT STD_LOGIC;
        fifo_rd_data    : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);

        -- Flags
        empty      : OUT STD_LOGIC;
        empty_next : OUT STD_LOGIC;
        full       : OUT STD_LOGIC;
        full_next  : OUT STD_LOGIC;
        -- The number of elements in the FIFO
        fill_count : OUT INTEGER RANGE RAM_DEPTH - 1 DOWNTO 0
    );
END fifo;

ARCHITECTURE rtl OF fifo IS

    TYPE ram_type IS ARRAY (0 TO RAM_DEPTH - 1) OF STD_LOGIC_VECTOR(t_data_i'RANGE);
    SIGNAL ram : ram_type;

    SUBTYPE index_type IS INTEGER RANGE ram_type'RANGE;
    SIGNAL head                 : index_type;
    SIGNAL tail                 : index_type;

    SIGNAL empty_i              : STD_LOGIC;
    SIGNAL full_i               : STD_LOGIC;
    SIGNAL wr_en                : STD_LOGIC;

    SIGNAL fill_count_i         : INTEGER RANGE RAM_DEPTH - 1 DOWNTO 0;

    -- Increment and wrap
    PROCEDURE incr(SIGNAL index : INOUT index_type) IS
    BEGIN
        IF index = index_type'high THEN
            index <= index_type'low;
        ELSE
            index <= index + 1;
        END IF;
    END PROCEDURE;

BEGIN
    wr_en      <= t_valid_i AND t_ready_i;
    -- Copy internal signals to output
    empty      <= empty_i;
    full       <= full_i;
    fill_count <= fill_count_i;

    -- Set the flags
    empty_i    <= '1' WHEN fill_count_i = 0 ELSE
        '0';
    empty_next <= '1' WHEN fill_count_i <= 1 ELSE
        '0';
    full_i <= '1' WHEN fill_count_i >= RAM_DEPTH - 1 ELSE
        '0';
    full_next <= '1' WHEN fill_count_i >= RAM_DEPTH - 2 ELSE
        '0';

    -- Update the head pointer in write
    PROC_HEAD : PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            IF rst_i = '1' THEN
                head <= 0;
            ELSE

                IF wr_en = '1' AND full_i = '0' THEN
                    incr(head);
                END IF;

            END IF;
        END IF;
    END PROCESS;

    -- Update the tail pointer on read and pulse valid
    PROC_TAIL : PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            IF rst_i = '1' THEN
                tail     <= 0;
                fifo_rd_valid <= '0';
            ELSE
                fifo_rd_valid <= '0';

                IF fifo_rd_en= '1' AND empty_i = '0' THEN
                    incr(tail);
                    fifo_rd_valid <= '1';
                END IF;

            END IF;
        END IF;
    END PROCESS;

    -- Write to and read from the RAM
    PROC_RAM : PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            ram(head) <= t_data_i;
            fifo_rd_data   <= ram(tail);
        END IF;
    END PROCESS;

    -- Update the fill count
    PROC_COUNT : PROCESS (head, tail)
    BEGIN
        IF head < tail THEN
            fill_count_i <= head - tail + RAM_DEPTH;
        ELSE
            fill_count_i <= head - tail;
        END IF;
    END PROCESS;

END ARCHITECTURE;
