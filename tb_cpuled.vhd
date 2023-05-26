--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		
--	File			
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- Testbench simulates the behavior of the CPULED module under different input conditions.
	-- The process block applies sequences of inputs to the CPULED module and
	-- the outputs are observed on the cpuLedDataOut and CPUStatLEDDrive signals.
	-- The clock signal (H1_CLKWR) is driven by a simple clock driver process.
	-- The testbench tests both when CPULEDWrite is asserted and not, and all the
	-- possible combinations of the intDATA bits that are used in the module.
	
--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity tb_CPULED is
end tb_CPULED;

architecture testbench of tb_CPULED is
    signal RESET, H1_CLKWR, CPULEDWrite : std_logic := '0';
    signal intDATA : std_logic_vector(31 downto 0) := (others => '0');
    signal cpuLedDataOut : std_logic_vector(31 downto 0);
    signal CPUStatLEDDrive : std_logic_vector(1 downto 0);
begin

    DUT: entity work.CPULED
    port map (
        RESET => RESET,
        H1_CLKWR => H1_CLKWR,
        intDATA => intDATA,
        cpuLedDataOut => cpuLedDataOut,
        CPULEDWrite => CPULEDWrite,
        CPUStatLEDDrive => CPUStatLEDDrive
    );

    clk_stimulus: process
    begin
        wait for 10 ns; H1_CLKWR <= not H1_CLKWR; 
    end process;
    
    process
    begin
        -- Reset sequence
        RESET <= '1'; 
        wait for 50 ns;
        RESET <= '0'; 
        wait for 50 ns;
        
        -- Test sequence 1: CPULEDWrite is 0
        CPULEDWrite <= '0';
        intDATA(1 downto 0) <= "00";
        wait for 100 ns; 

        -- Test sequence 2: CPULEDWrite is 1, intDATA is "00"
        CPULEDWrite <= '1';
        intDATA(1 downto 0) <= "00";
        wait for 100 ns;

        -- Test sequence 3: CPULEDWrite is 1, intDATA is "01"
        intDATA(1 downto 0) <= "01";
        wait for 100 ns;
        
        -- Test sequence 4: CPULEDWrite is 1, intDATA is "10"
        intDATA(1 downto 0) <= "10";
        wait for 100 ns;
        
        -- Test sequence 5: CPULEDWrite is 1, intDATA is "11"
        intDATA(1 downto 0) <= "11";
        wait for 100 ns;
        
        -- End of testbench
        assert false report "End of testbench" severity note;
        wait;
    end process;
end testbench;
