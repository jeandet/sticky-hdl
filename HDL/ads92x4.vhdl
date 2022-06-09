LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ads92x4 IS
    GENERIC (
        CLK_PERIOD : TIME := 20.8 ns -- F = 48MHz
    );
    PORT (
        reset : IN STD_LOGIC;
        clk_2x : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        smp_clk : IN STD_LOGIC;
        data_a : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        data_b : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);

        conv : OUT STD_LOGIC;
        cs : OUT STD_LOGIC;
        ready_strobe : IN STD_LOGIC;
        sclk : OUT STD_LOGIC;
        mosi : OUT STD_LOGIC;
        miso_a : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        miso_b : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE ar_ads92x4 OF ads92x4 IS
    SIGNAL bit_counter : INTEGER := 0;
    SIGNAL smp_clk_reg : STD_LOGIC := '0';
    SIGNAL gated_sclk : STD_LOGIC := '0';
    SIGNAL ready_strobe_r1 : STD_LOGIC := '0';
    SIGNAL ready_strobe_r0 : STD_LOGIC := '0';
    SIGNAL cs_reg : STD_LOGIC := '1';
    SIGNAL cs_reg_d : STD_LOGIC := '1';
    SIGNAL conv_sig : STD_LOGIC;
    SIGNAL conv_reg : STD_LOGIC;
    SIGNAL conv_reg_d : STD_LOGIC;
    TYPE state_t IS (idle, serialize, last_bit);
    SIGNAL state : state_t := idle;

    SIGNAL data_a_sr : STD_LOGIC_VECTOR(17 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_b_sr : STD_LOGIC_VECTOR(17 DOWNTO 0) := (OTHERS => '0');
BEGIN

    conv_gen : ENTITY work.pulse_gen GENERIC MAP(CLK_PERIOD => CLK_PERIOD, PULSE_MIN_LENGTH => 15 ns) PORT MAP (clk => clk, start => smp_clk, pulse => conv_sig);
    conv <= conv_sig;

    cs <= cs_reg;
    mosi <= '0';

    PROCESS (clk, reset)
    BEGIN
        IF reset = '0' THEN
            smp_clk_reg <= '0';
            cs_reg <= '1';
            state <= idle;
            conv_reg <= '1';
            bit_counter <= 0;
        ELSIF clk'event AND clk = '1' THEN
            conv_reg <= conv_sig;
            conv_reg_d <= conv_reg;
            CASE state IS
                WHEN idle =>
                    cs_reg <= '1';
                    IF conv_reg = '1' AND conv_reg_d = '0' THEN
                        state <= serialize;
                        data_a_sr <= (OTHERS => '0');
                        data_b_sr <= (OTHERS => '0');
                    ELSE
                        data_a <= data_a_sr(16 downto 1);
                        data_b <= data_b_sr(16 downto 1);
                    END IF;
                    bit_counter <= 0;
                WHEN serialize =>
                    IF bit_counter = 16 THEN
                        state <= last_bit;
                        cs_reg <= '1';
                    ELSE
                        cs_reg <= '0';
                        bit_counter <= bit_counter + 1;
                    END IF;
                    data_a_sr <= data_a_sr(16 DOWNTO 0) & miso_a(0);
                    data_b_sr <= data_b_sr(16 DOWNTO 0) & miso_b(0);
                WHEN last_bit => 
                    state <= idle;
                    data_a_sr <= data_a_sr(16 DOWNTO 0) & miso_a(0);
                    data_b_sr <= data_b_sr(16 DOWNTO 0) & miso_b(0);
            END CASE;
        END IF;
    END PROCESS;

    sclk <= gated_sclk;

    PROCESS (clk_2x)
    BEGIN
        IF clk_2x'event AND clk_2x = '1' THEN

            ready_strobe_r0 <= ready_strobe;
            ready_strobe_r1 <= ready_strobe_r0;
            cs_reg_d <= cs_reg;
            IF cs_reg_d = '0' AND cs_reg = '0' THEN
                gated_sclk <= NOT gated_sclk;
            ELSE
                gated_sclk <= '0';
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE ar_ads92x4;