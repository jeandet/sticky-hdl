LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fmc_if_with_fifo IS
    GENERIC (
        DEPTH : INTEGER RANGE 256 TO 8192 := 4096;
        BURST_SIZE : INTEGER := 16
    );
    PORT (
        reset : IN STD_LOGIC;
        clk : IN STD_LOGIC;

        fifo_full : OUT STD_LOGIC := '0';
        fifo_wr : IN STD_LOGIC;
        fifo_data_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        fmc_rd : IN STD_LOGIC;
        fmc_data : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        fmc_has_data : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE ar_fmc_if_with_fifo OF fmc_if_with_fifo IS

    SIGNAL fifo_l1_data_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL fifo_l1_empty : STD_LOGIC;
    SIGNAL fifo_l1_half_full : STD_LOGIC;
    SIGNAL fifo_l1_rd : STD_LOGIC;

    SIGNAL fifo_l0_data_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL fifo_l0_empty : STD_LOGIC := '1';
    SIGNAL fifo_l0_full : STD_LOGIC := '0';
    SIGNAL fifo_l0_half_full : STD_LOGIC := '0';
    SIGNAL fifo_l0_wr : STD_LOGIC;
    SIGNAL fifo_l0_rd : STD_LOGIC;

    TYPE state_t IS (idle, load1, load2);
    SIGNAL state : state_t := idle;
    SIGNAL L0_WRITE_CNT : INTEGER RANGE 0 TO BURST_SIZE - 1 := 0;
BEGIN

    fifo_l1 : ENTITY work.fifo
        GENERIC MAP(
            DEPTH => DEPTH,
            WDTH => 16,
            TRESHOLD => BURST_SIZE + 1
        )
        PORT MAP(
            reset => reset,
            clk => clk,

            data_in => fifo_data_in,
            data_out => fifo_l1_data_out,
            empty => fifo_l1_empty,
            full => fifo_full,
            half_full => fifo_l1_half_full,
            wr => fifo_wr,
            rd => fifo_l1_rd
        );

    fifo_l0 : ENTITY work.fifo_0ws
        GENERIC MAP(
            DEPTH => BURST_SIZE,
            WDTH => 16,
            TRESHOLD => 8
        )
        PORT MAP(
            reset => reset,
            clk => clk,

            data_in => fifo_l1_data_out,
            data_out => fifo_l0_data_out,
            empty => fifo_l0_empty,
            full => fifo_l0_full,
            half_full => fifo_l0_half_full,
            wr => fifo_l0_wr,
            rd => fifo_l0_rd
        );

    fmc_if0 : ENTITY work.fmc_if
        PORT MAP(
            reset => reset,
            clk => clk,

            rd => fmc_rd,
            data => fmc_data,
            has_data => fmc_has_data,

            fifo_data => fifo_l0_data_out,
            fifo_empty => fifo_l0_empty,
            fifo_half_full => fifo_l0_full,
            fifo_rd => fifo_l0_rd
        );
    PROCESS (clk, reset)
    BEGIN
        IF reset = '0' THEN
            fifo_l0_wr <= '0';
            fifo_l1_rd <= '0';
            state <= idle;
        ELSIF clk'event AND clk = '1' THEN
            CASE state IS
                WHEN idle =>
                    IF fifo_l1_empty = '0' AND fifo_l0_full = '0' THEN
                        fifo_l1_rd <= '1';
                        fifo_l0_wr <= '1';
                        state <= load1;
                    END IF;
                WHEN load1 =>
                    state <= load2;
                    fifo_l1_rd <= '0';
                    fifo_l0_wr <= '0';
                WHEN load2 =>
                    state <= idle;
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE ar_fmc_if_with_fifo;