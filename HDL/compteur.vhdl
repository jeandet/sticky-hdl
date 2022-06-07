  library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  

entity compteur is
  port (
    data_out: out std_logic_vector(7 downto 0);
    clk : in std_logic;
    increment : in std_logic);   
end compteur;

architecture interieur of compteur is 
signal data : std_logic_vector(7 downto 0):=(others=>'0');
signal increment_reg : std_logic:='0';

begin
process(clk)
begin
    if(clk'event and clk='1') then 
        increment_reg <= increment;
        if(increment_reg = '0' and increment = '1' ) then
            data <= std_logic_vector(unsigned(data) + 1);
        end if;
    
    
    end if;
end process;   
data_out <= data;
end interieur;