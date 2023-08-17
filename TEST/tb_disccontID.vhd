--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_DiscoverControlID
--	File					tb_disccontID.vhd	
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- This testbench provides a clock signal to DiscoverControlID and controls the RESET, SlowEnable and M_Card_ID_DATA signals.
	-- Each sequence represents a state transition in the FSM of DiscoverControlID. After the reset sequence,
	-- the SlowEnable signal is asserted and then random data is fed to the DiscoverControlID module.

	
--	Revision: 1.0
--
--	File history: 
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_DiscoverControlID is
end tb_DiscoverControlID;

architecture tb of tb_DiscoverControlID is
  constant SysClk_period : time := 33.3333 ns; -- 30 MHz clock
	constant Slow_period: time := 200 ns; -- 5 MHz slow enable

  signal RESET          : std_logic := '0';
  signal SysClk         : std_logic := '0';
  signal SlowEnable     : std_logic := '0';
  signal ControlID      : std_logic_vector(16 downto 0);
  signal M_Card_ID_CLK  : std_logic;
  signal M_Card_ID_DATA : std_logic := '0';
  signal M_Card_ID_LATCH: std_logic;
  signal M_Card_ID_LOAD : std_logic;

	begin
	
  -- Instantiate the unit under test (DUT)
  DUT: entity work.DiscoverControlID
    port map (
      RESET => RESET,
      SysClk => SysClk,
      SlowEnable => SlowEnable,
      ControlID => ControlID,
      M_Card_ID_CLK => M_Card_ID_CLK,
      M_Card_ID_DATA => M_Card_ID_DATA,
      M_Card_ID_LATCH => M_Card_ID_LATCH,
      M_Card_ID_LOAD => M_Card_ID_LOAD
    );

	SysClk_process : process
	begin
			SysClk <= '0';
			wait for SysClk_period/2;
			SysClk <= '1';
			wait for SysClk_period/2;
	end process;

	SlowEnable_process : process
	begin
			SlowEnable <= '0';
			wait for 7 * SysClk_period;
			SlowEnable <= '1';
			wait for SysClk_period;
	end process;

  -- Test bench process
  tb_process: process
  begin
			-- Reset sequence
			RESET <= '1';
			wait for 50 ns;
			RESET <= '0';
			wait for 50 ns;

			M_Card_ID_DATA <= '1';
			wait for 100 ns;
			M_Card_ID_DATA <= '0';
			wait for 100 ns;
			M_Card_ID_DATA <= '1';
			wait for 100 ns;
			M_Card_ID_DATA <= '1';
			wait for 100 ns;

			-- End of testbench
			assert false report "End of testbench" severity note;
			wait;
  end process tb_process;

end tb;


