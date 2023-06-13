--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		ExpSigRoute
--	File			ExpansionSigRoute.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		The entity "ExpSigRoute" represents a module in the source code
--		for the RMC75E modular motion controller.
--		The module is implemented in the VHDL language and is responsible
--		for routing various signals within the expansion module.
--
--	Revision: 1.1
--
--	File history:
--		Rev 1.1 : 06/01/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ExpSigRoute is
	Port ( 
		ExpMux					: in std_logic_vector (1 downto 0);
		ExpSerialSelect			: in std_logic;
		ExpLEDSelect			: in std_logic;
		ExpLEDData				: in std_logic;
		ExpData					: inout std_logic_vector (5 downto 0);
		ExpA_CS_L				: in std_logic;
		ExpA_CLK				: in std_logic;
		ExpA_DATA				: out std_logic_vector(1 downto 0);
		SerialMemoryDataIn		: out std_logic;
		SerialMemoryDataOut		: in std_logic;
		SerialMemoryDataControl	: in std_logic;
		SerialMemoryClk			: in std_logic;
		ExpD8_DataIn			: out std_logic;
		ExpD8_Clk				: in std_logic;
		ExpD8_DataOut			: in std_logic;
		ExpD8_OE				: in std_logic;
		ExpD8_Load				: in std_logic;
		ExpD8_Latch				: in std_logic;
		ExpQ1_A					: out std_logic;
		ExpQ1_B					: out std_logic;
		ExpQ1_Reg				: out std_logic;
		ExpQ1_FaultA			: out std_logic;
		ExpQ1_FaultB			: out std_logic
	);
end ExpSigRoute;

architecture ExpSigRoute_arch of ExpSigRoute is

	constant NA_Value: 	bit_vector (1 downto 0) := "00";
	constant Ax_Value: 	bit_vector (1 downto 0) := "01";
	constant D8_Value: 	bit_vector (1 downto 0) := "10";
	constant Q1_Value:	bit_vector (1 downto 0) := "11";

	constant NA:			std_logic_vector (1 downto 0) := To_StdLogicVector(NA_Value);
	constant Ax:			std_logic_vector (1 downto 0) := To_StdLogicVector(Ax_Value);
	constant D8:			std_logic_vector (1 downto 0) := To_StdLogicVector(D8_Value);
	constant Q1:			std_logic_vector (1 downto 0) := To_StdLogicVector(Q1_Value);

begin

	-- The following logic Switches the logic based upon the ExpMux settings
	-- The logic is directed either as an input or an output and logically 
	-- attached to the D8, A2/AP2 or the Q1 logic modules.

	-- If there is no valid module present then the logic is tied to '1', '0' or 'Z' as appropriate

	ExpQ1_A <= ExpData(0) when ExpMux=Q1 else '0';
	ExpQ1_B <= ExpData(1) when ExpMux=Q1 else '0';
	ExpQ1_Reg <= ExpData(2) when ExpMux=Q1 else '0';
	ExpQ1_FaultA <= ExpData(3) when ExpMux=Q1 else '0';
	ExpQ1_FaultB <= ExpData(4) when ExpMux=Q1 else '0';

	-- Analog input logic module connections
	SerialMemoryDataIn <= ExpData(1) when ExpMux=Ax and ExpSerialSelect='1' else 
								 '0' when ExpMux=NA and ExpSerialSelect='1' else 'Z';  

	ExpA_DATA(0) <= ExpData(2) when ExpMux=Ax else '0';
	ExpA_DATA(1) <= ExpData(3) when ExpMux=Ax else '0';

	-- DIO input logic module connections
	ExpD8_DataIn <= ExpData(4) when ExpMux=D8 else '0';

	-- ExpData(5 downto 0) output connections for both the AP2 and the DIO8 modules
	ExpData(0) <= 	SerialMemoryClk when ExpMux=Ax and ExpSerialSelect='1' else 
						ExpD8_Clk when ExpMux=D8 else 'Z';	-- clk

	ExpData(1) <= 	SerialMemoryDataOut when ExpMux=Ax and SerialMemoryDataControl='1' and ExpSerialSelect='1' else 
						'Z' when ExpMux=Ax and SerialMemoryDataControl='0' and ExpSerialSelect='1' else
						ExpLEDData when ExpLEDSelect='1' and ExpSerialSelect='0' and ExpMux=Ax else 
						ExpD8_DataOut when ExpMux=D8 else 'Z';	-- data

	ExpData(2) <= ExpD8_Latch when ExpMux=D8 else 'Z';

	ExpData(3) <= ExpD8_OE when ExpMux=D8 else 'Z';

	ExpData(4) <= ExpA_CS_L when ExpMux=Ax else 'Z';

	ExpData(5) <=	ExpA_CLK when ExpMux=Ax else 
					ExpD8_Load when ExpMux=D8 else 
					ExpLEDData when ExpLEDSelect='1' and ExpSerialSelect='0' and ExpMux=Q1 else 'Z';
			
end ExpSigRoute_arch;