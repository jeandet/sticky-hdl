library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.MATH_REAL.all;

entity pulse_gen is
generic(
    CLK_PERIOD    : time := 10 ns;
    PULSE_MIN_LENGTH : time := 100 ns
);
port(
    clk   : in  std_logic;
    start : in  std_logic;
    pulse : out std_logic
);
end entity;

architecture ar_pulse_gen of pulse_gen is
    signal cpt : integer:=0;
    constant cpt_max : integer := integer(ceil(real(PULSE_MIN_LENGTH/1 ps) / real( CLK_PERIOD /1 ps)));
    type state_t is (idle, counting, reload);
    signal state : state_t := idle;
begin

    process(clk)
    begin
        if clk'event and clk = '1' then
            case state is
                when idle =>
                    pulse <= '0';
                    if start = '1' then 
                        state <= counting;
                        pulse <= '1';
                    end if;
                    cpt   <= 0;
                when counting =>
                    if cpt >= cpt_max-1 then
                        cpt <= 0;
                        state <= reload;
                        pulse <= '0';
                    else
                        pulse <= '1';
                        cpt <= cpt + 1;
                    end if;
                when reload =>
                    pulse <= '0';
                    if start = '0' then 
                        state <= idle;
                    end if;
            end case;
        end if;
    end process;


end architecture ar_pulse_gen;