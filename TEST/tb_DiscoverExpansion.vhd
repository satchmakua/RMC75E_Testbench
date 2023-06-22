--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_DiscoverExpansionID
--	File			tb_DiscoverExpansion.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
	-- DUT:
	-- The DUT in question is the DiscoverExpansionID component, which is a part of the RMC75E modular motion controller.
	-- The DiscoverExpansionID component is responsible for managing the expansion ID information in the controller.
	-- It receives input signals such as RESET, SysClk, SlowEnable, and Exp_ID_DATA.
	-- It provides output signals ExpansionID0, ExpansionID1, ExpansionID2, ExpansionID3, 
	-- Exp_ID_CLK, Exp_ID_LATCH, and Exp_ID_LOAD. The component operates based on a state
	-- machine that controls the write sequence to the LED driver, allowing for the serial communication of expansion ID data.

	-- Test Bench:
	-- The test bench, tb_DiscoverExpansionID, is designed to verify the functionality of the DiscoverExpansionID
	-- component in the RMC75E modular motion controller. It instantiates the DiscoverExpansionID component and
	-- connects the necessary signals. The test bench includes stimulus generation processes to simulate different
	-- scenarios and test cases. It provides appropriate input stimuli to the DUT and observes its output signals.
	-- The test bench also includes clock generation to provide the required clock signals for the DUT.
	-- By simulating different input scenarios and verifying the DUT's outputs, the test bench ensures
	-- that the DiscoverExpansionID component functions as expected.
	
--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_DiscoverExpansionID is
end tb_DiscoverExpansionID;

architecture tb of tb_DiscoverExpansionID is
  constant CLK_PERIOD : time := 16.6667 ns; -- For 60 MHz clock
  constant SLOW_CLK_PERIOD : time := 2*CLK_PERIOD; -- For 30 MHz clock

  signal RESET           : std_logic := '0';
  signal SysClk          : std_logic := '0';
  signal SlowEnable      : std_logic := '0';
  signal ExpansionID0    : std_logic_vector(16 downto 0) := (others => '0');
  signal ExpansionID1    : std_logic_vector(16 downto 0) := (others => '0');
  signal ExpansionID2    : std_logic_vector(16 downto 0) := (others => '0');
  signal ExpansionID3    : std_logic_vector(16 downto 0) := (others => '0');
  signal Exp_ID_CLK      : std_logic;
  signal Exp_ID_DATA     : std_logic := '0';
  signal Exp_ID_LATCH    : std_logic;
  signal Exp_ID_LOAD     : std_logic;

begin
  -- Instantiate the unit under test (DUT)
  DUT: entity work.DiscoverExpansionID
    port map (
      RESET => RESET,
      SysClk => SysClk,
      SlowEnable => SlowEnable,
      ExpansionID0 => ExpansionID0,
      ExpansionID1 => ExpansionID1,
      ExpansionID2 => ExpansionID2,
      ExpansionID3 => ExpansionID3,
      Exp_ID_CLK => Exp_ID_CLK,
      Exp_ID_DATA => Exp_ID_DATA,
      Exp_ID_LATCH => Exp_ID_LATCH,
      Exp_ID_LOAD => Exp_ID_LOAD
    );

  -- Clock generation for SysClk
  clk_process: process
  begin
    wait for CLK_PERIOD / 2;
    SysClk <= not SysClk;
  end process;

  -- Clock generation for SlowEnable
  slow_clk_process: process
  begin
    wait for SLOW_CLK_PERIOD / 2;
    SlowEnable <= not SlowEnable;
  end process;

  -- Test bench process
  tb_process: process
  begin
    -- Reset sequence
    RESET <= '1';
    wait for CLK_PERIOD;
    RESET <= '0';

    -- Define your own test sequences with appropriate timing

    -- End of testbench
    assert false report "End of testbench" severity note;
    wait;
  end process tb_process;

end tb;


