library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity diviseur is
  port (
   clk_48M : out std_logic;
   clk_1M: out std_logic);   
end diviseur;

architecture interieur of diviseur is
  	signal clk_48 : std_logic;
    signal clk_reg : std_logic:='0';
	  constant val_max : integer := 48/2;
    signal div : integer range val_max downto 0 :=val_max;

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
    
    process (clk_48)
    begin
     if(clk_48'event and clk_48 = '1') then
        if(div = 0) then
          div <= val_max-1;
          clk_reg <= not clk_reg;
        else
          div <= div-1;
        end if;
      end if;
    end process;
    clk_48M <= clk_48;
    clk_1M <= clk_reg;
	end interieur;
