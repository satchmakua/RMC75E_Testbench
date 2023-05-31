--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_SerialMemoryInterface
--	File			tb_serial_mem.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- DUT (Design Under Test) - Serial Memory Interface:

	-- The Serial Memory Interface is a module designed to interface with a serial EEPROM device.
	-- It facilitates the clocking in and out of data from the EEPROM.
	-- The module includes a state machine that controls the serial
	-- communication process with the EEPROM. It supports read and write operations,
	-- manages device and memory addresses, and handles various control signals.
	-- The module is designed to operate with a system clock and provides outputs
	-- such as serial data, clock, and control signals.

	-- Test Bench - Serial Memory Interface:

	-- The test bench for the Serial Memory Interface module is designed to verify
	-- the functionality and robustness of the DUT. It instantiates the
	-- Serial Memory Interface module and provides stimulus to its inputs
	-- to simulate different scenarios. The test bench initializes the
	-- DUT with appropriate values, applies test vectors, and
	-- monitors the DUT's outputs. It includes processes to generate clock signals,
	-- control inputs, and stimuli for read and write operations.
	-- The test bench captures and analyzes the DUT's responses to ensure correct
	-- behavior and verify the expected functionality of the Serial Memory Interface module.
	
--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.numeric_std_unsigned.all;

entity tb_SerialMemoryInterface is
end tb_SerialMemoryInterface;

architecture tb_arch of tb_SerialMemoryInterface is
    -- Component declaration
    component SerialMemoryInterface
    port (
        SysReset                : in std_logic;          -- System Reset or PLL not locked
        H1_CLK                  : in std_logic;
        SysClk                  : in std_logic;
        SlowEnable              : in std_logic;
        intDATA                 : in std_logic_vector(31 downto 0);
        serialMemDataOut        : out std_logic_vector(31 downto 0);
        SerialMemXfaceWrite     : in std_logic;
        SerialMemoryDataIn      : in std_logic;
        SerialMemoryDataOut     : out std_logic;
        SerialMemoryDataControl : out std_logic;
        SerialMemoryClk         : out std_logic;
        Exp0SerialSelect        : out std_logic;
        Exp1SerialSelect        : out std_logic;
        Exp2SerialSelect        : out std_logic;
        Exp3SerialSelect        : out std_logic;
        EEPROMAccessFlag        : out std_logic;
        M_SPROM_CLK             : out std_logic;
        M_SPROM_DATA            : inout std_logic
    );
    end component;

    -- Signals
    signal SysReset, H1_CLK, SysClk, SlowEnable, SerialMemXfaceWrite, SerialMemoryDataIn : std_logic;
	signal SerialMemoryDataOut, SerialMemoryDataControl, SerialMemoryClk : std_logic;
    signal intDATA, serialMemDataOut : std_logic_vector(31 downto 0);
    signal Exp0SerialSelect, Exp1SerialSelect, Exp2SerialSelect, Exp3SerialSelect : std_logic;
    signal EEPROMAccessFlag, M_SPROM_CLK, M_SPROM_DATA : std_logic;

begin

    -- Instantiate the SerialMemoryInterface component
    DUT : SerialMemoryInterface
    port map (
        SysReset => SysReset,
        H1_CLK => H1_CLK,
        SysClk => SysClk,
        SlowEnable => SlowEnable,
        intDATA => intDATA,
        serialMemDataOut => serialMemDataOut,
        SerialMemXfaceWrite => SerialMemXfaceWrite,
        SerialMemoryDataIn => SerialMemoryDataIn,
        SerialMemoryDataOut => SerialMemoryDataOut,
        SerialMemoryDataControl => SerialMemoryDataControl,
        SerialMemoryClk => SerialMemoryClk,
        Exp0SerialSelect => Exp0SerialSelect,
        Exp1SerialSelect => Exp1SerialSelect,
        Exp2SerialSelect => Exp2SerialSelect,
        Exp3SerialSelect => Exp3SerialSelect,
        EEPROMAccessFlag => EEPROMAccessFlag,
        M_SPROM_CLK => M_SPROM_CLK,
        M_SPROM_DATA => M_SPROM_DATA
    );

    -- Stimulus process
    process
    begin
        -- Initialize inputs
        SysReset <= '1';
        H1_CLK <= '0';
        SysClk <= '0';
        SlowEnable <= '0';
        intDATA <= (others => '0');
        SerialMemXfaceWrite <= '0';
        SerialMemoryDataIn <= '0';

        -- Wait for reset to complete
        wait for 10 ns;
        SysReset <= '0';

        -- Test scenario 1: Write operation
        -- Write data 32'hABCD1234 to the EEPROM
        SerialMemXfaceWrite <= '1';
        intDATA <= "10101011110011010001001000110100";
        wait for 10 ns;
        SerialMemXfaceWrite <= '0';
        wait for 20 ns;

        -- Test scenario 2: Read operation
        -- Read data from the EEPROM
        SerialMemXfaceWrite <= '0';
        wait for 10 ns;
        wait for 20 ns;

        -- Test scenario 3: Write and Read operations
        -- Write data 32'h87654321 to the EEPROM
        SerialMemXfaceWrite <= '1';
        intDATA <= "10000111011001010000110000100001";
        wait for 10 ns;
        SerialMemXfaceWrite <= '0';
        wait for 20 ns;
        -- Read data from the EEPROM
        SerialMemXfaceWrite <= '0';
        wait for 10 ns;
        wait for 20 ns;

        -- Test scenario 4: Write and Read with different data
        -- Write data 32'h55AAFF00 to the EEPROM
        SerialMemXfaceWrite <= '1';
        intDATA <= "01010101101010101111111100000000";
        wait for 10 ns;
        SerialMemXfaceWrite <= '0';
        wait for 20 ns;
        -- Read data from the EEPROM
        SerialMemXfaceWrite <= '0';
        wait for 10 ns;
        wait for 20 ns;

		-- Test scenario 5: Continuous Write and Read operations
		-- Perform multiple write and read operations
		for i in 0 to 9 loop
			-- Write data i to the EEPROM
			SerialMemXfaceWrite <= '1';
			intDATA <= std_logic_vector(unsigned(to_unsigned(i, intDATA'length)));
			wait for 10 ns;
			SerialMemXfaceWrite <= '0';
			wait for 20 ns;
			-- Read data from the EEPROM
			SerialMemXfaceWrite <= '0';
			wait for 10 ns;
			wait for 20 ns;
		end loop;


        -- Additional test scenarios here...

        -- End simulation
        wait;
    end process;

end tb_arch;


