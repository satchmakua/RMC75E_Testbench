--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		TickSync
--	File			ticksync.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		
--		ticksync synchronizes the incoming control loop clock tick with the internal clock to make
--		it synchronous and usable by the internal logic.
--
--		The Sync'edTick pulse is output immediately after syncing up to the incoming tick pulse
--
--	Revision: 1.2
--
--	File history:
--		Rev 1.2 : 11/15/2022 :	Added SysReset signal to initialize loop ticks low
--		Rev 1.1 : 06/03/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_TickSync is
end tb_TickSync;

architecture testbench of tb_TickSync is
    constant CLK_PERIOD : time := 16.6667 ns;
    constant NUM_CYCLES : integer := 15000; -- 250 us / (16.6667 ns)

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
        while true loop
            wait for CLK_PERIOD / 2;
            SysClk <= not SysClk;
        end loop;
    end process;
    
    clk60_stimulus: process
    begin
        while true loop
            wait for CLK_PERIOD;
            H1_CLK <= not H1_CLK;
        end loop;
    end process;
    
    stimulus_process: process
    begin
        -- Reset sequence
        SysReset <= '1'; 
        LOOPTICK <= '0';
        wait for CLK_PERIOD;
        SysReset <= '0'; 
        wait for CLK_PERIOD;
        
        -- Test sequence 1: LOOPTICK pulse
        report "Test 1: LOOPTICK pulse";
        wait until rising_edge(SysClk);
        LOOPTICK <= '1';
        wait until rising_edge(SysClk);
        LOOPTICK <= '0';
        wait until rising_edge(SysClk);
        assert SynchedTick = '1' report "Test 1 failed: SynchedTick is not '1'" severity error;
        wait for 4 * CLK_PERIOD;
        
        -- Test sequence 2: Reset during LOOPTICK
        report "Test 2: Reset during LOOPTICK";
        wait until rising_edge(SysClk);
        LOOPTICK <= '1';
        wait for CLK_PERIOD / 2; 
        SysReset <= '1';
        wait for CLK_PERIOD / 2;
        assert SynchedTick = '0' report "Test 2 failed: SynchedTick is not '0'" severity error;
        SysReset <= '0';
        LOOPTICK <= '0';
        wait;
        
        -- Test sequence 3: Testing SynchedTick60
        report "Test 3: Testing SynchedTick60";
        wait until rising_edge(SysClk);
        LOOPTICK <= '1';
        wait until rising_edge(H1_CLK);
        LOOPTICK <= '0';
        wait until rising_edge(H1_CLK);
        wait until rising_edge(H1_CLK);
        -- Modify the assertion to check SynchedTick60
        assert SynchedTick60 = '1' report "Test 3 failed: SynchedTick60 is not '1'" severity error;
        wait;
        
        -- End simulation after specified number of cycles
        wait for NUM_CYCLES * CLK_PERIOD;
        assert false report "End of Test" severity note;
    end process;
end testbench;
