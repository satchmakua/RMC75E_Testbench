--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_ExpModuleLED
--	File					tb_ExpModuleLED.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

		-- Testbench for the 'ExpModuleLED' component.
		-- The 'ExpModuleLED' component interfaces with an external module and controls the LED states.
		-- It processes a variety of input signals to manage the status of the LEDs, including reading 
		-- and writing operations to individual LEDs. These operations are typically used in the context of 
		-- system discovery, EEPROM access, and synchronous system ticks.

		-- The testbench stimulates the 'ExpModuleLED' by providing signals mimicking real-life scenarios,
		-- such as system reset, discovery completion, LED writes, and LED reads. Two clock processes are 
		-- defined, 'H1_CLKWR_process' and 'SysClk_process', that mimic the behavior of the actual clock
		-- signals in the system.

		-- The simulation involves providing initial states, running sequences of LED read and write operations,
		-- and checking the outputs against the expected behavior.

		-- This testbench is designed to validate the functionality of the 'ExpModuleLED' component and ensure 
		-- it behaves as expected under different conditions, providing a reliable environment to test and debug 
		-- the design.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity tb_ExpModuleLED is
end tb_ExpModuleLED;

architecture tb of tb_ExpModuleLED is

  -- Component declaration
  component ExpModuleLED is
    port (
      Reset           : in std_logic;
      H1_CLKWR        : in std_logic;
      SysClk          : in std_logic;
      SlowEnable      : in std_logic;
      SynchedTick     : in std_logic;
      intDATA         : in std_logic_vector (31 downto 0);
      expLedDataOut   : out std_logic_vector(3 downto 0);
      Exp0LEDWrite    : in std_logic;
      Exp0LED0Write   : in std_logic;
      Exp0LED1Write   : in std_logic;
      Exp0LEDRead     : in std_logic;
      Exp0LED0Read    : in std_logic;
      Exp0LED1Read    : in std_logic;
      Exp1LEDWrite    : in std_logic;
      Exp1LED0Write   : in std_logic;
      Exp1LED1Write   : in std_logic;
      Exp1LEDRead     : in std_logic;
      Exp1LED0Read    : in std_logic;
      Exp1LED1Read    : in std_logic;
      Exp2LEDWrite    : in std_logic;
      Exp2LED0Write   : in std_logic;
      Exp2LED1Write   : in std_logic;
      Exp2LEDRead     : in std_logic;
      Exp2LED0Read    : in std_logic;
      Exp2LED1Read    : in std_logic;
      Exp3LEDWrite    : in std_logic;
      Exp3LED0Write   : in std_logic;
      Exp3LED1Write   : in std_logic;
      Exp3LEDRead     : in std_logic;
      Exp3LED0Read    : in std_logic;
      Exp3LED1Read    : in std_logic;
      EEPROMAccessFlag: in std_logic;
      DiscoveryComplete: in std_logic;
      ExpLEDOE        : out std_logic;
      ExpLEDLatch     : out std_logic;
      ExpLEDClk       : out std_logic;
      ExpLEDData      : out std_logic_vector (3 downto 0);
      ExpLEDSelect    : out std_logic_vector (3 downto 0);
      ExpOldAP2       : in std_logic_vector (3 downto 0)
    );
  end component;

  -- Inputs
  signal Reset           : std_logic := '0';
  signal H1_CLKWR        : std_logic := '0';
  signal SysClk          : std_logic := '0';
  signal SlowEnable      : std_logic := '0';
  signal SynchedTick     : std_logic := '0';
  signal intDATA         : std_logic_vector (31 downto 0) := (others => '0');
  signal Exp0LEDWrite    : std_logic := '0';
  signal Exp0LED0Write   : std_logic := '0';
  signal Exp0LED1Write   : std_logic := '0';
  signal Exp0LEDRead     : std_logic := '0';
  signal Exp0LED0Read    : std_logic := '0';
  signal Exp0LED1Read    : std_logic := '0';
  signal Exp1LEDWrite    : std_logic := '0';
  signal Exp1LED0Write   : std_logic := '0';
  signal Exp1LED1Write   : std_logic := '0';
  signal Exp1LEDRead     : std_logic := '0';
  signal Exp1LED0Read    : std_logic := '0';
  signal Exp1LED1Read    : std_logic := '0';
  signal Exp2LEDWrite    : std_logic := '0';
  signal Exp2LED0Write   : std_logic := '0';
  signal Exp2LED1Write   : std_logic := '0';
  signal Exp2LEDRead     : std_logic := '0';
  signal Exp2LED0Read    : std_logic := '0';
  signal Exp2LED1Read    : std_logic := '0';
  signal Exp3LEDWrite    : std_logic := '0';
  signal Exp3LED0Write   : std_logic := '0';
  signal Exp3LED1Write   : std_logic := '0';
  signal Exp3LEDRead     : std_logic := '0';
  signal Exp3LED0Read    : std_logic := '0';
  signal Exp3LED1Read    : std_logic := '0';
  signal EEPROMAccessFlag: std_logic := '0';
  signal DiscoveryComplete: std_logic := '0';
  signal ExpOldAP2       : std_logic_vector (3 downto 0) := (others => '0');

  -- Outputs
  signal expLedDataOut   : std_logic_vector (3 downto 0);
  signal ExpLEDOE        : std_logic;
  signal ExpLEDLatch     : std_logic;
  signal ExpLEDClk       : std_logic;
  signal ExpLEDData      : std_logic_vector (3 downto 0);
  signal ExpLEDSelect    : std_logic_vector (3 downto 0);

  -- Clock period definitions
  constant SysClk_period : time := 16.6667 ns;
  constant H1_CLK_period : time := 33.3334 ns;

	begin
	
  -- Instantiate the unit under test (UUT)
  uut: ExpModuleLED port map (
    Reset           => Reset,
    H1_CLKWR        => H1_CLKWR,
    SysClk          => SysClk,
    SlowEnable      => SlowEnable,
    SynchedTick     => SynchedTick,
    intDATA         => intDATA,
    expLedDataOut   => expLedDataOut,
    Exp0LEDWrite    => Exp0LEDWrite,
    Exp0LED0Write   => Exp0LED0Write,
    Exp0LED1Write   => Exp0LED1Write,
    Exp0LEDRead     => Exp0LEDRead,
    Exp0LED0Read    => Exp0LED0Read,
    Exp0LED1Read    => Exp0LED1Read,
    Exp1LEDWrite    => Exp1LEDWrite,
    Exp1LED0Write   => Exp1LED0Write,
    Exp1LED1Write   => Exp1LED1Write,
    Exp1LEDRead     => Exp1LEDRead,
    Exp1LED0Read    => Exp1LED0Read,
    Exp1LED1Read    => Exp1LED1Read,
    Exp2LEDWrite    => Exp2LEDWrite,
    Exp2LED0Write   => Exp2LED0Write,
    Exp2LED1Write   => Exp2LED1Write,
    Exp2LEDRead     => Exp2LEDRead,
    Exp2LED0Read    => Exp2LED0Read,
    Exp2LED1Read    => Exp2LED1Read,
    Exp3LEDWrite    => Exp3LEDWrite,
    Exp3LED0Write   => Exp3LED0Write,
    Exp3LED1Write   => Exp3LED1Write,
    Exp3LEDRead     => Exp3LEDRead,
    Exp3LED0Read    => Exp3LED0Read,
    Exp3LED1Read    => Exp3LED1Read,
    EEPROMAccessFlag=> EEPROMAccessFlag,
    DiscoveryComplete=> DiscoveryComplete,
    ExpLEDOE        => ExpLEDOE,
    ExpLEDLatch     => ExpLEDLatch,
    ExpLEDClk       => ExpLEDClk,
    ExpLEDData      => ExpLEDData,
    ExpLEDSelect    => ExpLEDSelect,
    ExpOldAP2       => ExpOldAP2
  );

	-- Clock process definitions
	H1_CLKWR_process : process
	begin
			H1_CLKWR <= '0';
			wait for H1_CLK_period/2;
			H1_CLKWR <= '1';
			wait for H1_CLK_period/2;
	end process;

	SysClk_process : process
	begin
			SysClk <= '0';
			wait for SysClk_period/2;
			SysClk <= '1';
			wait for SysClk_period/2;
	end process;

	-- SlowEnable signal process definition
	SlowEnable_process : process
	begin
			SlowEnable <= '0';
			wait for 7 * SysClk_period;
			SlowEnable <= '1';
			wait for SysClk_period;
	end process;

  -- Stimulus process
  stim_proc: process
  begin
    -- Initialize inputs
    Reset <= '1';
    wait for 20 ns;
    Reset <= '0';

    -- Wait for discovery completion
    wait for 50 ns;
    DiscoveryComplete <= '1';
		
		wait for 1 us;
				
		SynchedTick <= '1';
		wait for SysClk_period;
		SynchedTick <= '0';
		
		wait for 10 us;

		SynchedTick <= '1';
		wait for SysClk_period;
		SynchedTick <= '0';
				
    -- Enable LED writes and provide data
    Exp0LEDWrite <= '1';
    Exp0LED0Write <= '1';
    Exp0LED1Write <= '1';
    Exp0LEDRead <= '0';
    Exp0LED0Read <= '0';
    Exp0LED1Read <= '0';
    intDATA <= "11001100000000000000000000000000";
    wait for 10 ns;

    Exp1LEDWrite <= '1';
    Exp1LED0Write <= '1';
    Exp1LED1Write <= '1';
    Exp1LEDRead <= '0';
    Exp1LED0Read <= '0';
    Exp1LED1Read <= '0';
    intDATA <= "11000000000000000000000000000000";
    wait for 10 ns;

    Exp2LEDWrite <= '1';
    Exp2LED0Write <= '1';
    Exp2LED1Write <= '1';
    Exp2LEDRead <= '0';
    Exp2LED0Read <= '0';
    Exp2LED1Read <= '0';
    intDATA <= "11001100000000000000000000000000";
    wait for 10 ns;

    Exp3LEDWrite <= '1';
    Exp3LED0Write <= '1';
    Exp3LED1Write <= '1';
    Exp3LEDRead <= '0';
    Exp3LED0Read <= '0';
    Exp3LED1Read <= '0';
    intDATA <= "11011000000000000000000000000000";
    wait for 10 ns;

    -- Wait for some time
    wait for 100 ns;

    -- Disable LED writes
    Exp0LEDWrite <= '0';
    Exp0LED0Write <= '0';
    Exp0LED1Write <= '0';
    Exp1LEDWrite <= '0';
    Exp1LED0Write <= '0';
    Exp1LED1Write <= '0';
    Exp2LEDWrite <= '0';
    Exp2LED0Write <= '0';
    Exp2LED1Write <= '0';
    Exp3LEDWrite <= '0';
    Exp3LED0Write <= '0';
    Exp3LED1Write <= '0';

    -- Read LED data
    Exp0LEDRead <= '1';
    Exp0LED0Read <= '1';
    Exp0LED1Read <= '1';
    Exp1LEDRead <= '1';
    Exp1LED0Read <= '1';
    Exp1LED1Read <= '1';
    Exp2LEDRead <= '1';
    Exp2LED0Read <= '1';
    Exp2LED1Read <= '1';
    Exp3LEDRead <= '1';
    Exp3LED0Read <= '1';
    Exp3LED1Read <= '1';
    wait for 10 ns;

    -- Wait for some time
    wait for 100 ns;

    -- End of simulation
    wait;
  end process;

end tb;
