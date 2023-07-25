LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE std.env.stop;
USE ieee.math_real.ALL;

-----------------------------------------------------------

ENTITY top_tb_r2 IS
	GENERIC (
		v_sync : INTEGER := 240;
		h_sync : INTEGER := 160;
		RAM_WIDTH : NATURAL := 72;
		ADDR_WIDTH : INTEGER := 8;
		RAM_DEPTH_fifo : NATURAL := 240 * 160 * 3;
		RAM_DEPTH : NATURAL := 255;
		ROM_WIDTH : INTEGER := 72;
		ROM_DEPTH : INTEGER := 240 * 160
	);

END ENTITY top_tb_r2;

-----------------------------------------------------------

ARCHITECTURE testbench OF top_tb_r2 IS
	COMPONENT dist_mem_gen_0
		PORT (
			a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;
	-- Testbench DUT generics
	-- Testbench DUT ports
	SIGNAL clk_i : STD_LOGIC;
	SIGNAL rst_i : STD_LOGIC;
	---
	SIGNAL pixel_q : STD_LOGIC_VECTOR((7) DOWNTO 0);
	SIGNAL pixel_valid_out : STD_LOGIC;
	--in
	SIGNAL t_in_data_i_w : STD_LOGIC_VECTOR(71 DOWNTO 0);
	SIGNAL t_in_valid_i_w : STD_LOGIC := '1';
	SIGNAL t_in_ready_o_W : STD_LOGIC;
	SIGNAL look_1 : STD_LOGIC;
	-- Other constants
	CONSTANT C_CLK_PERIOD : TIME := 1 ns; -- NS
	signal test_eq_wr_addr_o :  INTEGER RANGE 0 TO RAM_DEPTH;
	signal test_eq_wr_data_o :  STD_LOGIC_VECTOR((RAM_WIDTH - 1) DOWNTO 0);
	signal test_eq_wr_en :  STD_LOGIC;
	SIGNAL addr : STD_LOGIC_VECTOR((15) DOWNTO 0);

	SIGNAL ram_wr_addr_o : INTEGER RANGE 0 TO 255;
	FILE file_wrt1 : text;
	FILE file_wrt2 : text;
	FILE file_wrt3 : text;
	FILE file_rd : text;
BEGIN

	-----------------------------------------------------------
	-- Clocks and Reset
	-----------------------------------------------------------
	CLK_GEN : PROCESS
	BEGIN
		clk_i <= '1';
		WAIT FOR C_CLK_PERIOD/2;
		clk_i <= '0';
		WAIT FOR C_CLK_PERIOD/2;
	END PROCESS CLK_GEN;
	writehis_PROCESS : PROCESS
		FILE w_text_files_1 : text OPEN write_mode IS "C:\Users\mbatu\Desktop\vivadoprj\histogram\updated_v2\his1.txt";
		FILE w_text_files_2 : text OPEN write_mode IS "C:\Users\mbatu\Desktop\vivadoprj\histogram\updated_v2\his2.txt";
		FILE w_text_files_3 : text OPEN write_mode IS "C:\Users\mbatu\Desktop\vivadoprj\histogram\updated_v2\his3.txt";
		VARIABLE w_text_line1 : line;
		VARIABLE w_text_line2 : line;
		VARIABLE w_text_line3 : line;
		VARIABLE text_string : STRING(1 TO 1) := ".";
	BEGIN
		file_open(file_wrt1, "C:\Users\mbatu\Desktop\vivadoprj\histogram\updated_v2\his1.txt", write_mode);
		file_open(file_wrt2, "C:\Users\mbatu\Desktop\vivadoprj\histogram\updated_v2\his2.txt", write_mode);
		file_open(file_wrt3, "C:\Users\mbatu\Desktop\vivadoprj\histogram\updated_v2\his3.txt", write_mode);

		WAIT FOR C_CLK_PERIOD;
		WAIT UNTIL pixel_valid_out = '1';
		WAIT FOR C_CLK_PERIOD;
		first_image : WHILE pixel_valid_out = '1' LOOP
			write(w_text_line1, to_integer(unsigned(pixel_q))); --write(w_text_line,ram_wr_addr_o,left,5);
			--write(w_text_linea, text_string);
			--write(w_text_linea,to_integer(unsigned(m_axis_dout_tdata(8 downto 0) )));--"10_0000_0000"
			writeline(file_wrt1, w_text_line1);
			WAIT FOR C_CLK_PERIOD;

		END LOOP; -- identifier
		file_close(file_wrt1);
		WAIT UNTIL pixel_valid_out = '1';
		WAIT FOR C_CLK_PERIOD;
		second_image : WHILE pixel_valid_out = '1' LOOP
			write(w_text_line2, to_integer(unsigned(pixel_q))); --write(w_text_line,ram_wr_addr_o,left,5);
			--write(w_text_linea, text_string);
			--write(w_text_linea,to_integer(unsigned(m_axis_dout_tdata(8 downto 0) )));--"10_0000_0000"
			writeline(file_wrt2, w_text_line2);
			WAIT FOR C_CLK_PERIOD;

		END LOOP; -- identifier
		file_close(file_wrt2);
		WAIT UNTIL pixel_valid_out = '1';
		WAIT FOR C_CLK_PERIOD;
		third_image : WHILE pixel_valid_out = '1' LOOP
			write(w_text_line3, to_integer(unsigned(pixel_q))); --write(w_text_line,ram_wr_addr_o,left,5);
			--write(w_text_linea, text_string);
			--write(w_text_linea,to_integer(unsigned(m_axis_dout_tdata(8 downto 0) )));--"10_0000_0000"
			writeline(file_wrt3, w_text_line3);
			WAIT FOR C_CLK_PERIOD;

		END LOOP; -- identifier
		file_close(file_wrt3);

		WAIT UNTIL rst_i = '1';

	END PROCESS;

	-----------------------------------------------------------
	-- Testbench Stimulus
	-----------------------------------------------------------
	random : PROCESS
		VARIABLE s, z : STD_LOGIC_VECTOR(0 DOWNTO 0);
		VARIABLE seed1, seed2 : POSITIVE; -- seed values for random generator
		VARIABLE rand : real; -- random real-number value in range 0 to 1.0  
		VARIABLE range_of_rand : real := 10.0; -- the range of random values created will be 0 to +1000.

	BEGIN
		uniform(seed1, seed2, rand); -- generate random number
		s := STD_LOGIC_VECTOR(to_unsigned(INTEGER(rand * range_of_rand), 1));
		--t_in_valid_i_w <= s(0);
		WAIT FOR C_CLK_PERIOD;
	END PROCESS; -- random
	---------------------------------------------------------------------------------
	--Transmitter
	--------------------------------------------------------------------------------
	look_1 <= (t_in_ready_o_W AND t_in_valid_i_w);
	PROC_TRANS : PROCESS
		--FILE r_text_file_1     : text OPEN read_mode IS "img1.txt";
		FILE r_text_file_2 : text OPEN read_mode IS "matlab_files/output_txt/img2.txt";
		FILE r_text_file_3 : text OPEN read_mode IS "matlab_files/output_txt/img3.txt";
		VARIABLE r_text_line_1 : line;
		VARIABLE r_text_line_2 : line;
		VARIABLE r_number_v_1 : INTEGER;
		VARIABLE r_number_v_2 : INTEGER;
	BEGIN
		rst_i <= '1';
		file_open(file_rd, "C:\Users\mbatu\Desktop\vivadoprj\histogram\updated_v2\reduced_video1.txt", read_mode);
		WAIT FOR 2 ns;
		rst_i <= '0';

		readline(file_rd, r_text_line_1);
		read(r_text_line_1, r_number_v_1);
		t_in_data_i_w <= STD_LOGIC_VECTOR(to_unsigned(r_number_v_1, 72));
		WAIT FOR C_CLK_PERIOD;
		WHILE rst_i = '0' LOOP

			WHILE look_1 = '1' LOOP
				readline(file_rd, r_text_line_1);
				read(r_text_line_1, r_number_v_1);
				t_in_data_i_w <= STD_LOGIC_VECTOR(to_unsigned(r_number_v_1, 72));
				WAIT FOR C_CLK_PERIOD;
			END LOOP; -- identifier
			WAIT FOR C_CLK_PERIOD;
		END LOOP;
		WAIT FOR C_CLK_PERIOD;
		WAIT FOR 10 ns;
		stop;
		WHILE NOT endfile(r_text_file_2) LOOP
			WAIT FOR C_CLK_PERIOD;
			WHILE look_1 = '1' LOOP
				readline(r_text_file_2, r_text_line_2);
				read(r_text_line_2, r_number_v_2);
				t_in_data_i_w <= STD_LOGIC_VECTOR(to_unsigned(r_number_v_2, 72));
				WAIT FOR C_CLK_PERIOD;
			END LOOP; -- identifier

		END LOOP;
		WAIT FOR C_CLK_PERIOD;

	END PROCESS;
	 REC_PROCESS : PROCESS
	 	FILE w_text_file : text OPEN write_mode IS "C:\Users\mbatu\Desktop\vivadoprj\histogram\updated_v2\w_im.txt";
	 	VARIABLE w_text_line : line;

	 BEGIN
	 	WAIT FOR 2 ns;
	 	WHILE rst_i = '0' LOOP
	 		IF (test_eq_wr_en = '1') THEN
	 		---write(w_text_line, test_eq_wr_addr_o); --write(w_text_line,ram_wr_addr_o,left,5);
	 			write(w_text_line, to_integer(unsigned(test_eq_wr_data_o)));
	 			writeline(w_text_file, w_text_line);
	 		END IF;
	 		WAIT FOR C_CLK_PERIOD;
	 	END LOOP; -- identifier
	 END PROCESS;
	 VIDEO_REC_PROCESS : PROCESS
	 	FILE w_text_file : text OPEN write_mode IS "C:\Users\mbatu\Desktop\vivadoprj\histogram\updated_v2\vide_rec.txt";
	 	VARIABLE w_text_line : line;

	 BEGIN
	 	WAIT FOR 2 ns;
	 	WHILE rst_i = '0' LOOP
	 		IF (pixel_valid_out = '1') THEN
	 		---write(w_text_line, test_eq_wr_addr_o); --write(w_text_line,ram_wr_addr_o,left,5);
	 			write(w_text_line, to_integer(unsigned(pixel_q)));
	 			writeline(w_text_file, w_text_line);
	 		END IF;
	 		WAIT FOR C_CLK_PERIOD;
	 	END LOOP; -- identifier
	 END PROCESS;


	-----------------------------------------------------------
	-- Entity Under Test
	-----------------------------------------------------------
	top_r2 : ENTITY work.top_r2
		GENERIC MAP(
			v_sync => v_sync,
			h_sync => h_sync,
			RAM_WIDTH => RAM_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH,
			RAM_DEPTH_fifo => RAM_DEPTH_fifo,
			RAM_DEPTH => RAM_DEPTH
		)
		PORT MAP(
			clk_i => clk_i,
			rst_i => rst_i,
			pixel_q => pixel_q,
			pixel_valid_out => pixel_valid_out,
			t_in_data_i => t_in_data_i_w,
			t_in_valid_i => t_in_valid_i_w,
			t_in_ready_o => t_in_ready_o_W,
			test_eq_wr_addr_o=>test_eq_wr_addr_o,
			test_eq_wr_data_o=>test_eq_wr_data_o,
			test_eq_wr_en=>test_eq_wr_en
		);
END ARCHITECTURE testbench;