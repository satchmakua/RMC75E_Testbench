--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		LatencyCounter
--	File			LatencyCounter.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		
--
--	Revision: 1.1
--
--	File history:
--		Rev 1.1 : 06/02/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LatencyCounter is
	Port (
		H1_CLK				: in std_logic;
		SynchedTick			: in std_logic;
		latencyDataOut		: out std_logic_vector (31 downto 0);
		LatencyCounterRead	: in std_logic
	);
end LatencyCounter;

architecture LT_ARCH of LatencyCounter is

	signal LatencyCounter : std_logic_vector (31 downto 0);	-- := X"00000000";

begin

	latencyDataOut(31 downto 0) <= LatencyCounter(31 downto 0); 

	process(H1_CLK)
	begin
		if falling_edge(H1_CLK) then
			if SynchedTick = '1' then
			LatencyCounter(31 downto 0) <= X"00000000";
			elsif LatencyCounterRead = '0' then
			LatencyCounter(31 downto 0) <= LatencyCounter(31 downto 0) + '1';
			end if;
		end if;
	end process;


end LT_ARCH;
