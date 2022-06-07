library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity  SB_HFOSC  is 
generic( CLKHF_DIV: string:="0b00"); 
port(
CLKHF : out std_logic;
CLKHFEN  :in std_logic;
CLKHFPU : in std_logic
);
end entity ;


architecture ar_clock of SB_HFOSC is
signal clk_sig : std_logic := '0';
begin

    CLKHF <= clk_sig;

    process
    begin
        wait for 10416 ps;
        clk_sig <= not clk_sig;
    end process;

end architecture ar_clock;
