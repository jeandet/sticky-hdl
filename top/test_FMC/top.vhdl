LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY top IS
  PORT (

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

  signal reset :  STD_LOGIC := '0';
  SIGNAL clkm : STD_LOGIC;
  SIGNAL rstn : STD_LOGIC;
  SIGNAL clk_1M : STD_LOGIC;
  SIGNAL clk_1M_reg : STD_LOGIC;
  SIGNAL clk_10k : STD_LOGIC;
  SIGNAL ADC_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL ADC_data_r : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL fifo_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL fifo_empty : STD_LOGIC;
  SIGNAL fifo_half_full : STD_LOGIC;
  SIGNAL fifo_rd : STD_LOGIC;
  SIGNAL fifo_wr : STD_LOGIC;
  SIGNAL fifo_full : STD_LOGIC;

BEGIN

conv <= clk_1M;

  rcc0 : ENTITY work.rcc
    PORT MAP(
      rst_in => reset,
      rst_out => rstn,
      clk_48M => OPEN,
      clk_24M => clkm,
      clk_1M => clk_1M,
      clk_10k => clk_10k
    );

  nor0 : ENTITY work.nor_interface
    PORT MAP(
      reset => rstn,
      clk => clkm,

      rd => rd,
      cs => cs,
      wr => wr,
      rs => rs,
      data => data,
      has_data => has_data,

      fifo_data => fifo_data,
      fifo_empty => fifo_empty,
      fifo_half_full => fifo_half_full,
      fifo_rd => fifo_rd
    );

  FIFO0 : ENTITY work.fifo 
    PORT MAP(
      reset => rstn,
      clk => clkm,

      data_in => ADC_data,
      data_out => fifo_data,
      empty => fifo_empty,
      full => fifo_full,
      half_full => fifo_half_full,
      wr => fifo_wr,
      rd => fifo_rd
    );

    process(clkm)
    begin
      if clkm'event and clkm='1' then
        reset <= '1';
      end if;
    end process;

    process(clkm, rstn)
    begin
      if rstn = '0' then
        ADC_data <= (others=>'0'); 
        ADC_data_r <= (others=>'0'); 
        fifo_wr <= '0';
        clk_1M_reg <= '1';
      elsif clkm'event and clkm='1' then
        clk_1M_reg <= clk_1M;
        if clk_1M_reg = '0' and clk_1M ='1' and fifo_full = '0' then
          --ADC_data_r <= std_logic_vector(UNSIGNED(ADC_data_r) + 1);
          ADC_data_r(8 downto 0) <= not ADC_data_r(8 downto 0);
          fifo_wr <= '1';
        else
          ADC_data <= ADC_data_r;
          fifo_wr <= '0';
        end if;
      end if;
    end process;

END interieur;