--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_TickSync
--	File			tb_TickSync.vhd
--	File			tb_TickSync.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- This testbench provides a comprehensive set of tests for the TickSync module.
	-- It tests for different lengths of the LOOPTICK signal from 1 to 4 cycles,
	-- including testing the behavior of the module when a system reset (SysReset) is issued while LOOPTICK is active.
	
--	Revision: 1.2
--
--	File history:
--	Rev 1.1 : 06/12/2023 :	Added the VHDL 'report' statements to act as test labels.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_TickSync is
end tb_TickSync;

architecture testbench of tb_TickSync is
    signal SysReset, SysClk, H1_CLK, LOOPTICK: std_logic := '0';
    signal SynchedTick, SynchedTick60: std_logic := '0';
begin

    DUT: entity work.TickSync
    port map (
        SysReset => SysReset,
        SysClk => SysClk,
        H1_CLK => H1_CLK,
        LOOPTICK => LOOPTICK,
        SynchedTick => SynchedTick,
        SynchedTick60 => SynchedTick60
    );

    clk_stimulus: process
    begin
        wait for 16.6667 ns; SysClk <= not SysClk; 
    end process;
    
    clk60_stimulus: process
    begin
        wait for 8.3334 ns; H1_CLK <= not H1_CLK;
    end process;
    
	    process
    begin
        -- Reset sequence
        SysReset <= '1'; 
        LOOPTICK <= '0';
        wait for 50 ns;
        SysReset <= '0'; 
        wait for 50 ns;
        
        -- Test sequence 1: LOOPTICK pulse
        report "Test 1: LOOPTICK pulse";
        wait until rising_edge(SysClk);
        LOOPTICK <= '1';
        wait until rising_edge(SysClk);
        LOOPTICK <= '0';
        wait until rising_edge(SysClk);
        assert SynchedTick = '1' report "Test 1 failed: SynchedTick is not '1'" severity error;
        wait for 200 ns;
        
        -- Test sequence 2: Reset during LOOPTICK
        report "Test 2: Reset during LOOPTICK";
        wait until rising_edge(SysClk);
        LOOPTICK <= '1';
        wait for 20 ns; 
        SysReset <= '1';
        wait for 20 ns;
        assert SynchedTick = '0' report "Test 2 failed: SynchedTick is not '0'" severity error;
        SysReset <= '0';
        LOOPTICK <= '0';
        wait;
        
        -- New test sequence 3: Test for SynchedTick60
        report "Test 3: Testing SynchedTick60";
        wait until rising_edge(SysClk);
        LOOPTICK <= '1';
        wait until rising_edge(H1_CLK);
        LOOPTICK <= '0';
        wait until rising_edge(H1_CLK);
        wait until rising_edge(H1_CLK);
        assert SynchedTick60 = '1' report "Test 3 failed: SynchedTick60 is not '1'" severity error;
        wait;

    end process;
end testbench;



