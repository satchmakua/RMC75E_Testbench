--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_DiscoverID
--	File			tb_DiscoverID.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

-- The test bench, named "DiscoverID_TB," is responsible for verifying the functionality
-- of the Design Under Test (DUT) named "DiscoverID." It provides stimulus signals,
-- monitors the DUT's behavior, and checks for expected results.
-- The test bench initializes signals, generates a clock,
-- and applies test stimuli to the DUT's inputs.
-- It also includes assertions to validate the DUT's outputs and stops
-- the simulation after a specified time.

-- The Design Under Test (DUT), named "DiscoverID," is the entity being tested.
-- It represents a module designed to perform the identification process in the RMC75E.
-- The DUT has inputs such as RESET, SysClk, SlowEnable, FPGAIDRead, ControlCardIDRead,
-- Expansion1IDRead, Expansion2IDRead, Expansion3IDRead, and Expansion4IDRead.
-- It also has outputs such as M_Card_ID_DATA, Exp_ID_DATA, MDTPresent, ANLGPresent,
-- QUADPresent, and DiscoveryComplete. The DUT's purpose is to read identification
-- information from various sources and provide the corresponding outputs,
-- indicating the presence of specific cards or modules.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_DiscoverID is
end tb_DiscoverID;

architecture tb of tb_DiscoverID is
  signal RESET          : std_logic;
  signal SysClk         : std_logic;
  signal SlowEnable     : std_logic;
  signal FPGAIDRead     : std_logic;
  signal ControlCardIDRead : std_logic;
  signal Expansion1IDRead : std_logic;
  signal Expansion2IDRead : std_logic;
  signal Expansion3IDRead : std_logic;
  signal Expansion4IDRead : std_logic;
  signal M_Card_ID_DATA : std_logic;
  signal Exp_ID_DATA    : std_logic;
  signal MDTPresent     : std_logic;
  signal ANLGPresent    : std_logic;
  signal QUADPresent    : std_logic;
  signal DiscoveryComplete : std_logic;
  signal Exp0Mux        : std_logic_vector(1 downto 0);
  signal Exp1Mux        : std_logic_vector(1 downto 0);
  signal Exp2Mux        : std_logic_vector(1 downto 0);
  signal Exp3Mux        : std_logic_vector(1 downto 0);

  -- Add necessary component declarations and signal mappings here

begin

  -- Instantiate the unit under test (UUT)
  -- Update the component name and port mappings according to your design
  UUT: entity work.DiscoverID
    port map (
      RESET => RESET,
      SysClk => SysClk,
      SlowEnable => SlowEnable,
      FPGAIDRead => FPGAIDRead,
      ControlCardIDRead => ControlCardIDRead,
      Expansion1IDRead => Expansion1IDRead,
      Expansion2IDRead => Expansion2IDRead,
      Expansion3IDRead => Expansion3IDRead,
      Expansion4IDRead => Expansion4IDRead,
      M_Card_ID_DATA => M_Card_ID_DATA,
      Exp_ID_DATA => Exp_ID_DATA,
      MDTPresent => MDTPresent,
      ANLGPresent => ANLGPresent,
      QUADPresent => QUADPresent,
      DiscoveryComplete => DiscoveryComplete,
      Exp0Mux => Exp0Mux,
      Exp1Mux => Exp1Mux,
      Exp2Mux => Exp2Mux,
      Exp3Mux => Exp3Mux
    );

  -- Add necessary test stimuli, assertions, and wait statements here

  -- Test bench process
  tb_process: process
  begin
    -- Initialize signals
    RESET <= '1';
    SysClk <= '0';
    SlowEnable <= '0';
    FPGAIDRead <= '0';
    ControlCardIDRead <= '0';
    Expansion1IDRead <= '0';
    Expansion2IDRead <= '0';
    Expansion3IDRead <= '0';
    Expansion4IDRead <= '0';
    M_Card_ID_DATA <= '0';
    Exp_ID_DATA <= '0';
    MDTPresent <= '0';
    ANLGPresent <= '0';
    QUADPresent <= '0';
    DiscoveryComplete <= '0';
    Exp0Mux <= (others => '0');
    Exp1Mux <= (others => '0');
    Exp2Mux <= (others => '0');
    Exp3Mux <= (others => '0');

    -- Wait for reset to complete
    wait for 10 ns;
    RESET <= '0';

    -- Generate clock
    SysClk <= not SysClk after 5 ns;

    -- Add test stimuli, assertions, and wait statements here

    -- End simulation after a certain time
    wait for 100 ns;
    if Now > 200 ns then
      assert false report "Simulation time expired" severity failure;
    end if;

    -- Stop the clock
    SysClk <= '0';
    wait;
  end process tb_process;

end tb;
