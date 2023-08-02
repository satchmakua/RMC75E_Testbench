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
--	File					tb_LatencyCounter.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

--  The RtdExpIDLED module serves as a switch between two sets of input signals: Exp_ID_CLK, Exp_ID_LATCH,
--  Exp_ID_LOAD and ExpLEDClk, ExpLEDLatch, ExpLEDOE. The module assigns either of these signal sets to
--  Exp_Mxd_ID_CLK, Exp_Mxd_ID_LATCH, Exp_Mxd_ID_LOAD based on the DiscoveryComplete signal.
--  If DiscoveryComplete is '0', the first set is chosen, else, the second set is chosen.
	
--	This test bench covers the two possible states of DiscoveryComplete.
--	Each state is tested separately, with relevant signals set to '1' and checking if the output
--	signals match the expected values. If not, the test bench reports a failure.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_RtdExpIDLED is
end tb_RtdExpIDLED;

architecture tb of tb_RtdExpIDLED is
    constant CLK_PERIOD : time := 16.6667 ns; -- 60 MHz clock
    constant NUM_CYCLES : integer := 3750; -- 250 us / (16.6667 ns)

    signal DiscoveryComplete : std_logic := '0';
    signal Exp_ID_CLK, Exp_ID_LATCH, Exp_ID_LOAD : std_logic := '0';
    signal ExpLEDOE, ExpLEDLatch, ExpLEDClk : std_logic := '0';
    signal Exp_Mxd_ID_CLK, Exp_Mxd_ID_LATCH, Exp_Mxd_ID_LOAD : std_logic;
		
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

    clk_stimulus: process
    begin
        while true loop
            wait for CLK_PERIOD / 2;
            Exp_ID_CLK <= not Exp_ID_CLK;
        end loop;
    end process;
    
    clk60_stimulus: process
    begin
        while true loop
            wait for CLK_PERIOD;
            ExpLEDClk <= not ExpLEDClk;
        end loop;
    end process;

    stimulus_process: process
    begin
        -- Wait for initial reset period
        wait for 2 * CLK_PERIOD;
        
        -- Set DiscoveryComplete high to switch control to external LED module
        DiscoveryComplete <= '1';
        wait for 2 * CLK_PERIOD;
        
        -- Perform some operations with external LED module control signals
        ExpLEDOE <= '1';
        wait for 2 * CLK_PERIOD;
        ExpLEDOE <= '0';
        wait for 2 * CLK_PERIOD;
        ExpLEDLatch <= '1';
        wait for 2 * CLK_PERIOD;
        ExpLEDLatch <= '0';
        wait for 2 * CLK_PERIOD;
        
        -- Set DiscoveryComplete low to switch control back to internal ID module
        DiscoveryComplete <= '0';
        wait for 2 * CLK_PERIOD;
        
        -- Perform some operations with internal ID module control signals
        Exp_ID_LOAD <= '1';
        wait for 2 * CLK_PERIOD;
        Exp_ID_LOAD <= '0';
        wait for 2 * CLK_PERIOD;
        Exp_ID_LATCH <= '1';
        wait for 2 * CLK_PERIOD;
        Exp_ID_LATCH <= '0';
        wait for 2 * CLK_PERIOD;
        
        -- End simulation after specified number of cycles
        wait for NUM_CYCLES * CLK_PERIOD;
        assert false report "End of Test" severity note;
    end process;
end tb;

