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
--		
--
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
		SysClk				: in std_logic;
		SynchedTick			: in std_logic;
		CtrlAxisData		: in std_logic_vector (1 downto 0);
		ExpA_DATA			: in std_logic_vector (7 downto 0);
		Serial2ParallelEN	: in std_logic;
		Serial2ParallelCLR	: in std_logic;
		S2P_Addr			: in std_logic_vector (3 downto 0);
		S2P_Data			: out std_logic_vector (15 downto 0)
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