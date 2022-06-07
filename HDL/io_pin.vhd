library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bidir_io is
    generic (
    EN_PULLDN   : boolean := false; 
    EN_PULLUP   : boolean := false);    
    port (
    io_pin    : inout std_logic; 
    d_in      : out   std_logic;
    d_out     : in    std_logic;
    out_en    : in    std_logic);
end bidir_io;

architecture sim of bidir_io is

begin

    io_pin <= d_out when out_en = '1' else 'Z';
    d_in   <= io_pin;

end sim;