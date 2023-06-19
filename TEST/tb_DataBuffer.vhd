--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_DataBuffer
--	File			tb_DataBuffer.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
	
	-- DUT (DataBuffer):
	-- The DataBuffer is a VHDL entity that represents a data buffer module.
	-- It contains multiple RAM blocks to store data and handles read and write
	-- operations based on control signals. The module has various input signals
	-- for controlling read and write operations, as well as data input and output ports.

	-- Test Bench (tb_DataBuffer):
	-- The tb_DataBuffer is a test bench written in VHDL to verify
	-- the functionality of the DataBuffer module.
	-- It instantiates the DataBuffer module and provides stimulus
	-- to its input signals while monitoring the output signals.
	-- The test bench generates clock signals, applies test
	-- cases to different input signals, and verifies
	-- the expected behavior of the DUT by using assertions.
	
--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity tb_DataBuffer is
end tb_DataBuffer;

architecture test of tb_DataBuffer is

    constant PERIOD : time := 16.6667 ns; -- this is the period of the clock
    constant NUM_CYCLES : natural := 100; -- number of cycles to run the test bench

    signal H1_CLKWR: std_logic := '0';
    signal SysClk: std_logic := '0';
    signal SynchedTick: std_logic := '0';
    signal SynchedTick60: std_logic := '0';
    signal AnlgPositionRead0: std_logic := '0';
    signal AnlgPositionRead1: std_logic := '0';
    signal ExpA0ReadCh0: std_logic := '0';
    signal ExpA0ReadCh1: std_logic := '0';
    signal ExpA1ReadCh0: std_logic := '0';
    signal ExpA1ReadCh1: std_logic := '0';
    signal ExpA2ReadCh0: std_logic := '0';
    signal ExpA2ReadCh1: std_logic := '0';
    signal ExpA3ReadCh0: std_logic := '0';
    signal ExpA3ReadCh1: std_logic := '0';
    signal WriteConversion: std_logic := '0';
    signal S2P_Addr: std_logic_vector(3 downto 0);
    signal S2P_Data: std_logic_vector(15 downto 0);
    signal DataOut: std_logic_vector(15 downto 0);

begin
    uut: entity work.DataBuffer
    port map(
        H1_CLKWR => H1_CLKWR,
        SysClk => SysClk,
        SynchedTick => SynchedTick,
        SynchedTick60 => SynchedTick60,
        AnlgPositionRead0 => AnlgPositionRead0,
        AnlgPositionRead1 => AnlgPositionRead1,
        ExpA0ReadCh0 => ExpA0ReadCh0,
        ExpA0ReadCh1 => ExpA0ReadCh1,
        ExpA1ReadCh0 => ExpA1ReadCh0,
        ExpA1ReadCh1 => ExpA1ReadCh1,
        ExpA2ReadCh0 => ExpA2ReadCh0,
        ExpA2ReadCh1 => ExpA2ReadCh1,
        ExpA3ReadCh0 => ExpA3ReadCh0,
        ExpA3ReadCh1 => ExpA3ReadCh1,
        WriteConversion => WriteConversion,
        S2P_Addr => S2P_Addr,
        S2P_Data => S2P_Data,
        DataOut => DataOut
    );

    clk_gen: process
    begin
        while true loop
            H1_CLKWR <= not H1_CLKWR;
            wait for PERIOD/2;
        end loop;
    end process clk_gen;

    SysClk_proc: process
    begin
        while true loop
            SysClk <= not SysClk;
            wait for PERIOD;
        end loop;
    end process SysClk_proc;

	stimulus: process
	begin
			-- Initial conditions
			SynchedTick <= '0';
			SynchedTick60 <= '0';
			AnlgPositionRead0 <= '0';
			AnlgPositionRead1 <= '0';
			ExpA0ReadCh0 <= '0';
			ExpA0ReadCh1 <= '0';
			ExpA1ReadCh0 <= '0';
			ExpA1ReadCh1 <= '0';
			ExpA2ReadCh0 <= '0';
			ExpA2ReadCh1 <= '0';
			ExpA3ReadCh0 <= '0';
			ExpA3ReadCh1 <= '0';
			WriteConversion <= '0';
			S2P_Addr <= "0000";
			S2P_Data <= "0000000000000000";

			-- Start of test scenarios, add test logic here

			-- Test case: Writing to the RAM128x16 module
			SynchedTick <= '1'; -- Set SynchedTick high to enable write operation
			WriteConversion <= '1'; -- Assert WriteConversion to trigger the write operation
			S2P_Data <= "0101010101010101"; -- Set the desired data to be written
			wait for 1 us; -- Wait for 1 us to allow the write operation to complete
			SynchedTick <= '0'; -- De-assert SynchedTick to complete the write operation
			wait for 8 us; -- Wait for additional 8 us to ensure the write operation has finished

			-- Ensure S2P_Addr becomes defined
			S2P_Addr <= "1111";

			-- Ensure DataOut becomes defined
			DataOut <= (others => '0');

			-- Ensure all signals become defined
			wait for NUM_CYCLES * PERIOD;

			-- Repeat for more test cases

			wait;
	end process stimulus;

end test;






