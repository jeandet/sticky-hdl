library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_sticky is
generic(
    PHY_CLK_PERIOD : time := 20.833333 ns;
    SMP_CLK_PERIOD : time := 310 ns;
    CLK_DIV    : integer := 1;
    CLK_MULT   : integer := 2
);
port(
    reset   : in std_logic;

    rd       : in std_logic;
    cs       : in std_logic;
    wr       : in std_logic;
    rs       : in std_logic;
    data     : inout std_logic_vector(15 downto 0);
    has_data : out std_logic;


    conv    : out std_logic;
    adc_cs      : out std_logic;
    ready_strobe : in std_logic;
    sclk    : out std_logic;
    mosi    : out std_logic;
    miso_a  : in std_logic_vector(1 downto 0);
    miso_b  : in std_logic_vector(1 downto 0)


);
end entity;

architecture ar_top_sticky of top_sticky is
signal  clk : std_logic;
signal  smp_clk     : std_logic;
signal  smp_clk_reg : std_logic;

signal adc_a_data   :  std_logic_vector(15 downto 0);
signal adc_b_data   :  std_logic_vector(15 downto 0);


signal fifo_data_out   :  std_logic_vector(15 downto 0);
signal fifo_data_in    :  std_logic_vector(15 downto 0);
signal fifo_empty      :  std_logic;
signal fifo_full       :  std_logic;
signal fifo_half_full  :  std_logic;
signal fifo_rd         :  std_logic;
signal fifo_wr         :  std_logic;

constant CLK_PERIOD : time := (REAL(CLK_DIV) / REAL(CLK_MULT)) * PHY_CLK_PERIOD;

begin

int_clk : entity work.clock generic map (CLK_DIV => CLK_DIV , CLK_MUL => CLK_MULT) port map(reset => reset, clk => clk);

fmc_interface : entity work.nor_interface
    port map (
        reset    => reset,
        clk      => clk,
    
        rd       => rd,
        cs       => cs,
        wr       => wr,
        rs       => rs,
        data     => data,
        has_data => has_data,
    
        fifo_data       => fifo_data_out,
        fifo_empty      => fifo_empty,
        fifo_half_full  => fifo_half_full,
        fifo_rd         => fifo_rd
    );


    fifo : entity work.fifo
        generic map(
            DEPTH    => 64,
            WDTH     => 16,
            TRESHOLD => 32
        )
        port map(
            reset   => reset,
            clk     => clk,
        
            data_in    => fifo_data_in,
            data_out   => fifo_data_out,
            empty      => fifo_empty,
            full       => fifo_full,
            half_full  => fifo_half_full,
            wr         => fifo_wr,
            rd         => fifo_rd
        );

smp_clk_gen: entity work.clk_gen 
    generic map(
        CLK_IN_PERIOD  => CLK_PERIOD,
        CLK_OUT_PERIOD => SMP_CLK_PERIOD
    )
    port map(
        clk_in  => clk,
        clk_out => smp_clk
    );

adc_driver: entity work.ads92x4 
    generic map(
        CLK_PERIOD => CLK_PERIOD
    )
    port map(
        reset   => reset,
        clk     => clk,
        smp_clk => smp_clk,
        data_a  => adc_a_data,
        data_b  => adc_b_data,
    
        conv    => conv,
        cs      => adc_cs,
        ready_strobe => ready_strobe,
        sclk    => sclk,
        mosi    => mosi,
        miso_a  => "00"&miso_a,
        miso_b  => "00"&miso_b
    );

    fifo_data_in <= adc_a_data;

    process (clk)
    begin
        if clk'event and clk='1' then
            smp_clk_reg <= smp_clk; 
            if smp_clk = '1' and smp_clk_reg = '0' then
                fifo_wr <= '1';
            else 
                fifo_wr <= '0';
            end if;
        end if;
    end process;

end architecture ar_top_sticky;