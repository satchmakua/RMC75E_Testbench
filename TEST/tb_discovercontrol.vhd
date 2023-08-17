--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_DiscoverControl
--	File			tb_DiscoverControl.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

-- This test unit is responsible for verifying the functionality
-- of the Design Under Test (DUT) "DiscoverID." It provides stimulus signals,
-- monitors the DUT's behavior, and checks for expected results.
-- The test bench initializes signals, generates a clock,
-- and applies test stimuli to the DUT's inputs.
-- It also includes assertions to validate the DUT's outputs and stops
-- the simulation after a specified time.

-- The Design Under Test (DUT), "DiscoverID," is the entity being tested.
-- It represents a module designed to perform the identification process in the RMC75E.
-- The DUT has inputs such as RESET, SysClk, SlowEnable, FPGAIDRead, ControlCardIDRead,
-- Expansion1IDRead, Expansion2IDRead, Expansion3IDRead, and Expansion4IDRead.
-- It also has outputs such as M_Card_ID_DATA, Exp_ID_DATA, MDTPresent, ANLGPresent,
-- QUADPresent, and DiscoveryComplete. The DUT's purpose is to read identification
-- information from various sources and provide the corresponding outputs,
-- indicating the presence of specific cards or modules.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_DiscoverControl is
end tb_DiscoverControl;

architecture tb of tb_DiscoverControl is
  constant SysClk_period : time := 33.33333 ns; -- For 60 MHz clock

  signal RESET          : std_logic;
  signal SysClk         : std_logic;
  signal SlowEnable     : std_logic;
  signal FPGAIDRead     : std_logic;
  signal ControlCardIDRead : std_logic;
  signal Expansion1IDRead : std_logic;
  signal Expansion2IDRead : std_logic;
  signal Expansion3IDRead : std_logic;
  signal Expansion4IDRead : std_logic;
  signal M_Card_ID_DATA : std_logic;
  signal Exp_ID_DATA    : std_logic;
  signal MDTPresent     : std_logic;
  signal ANLGPresent    : std_logic;
  signal QUADPresent    : std_logic;
  signal DiscoveryComplete : std_logic;
  signal Exp0Mux        : std_logic_vector(1 downto 0);
  signal Exp1Mux        : std_logic_vector(1 downto 0);
  signal Exp2Mux        : std_logic_vector(1 downto 0);
  signal Exp3Mux        : std_logic_vector(1 downto 0);

	begin
  -- Instantiate the unit under test (DUT)
  DUT: entity work.DiscoverID
    port map (
      RESET => RESET,
      SysClk => SysClk,
      SlowEnable => SlowEnable,
      FPGAIDRead => FPGAIDRead,
      ControlCardIDRead => ControlCardIDRead,
      Expansion1IDRead => Expansion1IDRead,
      Expansion2IDRead => Expansion2IDRead,
      Expansion3IDRead => Expansion3IDRead,
      Expansion4IDRead => Expansion4IDRead,
      M_Card_ID_DATA => M_Card_ID_DATA,
      Exp_ID_DATA => Exp_ID_DATA,
      MDTPresent => MDTPresent,
      ANLGPresent => ANLGPresent,
      QUADPresent => QUADPresent,
      DiscoveryComplete => DiscoveryComplete,
      Exp0Mux => Exp0Mux,
      Exp1Mux => Exp1Mux,
      Exp2Mux => Exp2Mux,
      Exp3Mux => Exp3Mux
    );

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

  -- Test bench process
  tb_process: process
  begin
    -- Initialize signals
		
		Expansion1IDRead <= '0';
		Expansion2IDRead <= '0';
		Expansion3IDRead <= '0';
		Expansion4IDRead <= '0';
		FPGAIDRead <= '0';
    ControlCardIDRead <= '0';
		M_Card_ID_DATA <= '0';
		
		RESET <= '1';
		wait for 50 ns;
    RESET <= '0';
		wait for 50 ns;
		
		M_Card_ID_DATA <= '1';
		wait for 100 ns;
		M_Card_ID_DATA <= '0';
		wait for 100 ns;
		M_Card_ID_DATA <= '1';
		wait for 100 ns;
		M_Card_ID_DATA <= '1';
		wait for 100 ns;
		
		Expansion1IDRead <= '1';
		wait for 1 us;
		Expansion1IDRead <= '0';
		
		Expansion2IDRead <= '1';
		wait for 1 us;
		Expansion2IDRead <= '0';
		
		Expansion3IDRead <= '1';
		wait for 1 us;
		Expansion3IDRead <= '0';
		
		Expansion4IDRead <= '1';
		wait for 1 us;
		Expansion4IDRead <= '0';
		
    Exp0Mux <= (others => '0');
    Exp1Mux <= (others => '0');
    Exp2Mux <= (others => '0');
    Exp3Mux <= (others => '0');

    wait;
  end process tb_process;
	
	
	tb_exp_process: process
  begin
    -- Reset sequence
		Exp_ID_DATA <= '0';
		
		wait for 1 us;

    -- Test 1: Test basic operation with Exp_ID_DATA = '1'
    Exp_ID_DATA <= '1';
    wait for SysClk_period * 20; -- Wait for 20 clock cycles

    -- Test 2: Test different Exp_ID_DATA values
    Exp_ID_DATA <= '0';

    -- Test 3: Test Shift Complete
    Exp_ID_DATA <= '1';
    wait for SysClk_period * 66; -- Wait for 66 clock cycles to complete one full shift (64 + 1)

    -- Test 4: Test writing different data values
    Exp_ID_DATA <= '0';
    wait for SysClk_period * 20; -- Wait for 20 clock cycles

    Exp_ID_DATA <= '1';
    wait for SysClk_period * 20; -- Wait for 20 clock cycles

    -- End of testbench
    assert false report "End of testbench" severity note;
		
    wait;
		
  end process tb_exp_process;
end tb;

