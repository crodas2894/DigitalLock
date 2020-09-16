library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity debouncer is
PORT( data : in std_logic;--input signal to be debounced 
clk : in std_logic;--input clock 
out_data : out std_logic); --debounced signal
end debouncer;

architecture Behavioral of debouncer is
signal inff : std_logic_vector(1 downto 0); -- input flip flops
constant cnt_max : integer := (100000000/50) ; -- 100MHz and 1/20ms=50Hz
signal count : integer range 0 to cnt_max := 0;
signal tmp_output, tmp_outputD: std_logic;

begin

process(clk)
begin
if(rising_edge(clk)) THEN
    inff <= inff(0) & data; -- sync in the input
    if(inff(0)/=inff(1)) then -- reset counter because input is changing
        count <= 0;
    elsif(count<cnt_max) then -- stable input time is not yet met
        count <= count + 1;
    elsif (count = cnt_max) then -- stable input time is met
        tmp_output <= inff(1);
    end if;
end if;
end process;

process(clk)
begin

if (rising_edge(clk)) then
tmp_outputD <= tmp_output;
out_data <= (not tmp_output) and tmp_outputD;
end if;
end process;

end Behavioral;