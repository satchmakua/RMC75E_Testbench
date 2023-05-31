--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		RtdExpIDLED
--	File			rtdexpidled.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		This module reroutes control of the CLK, LATCH, and LOAD lines for 
--		the Expansion modules. The control lines are first used to capture
--		the ID of the modules and are then used to control the LED colors
--		of the modules.
--
--		The process of reading the ID's is known as discovery. Hence, the
--		signal used to switch control to the LED's is called "DiscoveryComplete"
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

entity RtdExpIDLED is
	Port ( 
	 	DiscoveryComplete	: in std_logic;
		Exp_ID_CLK			: in std_logic;
		Exp_ID_LATCH		: in std_logic;
		Exp_ID_LOAD			: in std_logic;

		ExpLEDOE			: in std_logic;
		ExpLEDLatch			: in std_logic;
		ExpLEDClk			: in std_logic;

		Exp_Mxd_ID_CLK		: out std_logic;
		Exp_Mxd_ID_LATCH	: out std_logic;
		Exp_Mxd_ID_LOAD		: out std_logic
	);
end RtdExpIDLED;

architecture RtdExpIDLED_arch of RtdExpIDLED is

	begin

	process(DiscoveryComplete, Exp_ID_CLK, Exp_ID_LATCH, Exp_ID_LOAD, ExpLEDClk, ExpLEDLatch, ExpLEDOE)
	begin
		if DiscoveryComplete='0' then
			Exp_Mxd_ID_Clk <= Exp_ID_CLK;
			Exp_Mxd_ID_LATCH <= Exp_ID_LATCH;
			Exp_Mxd_ID_LOAD <= Exp_ID_LOAD;
		else
			Exp_Mxd_ID_Clk <= ExpLEDClk;
			Exp_Mxd_ID_LATCH <= ExpLEDLatch;
			Exp_Mxd_ID_LOAD <= ExpLEDOE;
		end if;
	end process;

end RtdExpIDLED_arch;