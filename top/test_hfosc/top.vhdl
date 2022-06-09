LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY top IS
  PORT (
    reset : in STD_LOGIC;
    rd : IN STD_LOGIC;
    cs : IN STD_LOGIC;
    wr : IN STD_LOGIC;
    rs : IN STD_LOGIC;
    data : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    has_data : OUT STD_LOGIC;

    conv : OUT STD_LOGIC
  );
END top;

ARCHITECTURE interieur OF top IS

  SIGNAL clkm : STD_LOGIC;
  SIGNAL rstn : STD_LOGIC;
  SIGNAL clk_48M : STD_LOGIC;
  SIGNAL clk_1M : STD_LOGIC;
  SIGNAL clk_1M_reg : STD_LOGIC;
  SIGNAL clk_10k : STD_LOGIC;
  SIGNAL ADC_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL fifo_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL fifo_empty : STD_LOGIC;
  SIGNAL fifo_half_full : STD_LOGIC;
  SIGNAL fifo_rd : STD_LOGIC;
  SIGNAL fifo_wr : STD_LOGIC;
  SIGNAL fifo_full : STD_LOGIC;
  

BEGIN

  conv <= clk_48M;

  rcc0 : ENTITY work.rcc
    PORT MAP(
      rst_in => reset,
      rst_out => rstn,
      clk_48M => clk_48M,
      clk_24M => clkm,
      clk_1M => clk_1M,
      clk_10k => clk_10k
    );

END interieur;