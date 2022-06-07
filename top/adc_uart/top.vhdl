library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  

entity top is
    port (
        sclk : out std_logic;
        rst : in std_logic;
        miso_a : in std_logic_vector(3 downto 0);
        miso_b : in std_logic_vector(3 downto 0);
        conv   : out std_logic;
        cs      : out std_logic;
        ready_strobe : in std_logic;
        Txd : out std_logic);   
end top;

architecture interieur of top is
    signal clkm : std_logic;
    signal rstn : std_logic;
    signal clk_1M : std_logic;
    signal clk_10k : std_logic;
    signal data_16 : std_logic_vector(15 downto 0);
    signal data_8  : std_logic_vector(7 downto 0);
    signal ready_uart : std_logic;
    signal send_uart : std_logic;
    signal increment : std_logic;
  
    
    begin
    rcc0  : entity work.rcc 
      port map(
        rst_in  => rst, 
        rst_out => rstn,
        clk_48M => open,
        clk_24M => clkm,
        clk_1M  => clk_1M,
        clk_10k => clk_10k
        );

    ads92x4 : entity work.ads92x4 
      generic map (CLK_PERIOD => 41667 ps)
      port map(
        smp_clk => clk_10k,
        clk => clkm,
        sclk => sclk,
        data_a => data_16,
        data_b => open,
        miso_a => miso_a,
        miso_b => miso_b,
        reset => rstn,
        cs => cs,
        conv => conv,
        ready_strobe => ready_strobe,
        mosi => open
      );
                                              
    
    adc_uart : entity work.adc_uart port map(rst => rst, data_16 => data_16, data_8 => data_8, rdy_uart => ready_uart, send => send_uart, clkm => clkm, smpclk => clk_10k);


    uart : entity work.uart port map(Txd => Txd, rst => rstn, data => data_8, send => send_uart, serial_clk => clk_1M,ready => ready_uart);
end interieur;