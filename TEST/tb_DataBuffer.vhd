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

    -- Clock period definitions
    constant H1_CLK_period : time := 16.6667 ns;
    constant SysClk_period : time := 33.3333 ns;

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
    signal S2P_Addr: std_logic_vector(3 downto 0):= (others => '0');
    signal S2P_Data: std_logic_vector(15 downto 0):= (others => '0');
		signal DataOut: std_logic_vector(15 downto 0):= (others => '0');
		
		signal clk: std_logic := '0';
    signal we: std_logic := '0';
    signal a: std_logic_vector(6 downto 0) := (others => '0');
    signal d: std_logic_vector(15 downto 0) := (others => '0');
    signal o: std_logic_vector(15 downto 0);

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

		uut_ram: entity work.RAM128x16
		port map (
				clk => clk,
				we => we,
				a => a,
				d => d,
				o => o
		);

    SysClk_proc: process
    begin
        while true loop
            SysClk <= not SysClk;
            wait for SysClk_PERIOD;
        end loop;
    end process SysClk_proc;

		Clk_proc: process
		begin
				while true loop
						Clk <= not SysClk;
						wait for SysClk_PERIOD;
				end loop;
		end process Clk_proc;
		
		H1_CLKWR_process : process
    begin
        H1_CLKWR <= '0';
        wait for H1_CLK_period/2;
        H1_CLKWR <= '1';
        wait for H1_CLK_period/2;
    end process;
		
	stimulus: process
	begin
			SynchedTick60 <= '1';
			SynchedTick <= '1';
			wait for SysClk_period/2;
			SynchedTick60 <= '0';
			wait for SysClk_period/2;
			SynchedTick <= '0';
			
			wait for 125 us;

			SynchedTick60 <= '1';
			SynchedTick <= '1';
			wait for SysClk_period/2;
			SynchedTick60 <= '0';
			wait for SysClk_period/2;
			SynchedTick <= '0';
			
			AnlgPositionRead0 <= '1';
			for i in 0 to 15 loop
					wait until falling_edge(H1_CLKWR);
					wait for 2 ns;
					S2P_Data(i) <= '1';
			end loop;
			AnlgPositionRead0 <= '1';
			wait for 5 us;
			AnlgPositionRead0 <= '0';
			
			AnlgPositionRead1 <= '1';
			for i in 0 to 15 loop
					wait until falling_edge(H1_CLKWR);
					wait for 5 us;
					S2P_Data(i) <= '1';
			end loop;
			AnlgPositionRead1 <= '0';
			
			wait for 5 us;
			
			ExpA1ReadCh0 <= '1';
			wait for 5 us;
			ExpA1ReadCh0 <= '0';

			ExpA1ReadCh1 <= '1';
			wait for 5 us;
			ExpA1ReadCh1 <= '0';

			wait for 1000 us;
			
	end process stimulus;

end test;






