--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		MDTSSIRoute
--	File					mdtssiroute.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

--	MDT/SSI Routing

	-- The MDTSSIRoute module describes the interface and
	-- behavior of a routing module for the Magnetostrictive Displacement Transducer (MDT) and
	-- Synchronous Serial Interface (SSI) clocks in the RMC75E modular motion controller.
	-- The module takes input signals related to the SSI select, internal MDT clock,
	-- SSI clock, and MDT interrupt, and provides output signals for the internal clocks of Axis0 and Axis1.

	-- The purpose of the MDTSSIRoute module is to control the routing of clock signals
	-- for the MDT and SSI based on the SSI select signal. It selects either the MDT internal
	-- clock or the SSI clock for each axis based on the value of the SSI select signal.
	
	-- The architecture MDTSSIRoute_arch describes the internal implementation of the MDTSSIRoute module.
	-- It includes two assignments that control the routing of clock signals based on the SSI select signal.

	-- M_AX0_INT_CLK is assigned the value of M_AX0_MDT_INT when SSISelect(0) is '0',
	-- indicating that the MDT internal clock is selected for Axis0. Otherwise,
	-- it is assigned the value of M_AX0_SSI_CLK, indicating that the SSI clock is selected.
	-- M_AX1_INT_CLK follows a similar assignment logic as M_AX0_INT_CLK, but for Axis1.
	-- Overall, the MDTSSIRoute module provides the functionality to select the appropriate
	-- clock source for each axis based on the SSI select signal. It enables the routing of
	-- clock signals between the MDT internal clock and the SSI clock, allowing flexible control
	-- over the timing and synchronization of operations within the modular motion controller.
	
--	Revision: 1.1
--
--	File history:
--		Rev 1.1 : 06/02/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity MDTSSIRoute is
	port (
		SSISelect		: in std_logic_vector (1 downto 0); -- 2-bit signal that selects the clock source for each axis
		M_AX0_INT_CLK	: out std_logic; -- '00' selects the MDT internal clock, and '01' selects the SSI clock
		M_AX1_INT_CLK	: out std_logic; -- Output internal clock signal for Axis0
		M_AX0_SSI_CLK	: in std_logic; -- Input SSI clock signal for Axis0
		M_AX1_SSI_CLK	: in std_logic; -- Input SSI clock signal for Axis1
		M_AX0_MDT_INT	: in std_logic; -- Input MDT interrupt signal for Axis0
		M_AX1_MDT_INT	: in std_logic 	-- Input MDT interrupt signal for Axis1
	);
end MDTSSIRoute;

architecture MDTSSIRoute_arch of MDTSSIRoute is

begin

	M_AX0_INT_CLK <= M_AX0_MDT_INT when SSISelect(0)='0' else M_AX0_SSI_CLK;  
	M_AX1_INT_CLK <= M_AX1_MDT_INT when SSISelect(1)='0' else M_AX1_SSI_CLK;  

end MDTSSIRoute_arch;
