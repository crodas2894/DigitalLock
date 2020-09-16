library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity DigitalLock is
	port (
		button : in std_logic_vector(4 downto 0);
		clk    : in std_logic;
		LED    : out std_logic_vector(7 downto 0));
end DigitalLock;

architecture Behavioral of DigitalLock is

	--Debouncer
	component debouncer is
		port (
			data     : in std_logic;--input signal to be debounced 
			clk      : in std_logic;--input clock 
			out_data : out std_logic); --debounced signal
	end component;
	--States
	type State_type is (idle, t1, t2, t3, unlock, w1, w2, w3, alarm, recover, rst_buffer1, rst_buffer2);
	signal cur_state, next_state : State_type := idle;
	--LED signals
	signal flashing_led : std_logic_vector(7 downto 0) := "00000001";
	signal flashing_count : integer := 50000000;
	signal ring_led : std_logic_vector(7 downto 0) := "00000000"; -- alarm state
	signal ring_count : integer := 50000000;
	signal recover_led : std_logic_vector(7 downto 0) := "00001111";
	signal recover_count : integer := 50000000;
	--Clock signals
	signal clksig : std_logic;
	--Debouncer signals
	signal db_north, db_south, db_center, db_east, db_west : std_logic := '0';

begin
	North : debouncer port map(
		data     => button(4),
		clk      => clk,
		out_data => db_north);
	South : debouncer port map(
		data     => button(1),
		clk      => clk,
		out_data => db_south);
	East : debouncer port map(
		data     => button(3),
		clk      => clk,
		out_data => db_east);
	West : debouncer port map(
		data     => button(2),
		clk      => clk,
		out_data => db_west);
	Center : debouncer port map(
		data     => button(0),
		clk      => clk,
		out_data => db_center);

	--fsm code
	process (clk)
	begin
		if (rising_edge(clk)) then
			cur_state <= next_state;
		end if;
	end process;

	process (clk)
	begin
		if (rising_edge(clk)) then
			case cur_state is
				when idle =>
					if (db_south = '1') then
						next_state <= t1;
					elsif (db_north = '1' or db_east = '1' or db_west = '1' or db_center = '1') then
						next_state <= w1;
					end if;
					if (flashing_count = 50000000) then
						flashing_led <= flashing_led(0) & flashing_led(7 downto 1);
						flashing_count <= 0;
					else
						flashing_count <= flashing_count + 1;
					end if;
					LED <= flashing_led;

				when t1 =>
					if (db_west = '1') then
						next_state <= t2;
					elsif (db_east = '1') then
						next_state <= rst_buffer1;
					elsif (db_north = '1' or db_south = '1' or db_center = '1') then
						next_state <= w2;
					end if;
					LED <= "00000001";
					flashing_led <= "00000001";

				when t2 =>
					if (db_east = '1') then
						next_state <= t3;
					elsif (db_north = '1' or db_west = '1' or db_south = '1' or db_center = '1') then
						next_state <= w3;
					end if;
					LED <= "00000011";

				when t3 =>
					if (db_west = '1') then
						next_state <= unlock;
					elsif (db_east = '1') then
						next_state <= idle;
					elsif (db_north = '1' or db_south = '1' or db_center = '1') then
						next_state <= alarm;
					end if;
					LED <= "00000111";

				when unlock =>
					if (db_south = '1' or db_north = '1' or db_center = '1' or db_west = '1' or db_east = '1') then
						next_state <= idle;
					end if;
					LED <= "11111111";

				when w1 =>
					if (db_east = '1') then
						next_state <= rst_buffer1;
					elsif (db_north = '1' or db_south = '1' or db_west = '1' or db_center = '1') then
						next_state <= w2;
					end if;
					LED <= "10000000";
					flashing_led <= "00000001";

				when w2 =>
					if (db_east = '1') then
						next_state <= rst_buffer2;
					elsif (db_north = '1' or db_south = '1' or db_west = '1' or db_center = '1') then
						next_state <= w3;
					end if;
					LED <= "11000000";

				when w3 =>
					if (db_east = '1'or db_north = '1' or db_south = '1' or db_west = '1' or db_center = '1') then
						next_state <= alarm;
					end if;
					LED <= "11100000";

				when alarm =>
					if (db_west = '1') then
						next_state <= recover;
					end if;
					if (ring_count = 50000000) then
						ring_led <= not ring_led;
						ring_count <= 0;
					else
						ring_count <= ring_count + 1;
					end if;
					LED <= ring_led;

				when recover =>
					if (db_east = '1') then
						next_state <= unlock;
					elsif (db_north = '1' or db_south = '1' or db_center = '1') then
						next_state <= alarm;
					end if;
					if (recover_count = 50000000) then
						recover_led <= not recover_led;
						recover_count <= 0;
					else
						recover_count <= recover_count + 1;
					end if;
					LED <= recover_led;
				when rst_buffer1 =>
					if (db_east = '1') then
						next_state <= idle;
					elsif (db_west = '1' or db_north = '1' or db_south = '1' or db_center = '1') then
						next_state <= w3;
					end if;
					LED <= "00111100";
				when rst_buffer2 =>
					if (db_east = '1') then
						next_state <= idle;
					elsif (db_west = '1' or db_north = '1' or db_south = '1' or db_center = '1') then
						next_state <= alarm;
					end if;
					LED <= "00111100";
			end case;
		end if;
	end process;

end Behavioral;