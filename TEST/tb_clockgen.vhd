--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_clock_gen
--	File			tb_clock_gen.vhd
--
--------------------------------------------------------------------------------
--
--	Description:
 
	-- This clock_gen test bench is designed to verify the functionality of the Clock_Gen module,
	-- which is responsible for generating conditioned clock signals based on raw clock inputs.
	-- The test bench instantiates the Clock_Gen module as the unit under test (UUT)
	-- and applies a sequence of test cases to simulate different scenarios.

	-- The test bench starts with a default state where the LOCK signal is expected to be '0'.
	-- It then proceeds to test various aspects of the Clock_Gen module by manipulating the input signals.
	-- The test cases include asserting and deasserting the PLL_ARST_N signal,
	-- toggling the CLK1_PAD signal, and asserting and deasserting the PLL_POWERDOWN_N signal.
	-- Each test case is followed by a delay to allow the signals to propagate and the DUT to respond.

	-- Throughout the test bench, assertions are used to check the expected behavior of the LOCK signal.
	-- If the observed behavior deviates from the expected behavior, an assertion failure is triggered,
	-- indicating a potential issue with the Clock_Gen module.
--
--	Revision: 1.1
--
--	File history:
--		Rev 1.1 : 06/13/2023 :	Added and refined test cases
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library smartfusion2;
use smartfusion2.all;

architecture test of tb_Clock_Gen is
    component Clock_Gen
        port(
            CLK1_PAD        : in  std_logic;
            PLL_ARST_N      : in  std_logic;
            PLL_POWERDOWN_N : in  std_logic;
            GL0             : out std_logic;
            GL1             : out std_logic;
            GL2             : out std_logic;
            LOCK            : out std_logic
        );
    end component;

    signal CLK1_PAD        : std_logic := '0';
    signal PLL_ARST_N      : std_logic := '0';
    signal PLL_POWERDOWN_N : std_logic := '0';
    signal GL0             : std_logic;
    signal GL1             : std_logic;
    signal GL2             : std_logic;
    signal LOCK            : std_logic;

begin
    UUT: Clock_Gen
    port map(
        CLK1_PAD        => CLK1_PAD,
        PLL_ARST_N      => PLL_ARST_N,
        PLL_POWERDOWN_N => PLL_POWERDOWN_N,
        GL0             => GL0,
        GL1             => GL1,
        GL2             => GL2,
        LOCK            => LOCK
    );

    Stimulus_Process : process
begin
    -- Test Case 1: Default state
    wait for 100 ns;
    assert LOCK = '0'
        report "Test Case 1: Lock is not '0' at start. Actual value: " & to_string(LOCK)
        severity error;

    -- Test Case 2: Assert PLL_ARST_N
    PLL_ARST_N <= '1';
    wait for 100 ns;
    assert LOCK = '0'
        report "Test Case 2: Lock is not '0' when PLL_ARST_N is asserted. Actual value: " & to_string(LOCK)
        severity error;

    -- Test Case 3: Deassert PLL_ARST_N
    PLL_ARST_N <= '0';
    wait for 100 ns;

    -- Test Case 4: Assert CLK1_PAD
    CLK1_PAD <= '1';
    wait for 100 ns;

    -- Test Case 5: Deassert CLK1_PAD
    CLK1_PAD <= '0';
    wait for 100 ns;

    -- Test Case 6: Assert PLL_POWERDOWN_N
    PLL_POWERDOWN_N <= '1';
    wait for 100 ns;
    assert LOCK = '0'
        report "Test Case 6: Lock is not '0' when PLL_POWERDOWN_N is asserted. Actual value: " & to_string(LOCK)
        severity error;

    -- Test Case 7: Deassert PLL_POWERDOWN_N
    PLL_POWERDOWN_N <= '0';
    wait for 100 ns;

    -- Additional test cases with signal toggling
    -- Test Case 8: Toggling CLK1_PAD
    CLK1_PAD <= '1';
    wait for 50 ns;
    CLK1_PAD <= '0';
    wait for 50 ns;
    CLK1_PAD <= '1';
    wait for 50 ns;

    -- Test Case 9: Toggling PLL_ARST_N and PLL_POWERDOWN_N
    PLL_ARST_N <= '1';
    PLL_POWERDOWN_N <= '1';
    wait for 50 ns;
    PLL_ARST_N <= '0';
    PLL_POWERDOWN_N <= '0';
    wait for 50 ns;

    -- Stop the simulation
    report "Simulation complete" severity note;
    wait;
end process Stimulus_Process;


end test;

