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

	 -- Testbench simulates the behavior of the CPUConfig module under different input conditions.
	 -- The process block applies sequences of inputs to the CPUConfig module and
	 -- the outputs are observed on the cpuConfigDataOut, M_DRV_EN_L, DLL_RST, and LoopTime signals.
	 -- The clock signals (H1_CLKWR and H1_PRIMARY) are driven by a simple clock driver process.
	 
--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity tb_CPUConfig is
end tb_CPUConfig;

architecture testbench of tb_CPUConfig is
    constant H1_PRIMARY_clk_period : time := 16.6667 ns; 
    constant num_cycles : integer := 15_000; 
    
    signal RESET, SysRESET, H1_CLKWR, H1_PRIMARY, CPUConfigWrite, HALT_DRIVE_L, DLL_LOCK, ENET_Build : std_logic := '0';
    signal intDATA : std_logic_vector(31 downto 0) := (others => '0');
    signal cpuConfigDataOut : std_logic_vector(31 downto 0);
    signal M_DRV_EN_L, DLL_RST : std_logic;
    signal LoopTime : std_logic_vector(2 downto 0);
begin

    DUT: entity work.CPUConfig
    port map (
        RESET => RESET,
        SysRESET => SysRESET,
        H1_CLKWR => H1_CLKWR,
        H1_PRIMARY => H1_PRIMARY,
        intDATA => intDATA,
        cpuConfigDataOut => cpuConfigDataOut,
        CPUConfigWrite => CPUConfigWrite,
        M_DRV_EN_L => M_DRV_EN_L,
        HALT_DRIVE_L => HALT_DRIVE_L,
        DLL_LOCK => DLL_LOCK,
        DLL_RST => DLL_RST,
        LoopTime => LoopTime,
        ENET_Build => ENET_Build
    );

    clk_stimulus: process
    begin
        wait for H1_PRIMARY_clk_period / 2; H1_CLKWR <= not H1_CLKWR; 
        wait for H1_PRIMARY_clk_period / 2; H1_PRIMARY <= not H1_PRIMARY; 
    end process;
    
    process
    begin
        -- Reset sequence
        RESET <= '1'; 
        wait for H1_PRIMARY_clk_period;
        RESET <= '0'; 
        wait for H1_PRIMARY_clk_period;

        for i in 1 to num_cycles loop
            -- Test sequence 1: CPUConfigWrite is 0
            CPUConfigWrite <= '0';
            HALT_DRIVE_L <= '0';
            intDATA <= (others => '0');
            wait for H1_PRIMARY_clk_period * 6; 

            -- Test sequence 2: CPUConfigWrite is 1, intDATA is "000.."
            CPUConfigWrite <= '1';
            HALT_DRIVE_L <= '1';
            intDATA(6 downto 0) <= "0010000";
            wait for H1_PRIMARY_clk_period * 6;

            -- Test sequence 3: CPUConfigWrite is 1, intDATA is "000.."
            intDATA(6 downto 0) <= "0100000";
            wait for H1_PRIMARY_clk_period * 6;
            
            -- Test sequence 4: CPUConfigWrite is 1, intDATA is "000.."
            intDATA(6 downto 0) <= "1000000";
            wait for H1_PRIMARY_clk_period * 6;
            
            -- Test sequence 5: CPUConfigWrite is 1, intDATA is "000.."
            intDATA(6 downto 0) <= "1110000";
            wait for H1_PRIMARY_clk_period * 6;
        end loop;
        
        -- End of testbench
        assert false report "End of testbench" severity note;
        wait;
    end process;
end testbench;

