LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY top IS
  PORT (
    reset : IN STD_LOGIC;
    rd : IN STD_LOGIC;
    cs : IN STD_LOGIC;
    wr : IN STD_LOGIC;
    rs : IN STD_LOGIC;
    data : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    has_data : OUT STD_LOGIC;

    conv : OUT STD_LOGIC;
    adc_cs : OUT STD_LOGIC;
    ready_strobe : IN STD_LOGIC;
    sclk : OUT STD_LOGIC;
    mosi : OUT STD_LOGIC;
    miso_a : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    miso_b : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
END top;

ARCHITECTURE interieur OF top IS
  SIGNAL rd_reg0 : STD_LOGIC;
  SIGNAL rd_reg1 : STD_LOGIC;
  SIGNAL rd_reg2 : STD_LOGIC;
  SIGNAL ready_strobe_reg0 : STD_LOGIC;
  SIGNAL ready_strobe_reg1 : STD_LOGIC;
  SIGNAL clkm : STD_LOGIC;
  SIGNAL rstn : STD_LOGIC;
  SIGNAL clk_48M : STD_LOGIC;
  SIGNAL smp_clk_reg : STD_LOGIC;
  SIGNAL clk_10k : STD_LOGIC;
  SIGNAL fifo_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL fifo_empty : STD_LOGIC;
  SIGNAL fifo_half_full : STD_LOGIC;
  SIGNAL fifo_rd : STD_LOGIC;
  SIGNAL fifo_wr : STD_LOGIC;
  SIGNAL fifo_full : STD_LOGIC;

  SIGNAL smp_clk : STD_LOGIC;
  SIGNAL adc_a_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL adc_b_data : STD_LOGIC_VECTOR(15 DOWNTO 0);

  SIGNAL adc_a_data_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL adc_b_data_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);

  TYPE seq_state_t IS (idle, adc_a_msb, adc_a_lsb, adc_b_msb, adc_b_lsb);
  SIGNAL seq_state : seq_state_t := idle;
BEGIN

  rcc0 : ENTITY work.rcc
    PORT MAP(
      rst_in => reset,
      rst_out => rstn,
      clk_48M => clk_48M,
      clk_24M => clkm,
      clk_1M => smp_clk,
      clk_10k => clk_10k
    );

  fmc_if0 : ENTITY work.fmc_if_with_fifo
    GENERIC MAP(
      DEPTH => 4096,
      BURST_SIZE => 16
    )
    PORT MAP(
      reset => rstn,
      clk => clkm,

      fifo_full => fifo_full,
      fifo_wr => fifo_wr,
      fifo_data_in => fifo_data,
      fmc_rd => rd,
      fmc_data => data,
      fmc_has_data => has_data
    );

  adc_driver : ENTITY work.ads92x4
    GENERIC MAP(
      CLK_PERIOD => 41 ns
    )
    PORT MAP(
      reset => rstn,
      clk_2x => clk_48M,
      clk => clkm,
      smp_clk => smp_clk,
      data_a => adc_a_data,
      data_b => adc_b_data,

      conv => conv,
      cs => adc_cs,
      ready_strobe => ready_strobe_reg1,
      sclk => sclk,
      mosi => mosi,
      miso_a => "00" & miso_a,
      miso_b => "00" & miso_b
    );

  PROCESS (clkm, rstn)
  BEGIN
    IF rstn = '0' THEN
      fifo_data <= (OTHERS => '0');
      fifo_wr <= '0';
      smp_clk_reg <= '1';
      seq_state <= idle;
    ELSIF clkm'event AND clkm = '1' THEN
      smp_clk_reg <= smp_clk;
      CASE seq_state IS
        WHEN idle =>
          IF smp_clk_reg = '0' AND smp_clk = '1' AND fifo_full = '0' THEN
            adc_a_data_reg <= adc_a_data;
            adc_b_data_reg <= adc_b_data;
            seq_state <= adc_a_msb;
          END IF;
          fifo_wr <= '0';
        WHEN adc_a_msb =>
          fifo_wr <= '1';
          fifo_data <= X"00" & adc_a_data_reg(15 DOWNTO 8);
          seq_state <= adc_a_lsb;
        WHEN adc_a_lsb =>
          fifo_data <= X"01" & adc_a_data_reg(7 DOWNTO 0);
          seq_state <= adc_b_msb;
        WHEN adc_b_msb =>
          fifo_data <= X"02" & adc_b_data_reg(15 DOWNTO 8);
          seq_state <= adc_b_lsb;
        WHEN adc_b_lsb =>
          fifo_data <= X"03" & adc_b_data_reg(7 DOWNTO 0);
          seq_state <= idle;
      END CASE;
    END IF;
  END PROCESS;

  PROCESS (clk_48M)
  BEGIN
    IF clk_48M'event AND clk_48M = '1' THEN
      rd_reg0 <= rd;
      rd_reg1 <= rd_reg0;
      rd_reg2 <= rd_reg1;

      ready_strobe_reg0 <= ready_strobe;
      ready_strobe_reg1 <= ready_strobe_reg0;
    END IF;
  END PROCESS;

END interieur;