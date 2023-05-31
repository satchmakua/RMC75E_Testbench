--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		start_delay
--	File			start_delay.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		start_delay.vhd
--		module provides a delay for the start of the data capture.
--		the delay is different for 1 ms loops and 2 ms loops and the 
--		configuration is selected by signal LOOP_TIME.  
--		START_READ tells the ssi_controller to begin SSI clocking
--
--	Revision: 1.1
--
--	File history:
--		Rev 1.1 : 06/09/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity start_delay is
	port (
		SysClk				: in std_logic;							-- 30MHz system clock
		SlowEnable			: in std_logic;							-- 3.75MHz system enable (active every 8th 30MHz clock)
		SynchedTick			: in std_logic;							-- Control loop tick valid on rising edge of 30MHz clock
		SSISelect			: in std_logic;
		DelayTerminalCount	: in std_logic_vector (15 downto 0);
		StartRead			: out std_logic							-- Start the SSI clock output/data input 
	);
end start_delay;

architecture start_delay_arch of start_delay is

	signal	DelayCntEn			: std_logic;	-- := '0';
	signal	DelayCounter		: std_logic_vector (15 downto 0);	-- := X"0000";
	signal	StartRead_Int		: std_logic;	-- := '0';

begin

	process (SysClk)
	begin
		if rising_edge(SysClk) then
			-- Enable the dealy counter with loop tick and disable it when SSI read cycle starts
			DelayCntEn <= (DelayCntEn and (not StartRead_Int)) or (SynchedTick and SSISelect);
			-- Reset the delay counter with loop tick or as soon as the counter expires
			if (DelayCounter = DelayTerminalCount) or (SynchedTick = '1') then
				DelayCounter <= X"0000"; 
			elsif DelayCntEn and SlowEnable then
				DelayCounter <= DelayCounter + '1';
			end if;
			-- Generate a pulse to start the SSI read cycle when the delay timer expires.
			if DelayCounter = DelayTerminalCount then
				StartRead_Int <= '1';
			else
				StartRead_Int <= '0';
			end if;
		end if;
	end process;

	StartRead <= StartRead_Int;

end start_delay_arch;
