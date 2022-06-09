LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY bram IS
    GENERIC (
        ABITS : INTEGER RANGE 8 TO 12 := 8
    );
    PORT (
        RDATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        RADDR : IN STD_LOGIC_VECTOR(ABITS - 1 DOWNTO 0);
        RCLK : IN STD_LOGIC;
        RCLKE : IN STD_LOGIC;
        RE : IN STD_LOGIC;
        WADDR : IN STD_LOGIC_VECTOR(ABITS - 1 DOWNTO 0);
        WCLK : IN STD_LOGIC;
        WCLKE : IN STD_LOGIC;
        WDATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        MASK : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        WE : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE hw_ram OF bram IS
    CONSTANT BRAM_COUNT : INTEGER := 2**(ABITS - 8);
    TYPE data_mux_t IS ARRAY(0 TO BRAM_COUNT - 1) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL data_mux : data_mux_t;
    SIGNAL selected_out : INTEGER RANGE 0 TO BRAM_COUNT - 1 := 0;
    SIGNAL RE_mux : STD_LOGIC_VECTOR(0 TO BRAM_COUNT - 1);
    SIGNAL WE_mux : STD_LOGIC_VECTOR(0 TO BRAM_COUNT - 1);
BEGIN
    multi_blocks : IF BRAM_COUNT > 1 GENERATE
        brams_blocks : FOR i IN 0 TO BRAM_COUNT - 1 GENERATE
            brams_x : ENTITY work.bram_256x16
                PORT MAP(
                    RDATA => data_mux(i),
                    RADDR => RADDR(7 DOWNTO 0),
                    RCLK => RCLK,
                    RCLKE => RCLKE,
                    RE => RE_mux(i),
                    WADDR => WADDR(7 DOWNTO 0),
                    WCLK => WCLK,
                    WCLKE => WCLKE,
                    WDATA => WDATA,
                    MASK => MASK,
                    WE => WE_mux(i)
                );

            WE_mux(i) <= WE WHEN to_integer(unsigned(WADDR(ABITS - 1 DOWNTO 8))) = i ELSE
            '0';
            RE_mux(i) <= RE WHEN to_integer(unsigned(WADDR(ABITS - 1 DOWNTO 8))) = i ELSE
            '0';

        END GENERATE;
        PROCESS (RCLK)
        BEGIN
            IF RCLK'event AND RCLK = '1' THEN
                IF RE = '1' THEN
                    selected_out <= to_integer(unsigned(WADDR(ABITS - 1 DOWNTO 8)));
                END IF;
            END IF;
        END PROCESS;
        RDATA <= data_mux(selected_out);
    END GENERATE;

    single_blocks : IF BRAM_COUNT = 1 GENERATE
        bram_0 : ENTITY work.bram_256x16
            PORT MAP(
                RDATA => RDATA,
                RADDR => RADDR(7 DOWNTO 0),
                RCLK => RCLK,
                RCLKE => RCLKE,
                RE => RE,
                WADDR => WADDR(7 DOWNTO 0),
                WCLK => WCLK,
                WCLKE => WCLKE,
                WDATA => WDATA,
                MASK => MASK,
                WE => WE
            );
    END GENERATE;

END hw_ram;