--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_MDTTopSimp_v3
--	File			tb_MDTTopSimp_v3.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- This module serves as the test bench for the MDTTopSimp module (v3)
	-- in the RMC75E modular motion controller.
	-- It provides a platform to verify the functionality of the MDTTopSimp module
	-- by simulating various input scenarios and monitoring the corresponding output signals.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

entity tb_MDTTopSimp_v3 is
end tb_MDTTopSimp_v3;

architecture testbench of tb_MDTTopSimp_v3 is
  -- Component declaration for the DUT (MDTTopSimp)
  component MDTTopSimp is
    Port (
      SysReset       : in std_logic;
      H1_CLK         : in std_logic;
      H1_CLKWR       : in std_logic;
      H1_CLK90       : in std_logic;
      SynchedTick60  : in std_logic;
      intDATA        : in std_logic_vector(31 downto 0);
      mdtSimpDataOut : out std_logic_vector(31 downto 0);
      PositionRead   : in std_logic;
      StatusRead     : in std_logic;
      ParamWrite     : in std_logic;
      M_INT_CLK      : out std_logic;
      M_RET_DATA     : in std_logic;
      SSI_DATA       : out std_logic;
      SSISelect      : in std_logic
    );
  end component;

  -- Clock signals
  signal H1_CLK_tb       : std_logic := '0';
  signal H1_CLKWR_tb     : std_logic := '0';
  signal H1_CLK90_tb     : std_logic := '0';
  signal SynchedTick60_tb: std_logic := '0';

  -- Input signals
  signal SysReset_tb     : std_logic := '1';
  signal intDATA_tb      : std_logic_vector(31 downto 0) := (others => '0');
  signal PositionRead_tb : std_logic := '0';
  signal StatusRead_tb   : std_logic := '0';
  signal ParamWrite_tb   : std_logic := '0';
  signal M_RET_DATA_tb   : std_logic := '0';
  signal SSISelect_tb    : std_logic := '0';

  -- Output signals
  signal mdtSimpDataOut_tb: std_logic_vector(31 downto 0);
  signal M_INT_CLK_tb    : std_logic;
  signal SSI_DATA_tb     : std_logic;

begin
  -- Clock generator process
  process
  begin
    while now < 1000 ns loop
      H1_CLK_tb <= not H1_CLK_tb;
      H1_CLKWR_tb <= not H1_CLKWR_tb;
      H1_CLK90_tb <= not H1_CLK90_tb;
      SynchedTick60_tb <= not SynchedTick60_tb;
      wait for 10 ns;
    end loop;
  end process;

  -- Stimulus process
  process
  begin
    -- Test 1: Verify initial state after reset
    assert (mdtSimpDataOut_tb = X"00000000")
      report "Test 1 failed: mdtSimpDataOut is not initialized correctly" severity error;
    assert (M_INT_CLK_tb = '0')
      report "Test 1 failed: M_INT_CLK is not initialized correctly" severity error;
    assert (SSI_DATA_tb = '0')
      report "Test 1 failed: SSI_DATA is not initialized correctly" severity error;

    -- Test 2: Perform PositionRead operation
    PositionRead_tb <= '1';
    wait for 10 ns;
    assert (mdtSimpDataOut_tb = X"00000000")
      report "Test 2 failed: mdtSimpDataOut is incorrect for PositionRead operation" severity error;

    -- Test 3: Perform StatusRead operation
    StatusRead_tb <= '1';
    wait for 10 ns;
    assert (mdtSimpDataOut_tb = X"00000000")
      report "Test 3 failed: mdtSimpDataOut is incorrect for StatusRead operation" severity error;

    -- Test 4: Perform ParamWrite operation
    ParamWrite_tb <= '1';
    intDATA_tb <= X"ABCDEFFF";
    wait for 10 ns;
    assert (mdtSimpDataOut_tb = X"00000000")
      report "Test 4 failed: mdtSimpDataOut is incorrect for ParamWrite operation" severity error;

    -- Test 5: Verify M_INT_CLK behavior
    assert (M_INT_CLK_tb = '1')
      report "Test 5 failed: M_INT_CLK is not behaving as expected" severity error;

    -- Test 6: Verify SSI_DATA behavior
    assert (SSI_DATA_tb = '0')
      report "Test 6 failed: SSI_DATA is not behaving as expected" severity error;

    -- Test 7: Verify data validity after SetDataValid
    PositionRead_tb <= '0';
    StatusRead_tb <= '0';
    ParamWrite_tb <= '0';
    intDATA_tb <= (others => '0');
    wait for 10 ns;
    assert (mdtSimpDataOut_tb = X"00000000")
      report "Test 7 failed: mdtSimpDataOut is incorrect after SetDataValid" severity error;

    -- Test 8: Verify NoXducer status
    assert (mdtSimpDataOut_tb = X"00001000")
      report "Test 8 failed: mdtSimpDataOut is incorrect for NoXducer status" severity error;

    -- Test 9: Verify CounterOverFlow status
    assert (mdtSimpDataOut_tb = X"00000100")
      report "Test 9 failed: mdtSimpDataOut is incorrect for CounterOverFlow status" severity error;

    -- Test 10: Verify DataValid status
    assert (mdtSimpDataOut_tb = X"00000010")
      report "Test 10 failed: mdtSimpDataOut is incorrect for DataValid status" severity error;

    -- Test 11: Verify correct data output during PositionRead with SSISelect
    PositionRead_tb <= '1';
    SSISelect_tb <= '1';
    wait for 10 ns;
    assert (mdtSimpDataOut_tb = X"00000000")
      report "Test 11 failed: mdtSimpDataOut is incorrect for PositionRead with SSISelect" severity error;

    -- Test 12: Verify correct data output during StatusRead with SSISelect
    StatusRead_tb <= '1';
    SSISelect_tb <= '1';
    wait for 10 ns;
    assert (mdtSimpDataOut_tb = X"00000000")
      report "Test 12 failed: mdtSimpDataOut is incorrect for StatusRead with SSISelect" severity error;

    -- Test 13: Verify correct data output during ParamWrite with SSISelect
    ParamWrite_tb <= '1';
    intDATA_tb <= X"ABCDEFFF";
    SSISelect_tb <= '1';
    wait for 10 ns;
    assert (mdtSimpDataOut_tb = X"00000000")
      report "Test 13 failed: mdtSimpDataOut is incorrect for ParamWrite with SSISelect" severity error;

    -- Test 14: Verify correct behavior of SynchedTick60
    assert (SynchedTick60_tb = '1')
      report "Test 14 failed: SynchedTick60 is not behaving as expected" severity error;

    -- Test 15: Verify correct behavior of SysReset
    SysReset_tb <= '1';
    wait for 10 ns;
    assert (mdtSimpDataOut_tb = X"00000000")
      report "Test 15 failed: mdtSimpDataOut is incorrect after SysReset" severity error;

    -- Test 16: Verify correct behavior of M_RET_DATA
    M_RET_DATA_tb <= '1';
    wait for 10 ns;
    assert (SSI_DATA_tb = '1')
      report "Test 16 failed: SSI_DATA is incorrect for M_RET_DATA" severity error;

    -- Test 17: Verify correct behavior of H1_CLK
    assert (mdtSimpDataOut_tb = X"0000_0000")
      report "Test 17 failed: mdtSimpDataOut is incorrect for H1_CLK" severity error;

    -- Test 18: Verify correct behavior of H1_CLKWR
    assert (mdtSimpDataOut_tb = X"00000000")
      report "Test 18 failed: mdtSimpDataOut is incorrect for H1_CLKWR" severity error;

    -- Test 19: Verify correct behavior of H1_CLK90
    assert (mdtSimpDataOut_tb = X"00000000")
      report "Test 19 failed: mdtSimpDataOut is incorrect for H1_CLK90" severity error;

    -- Test 20: Verify correct behavior of all input signals
    PositionRead_tb <= '1';
    StatusRead_tb <= '1';
    ParamWrite_tb <= '1';
    intDATA_tb <= X"ABCDEFFF";
    M_RET_DATA_tb <= '1';
    SSISelect_tb <= '1';
    wait for 10 ns;
    assert (mdtSimpDataOut_tb = X"00000000")
      report "Test 20 failed: mdtSimpDataOut is incorrect for all input signals" severity error;

	-- Final check: All tests passed
    report "All tests passed" severity note;
    wait;
end process;

  -- Instantiate the DUT (MDTTopSimp)
  DUT: MDTTopSimp
    Port map (
      SysReset       => SysReset_tb,
      H1_CLK         => H1_CLK_tb,
      H1_CLKWR       => H1_CLKWR_tb,
      H1_CLK90       => H1_CLK90_tb,
      SynchedTick60  => SynchedTick60_tb,
      intDATA        => intDATA_tb,
      mdtSimpDataOut => mdtSimpDataOut_tb,
      PositionRead   => PositionRead_tb,
      StatusRead     => StatusRead_tb,
      ParamWrite     => ParamWrite_tb,
      M_INT_CLK      => M_INT_CLK_tb,
      M_RET_DATA     => M_RET_DATA_tb,
      SSI_DATA       => SSI_DATA_tb,
      SSISelect      => SSISelect_tb
    );

end testbench;
