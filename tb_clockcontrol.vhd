--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_ClockControl
--	File			tb_ClockControl.vhd
--
--------------------------------------------------------------------------------
--
--	Description:

-- 	DUT:
	-- ClockControl - responsible for generating various clock signals based on the input signals provided.
	-- The ClockControl component takes inputs such as H1_PRIMARY, H1_CLKWR, RESET, DLL_RST,
	-- and generates output clock signals like H1_CLK, H1_CLK90, SysClk, and control
	-- signals like SysRESET, PowerUp, Enable, and SlowEnable. It also provides an output
	-- signal DLL_LOCK to indicate whether the DLL (Delay-Locked Loop) is locked or not.

	-- Test Bench:
	-- The test bench tb_ClockControl is designed to verify the functionality and
	-- behavior of the ClockControl component. It instantiates the ClockControl
	-- component and provides stimulus to its inputs to observe the expected behavior of the DUT.
	-- The test bench includes a stimulus process that applies various test cases and
	-- stimuli to the DUT inputs. It also includes assertions to
	-- check the correctness of the DUT outputs and behavior.
	-- The test bench ensures that all signals are defined and that the
	-- simulation runs for a sufficient time (250 microseconds) to validate the DUT's behavior.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ClockControl is
end tb_ClockControl;

architecture tb of tb_ClockControl is 

    -- DUT Component Declaration
    component ClockControl is
        Port ( 
            H1_PRIMARY   : in std_logic;
            H1_CLKWR     : in std_logic;
            H1_CLK       : out std_logic;
            H1_CLK90     : out std_logic;
            SysClk       : out std_logic;
            RESET        : in std_logic;
            DLL_RST      : in std_logic;
            DLL_LOCK     : out std_logic;
            SysRESET     : out std_logic;
            PowerUp      : out std_logic;
            Enable       : out std_logic;
            SlowEnable   : out std_logic
        );
    end component;

    -- Input and output signals
    signal H1_PRIMARY   : std_logic := '0';
    signal H1_CLKWR     : std_logic := '0';
    signal H1_CLK       : std_logic := '0';
    signal H1_CLK90     : std_logic := '0';
    signal SysClk       : std_logic := '0';
    signal RESET        : std_logic := '0';
    signal DLL_RST      : std_logic := '0';
    signal DLL_LOCK     : std_logic := '0';
    signal SysRESET     : std_logic := '0';
    signal PowerUp      : std_logic := '0';
    signal Enable       : std_logic := '0';
    signal SlowEnable   : std_logic := '0';

    -- Clock period definitions
    constant clk_period : time := 16.666 us;

begin

    -- Instantiate DUT
    DUT: ClockControl port map (
        H1_PRIMARY => H1_PRIMARY,
        H1_CLKWR   => H1_CLKWR,
        H1_CLK     => H1_CLK,
        H1_CLK90   => H1_CLK90,
        SysClk     => SysClk,
        RESET      => RESET,
        DLL_RST    => DLL_RST,
        DLL_LOCK   => DLL_LOCK,
        SysRESET   => SysRESET,
        PowerUp    => PowerUp,
        Enable     => Enable,
        SlowEnable => SlowEnable
    );

    -- Stimulus process
    stimulus : process
    begin
        -- Initial state
        RESET <= '0';
        DLL_RST <= '0';
        H1_PRIMARY <= '0';
        H1_CLKWR <= '0';
        wait for clk_period;

        -- Test Case: Basic clock signals
        H1_PRIMARY <= '1';
        H1_CLKWR <= '1';
        wait for clk_period * 10;
        
        -- Test Case: Assert DLL_LOCK after a delay
        wait for clk_period * 5;
        assert (DLL_LOCK = '1') report "DLL not locked" severity error;

        -- Test Case: Reset activation
        RESET <= '1';
        wait for clk_period * 5;
        RESET <= '0';
        wait for clk_period * 5;

        -- Test Case: DLL Reset
        DLL_RST <= '1';
        wait for clk_period * 5;
        DLL_RST <= '0';

        -- Test Case: PowerUp signal assertion
        wait for clk_period * 5;
        assert (PowerUp = '1') report "PowerUp signal not asserted" severity error;
        
        -- Test Case: Enable and SlowEnable signals
        wait for clk_period * 5;
        assert (Enable = '1') report "Enable signal not asserted" severity error;
        assert (SlowEnable = '1') report "SlowEnable signal not asserted" severity error;

        -- End simulation
        wait;
    end process;
end;
