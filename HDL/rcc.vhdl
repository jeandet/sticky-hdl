library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity rcc is
  port (
    rst_in  : in std_logic;
    rst_out  : out std_logic;
    clk_48M : out std_logic;
    clk_24M : out std_logic;
    clk_1M: out std_logic;
    clk_10k: out std_logic
    );   
end rcc;

architecture interieur of rcc is
  	signal clk_48 : std_logic;
    signal clk_24M_reg : std_logic:='0';

	component  SB_HFOSC  is 
	generic( CLKHF_DIV: string:="0b00"); 
	port(
		CLKHF : out std_logic;
		CLKHFEN  :in std_logic;
		CLKHFPU : in std_logic
		);
	end component ;
  begin
    
   
    u_osc: SB_HFOSC    
    Generic map (CLKHF_DIV => "0b00")
    port map(
		CLKHFPU => '1',	--Tie pullup high
		CLKHFEN => '1',	--Enable clock output
		CLKHF => clk_48	--Clock output
	  );


    clk1M_gen: entity work.clk_gen generic map(CLK_IN_PERIOD =>  41667 ps, CLK_OUT_PERIOD => 1000 ns) port map (clk_in => clk_24M_reg, clk_out => clk_1M);
    clk10k_gen: entity work.clk_gen generic map(CLK_IN_PERIOD => 41667 ps, CLK_OUT_PERIOD => 100 us) port map (clk_in => clk_24M_reg, clk_out => clk_10k);
    
    process (clk_48)
    begin
        if(clk_48'event and clk_48 = '1') then
            clk_24M_reg <= not clk_24M_reg;
            rst_out     <= rst_in;
        end if;
    end process;
    clk_48M <= clk_48;
    clk_24M <= clk_24M_reg;
	end interieur;
