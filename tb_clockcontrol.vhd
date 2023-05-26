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

--	ClockControl manages different clock frequencies and outputs them with
--	different characteristics (phase lag, frequency halving).
--	It also provides additional controls and indications such
--	as reset signals, lock indications, and power-up signals.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.std_logic_unsigned.all;

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
    uut: ClockControl port map (
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

        -- Test Case: Reset activation
        RESET <= '1';
        wait for clk_period * 5;
        RESET <= '0';
        wait for clk_period * 5;

        -- Test Case: DLL Reset
        DLL_RST <= '1';
        wait for clk_period * 5;
        DLL_RST <= '0';

        -- End simulation
        wait;
    end process;
end;
