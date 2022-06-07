library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  

entity top is
    port (
        rst : in std_logic;
        sck : out std_logic;
        Txd : out std_logic);   
end top;

architecture interieur of top is
    signal serial_clk : std_logic;
    signal clk_48M : std_logic;
    signal data : std_logic_vector(7 downto 0);
    signal increment : std_logic;
  
    
    begin
    sck <= serial_clk;
    diviseur : entity work.diviseur port map(clk_1M => serial_clk,clk_48M => clk_48M ); 
    compteur : entity work.compteur port map(data_out => data, clk => clk_48M, increment => increment );
    uart : entity work.uart port map(Txd => Txd, rst => rst, data => data, send => '1', serial_clk => serial_clk,ready => increment);
end interieur;
