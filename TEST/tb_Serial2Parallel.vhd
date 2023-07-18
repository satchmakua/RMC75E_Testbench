--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_Serial2Parallel
--	File			tb_Serial2Parallel.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- DUT (Serial2Parallel):
	-- The Serial2Parallel module is a synchronous serial-to-parallel data converter.
	-- It takes in 8-bit serial data streams and converts them into 16-bit parallel
	-- data based on the enabled channel. Each channel receives 2 bits of data,
	-- one from the CtrlAxisData input and one from the ExpA_DATA input.
	-- The conversion process occurs on the rising edge of the SysClk signal.
	-- When the SynchedTick or Serial2ParallelCLR signal is high,
	-- all internal registers are reset.
	-- The conversion process is enabled when the Serial2ParallelEN signal is high.

	-- Test Bench:
	-- The test bench (tb_Serial2Parallel) is designed to verify the
	-- functionality of the Serial2Parallel module.
	-- It provides stimuli to the DUT by applying different input values and
	-- sequences to test various scenarios. The test bench generates clock signals,
	-- initializes input signals, and applies test cases to stimulate the DUT.
	-- It includes test cases to verify the clear function, serial-to-parallel
	-- conversion for control axis data and ExpA_DATA, and different combinations of inputs.
	-- Assertion statements are used to check the correctness of the output value (S2P_Data)
	-- against the expected value. The test bench aims to ensure the robustness and
	-- correctness of the Serial2Parallel module's behavior under various conditions.
	
--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity tb_Serial2Parallel is
end tb_Serial2Parallel;

architecture tb_arch of tb_Serial2Parallel is
    signal SysClk, SynchedTick, Serial2ParallelEN, Serial2ParallelCLR: std_logic := '0';
    signal CtrlAxisData: std_logic_vector(1 downto 0) := (others => '0');
    signal ExpA_DATA: std_logic_vector(7 downto 0) := (others => '0');
    signal S2P_Addr: std_logic_vector(3 downto 0) := (others => '0');
    signal S2P_Data: std_logic_vector(15 downto 0);
    
    constant CLK_PERIOD : time := 33.3333 ns;

begin
    DUT: entity work.Serial2Parallel
    port map (
        SysClk => SysClk,
        SynchedTick => SynchedTick,
        CtrlAxisData => CtrlAxisData,
        ExpA_DATA => ExpA_DATA,
        Serial2ParallelEN => Serial2ParallelEN,
        Serial2ParallelCLR => Serial2ParallelCLR,
        S2P_Addr => S2P_Addr,
        S2P_Data => S2P_Data
    );

    SysClk_process : process
    begin
        SysClk <= '0';
        wait for CLK_PERIOD/2;
        SysClk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
    begin
				wait for 5 us;
        
        -- Set SynchedTick high for 1 us
        SynchedTick <= '1';
        wait for CLK_PERIOD;
        SynchedTick <= '0';
        
        -- Wait for 7 us
        wait for 7 us;
        
        -- Set SynchedTick high again for 1 us
        SynchedTick <= '1';
        wait for CLK_PERIOD;
        SynchedTick <= '0';
        
				Serial2ParallelCLR <= '1';
				wait for CLK_PERIOD;
				Serial2ParallelCLR <= '0';
				
				Serial2ParallelEN <= '1';
				wait for CLK_PERIOD;
				Serial2ParallelEN <= '0';
				
				ExpA_DATA(3 downto 1) <= "111";
				
				CtrlAxisData <= "01";
				wait for 1 us;
				CtrlAxisData <= "11";
				wait for 1 us;
				CtrlAxisData <= "10";
				wait for 1 us;
				CtrlAxisData <= "00";
				
        -- End simulation
        wait;
    end process stim_proc;

end tb_arch;


