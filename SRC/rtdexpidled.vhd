--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name			RtdExpIDLED
--	File						rtdexpidled.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- This module reroutes control of the CLK, LATCH, and LOAD lines for 
	-- the Expansion modules. The control lines are first used to capture
	-- the ID of the modules and are then used to control the LED colors
	-- of the modules.

	-- The process of reading the ID's is known as discovery. Hence, the
	-- signal used to switch control to the LED's is called "DiscoveryComplete".
		
	-- It serves as a multiplexer and control logic for selecting and controlling
	-- the clock, latch, and load signals for an external LED module based on the state of the DiscoveryComplete signal.

	-- Components:

	-- Architecture:
	-- The architecture of the RtdExpIDLED module, named RtdExpIDLED_arch, consists of a process block
	-- that controls the selection of clock, latch, and load signals based on the state of the DiscoveryComplete
	-- signal and the signals from the external LED module.

	-- During the process, if the DiscoveryComplete signal is low (0), indicating that the device
	-- discovery process is not yet complete, the internal ID signals (Exp_ID_CLK, Exp_ID_LATCH, Exp_ID_LOAD)
	-- are selected and assigned to the corresponding output signals (Exp_Mxd_ID_CLK, Exp_Mxd_ID_LATCH, Exp_Mxd_ID_LOAD).

	-- However, if the DiscoveryComplete signal is high (1), indicating that the device discovery process is complete,
	-- the signals from the external LED module (ExpLEDClk, ExpLEDLatch, ExpLEDOE) are selected and assigned to the
	-- corresponding output signals (Exp_Mxd_ID_CLK, Exp_Mxd_ID_LATCH, Exp_Mxd_ID_LOAD).

	-- The RtdExpIDLED module provides the necessary logic to control the selection of clock, latch,
	-- and load signals based on the state of the DiscoveryComplete signal, allowing seamless integration
	-- of the external LED module into the RMC75E modular motion controller.

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
	 	DiscoveryComplete	: in std_logic; -- A control signal indicating the completion of the device discovery process
		Exp_ID_CLK			: in std_logic; -- The clock signal for the internal ID module
		Exp_ID_LATCH		: in std_logic; -- The latch signal for the internal ID module
		Exp_ID_LOAD			: in std_logic; -- The load signal for the internal ID module

		ExpLEDOE			: in std_logic; -- The output enable signal from the external LED module
		ExpLEDLatch			: in std_logic; -- The latch signal from the external LED module
		ExpLEDClk			: in std_logic; -- The clock signal from the external LED module

		Exp_Mxd_ID_CLK		: out std_logic; -- The selected clock signal for the ID module
		Exp_Mxd_ID_LATCH	: out std_logic; -- The selected latch signal for the ID module
		Exp_Mxd_ID_LOAD		: out std_logic	 -- The selected load signal for the ID module
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