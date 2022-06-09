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


    SIGNAL fifo_l0_data_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL fifo_l0_empty : STD_LOGIC := '1';
    SIGNAL fifo_l0_half_full : STD_LOGIC := '0';
    SIGNAL fifo_l0_rd : STD_LOGIC;

    SIGNAL L0_WRITE_CNT : INTEGER RANGE 0 TO BURST_SIZE - 1 := 0;
BEGIN

    fifo_l0 : ENTITY work.fifo_0ws
        GENERIC MAP(
            DEPTH => DEPTH,
            WDTH => 16,
            TRESHOLD => BURST_SIZE
        )
        PORT MAP(
            reset => reset,
            clk => clk,

            data_in => fifo_data_in,
            data_out => fifo_l0_data_out,
            empty => fifo_l0_empty,
            full => fifo_full,
            half_full => fifo_l0_half_full,
            wr => fifo_wr,
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
            fifo_half_full => fifo_l0_half_full,
            fifo_rd => fifo_l0_rd
        );
END ARCHITECTURE ar_fmc_if_with_fifo;