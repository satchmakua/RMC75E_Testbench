--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_MDTTopSimp_v2
--	File			tb_MDTTopSimp_v2.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

-- This module serves as the test bench for the MDTTopSimp module
-- in the RMC75E modular motion controller.
-- It provides a platform to verify the functionality of the MDTTopSimp module
-- by simulating various input scenarios and monitoring the corresponding output signals.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_MDTTopSimp_v2 is
end tb_MDTTopSimp_v2;

architecture tb of tb_MDTTopSimp_v2 is
    -- Testbench signals corresponding to the port of the device under test
    signal SysReset : std_logic;
    signal H1_CLK : std_logic;
    signal H1_CLKWR : std_logic;
    signal H1_CLK90 : std_logic;
    signal SynchedTick60 : std_logic;
    signal intDATA : std_logic_vector(31 downto 0);
    signal mdtSimpDataOut : std_logic_vector(31 downto 0);
    signal PositionRead : std_logic;
    signal StatusRead : std_logic;
    signal ParamWrite : std_logic;
    signal M_INT_CLK : std_logic;
    signal M_RET_DATA : std_logic;
    signal SSI_DATA : std_logic;
    signal SSISelect : std_logic;

    -- Clock period for the 60 MHz clock
    constant H1_CLK_period : time := 16.6667 ns;  -- 60 MHz

begin
    -- Instantiate the device under test
    DUT: entity work.MDTTopSimp
        port map (
            SysReset => SysReset,
            H1_CLK => H1_CLK,
            H1_CLKWR => H1_CLKWR,
            H1_CLK90 => H1_CLK90,
            SynchedTick60 => SynchedTick60,
            intDATA => intDATA,
            mdtSimpDataOut => mdtSimpDataOut,
            PositionRead => PositionRead,
            StatusRead => StatusRead,
            ParamWrite => ParamWrite,
            M_INT_CLK => M_INT_CLK,
            M_RET_DATA => M_RET_DATA,
            SSI_DATA => SSI_DATA,
            SSISelect => SSISelect
        );

    -- Clock process for H1_CLK and H1_CLK90
    clk_process : process
    begin
        H1_CLK <= '0';
        H1_CLK90 <= '1';
        wait for H1_CLK_period / 4;  -- 90 degree phase shift
        H1_CLK <= '1';
        H1_CLK90 <= '0';
        wait for H1_CLK_period / 4;
        H1_CLK <= '0';
        H1_CLK90 <= '1';
        wait for H1_CLK_period / 4;
        H1_CLK <= '1';
        H1_CLK90 <= '0';
        wait for H1_CLK_period / 4;
    end process clk_process;

	-- Testbench process
	testbench_process : process
	begin
		-- Initialize all signals
		SysReset <= '1';
		H1_CLKWR <= '0';
		SynchedTick60 <= '0';
		intDATA <= (others => '0');
		PositionRead <= '0';
		StatusRead <= '0';
		ParamWrite <= '0';
		M_RET_DATA <= '0';
		SSISelect <= '0';

		wait for 20 ns;
		SysReset <= '0';  -- Deassert reset

		-- Test 1: Check basic operation after reset
		assert mdtSimpDataOut = "00000000000000000000000000000000"
		report "Test 1 failed: Unexpected mdtSimpDataOut after reset" severity error;

		-- Test 2: ParamWrite operation
		ParamWrite <= '1';
		intDATA <= "00000000000000000000000000000001";
		wait for 20 ns;
		ParamWrite <= '0';
		assert mdtSimpDataOut = "00000000000000000000000000000001"
		report "Test 2 failed: ParamWrite operation didn't work correctly" severity error;

		-- Test 3: Check SSI_DATA operation
		SSI_DATA <= '1';
		wait for 20 ns;
		assert mdtSimpDataOut = "00000000000000000000000000000000"
		report "Test 3 failed: Unexpected mdtSimpDataOut with SSI_DATA '1'" severity error;

		-- Test 4: Check PositionRead operation
		PositionRead <= '1';
		wait for 20 ns;
		PositionRead <= '0';
		-- assuming that PositionRead should change mdtSimpDataOut to "00000000000000000000000000000001"
		assert mdtSimpDataOut = "00000000000000000000000000000001"
		report "Test 4 failed: PositionRead operation didn't work correctly" severity error;

		-- Test 5: Check StatusRead operation
		StatusRead <= '1';
		wait for 20 ns;
		StatusRead <= '0';
		-- assuming that StatusRead should change mdtSimpDataOut to "00000000000000000000000000000001"
		assert mdtSimpDataOut = "00000000000000000000000000000001"
		report "Test 5 failed: StatusRead operation didn't work correctly" severity error;

	end process testbench_process;
end architecture tb;
