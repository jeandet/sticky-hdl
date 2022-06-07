-- This file is public domain, it can be freely copied without restrictions.
-- SPDX-License-Identifier: CC0-1.0
-- counter DUT
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity adc_uart is
  port(
  rst : in std_logic;
  data_16 : in std_logic_vector(15 downto 0);
  clkm : in std_logic;
  smpclk : in std_logic;
  rdy_uart : in std_logic;
  data_8 : out std_logic_vector(7 downto 0);
  send : out std_logic);
end entity adc_uart;

architecture interieur of adc_uart is
  type ETAT_POSSIBLE is (idle,E1,E2,E3);
  signal ETAT : ETAT_POSSIBLE;
  signal mem_data_16 : std_logic_vector(15 downto 0);
  signal smpclk_reg : std_logic := '0';
  begin

  process(clkm, rst)
  begin
  if (rst = '0') then 
    ETAT <= idle;
    send <='0';
    data_8 <= "00000000";
  elsif(clkm'event and clkm = '1') then
    case ETAT is 
      when idle => smpclk_reg <= smpclk;
                   if(smpclk_reg = '0' and smpclk = '1' ) then 
                      mem_data_16 <= data_16;
                      ETAT <= E1;
                   end if;
   
      when E1   => send <= '1';
                   data_8 <=  mem_data_16(15 downto 8);
                   if(rdy_uart = '0') then 
                    send <= '0';
                    ETAT <=  E2;
                   end if;
   
      when E2   => if(rdy_uart = '1') then ETAT <=  E3;
                   end if;

      when E3   => send <= '1';
                   data_8 <= mem_data_16(7 downto 0);   
                   if(rdy_uart = '0') then
                    send <= '0'; 
                    ETAT <=  idle;
                  end if;
  
   end case;
  end if;
  end process;
  
  end interieur;
    
