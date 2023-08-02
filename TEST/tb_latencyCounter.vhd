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
--	File					tb_LatencyCounter.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- tb_LatencyCounter is designed to verify the functionality of the LatencyCounter module.
	-- The test bench generates a 60MHz clock signal and control signals for the module and checks the module's 
	-- output against expected results. Two test cases are designed where the SynchedTick signal sends a single 
	-- 30MHz pulse at 1us and 8us after the LatencyCounterRead signal transitions from high to low after 33.3333 ns.
	-- The functionality of the LatencyCounter module is deemed correct if it produces the expected output after 
	-- receiving these signals.

--	Revision: 1.0

--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_LatencyCounter is
end tb_LatencyCounter;

architecture tb of tb_LatencyCounter is

  -- Component declaration
  component LatencyCounter is
    port (
      H1_CLK            : in std_logic;
      SynchedTick       : in std_logic;
      latencyDataOut    : out std_logic_vector(31 downto 0);
      LatencyCounterRead: in std_logic
    );
  end component;

  -- Clock signal
  signal H1_CLK      : std_logic := '0';
  constant H1_CLK_period: time := 16.6667 ns;  -- 60MHz clock period

  -- Other signals
  signal SynchedTick       : std_logic := '0';
  signal LatencyCounterRead: std_logic := '1'; -- Starts high
  signal latencyDataOut    : std_logic_vector(31 downto 0);

begin

  -- Instantiate the unit under test
  uut: LatencyCounter
    port map (
      H1_CLK            => H1_CLK,
      SynchedTick       => SynchedTick,
      latencyDataOut    => latencyDataOut,
      LatencyCounterRead=> LatencyCounterRead
    );

  -- Clock process
  process
  begin
    while true loop
      H1_CLK <= '0';
      wait for H1_CLK_period / 2;
      H1_CLK <= '1';
      wait for H1_CLK_period / 2;
    end loop;
  end process;

  -- Stimulus process
  process
  begin
    -- Initialize signals
    SynchedTick <= '0';
    
    -- Wait for initial stabilization
    wait for H1_CLK_period;

    -- Make LatencyCounterRead transition from high to low
    wait for 33.3333 ns;
    LatencyCounterRead <= '0';

    -- Test case 1
    wait for 1 us - 33.3333 ns;
    SynchedTick <= '1'; -- 30MHz pulse
    wait for 33.3333 ns; -- 30MHz pulse width
    SynchedTick <= '0';
    
    -- Test case 2
    wait for 8 us - 33.3333 ns;
    SynchedTick <= '1'; -- 30MHz pulse
    wait for 33.3333 ns; -- 30MHz pulse width
    SynchedTick <= '0';

    -- Test case 3 - Verify data output
    wait for H1_CLK_period;
    assert latencyDataOut = X"00000001"
      report "Test case failed: Incorrect data output."
      severity error;

    -- End the simulation
    wait;
  end process;

end tb;




