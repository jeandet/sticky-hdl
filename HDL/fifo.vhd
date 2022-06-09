LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.math_real.all;


ENTITY fifo IS
    GENERIC (
        DEPTH : INTEGER := 4096;
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

ARCHITECTURE ar_fifo OF fifo IS
    CONSTANT ABITS : INTEGER :=integer(ceil(log2(real(DEPTH))));
    SIGNAL write_ptr : INTEGER RANGE 0 TO DEPTH-1 := 0;
    SIGNAL read_ptr : INTEGER RANGE 0 TO DEPTH-1 := 0;
    SIGNAL write_addr : STD_LOGIC_VECTOR(ABITS-1 DOWNTO 0);
    SIGNAL read_addr : STD_LOGIC_VECTOR(ABITS-1 DOWNTO 0);
    SIGNAL WDATA : STD_LOGIC_VECTOR(WDTH - 1 DOWNTO 0);
    SIGNAL RDATA : STD_LOGIC_VECTOR(WDTH - 1 DOWNTO 0);
    SIGNAL ram_re : STD_LOGIC := '0';
    SIGNAL ram_we : STD_LOGIC := '0';
    SIGNAL data_count : INTEGER := 0;
    SIGNAL full_sig : STD_LOGIC := '0';
    SIGNAL empty_sig : STD_LOGIC := '1';
BEGIN

    RAM0 : ENTITY work.bram
        GENERIC MAP (ABITS => ABITS)
        PORT MAP(
            RDATA => RDATA,
            RADDR => read_addr,
            RCLK => clk,
            RCLKE => '1',
            RE => ram_re,
            WADDR => write_addr,
            WCLK => clk,
            WCLKE => '1',
            WDATA => WDATA,
            MASK => X"0000",
            WE => ram_we
        );

    read_addr <= STD_LOGIC_VECTOR(to_unsigned(read_ptr, read_addr'length));
    full <= full_sig;
    half_full <= '1' WHEN data_count >= TRESHOLD ELSE
        '0';
    empty_sig <= '1' WHEN data_count = 0 ELSE
        '0';
    full_sig <= '1' WHEN data_count = DEPTH ELSE
        '0';
    
    data_out <= RDATA;
    empty <= empty_sig;

    PROCESS (clk, reset)
    BEGIN
        IF reset = '0' THEN
            data_count <= 0;
        ELSIF clk'event AND clk = '1' THEN
            IF wr = '1' AND rd = '0' AND data_count /= DEPTH THEN
                data_count <= data_count + 1;
            ELSIF rd = '1' AND wr = '0' AND data_count /= 0 THEN
                data_count <= data_count - 1;
            END IF;
        END IF;
    END PROCESS;
    PROCESS (clk, reset)
    BEGIN
        IF reset = '0' THEN
            write_ptr <= 0;
            ram_we <= '0';
            write_addr <= (OTHERS => '0');
        ELSIF clk'event AND clk = '1' THEN
            IF wr = '1' AND full_sig = '0' THEN
                write_ptr <= (write_ptr + 1) MOD (DEPTH);
                write_addr <= STD_LOGIC_VECTOR(to_unsigned(write_ptr, write_addr'length));
                ram_we <= '1';
                WDATA <= data_in;
            ELSE
                ram_we <= '0';
            END IF;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF reset = '0' THEN
            read_ptr <= 0;
        ELSIF clk'event AND clk = '1' THEN
            IF rd = '1' THEN
                read_ptr <= (read_ptr + 1) MOD (DEPTH);
            END IF;
        END IF;
    END PROCESS;
    ram_re <= '1' when rd = '1' and empty_sig='0' else '0';

END ARCHITECTURE ar_fifo;

