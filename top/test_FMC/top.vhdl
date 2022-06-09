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

    conv : OUT STD_LOGIC
  );
END top;

ARCHITECTURE interieur OF top IS
  SIGNAL rd_reg0 : STD_LOGIC;
  SIGNAL rd_reg1 : STD_LOGIC;
  SIGNAL rd_reg2 : STD_LOGIC;
  SIGNAL clkm : STD_LOGIC;
  SIGNAL rstn : STD_LOGIC;
  SIGNAL clk_48M : STD_LOGIC;
  SIGNAL clk_1M : STD_LOGIC;
  SIGNAL clk_1M_reg : STD_LOGIC;
  SIGNAL clk_10k : STD_LOGIC;
  SIGNAL ADC_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL fifo_wr : STD_LOGIC;
  SIGNAL fifo_full : STD_LOGIC;
  SIGNAL fifo_full_r1 : STD_LOGIC;
  SIGNAL fifo_full_r2 : STD_LOGIC;

  TYPE state_t IS (idle, wait_for_fifo, write);
  SIGNAL state : state_t := idle;

BEGIN

  conv <= fifo_full;

  rcc0 : ENTITY work.rcc
    PORT MAP(
      rst_in => reset,
      rst_out => rstn,
      clk_48M => clk_48M,
      clk_24M => clkm,
      clk_1M => clk_1M,
      clk_10k => clk_10k
    );

  fmc_if0 : ENTITY work.fmc_if_with_fifo
    GENERIC MAP(
      DEPTH => 256,
      BURST_SIZE => 16
    )
    PORT MAP(
      reset => rstn,
      clk => clkm,

      fifo_full => fifo_full,
      fifo_wr => fifo_wr,
      fifo_data_in => ADC_data,
      fmc_rd => rd_reg2,
      fmc_data => data,
      fmc_has_data => has_data
    );

  PROCESS (clkm, rstn)
  BEGIN
    IF rstn = '0' THEN
      ADC_data <= (OTHERS => '0');
      fifo_wr <= '0';
      clk_1M_reg <= '1';
      state <= idle;
      fifo_full_r1 <= '0';
      fifo_full_r2 <= '0';
    ELSIF clkm'event AND clkm = '1' THEN
      clk_1M_reg <= clk_1M;
      fifo_full_r1 <= fifo_full;
      fifo_full_r2 <= fifo_full_r1;
      CASE state IS
        WHEN idle =>
          IF clk_1M_reg = '0' AND clk_1M = '1' THEN
            state <= wait_for_fifo;
            ADC_data <= X"00" & STD_LOGIC_VECTOR(UNSIGNED(ADC_data(7 DOWNTO 0)) + 1);
          END IF;
          fifo_wr <= '0';
        WHEN wait_for_fifo =>
          IF fifo_full_r2 = '0' THEN
            fifo_wr <= '1';
            state <= write;
          END IF;
        WHEN write =>
          fifo_wr <= '0';
          state <= idle;
      END CASE;
    END IF;
  END PROCESS;

  PROCESS (clk_48M)
  BEGIN
    IF clk_48M'event AND clk_48M = '1' THEN
      rd_reg0 <= rd;
      rd_reg1 <= rd_reg0;
      rd_reg2 <= rd_reg1;
    END IF;
  END PROCESS;

END interieur;