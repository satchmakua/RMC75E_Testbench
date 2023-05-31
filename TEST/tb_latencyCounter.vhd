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

	-- The CPULED module uses a clock signal (H1_CLKWR) and a reset signal
	-- (RESET) to manage a 2-bit LED status (CPUStatusLED). This status is
	-- set based on the least significant bits of the intDATA input when
	-- CPULEDWrite is high. The LED status drives the cpuLedDataOut and
	-- CPUStatLEDDrive signals. If the LED status is "00", CPUStatLEDDrive
	-- is set to high impedance state "ZZ". Otherwise,
	-- it's set to the inverse of CPUStatusLED.

	-- This test bench first resets the module, ensuring all signals are in known states.
	-- Then, two test cases are executed. Test1 ensures that the CPUStatusLED isn't updated
	-- when CPULEDWrite is low. Test2 confirms that CPUStatusLED updates based on intDATA when
	-- CPULEDWrite is high, and that this change is reflected in cpuLedDataOut and CPUStatLEDDrive.
	
--	Revision: 1.0

--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_LatencyCounter is
end tb_LatencyCounter;

architecture tb of tb_LatencyCounter is
    signal H1_CLK : std_logic := '0';
    signal SynchedTick : std_logic := '0';
    signal latencyDataOut : std_logic_vector(31 downto 0);
    signal LatencyCounterRead : std_logic := '0';

begin
    DUT : entity work.LatencyCounter
    port map (
        H1_CLK => H1_CLK,
        SynchedTick => SynchedTick,
        latencyDataOut => latencyDataOut,
        LatencyCounterRead => LatencyCounterRead
    );

    -- Initialize latencyDataOut signal
    process
    begin
        latencyDataOut <= (others => '0');
        wait;
    end process;

    -- Test sequence
    process
    begin
        -- Reset the module
        H1_CLK <= '0';
        SynchedTick <= '0';
        LatencyCounterRead <= '0';
        wait for 10 ns;
        
        -- Test1: SynchedTick = '1', LatencyCounterRead = '0'
        SynchedTick <= '1';
        wait for 10 ns;
        assert (latencyDataOut = X"00000000") report "Test1 failed" severity error;
        
        -- Test2: SynchedTick = '0', LatencyCounterRead = '0'
        SynchedTick <= '0';
        wait for 10 ns;
        assert (latencyDataOut = X"00000001") report "Test2 failed" severity error;
        
        -- Test3: SynchedTick = '0', LatencyCounterRead = '1'
        LatencyCounterRead <= '1';
        wait for 10 ns;
        assert (latencyDataOut = X"00000001") report "Test3 failed" severity error;
	
        -- End test sequence
        wait;
    end process;

end tb;


