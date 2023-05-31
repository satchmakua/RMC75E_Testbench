--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_LatencyCounter
--	File			tb_LatencyCounter.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

--  The RtdExpIDLED module serves as a switch between two sets of input signals: Exp_ID_CLK, Exp_ID_LATCH,
--  Exp_ID_LOAD and ExpLEDClk, ExpLEDLatch, ExpLEDOE. The module assigns either of these signal sets to
--  Exp_Mxd_ID_CLK, Exp_Mxd_ID_LATCH, Exp_Mxd_ID_LOAD based on the DiscoveryComplete signal.
--  If DiscoveryComplete is '0', the first set is chosen, else, the second set is chosen.
	
--	his test bench covers the two possible states of DiscoveryComplete.
--	Each state is tested separately, with relevant signals set to '1' and checking if the output
--	signals match the expected values. If not, the test bench reports a failure.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_RtdExpIDLED is
end tb_RtdExpIDLED;

architecture tb of tb_RtdExpIDLED is
    signal DiscoveryComplete : std_logic := '0';
    signal Exp_ID_CLK : std_logic := '0';
    signal Exp_ID_LATCH : std_logic := '0';
    signal Exp_ID_LOAD : std_logic := '0';

    signal ExpLEDOE : std_logic := '0';
    signal ExpLEDLatch : std_logic := '0';
    signal ExpLEDClk : std_logic := '0';

    signal Exp_Mxd_ID_CLK : std_logic;
    signal Exp_Mxd_ID_LATCH : std_logic;
    signal Exp_Mxd_ID_LOAD : std_logic;

begin
    DUT: entity work.RtdExpIDLED
    port map (
        DiscoveryComplete => DiscoveryComplete,
        Exp_ID_CLK => Exp_ID_CLK,
        Exp_ID_LATCH => Exp_ID_LATCH,
        Exp_ID_LOAD => Exp_ID_LOAD,
        ExpLEDOE => ExpLEDOE,
        ExpLEDLatch => ExpLEDLatch,
        ExpLEDClk => ExpLEDClk,
        Exp_Mxd_ID_CLK => Exp_Mxd_ID_CLK,
        Exp_Mxd_ID_LATCH => Exp_Mxd_ID_LATCH,
        Exp_Mxd_ID_LOAD => Exp_Mxd_ID_LOAD
    );

    -- Test sequence
    process
    begin
        -- Test1: DiscoveryComplete='0'
        DiscoveryComplete <= '0';
        Exp_ID_CLK <= '1'; Exp_ID_LATCH <= '1'; Exp_ID_LOAD <= '1';
        wait for 20 ns;
        assert (Exp_Mxd_ID_CLK = '1' and Exp_Mxd_ID_LATCH = '1' and Exp_Mxd_ID_LOAD = '1') report "Test1 failed" severity error;
        
        -- Test2: DiscoveryComplete='1'
        DiscoveryComplete <= '1';
        ExpLEDClk <= '1'; ExpLEDLatch <= '1'; ExpLEDOE <= '1';
        wait for 20 ns;
        assert (Exp_Mxd_ID_CLK = '1' and Exp_Mxd_ID_LATCH = '1' and Exp_Mxd_ID_LOAD = '1') report "Test2 failed" severity error;
        
        -- End test sequence
        wait;
    end process;
end tb;
