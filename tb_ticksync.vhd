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
	
--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_TickSync is
end tb_TickSync;

architecture testbench of tb_TickSync is
    signal SysReset, SysClk, H1_CLK, LOOPTICK : std_logic := '0';
    signal SynchedTick, SynchedTick60: std_logic;
begin

    DUT: entity work.TickSync
    port map (
        SysReset => SysReset,
        SysClk => SysReset,
        H1_CLK => H1_CLK,
        LOOPTICK => LOOPTICK,
        SynchedTick => SynchedTick,
        SynchedTick60 => SynchedTick60
    );

    clk_stimulus: process
    begin
        wait for 16 ns; SysClk <= not SysClk; 
    end process;
    
    clk60_stimulus: process
    begin
        wait for 8 ns; H1_CLK <= not H1_CLK;
    end process;
    
    process
    begin
        -- Reset sequence
        SysReset <= '1'; 
        LOOPTICK <= '0';
        wait for 50 ns;
        SysReset <= '0'; 
        wait for 50 ns;
        
        -- Test sequence 1: LOOPTICK for 2 system clock cycles
        LOOPTICK <= '1';
        wait for 40 ns; 
        LOOPTICK <= '0';
        wait for 200 ns;
        
        -- Test sequence 2: LOOPTICK for 1 system clock cycle
        LOOPTICK <= '1';
        wait for 20 ns; 
        LOOPTICK <= '0';
        wait for 200 ns;
        
        -- Test sequence 3: LOOPTICK for 3 system clock cycles
        LOOPTICK <= '1';
        wait for 60 ns; 
        LOOPTICK <= '0';
        wait for 200 ns;
        
        -- Test sequence 4: LOOPTICK for 4 system clock cycles
        LOOPTICK <= '1';
        wait for 80 ns; 
        LOOPTICK <= '0';
        wait for 200 ns;
        
        -- Test sequence 5: Reset during LOOPTICK
        LOOPTICK <= '1';
        wait for 20 ns; 
        SysReset <= '1';
        wait for 20 ns;
        SysReset <= '0';
        LOOPTICK <= '0';
        wait;
    end process;
    
end testbench;
