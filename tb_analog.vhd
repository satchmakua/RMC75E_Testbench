--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_analog
--	File			tb_analog.vhd
--
--------------------------------------------------------------------------------
--
--	Description:
 
--	DUT:
	-- The DUT is the analog component of the ROMC75E source code.
	-- It represents a digital circuit that performs analog data processing.
	-- The DUT has several input and output ports, including control signals,
	-- clock signals, data signals, and various read and write signals.
	-- It includes internal components like "StateMachine," "Serial2Parallel,"
	-- and "DataBuffer" to handle different functionalities of the analog processing.

	-- Test Bench:
	-- The test bench, named "tb_analog," is responsible for verifying
	-- the functionality of the DUT. It instantiates the DUT and provides
	-- stimulus signals to simulate different scenarios and test cases.
	-- The test bench initializes the signals to default values and
	-- generates test stimuli to stimulate the DUT. It includes assertions
	-- to check the expected behavior of the DUT and reports errors if any mismatches occur.
	-- The test bench also ensures that all signals are defined after running the simulation
	-- by checking certain signals' values at the end of the simulation duration.
--
--
--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_analog is
end tb_analog;

architecture tb of tb_analog is 
    component Analog is
        port(
            SysReset            : in std_logic;
            H1_CLKWR            : in std_logic;
            SysClk              : in std_logic;
            SlowEnable          : in std_logic;
            SynchedTick         : in std_logic;
            SynchedTick60       : in std_logic;
            LoopTime            : in std_logic_vector (2 downto 0);
            AnlgDATA            : out std_logic_vector (31 downto 0);
            AnlgPositionRead0   : in std_logic;
            AnlgPositionRead1   : in std_logic;
            ExpA0ReadCh0        : in std_logic;
            ExpA0ReadCh1        : in std_logic;
            ExpA1ReadCh0        : in std_logic;
            ExpA1ReadCh1        : in std_logic;
            ExpA2ReadCh0        : in std_logic;
            ExpA2ReadCh1        : in std_logic;
            ExpA3ReadCh0        : in std_logic;
            ExpA3ReadCh1        : in std_logic;
            ExpA_CS_L           : out std_logic;
            ExpA_CLK            : out std_logic;
            CtrlAxisData        : in std_logic_vector (1 downto 0);
            ExpA_DATA           : in std_logic_vector (7 downto 0)
        );
    end component Analog;

    -- Initialize all signals
    signal SysReset            : std_logic := '0';
    signal H1_CLKWR            : std_logic := '0';
    signal SysClk              : std_logic := '0';
    signal SlowEnable          : std_logic := '0';
    signal SynchedTick         : std_logic := '0';
    signal SynchedTick60       : std_logic := '0';
    signal LoopTime            : std_logic_vector (2 downto 0) := (others => '0');
    signal AnlgDATA            : std_logic_vector (31 downto 0);
    signal AnlgPositionRead0   : std_logic := '0';
    signal AnlgPositionRead1   : std_logic := '0';
    signal ExpA0ReadCh0        : std_logic := '0';
    signal ExpA0ReadCh1        : std_logic := '0';
    signal ExpA1ReadCh0        : std_logic := '0';
    signal ExpA1ReadCh1        : std_logic := '0';
    signal ExpA2ReadCh0        : std_logic := '0';
    signal ExpA2ReadCh1        : std_logic := '0';
    signal ExpA3ReadCh0        : std_logic := '0';
    signal ExpA3ReadCh1        : std_logic := '0';
    signal ExpA_CS_L           : std_logic := '0';
    signal ExpA_CLK            : std_logic := '0';
    signal CtrlAxisData        : std_logic_vector (1 downto 0) := (others => '0');
    signal ExpA_DATA           : std_logic_vector (7 downto 0) := (others => '0');

begin 
    DUT: Analog port map(
        SysReset            => SysReset,
        H1_CLKWR            => H1_CLKWR,
        SysClk              => SysClk,
        SlowEnable          => SlowEnable,
        SynchedTick         => SynchedTick,
        SynchedTick60       => SynchedTick60,
        LoopTime            => LoopTime,
        AnlgDATA            => AnlgDATA,
        AnlgPositionRead0   => AnlgPositionRead0,
        AnlgPositionRead1   => AnlgPositionRead1,
        ExpA0ReadCh0        => ExpA0ReadCh0,
        ExpA0ReadCh1        => ExpA0ReadCh1,
        ExpA1ReadCh0        => ExpA1ReadCh0,
        ExpA1ReadCh1        => ExpA1ReadCh1,
        ExpA2ReadCh0        => ExpA2ReadCh0,
        ExpA2ReadCh1        => ExpA2ReadCh1,
        ExpA3ReadCh0        => ExpA3ReadCh0,
        ExpA3ReadCh1        => ExpA3ReadCh1,
        ExpA_CS_L           => ExpA_CS_L,
        ExpA_CLK            => ExpA_CLK,
        CtrlAxisData        => CtrlAxisData,
        ExpA_DATA           => ExpA_DATA
    );

    stimulus: process
    begin  
        -- Reset signal
        SysReset <= '1';
        wait for 10 ns;
        SysReset <= '0';
        wait for 10 ns;

        -- Enable signals
        SlowEnable <= '1';
        SynchedTick <= '1';
        SynchedTick60 <= '1';

        -- Test 1: Vary LoopTime to create different scenarios
        LoopTime <= "000";
        wait for 100 ns;
        LoopTime <= "001";
        wait for 100 ns;
        LoopTime <= "010";
        wait for 100 ns;
        LoopTime <= "011";
        wait for 100 ns;
        -- Continue for other LoopTime values
        
        -- Test 2: Additional test stimuli and assertions
        AnlgPositionRead0 <= '1';
        wait for 100 ns;
        assert (AnlgDATA = X"0000_0000") report "AnlgDATA mismatch for AnlgPositionRead0 = '1'" severity error;
        AnlgPositionRead0 <= '0';
        
        ExpA0ReadCh0 <= '1';
        wait for 100 ns;
        assert (AnlgDATA = X"0000_0000") report "AnlgDATA mismatch for ExpA0ReadCh0 = '1'" severity error;
        ExpA0ReadCh0 <= '0';
        
        -- Test 3: Ensure all signals are defined after 250 microseconds
        wait for 250 us;
        assert ExpA_CS_L'event and ExpA_CLK'event report "ExpA_CS_L and ExpA_CLK are not defined" severity error;
        
        wait;
    end process;
end tb;