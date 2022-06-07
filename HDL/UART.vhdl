-- This file is public domain, it can be freely copied without restrictions.
-- SPDX-License-Identifier: CC0-1.0
-- counter DUT
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  

entity uart is
  port (
    data : in std_logic_vector(7 downto 0);
    send, rst, serial_clk: in std_logic;
    Txd, ready: out std_logic);   
end uart;

architecture interieur of uart is
  constant start_bit : std_logic := '0';
  constant stop_bit : std_logic :=  '1';
	signal shift_reg : std_logic_vector(9 downto 0):= (others=>stop_bit);
  signal cpt: integer:=0;
  type STATE_T is (idle,sending);
  signal STATE : STATE_T:=idle;
  begin

    Txd <= shift_reg(0);
    Process(serial_clk,rst)
    begin
      if(rst ='0') then
        shift_reg <= (others=>stop_bit); -- mise au repos
        cpt <= 0;
        STATE <= idle;
        ready <= '1';

      elsif serial_clk'event and serial_clk='1' then
        case STATE is
          when idle => 
            cpt <= 0;
            ready <= '1';
            shift_reg <= (others=>stop_bit);
            if(send ='1') then 
              shift_reg <= stop_bit & data & start_bit;
              STATE <= sending;
              ready <= '0';
            end if; 
          when sending =>
            shift_reg <= stop_bit & shift_reg(9 downto 1);
            cpt <= cpt + 1;
            if(cpt = 8) then
              STATE <= idle;
              ready <= '1'; 
            end if;
        end case;
       end if;
    end Process;
 

   
end interieur;
