LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY SB_RAM40_4K IS
    GENERIC (
        INIT_0 : STRING;
        INIT_1 : STRING;
        INIT_2 : STRING;
        INIT_3 : STRING;
        INIT_4 : STRING;
        INIT_5 : STRING;
        INIT_6 : STRING;
        INIT_7 : STRING;
        INIT_8 : STRING;
        INIT_9 : STRING;
        INIT_A : STRING;
        INIT_B : STRING;
        INIT_C : STRING;
        INIT_D : STRING;
        INIT_E : STRING;
        INIT_F : STRING;
        READ_MODE : INTEGER;
        WRITE_MODE : INTEGER
    );
    PORT (
        RDATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        RADDR : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        RCLK : IN STD_LOGIC;
        RCLKE : IN STD_LOGIC;
        RE : IN STD_LOGIC;
        WADDR : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        WCLK : IN STD_LOGIC;
        WCLKE : IN STD_LOGIC;
        WDATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        MASK : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        WE : IN STD_LOGIC
    );

END ENTITY;

ARCHITECTURE sim_model OF SB_RAM40_4K IS
    TYPE rcells_memory_t IS ARRAY(0 TO 255) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rcells_memory : rcells_memory_t;
BEGIN
    read : PROCESS  
    BEGIN
        WAIT UNTIL RCLK = '1';
        WAIT FOR 5 ns;
        IF RE = '1' THEN
        RDATA <= rcells_memory(to_integer(unsigned(RADDR)));
        END IF;
        WAIT UNTIL RCLK = '0';
    END PROCESS;

    write : PROCESS
    BEGIN
        WAIT UNTIL WCLK = '1';
        WAIT FOR 5 ns;
        IF WE = '1' THEN
            rcells_memory(to_integer(unsigned(WADDR))) <= WDATA;
        END IF;
        WAIT UNTIL WCLK = '0';
    END PROCESS;

END sim_model;