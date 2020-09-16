library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clock_divider is
Port ( clk : in STD_LOGIC;
clk_out: out STD_LOGIC);
end clock_divider;

architecture Behavioral of clock_divider is
signal newclk : std_logic := '0';

begin
clkdiv: process(clk)
variable count: integer := 0;
variable clksig: std_logic:= '0';
begin
if rising_edge(clk) then
    if (count < 20000) then
        count := count + 1;
    else
        clksig := not clksig;
        count := 0;
    end if;
end if;
clk_out <= clksig;
end process;
end Behavioral;
