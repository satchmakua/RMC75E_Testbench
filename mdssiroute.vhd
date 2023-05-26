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
--	File			mdtssiroute.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		MDT/SSI Routing
--
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
		SSISelect		: in std_logic_vector (1 downto 0);
		M_AX0_INT_CLK	: out std_logic;
		M_AX1_INT_CLK	: out std_logic;
		M_AX0_SSI_CLK	: in std_logic;
		M_AX1_SSI_CLK	: in std_logic;
		M_AX0_MDT_INT	: in std_logic; 
		M_AX1_MDT_INT	: in std_logic 
	);
end MDTSSIRoute;

architecture MDTSSIRoute_arch of MDTSSIRoute is

begin

	M_AX0_INT_CLK <= M_AX0_MDT_INT when SSISelect(0)='0' else M_AX0_SSI_CLK;  
	M_AX1_INT_CLK <= M_AX1_MDT_INT when SSISelect(1)='0' else M_AX1_SSI_CLK;  

end MDTSSIRoute_arch;