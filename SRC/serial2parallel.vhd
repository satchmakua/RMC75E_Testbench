--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		Serial2Parallel
--	File			serial2parallel.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- The Serial2Parallel module serves as a serial-to-parallel converter 
	-- and data distributor for various input signals.
	-- The module takes serial input data and converts it into parallel
	-- format for multiple output channels based on the control signals.

	-- Architecture:

	-- The architecture of the Serial2Parallel module, named Serial2Parallel_arch, consists of internal
	-- signals and a process block for data conversion and distribution.

	-- Internal Signals:
	-- S2P_M0Ch0_Data: Sixteen-bit data for Module 0, Channel 0.
	-- S2P_M0Ch1_Data: Sixteen-bit data for Module 0, Channel 1.
	-- S2P_M1Ch0_Data: Sixteen-bit data for Module 1, Channel 0.
	-- S2P_M1Ch1_Data: Sixteen-bit data for Module 1, Channel 1.
	-- S2P_M2Ch0_Data: Sixteen-bit data for Module 2, Channel 0.
	-- S2P_M2Ch1_Data: Sixteen-bit data for Module 2, Channel 1.
	-- S2P_M3Ch0_Data: Sixteen-bit data for Module 3, Channel 0.
	-- S2P_M3Ch1_Data: Sixteen-bit data for Module 3, Channel 1.
	-- S2P_CtrlAxis0_Data: Sixteen-bit data for Control Axis 0.
	-- S2P_CtrlAxis1_Data: Sixteen-bit data for Control Axis 1.
	
	-- The Serial2Parallel module includes a process block that performs
	-- the following operations based on the rising edge of the SysClk signal:

	-- When SynchedTick or Serial2ParallelCLR is high, indicating a reset condition, all internal data registers are cleared to 0.

	-- When Serial2ParallelEN is high, the module enables the data conversion and distribution process.
	-- The input data is shifted into the respective internal data registers for each output channel,
	-- expanding the serial input data into 16-bit parallel words.

	-- The S2P_Data output is determined based on the S2P_Addr input.
	-- The selected output channel's data is assigned to the S2P_Data output.

	-- The Serial2Parallel module provides the functionality of converting serial input data into
	-- parallel format and distributing it to the appropriate output channels based on control signals.
	-- This module facilitates efficient data handling and distribution within the RMC75E modular motion controller.

--	Revision: 1.1
--
--	File history:
--		Rev 1.1 : 06/06/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity Serial2Parallel is
	port (
		SysClk				: in std_logic; 											-- 30MHz system clock signal
		SynchedTick			: in std_logic; 										-- The synchronized tick signal
		CtrlAxisData		: in std_logic_vector (1 downto 0); -- Two-bit control axis data input
		ExpA_DATA			: in std_logic_vector (7 downto 0); 	-- Eight-bit data input for expansion module A
		Serial2ParallelEN	: in std_logic;										-- The enable signal for the Serial2Parallel module
		Serial2ParallelCLR	: in std_logic;									-- The clear signal for resetting the internal data registers
		S2P_Addr			: in std_logic_vector (3 downto 0); 	-- Four-bit address input for selecting the output channel
		S2P_Data			: out std_logic_vector (15 downto 0) 	-- Sixteen-bit parallel data output
	);
end Serial2Parallel;

architecture Serial2Parallel_arch of Serial2Parallel is

	signal	S2P_M0Ch0_Data,
			S2P_M0Ch1_Data,
			S2P_M1Ch0_Data,
			S2P_M1Ch1_Data,
			S2P_M2Ch0_Data,
			S2P_M2Ch1_Data,
			S2P_M3Ch0_Data,
			S2P_M3Ch1_Data,
			S2P_CtrlAxis0_Data,
			S2P_CtrlAxis1_Data	: std_logic_vector (15 downto 0);	-- := X"0000";

begin

	-- The shift register to converts incoming data from serial to parallel.
	-- This S2P converter will convert eight serial bit streams into 
	-- 16-bit parallel words. 
	
	S2P_Data(15 downto 0) <=	S2P_CtrlAxis0_Data(15 downto 0) when S2P_Addr(3 downto 0) = X"0" else
								S2P_CtrlAxis1_Data(15 downto 0) when S2P_Addr(3 downto 0) = X"1" else
								S2P_M0Ch0_Data(15 downto 0) when S2P_Addr(3 downto 0)= X"2" else
								S2P_M0Ch1_Data(15 downto 0) when S2P_Addr(3 downto 0)= X"3" else
								S2P_M1Ch0_Data(15 downto 0) when S2P_Addr(3 downto 0)= X"4" else
								S2P_M1Ch1_Data(15 downto 0) when S2P_Addr(3 downto 0)= X"5" else
								S2P_M2Ch0_Data(15 downto 0) when S2P_Addr(3 downto 0)= X"6" else
								S2P_M2Ch1_Data(15 downto 0) when S2P_Addr(3 downto 0)= X"7" else
								S2P_M3Ch0_Data(15 downto 0) when S2P_Addr(3 downto 0)= X"8" else
								S2P_M3Ch1_Data(15 downto 0);

	process (SysClk)
	begin
		if rising_edge(SysClk) then
			if (SynchedTick = '1' or Serial2ParallelCLR = '1') then
				S2P_CtrlAxis0_Data(15 downto 0) <= X"0000";
				S2P_CtrlAxis1_Data(15 downto 0) <= X"0000";
				S2P_M0Ch0_Data (15 downto 0) <= X"0000";
				S2P_M0Ch1_Data (15 downto 0) <= X"0000";
				S2P_M1Ch0_Data (15 downto 0) <= X"0000";
				S2P_M1Ch1_Data (15 downto 0) <= X"0000";
				S2P_M2Ch0_Data (15 downto 0) <= X"0000";
				S2P_M2Ch1_Data (15 downto 0) <= X"0000";
				S2P_M3Ch0_Data (15 downto 0) <= X"0000";
				S2P_M3Ch1_Data (15 downto 0) <= X"0000";

			elsif Serial2ParallelEN = '1' then
				S2P_CtrlAxis0_Data(15 downto 0) <= S2P_CtrlAxis0_Data(14 downto 0) & CtrlAxisData(0);
				S2P_CtrlAxis1_Data(15 downto 0) <= S2P_CtrlAxis1_Data(14 downto 0) & CtrlAxisData(1);

				S2P_M0Ch0_Data(15 downto 0) <= S2P_M0Ch0_Data(14 downto 0) & ExpA_DATA(0); 
				S2P_M0Ch1_Data(15 downto 0) <= S2P_M0Ch1_Data(14 downto 0) & ExpA_DATA(1); 

				S2P_M1Ch0_Data(15 downto 0) <= S2P_M1Ch0_Data(14 downto 0) & ExpA_DATA(2); 
				S2P_M1Ch1_Data(15 downto 0) <= S2P_M1Ch1_Data(14 downto 0) & ExpA_DATA(3); 

				S2P_M2Ch0_Data(15 downto 0) <= S2P_M2Ch0_Data(14 downto 0) & ExpA_DATA(4); 
				S2P_M2Ch1_Data(15 downto 0) <= S2P_M2Ch1_Data(14 downto 0) & ExpA_DATA(5); 

				S2P_M3Ch0_Data(15 downto 0) <= S2P_M3Ch0_Data(14 downto 0) & ExpA_DATA(6); 
				S2P_M3Ch1_Data(15 downto 0) <= S2P_M3Ch1_Data(14 downto 0) & ExpA_DATA(7); 
			end if;
		end if;
	end process;

end Serial2Parallel_arch;