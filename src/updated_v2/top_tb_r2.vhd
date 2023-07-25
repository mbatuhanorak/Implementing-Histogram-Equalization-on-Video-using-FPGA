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
	RAM_DEPTH_fifo : NATURAL := 240*160*3;
	RAM_DEPTH : NATURAL := 255;
		ROM_WIDTH : INTEGER := 72;
		ROM_DEPTH : INTEGER := 240*160
);

END ENTITY top_tb_r2;

-----------------------------------------------------------

ARCHITECTURE testbench OF top_tb_r2 IS

	-- Testbench DUT generics
	-- Testbench DUT ports
	SIGNAL clk_i          : STD_LOGIC;
	SIGNAL rst_i          : STD_LOGIC;
	---
	SIGNAL t_in_data_i_w  : STD_LOGIC_VECTOR(71 DOWNTO 0);
	SIGNAL t_in_valid_i_w : STD_LOGIC;
	SIGNAL t_in_ready_o_W : STD_LOGIC;
	SIGNAL look_1         : STD_LOGIC;
	-- Other constants
	CONSTANT C_CLK_PERIOD : TIME := 1 ns; -- NS
	signal clk  : STD_LOGIC;
	signal addr : INTEGER RANGE 0 TO ROM_DEPTH - 1;
	signal q    : STD_LOGIC_VECTOR((ROM_WIDTH - 1) DOWNTO 0);
	
	SIGNAL ram_datao      : STD_LOGIC_VECTOR(71 DOWNTO 0);
	SIGNAL ram_wr_addr_o  : INTEGER RANGE 0 TO 255;
	SIGNAL ram_data_en    : STD_LOGIC;
	SIGNAL pixel_data_o   : STD_LOGIC_VECTOR(71 DOWNTO 0);
	SIGNAL pixel_data_r   : STD_LOGIC_VECTOR(71 DOWNTO 0);
	SIGNAL pixel_valid_o  : STD_LOGIC;
	FILE file_wrt         : text;
	FILE file_rd          : text;
  signal m_axis_dout_tdata : STD_LOGIC_VECTOR(71 DOWNTO 0) ;
  signal m_axis_dout_tvalid : STD_LOGIC;
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
		FILE w_text_files_1   : text OPEN write_mode IS "C:\Users\mbatu\Desktop\work_artron\vivado\source\histogram\updated_v2\his.txt";
		VARIABLE w_text_linea : line;
		variable text_string : string(1 to 1):=".";
	BEGIN
		file_open(file_wrt, "C:\Users\mbatu\Desktop\work_artron\vivado\source\histogram\updated_v2\his.txt", write_mode);
		WAIT FOR C_CLK_PERIOD;
		WAIT UNTIL m_axis_dout_tvalid = '1';
		identifier : WHILE m_axis_dout_tvalid = '1' LOOP
			write(w_text_linea, to_integer(unsigned(m_axis_dout_tdata(71 downto 2) ))); --write(w_text_line,ram_wr_addr_o,left,5);
			--write(w_text_linea, text_string);
			--write(w_text_linea,to_integer(unsigned(m_axis_dout_tdata(8 downto 0) )));--"10_0000_0000"
			writeline(file_wrt, w_text_linea);
			WAIT FOR C_CLK_PERIOD;

		END LOOP; -- identifier
		file_close(file_wrt);
		WAIT UNTIL rst_i = '1';

	END PROCESS;

	-----------------------------------------------------------
	-- Testbench Stimulus
	-----------------------------------------------------------
	random : PROCESS
		VARIABLE s, z          : STD_LOGIC_VECTOR(0 DOWNTO 0);
		VARIABLE seed1, seed2  : POSITIVE;     -- seed values for random generator
		VARIABLE rand          : real;         -- random real-number value in range 0 to 1.0  
		VARIABLE range_of_rand : real := 10.0; -- the range of random values created will be 0 to +1000.

	BEGIN
		uniform(seed1, seed2, rand); -- generate random number
		s := STD_LOGIC_VECTOR(to_unsigned(INTEGER(rand * range_of_rand), 1));
		t_in_valid_i_w <= s(0);
		WAIT FOR C_CLK_PERIOD;
	END PROCESS; -- random
	---------------------------------------------------------------------------------
	--Transmitter
	--------------------------------------------------------------------------------
	look_1 <= (t_in_ready_o_W AND t_in_valid_i_w);
	PROC_TRANS : PROCESS
		--FILE r_text_file_1     : text OPEN read_mode IS "img1.txt";
		FILE r_text_file_2     : text OPEN read_mode IS "matlab_files/output_txt/img2.txt";
		FILE r_text_file_3     : text OPEN read_mode IS "matlab_files/output_txt/img3.txt";
		VARIABLE r_text_line_1 : line;
		VARIABLE r_text_line_2 : line;
		VARIABLE r_text_line_3 : line;
		VARIABLE r_number_v_1  : INTEGER;
		VARIABLE r_number_v_2  : INTEGER;
		VARIABLE r_number_v_3  : INTEGER;
		VARIABLE temp          : STD_LOGIC_VECTOR(71 DOWNTO 0);
		VARIABLE tick          : STD_LOGIC := '0';
	BEGIN
		rst_i <= '1';
		file_open(file_rd, "C:\Users\mbatu\Desktop\work_artron\vivado\source\histogram\updated_v2\img1.txt", read_mode);
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
		FILE w_text_file     : text OPEN write_mode IS "C:\Users\mbatu\Desktop\work_artron\vivado\source\histogram\updated_v2\w_im.txt";
		FILE w_text_file1    : text OPEN write_mode IS "matlab_files/output_txt/w_im1.txt";
		VARIABLE w_text_line : line;

	BEGIN
		WAIT FOR 2 ns;
		WHILE rst_i = '0' LOOP
			IF (ram_data_en = '1') THEN
				write(w_text_line, ram_wr_addr_o); --write(w_text_line,ram_wr_addr_o,left,5);
				write(w_text_line, to_integer(unsigned(ram_datao)));
				writeline(w_text_file, w_text_line);
			END IF;
			WAIT FOR C_CLK_PERIOD;
		END LOOP; -- identifier
	END PROCESS;
	-- REC_PROCESS
	for_rom : process
	begin
		FOR i IN 0 TO ROM_DEPTH - 1 LOOP
		addr<=i;
		WAIT FOR C_CLK_PERIOD;
	END LOOP;
		
	end process;
	single_port_rom : entity work.single_port_rom
	generic map (
	  ROM_WIDTH => ROM_WIDTH,
	  ROM_DEPTH => ROM_DEPTH
	)
	port map (
	  clk  => clk,
	  addr => addr,
	  q    => q
	);
	

	-----------------------------------------------------------
	-- Entity Under Test
	-----------------------------------------------------------
	top_1 : ENTITY work.top_r2
	generic map (
		v_sync         => v_sync,
		h_sync         => h_sync,
		RAM_WIDTH      => RAM_WIDTH,
		ADDR_WIDTH     => ADDR_WIDTH,
		RAM_DEPTH_fifo => RAM_DEPTH_fifo,
		RAM_DEPTH      => RAM_DEPTH
	  )
		PORT MAP(
			clk_i         => clk_i,
			rst_i         => rst_i,
			t_in_data_i   => t_in_data_i_w,
			ram_datao     => ram_datao,
			ram_wr_addr_o => ram_wr_addr_o,
			ram_data_en   => ram_data_en,
			t_in_valid_i  => t_in_valid_i_w,
			t_in_ready_o  => t_in_ready_o_W,
			pixel_data_o  => pixel_data_o,
			pixel_valid_o => pixel_valid_o,
			m_axis_dout_tvalid =>m_axis_dout_tvalid,
			m_axis_dout_tdata  =>m_axis_dout_tdata 
		);
END ARCHITECTURE testbench;
