LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fifo IS
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
        empty : OUT STD_LOGIC :='1';
        full : OUT STD_LOGIC := '0';
        half_full : OUT STD_LOGIC := '0';
        wr : IN STD_LOGIC;
        rd : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE ar_fifo OF fifo IS
    SIGNAL write_ptr : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL read_ptr : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL write_addr : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL read_addr : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL WDATA : STD_LOGIC_VECTOR(WDTH - 1 DOWNTO 0);
    SIGNAL RDATA : STD_LOGIC_VECTOR(WDTH - 1 DOWNTO 0);
    SIGNAL ram_re : STD_LOGIC := '0';
    SIGNAL ram_we : STD_LOGIC := '0';
    SIGNAL data_count : INTEGER := 0;
    SIGNAL full_sig : STD_LOGIC := '0';
    SIGNAL empty_sig : STD_LOGIC := '1';
    SIGNAL empty_sig_r : STD_LOGIC := '1';
    TYPE r_state_t IS (idle, load_pipe0,load_pipe1);
    SIGNAL r_state : r_state_t := load_pipe0;
BEGIN

    RAM0 : ENTITY work.bram_256x16(hw_ram)
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
    full_sig <= '1' WHEN data_count = 256 ELSE
        '0';

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
                write_ptr <= (write_ptr + 1) MOD (DEPTH - 1);
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
            r_state  <= load_pipe0;
        ELSIF clk'event AND clk = '1' THEN
            empty_sig_r <= empty_sig;

            case r_state is    
                when load_pipe0 =>
                    data_out <= RDATA;
                    if empty_sig_r = '0' then
                        r_state <= load_pipe1;
                    end if;
                when load_pipe1 =>
                    data_out <= RDATA;
                    read_ptr <= (read_ptr + 1) MOD (DEPTH - 1);
                    r_state <= idle;
                when idle =>
                    empty <= '0';
                    IF rd = '1' THEN
                        read_ptr <= (read_ptr + 1) MOD (DEPTH - 1);
                        data_out <= RDATA;
                        empty <= empty_sig;
                        if data_count = 1 then
                            empty <= '1';
                            empty_sig_r <= '1';
                            r_state <= load_pipe0;
                        end if;
                    END IF;
            end case;
        END IF;
    END PROCESS;

    ram_re <= '1';
END ARCHITECTURE ar_fifo;