--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_StateMachine
--	File			tb_StateMachine.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- Test Bench (tb_StateMachine):

	-- The test bench (tb_StateMachine) is responsible for verifying the functionality
	-- of the StateMachine design under different test scenarios. It initializes the input signals,
	-- applies various test cases to the DUT (StateMachine), and performs assertions
	-- to validate the correctness of the output signals. The test bench includes
	-- multiple test cases that cover different aspects of the StateMachine's behavior,
	-- such as basic functionality, state transitions, loop time changes, and combinations of inputs.
	-- It also includes assertions to check the values of theoutput signals and report
	-- errors if any mismatches are detected.

	-- DUT (StateMachine):

	-- The DUT (StateMachine) is a design that implements a state machine controlling
	-- the sampling of data from an A2D converter. It operates by taking four samples:
	-- two samples from channel 0 and two samples from channel 1. The spacing between
	-- sample groups is controlled by the LoopTime signal. The StateMachine design
	-- ensures synchronized sampling and handles state transitions based on various input signals.
	-- It generates output signals, including ExpA_CS_L, ExpA_CLK, Serial2ParallelEN, Serial2ParallelCLR,
	-- and WriteConversion, to control the A2D converter and communicate the conversion results.
	-- The DUT's functionality is verified by the test bench through various test cases and assertions.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_StateMachine is
end tb_StateMachine;

architecture tb_arch of tb_StateMachine is
    -- Component declaration
    component StateMachine is
        port (
            -- Input signals
            SysReset            : in std_logic;
            SysClk              : in std_logic;
            SlowEnable          : in std_logic;
            SynchedTick         : in std_logic;
            LoopTime            : in std_logic_vector(2 downto 0);
            -- Output signals
            ExpA_CS_L           : out std_logic;
            ExpA_CLK            : out std_logic;
            Serial2ParallelEN   : out std_logic;
            Serial2ParallelCLR  : out std_logic;
            WriteConversion     : out std_logic
        );
    end component;

    -- Signal declarations
    signal SysReset_tb         : std_logic := '0';
    signal SysClk_tb           : std_logic := '0';
    signal SlowEnable_tb       : std_logic := '0';
    signal SynchedTick_tb      : std_logic := '0';
    signal LoopTime_tb         : std_logic_vector(2 downto 0) := "000";
    signal ExpA_CS_L_tb        : std_logic;
    signal ExpA_CLK_tb         : std_logic;
    signal Serial2ParallelEN_tb: std_logic;
    signal Serial2ParallelCLR_tb: std_logic;
    signal WriteConversion_tb  : std_logic;

begin
    -- Instantiate the DUT
    dut: StateMachine
    port map (
        SysReset            => SysReset_tb,
        SysClk              => SysClk_tb,
        SlowEnable          => SlowEnable_tb,
        SynchedTick         => SynchedTick_tb,
        LoopTime            => LoopTime_tb,
        ExpA_CS_L           => ExpA_CS_L_tb,
        ExpA_CLK            => ExpA_CLK_tb,
        Serial2ParallelEN   => Serial2ParallelEN_tb,
        Serial2ParallelCLR  => Serial2ParallelCLR_tb,
        WriteConversion     => WriteConversion_tb
    );

    -- Clock generation process
    clk_proc : process
    begin
        while true loop
            wait for 16.67 ns;  -- half of the 30MHz clock period
            SysClk_tb <= not SysClk_tb;
        end loop;
    end process clk_proc;

    -- Stimulus process
	stim_proc: process
	begin
		-- Initialize signals
		SysReset_tb <= '1';
		wait for 33.33 ns;  -- wait for one clock cycle
		SysReset_tb <= '0';

		-- Test case 1: Basic functionality
		wait for 33.33 ns;
		SysClk_tb <= not SysClk_tb;

		-- Test case 2: Enable every 8th system clock
		SlowEnable_tb <= '1';
		for i in 1 to 8 loop
			wait for 33.33 ns;
			SysClk_tb <= not SysClk_tb;
		end loop;
		SlowEnable_tb <= '0';

		-- Test case 3: Change loop time
		wait for 33.33 ns;
		LoopTime_tb <= "001"; -- 250us loop time
		wait for 33.33 ns;
		SynchedTick_tb <= '1';
		wait for 33.33 ns;
		SynchedTick_tb <= '0';

		-- Test case 4: State transitions and output signals
		wait for 33.33 ns;
		SynchedTick_tb <= '1';
		wait for 33.33 ns;
		LoopTime_tb <= "100"; -- 2ms loop time
		wait for 33.33 ns;
		SynchedTick_tb <= '0';
		wait for 33.33 ns;
		SynchedTick_tb <= '1';

		-- Test case 5: Reset signal
		wait for 33.33 ns;
		SysReset_tb <= '1';
		wait for 33.33 ns;
		SysReset_tb <= '0';

		-- Test case 6: Combination of inputs
		wait for 33.33 ns;
		SlowEnable_tb <= '1';
		wait for 33.33 ns;
		SynchedTick_tb <= '1';
		wait for 33.33 ns;
		LoopTime_tb <= "101"; -- 4ms loop time
		wait for 33.33 ns;
		SynchedTick_tb <= '0';
		wait for 33.33 ns;
		SynchedTick_tb <= '1';
		wait for 33.33 ns;
		LoopTime_tb <= "010"; -- 500us loop time
		wait for 33.33 ns;
		SynchedTick_tb <= '0';
		wait for 33.33 ns;
		SlowEnable_tb <= '0';

		-- End simulation
		wait;
	end process stim_proc;

	-- Assertion process
	assert_proc: process
	begin
		-- Test case 1: Basic functionality
		wait for 66.67 ns;
		assert ExpA_CS_L_tb = '1' report "Error: ExpA_CS_L_tb is not '1'" severity error;
		assert ExpA_CLK_tb = '1' report "Error: ExpA_CLK_tb is not '1'" severity error;
		-- Add rest of the assertions for test case 1 here

		-- Test case 2: Enable every 8th system clock
		wait for 8 * 33.33 ns;
		assert ExpA_CS_L_tb = '1' report "Error: ExpA_CS_L_tb is not '1'" severity error;
		-- Add rest of the assertions for test case 2 here

		-- Test case 3: Change loop time
		wait for 66.67 ns;
		assert ExpA_CS_L_tb = '1' report "Error: ExpA_CS_L_tb is not '1'" severity error;
		-- Add rest of the assertions for test case 3 here

		-- Test case 4: State transitions and output signals
		wait for 132.67 ns;
		assert ExpA_CS_L_tb = '1' report "Error: ExpA_CS_L_tb is not '1'" severity error;
		-- Add rest of the assertions for test case 4 here

		-- Test case 5: Reset signal
		wait for 66.67 ns;
		assert ExpA_CS_L_tb = '1' report "Error: ExpA_CS_L_tb is not '1'" severity error;
		-- Add rest of the assertions for test case 5 here

		-- Test case 6: Combination of inputs
		wait for 8 * 33.33 ns;
		assert ExpA_CS_L_tb = '1' report "Error: ExpA_CS_L_tb is not '1'" severity error;
		-- Add rest of the assertions for test case 6 here

		-- End simulation
		wait;
	end process assert_proc;
end architecture tb_arch;

