library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ads92x4 is
generic(
    CLK_PERIOD : time := 20.8 ns  -- F = 48MHz
);
port(
    reset   : in std_logic;
    clk     : in std_logic;
    smp_clk : in std_logic;
    data_a  : out std_logic_vector(15 downto 0);
    data_b  : out std_logic_vector(15 downto 0);

    conv    : out std_logic;
    cs      : out std_logic;
    ready_strobe : in std_logic;
    sclk    : out std_logic;
    mosi    : out std_logic;
    miso_a  : in std_logic_vector(3 downto 0);
    miso_b  : in std_logic_vector(3 downto 0)
);
end entity;

architecture ar_ads92x4 of ads92x4 is
    signal bit_counter : integer :=0; 
    signal smp_clk_reg : std_logic := '0';
    signal gated_sclk  : std_logic := '0';
    signal cs_reg      : std_logic := '1';
    signal cs_reg_d      : std_logic := '1';
    type state_t is (idle, serialize);
    signal state : state_t := idle;
    
    signal data_a_sr  :  std_logic_vector(15 downto 0):=(others => '0');
    signal data_b_sr  :  std_logic_vector(15 downto 0):=(others => '0');
begin

    --sclk_gen: entity work.clk_gen generic map(CLK_IN_PERIOD => CLK_PERIOD, CLK_OUT_PERIOD => 17 ns) port map (clk_in => clk, clk_out => gated_sclk);
    conv_gen: entity work.pulse_gen generic map(CLK_PERIOD => CLK_PERIOD, PULSE_MIN_LENGTH => 15 ns) port map (clk => clk, start => smp_clk, pulse => conv);

    cs <= cs_reg;
    mosi        <= '0';

    process(clk, reset)
    begin
        if reset = '0' then 
            smp_clk_reg <= '0';
            cs_reg      <= '1';
            state       <= idle;
        elsif clk'event and clk = '1' then
            cs_reg_d <= cs_reg;
            case state is
                when idle =>
                    if ready_strobe = '1' then
                        state <= serialize;
                    end if;
                    cs_reg <= '1';
                    data_a <= data_a_sr;
                    data_b <= data_b_sr;
                when serialize =>
                    if bit_counter = 16 then 
                        state <= idle;
                        cs_reg <= '1';
                    else
                        cs_reg <= '0';
                    end if;
            end case;
        end if;
    end process;

    process(gated_sclk)
    begin
        if gated_sclk'event and gated_sclk ='1' then
            if state = serialize and cs_reg = '0' then
                if bit_counter < 16 then
                    bit_counter <= bit_counter + 1;
                end if;
            else
                bit_counter <= 0;
            end if;
            if cs_reg = '0' then --or bit_counter = 16 then
                data_a_sr <= data_a_sr(14 downto 0) & miso_a(0);
                data_b_sr <= data_b_sr(14 downto 0) & miso_b(0);
            end if;

        end if; 
    end process;
    gated_sclk <= clk;
    sclk <= gated_sclk when cs_reg_d = '0' and state = serialize else '0';

end architecture ar_ads92x4;
