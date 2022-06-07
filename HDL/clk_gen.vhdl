library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.MATH_REAL.all;

entity clk_gen is
generic(
    CLK_IN_PERIOD  : time := 10 ns;
    CLK_OUT_PERIOD : time := 100 ns
);
port(
    clk_in  : in  std_logic;
    clk_out : out std_logic
);
end entity;

architecture ar_clk_gen of clk_gen is
    signal cpt : integer:=0;
    signal clk : std_logic := '0';
    constant cpt_max : integer := CLK_OUT_PERIOD/CLK_IN_PERIOD;
begin

    DIVIDER : if cpt_max>1 generate
        process(clk_in)
        begin
            if clk_in'event and clk_in = '1' then
                if cpt >= integer(ceil(real(cpt_max)/2.0))-1 then
                    cpt <= 0;
                    clk <= not clk;
                else
                    cpt <= cpt + 1;
                end if;
            end if;
        end process;
        clk_out <= clk;
    end generate DIVIDER;

    NO_DIVIDER : if cpt_max<2 generate
        clk_out <= clk_in;
    end generate NO_DIVIDER;

end architecture ar_clk_gen;