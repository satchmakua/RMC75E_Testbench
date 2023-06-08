--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		TickSync
--	File			ticksync.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		ticksync.vhd
--		ticksync synchronizes the incoming control loop clock tick with the internal clock to make
--		it synchronous and usable by the internal logic.
--
--		The Sync'edTick pulse is output immediately after syncing up to the incoming tick pulse
--
--	Revision: 1.2
--
--	File history:
--		Rev 1.2 : 11/15/2022 :	Added SysReset signal to initialize loop ticks low
--		Rev 1.1 : 06/03/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TickSync is
	port (
		SysReset		: in std_logic;		-- Main system Reset signal
		SysClk			: in std_logic;		-- 30MHz system clock
		H1_CLK			: in std_logic;		-- 60MHz System clock
		LOOPTICK		: in std_logic;
		SynchedTick		: out std_logic;	-- Control loop timing pulse synchronized with the
											-- 30MHz system clock. Valid from rising-edge to rising-edge
		SynchedTick60	: out std_logic		-- 60MHz system clock. Valid from rising-edge to rising-edge
	);
end TickSync;

architecture ticksync_arch of TickSync is

	signal	TickSync,
			LatchedTickSync		: std_logic;	-- := '0';
	signal	TickSync60,
			LatchedTickSync60	: std_logic;	-- := '0';
begin

	-- sync up the control loop TICK with the internal clock
	process (SysClk, LOOPTICK)
	begin
		if LOOPTICK then
			TickSync <= '1';
		elsif rising_edge(SysClk) then -- Clk rising edge
			if LatchedTickSync or SysReset then
				TickSync <= '0';
			end if;
			LatchedTickSync <= TickSync and not LatchedTickSync and not SysReset;
		end if;
	end process;

	-- the signal "SynchedTick" will be used in the system to start events
	SynchedTick <= LatchedTickSync;

	-- sync up the control loop TICK with the internal clock
	process (H1_CLK, LOOPTICK)
	begin
		if LOOPTICK then
			TickSync60 <= '1';
		elsif rising_edge(H1_CLK) then -- Clk rising edge
			if LatchedTickSync60 or SysReset then
				TickSync60 <= '0';
			end if;
			LatchedTickSync60 <= TickSync60 and not LatchedTickSync60 and not SysReset;
		end if;
	end process;

	-- the signal "SynchedTick60" will be used in the MDT interface
	SynchedTick60 <= LatchedTickSync60;

end ticksync_arch;