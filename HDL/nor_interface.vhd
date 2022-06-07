LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY nor_interface IS
    PORT (
        reset : IN STD_LOGIC;
        clk : IN STD_LOGIC;

        rd : IN STD_LOGIC;
        cs : IN STD_LOGIC;
        wr : IN STD_LOGIC;
        rs : IN STD_LOGIC;
        data : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        has_data : OUT STD_LOGIC;

        fifo_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        fifo_empty : IN STD_LOGIC;
        fifo_half_full : IN STD_LOGIC;
        fifo_rd : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE ar_nor_interface OF nor_interface IS
    SIGNAL data_reg_in : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL data_reg_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL data_out_enable : STD_LOGIC := '0';
    SIGNAL fifo_rd_reg : STD_LOGIC := '0';
    TYPE state_t IS (idle, data_latch);
    SIGNAL state : state_t := idle;
BEGIN

    data_pins : FOR I IN 15 DOWNTO 0 GENERATE
        pin : ENTITY work.bidir_io
            PORT MAP(
                io_pin => data(I),
                d_in => data_reg_in(I),
                d_out => data_reg_out(I),
                out_en => data_out_enable
            );
    END GENERATE;

    has_data <= fifo_half_full;

    --data_reg_out <= X"FFFF";
    PROCESS (reset, clk)
    BEGIN
        IF reset = '0' THEN
            state <= idle;
            fifo_rd_reg <= '0';
        ELSIF clk'event AND clk = '1' THEN
            CASE state IS
                WHEN idle =>
                    fifo_rd_reg <= '0';
                    IF rd = '0' THEN
                        state <= data_latch;
                        fifo_rd_reg <= '1';
                    ELSE
                        data_reg_out <= fifo_data;
                    END IF;
                WHEN data_latch =>
                    fifo_rd_reg <= '0';
                    IF rd = '1' THEN
                        state <= idle;
                    END IF;
            END CASE;
        END IF;
    END PROCESS;

    data_out_enable <= (NOT rd) AND reset;

    fifo_rd <= '1' WHEN rd = '0' AND fifo_rd_reg = '0' AND state = idle ELSE '0';
END ARCHITECTURE ar_nor_interface;