LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fifo_0ws IS
    GENERIC (
        DEPTH : INTEGER := 16;
        WDTH : INTEGER := 16;
        TRESHOLD : INTEGER := 8
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
    TYPE rcells_memory_t IS ARRAY(0 TO DEPTH - 1) OF STD_LOGIC_VECTOR(WDTH - 1 DOWNTO 0);
    SIGNAL rcells_memory : rcells_memory_t;
    SIGNAL write_ptr : INTEGER RANGE 0 TO DEPTH - 1 := 0;
    SIGNAL read_ptr : INTEGER RANGE 0 TO DEPTH - 1 := 0;
    SIGNAL data_count : INTEGER := 0;
    SIGNAL full_sig : STD_LOGIC := '0';
    SIGNAL empty_sig : STD_LOGIC := '1';
BEGIN

    full <= full_sig;
    half_full <= '1' WHEN data_count >= TRESHOLD ELSE
        '0';
    empty_sig <= '1' WHEN data_count = 0 ELSE
        '0';
    full_sig <= '1' WHEN data_count = DEPTH ELSE
        '0';

    empty <= empty_sig;

    count : PROCESS (clk, reset)
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

    write : PROCESS (clk, reset)
    BEGIN
        IF reset = '0' THEN
            write_ptr <= 0;
        ELSIF clk'event AND clk = '1' THEN
            IF wr = '1' AND full_sig = '0' THEN
                write_ptr <= (write_ptr + 1) MOD (DEPTH);
                rcells_memory(write_ptr) <= data_in;
            END IF;
        END IF;
    END PROCESS;

    read : PROCESS (clk, reset)
    BEGIN
        IF reset = '0' THEN
            read_ptr <= 0;
        ELSIF clk'event AND clk = '1' THEN
            IF rd = '1' and empty_sig ='0' THEN
                read_ptr <= (read_ptr + 1) MOD (DEPTH);
            END IF;
        END IF;
    END PROCESS;

    data_out <= rcells_memory(read_ptr);

END ARCHITECTURE ar_fifo_0ws;