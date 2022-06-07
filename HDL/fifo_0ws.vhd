LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY fifo_0ws IS
    GENERIC (
        DEPTH : INTEGER := 256;
        WDTH : INTEGER := 16;
        TRESHOLD : INTEGER := 32
    );
    PORT (
        reset : IN STD_LOGIC;
        clk : IN STD_LOGIC;

        data_in : IN STD_LOGIC_VECTOR(WDTH - 1 DOWNTO 0);
        data_out : OUT STD_LOGIC_VECTOR(WDTH - 1 DOWNTO 0);
        empty : OUT STD_LOGIC := '1';
        full : OUT STD_LOGIC := '0';
        half_full : OUT STD_LOGIC := '0';
        wr : IN STD_LOGIC;
        rd : IN STD_LOGIC
    );
END ENTITY;
ARCHITECTURE ar_fifo_0ws OF fifo_0ws IS
    SIGNAL data_out_sig : STD_LOGIC_VECTOR(WDTH - 1 DOWNTO 0);
    SIGNAL rd_sig : STD_LOGIC := '0';
    SIGNAL full_sig : STD_LOGIC := '0';
    SIGNAL half_full_sig : STD_LOGIC := '0';
    SIGNAL empty_sig : STD_LOGIC := '1';
    type state_t is (pipe0, idle);
    signal state : state_t := pipe0;
BEGIN

    FIFO : ENTITY work.fifo
        GENERIC MAP(
            DEPTH => DEPTH,
            WDTH => WDTH,
            TRESHOLD => TRESHOLD
        )
        PORT MAP(
            reset => reset,
            clk => clk,

            data_in => data_in,
            data_out => data_out_sig,
            empty => empty_sig,
            full => full_sig,
            half_full => half_full_sig,
            wr => wr,
            rd => rd_sig
        );

    PROCESS (reset, clk)
    BEGIN
        IF reset = '1' THEN
            state <= pipe0;
        ELSIF clk'event AND clk = '1' THEN
            case state is
                when pipe0 =>
                when idle =>

            end case;
        END IF;
    END PROCESS;

END ARCHITECTURE ar_fifo_0ws;