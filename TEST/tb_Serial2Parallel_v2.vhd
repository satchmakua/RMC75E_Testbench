--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_Serial2Parallel_v2
--	File			tb_Serial2Parallel_v2.vhd
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
	-- The test bench (tb_Serial2Parallel_v2) is designed to verify the
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

entity tb_Serial2Parallel_v2 is
end tb_Serial2Parallel_v2;

architecture tb_arch of tb_Serial2Parallel_v2 is
    signal SysClk, SynchedTick, Serial2ParallelEN, Serial2ParallelCLR: std_logic := '0';
    signal CtrlAxisData: std_logic_vector(1 downto 0) := (others => '0');
    signal ExpA_DATA: std_logic_vector(7 downto 0) := (others => '0');
    signal S2P_Addr: std_logic_vector(3 downto 0) := (others => '0');
    signal S2P_Data: std_logic_vector(15 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;

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

    -- Clock generator process
    clk_gen_proc: process
    begin
        while now < 1000 ns loop
            SysClk <= '0';
            wait for CLK_PERIOD/2;
            SysClk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process clk_gen_proc;

    stim_proc: process
    begin
        -- Initial values
        wait for 10 ns;
        
        -- Test Clear function
        Serial2ParallelCLR <= '1';
        wait for CLK_PERIOD;
        Serial2ParallelCLR <= '0';
        
        -- Test Serial to Parallel function for Control Axis 0 and 1
        CtrlAxisData <= "10";
        Serial2ParallelEN <= '1';
        wait for CLK_PERIOD;
        
        -- Test Serial to Parallel function for all channels
        for i in 0 to 7 loop
            ExpA_DATA(i) <= '1';
            wait for CLK_PERIOD;
        end loop;
        Serial2ParallelEN <= '0';
        
        -- Test with different Control Axis data
        CtrlAxisData <= "01";
        wait for CLK_PERIOD;
        
        -- Test with different ExpA_DATA values
        ExpA_DATA <= "10101010";
        wait for CLK_PERIOD;
        
        -- Test with different S2P_Addr values
        S2P_Addr <= "1100";
        wait for CLK_PERIOD;
        
        -- Test with different combinations of inputs
        ExpA_DATA <= "01010101";
        S2P_Addr <= "0101";
        wait for CLK_PERIOD;
        
        wait;
    end process stim_proc;

    -- Assertion for expected behavior
    assert S2P_Data = "1010101010101010"
        report "Incorrect output value" severity error;

end tb_arch;

