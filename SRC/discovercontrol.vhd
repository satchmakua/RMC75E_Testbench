--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		DiscoverID
--	File					discovercontrol.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

--		Overview:
--		This module is used to read the Control Module ID word
--		The Control ID is then used by the CPU and also by the FPGA to
--		dictate the transducer interface logic configuration
--		
--		Logic Description:
--		On RMC70 system power-up the Control Module ID word is serially transferred from
--		the Control Module into the FPGA for system use. This transfer only needs to happen
--		once and the data is then used until system power-down. The state-machine is treated
--		as a one-shot device in that it will begin at state zero and stop at the ending state.
--		The state machine will not leave the ending state until power is cycled on the system.
--
--	Revision: 1.9
--
--	File history:
--		Rev 1.9 : 02/28/2023 :	Set minor rev to 02
--		Rev 1.8 : 02/07/2023 :	Update major rev to 3 and minor rev to 01
--		Rev 1.7 : 12/30/2022 :	Updated minor rev to 10 (16)
--		Rev 1.6 : 11/23/2022 :	Updated minor rev to 0F (15)
--		Rev 1.5 : 11/14/2022 :	Updated minor rev to 0E (14)
--		Rev 1.4 : 11/11/2022 :	Updated minor rev to 0D (13)
--		Rev 1.3 : 11/01/2022 :	Cleaned up constants
--														Updated minor rev through 0C (12)

--		Rev 1.2 : 10/18/2022 :	Many changes throughout
--														Updated minor rev to 04 and then 05

--		Rev 1.1 : 06/10/2022 :	Updated formatting
--														Added ID vaule for Igloo2
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DiscoverID is
	Port (
		RESET				: in std_logic;
		SysClk				: in std_logic;
		SlowEnable			: in std_logic;
		discoverIdDataOut	: out std_logic_vector(31 downto 0);
		FPGAIDRead			: in std_logic;
		ControlCardIDRead	: in std_logic;
		Expansion1IDRead	: in std_logic;
		Expansion2IDRead	: in std_logic;
		Expansion3IDRead	: in std_logic;
		Expansion4IDRead	: in std_logic;
		M_Card_ID_CLK		: out std_logic;
		M_Card_ID_DATA		: in std_logic;
		M_Card_ID_LATCH		: out std_logic;
		M_Card_ID_LOAD		: out std_logic;
		Exp_ID_CLK			: out std_logic;
		Exp_ID_DATA			: in std_logic;
		Exp_ID_LATCH		: out std_logic;
		Exp_ID_LOAD			: out std_logic;
		Exp0Mux				: out std_logic_vector (1 downto 0);
		Exp1Mux				: out std_logic_vector (1 downto 0);
		Exp2Mux				: out std_logic_vector (1 downto 0);
		Exp3Mux				: out std_logic_vector (1 downto 0);
		MDTPresent			: out std_logic;
		ANLGPresent			: out std_logic;
		QUADPresent			: out std_logic;
		DiscoveryComplete	: out std_logic;
		ExpOldAP2			: out std_logic_vector (3 downto 0);
		ENET_Build			: out std_logic
	);
end DiscoverID;

architecture DiscoverID_arch of DiscoverID is

	component DiscoverControlID is
		Port (
			RESET			: in std_logic;
			SysClk			: in std_logic;
			SlowEnable		: in std_logic;
			ControlID		: inout std_logic_vector(16 downto 0);
			M_Card_ID_CLK	: out std_logic;
			M_Card_ID_DATA	: in std_logic;
			M_Card_ID_LATCH	: out std_logic;
			M_Card_ID_LOAD	: out std_logic
		);
	end component;

	component DiscoverExpansionID is
		Port (
			RESET			: in std_logic;
			SysClk			: in std_logic;
			SlowEnable		: in std_logic;
			ExpansionID0	: inout std_logic_vector(16 downto 0);
			ExpansionID1	: inout std_logic_vector(16 downto 0);
			ExpansionID2	: inout std_logic_vector(16 downto 0);
			ExpansionID3	: inout std_logic_vector(16 downto 0);
			Exp_ID_CLK		: out std_logic;
			Exp_ID_DATA		: in std_logic;
			Exp_ID_LATCH	: out std_logic;
			Exp_ID_LOAD		: out std_logic
		);
	end component;


-- FPGA Major Value == 02
-- Full Support for -MA1, MA2, -AA1, -AA2 and -AP2 modules

-- FPGA ID Value == 02 & FPGA Major Value == 02 FPGA Minor Value == 00
-- Ported the FPGA from the XC2S100E to the XC2S150E
-- Full support for the -AP2 modules has been reinstated and -A2 support has been added

-- FPGA ID Value == 02 & FPGA Major Value == 02 FPGA Minor Value == 01
-- Fixed a bug w/Serial Memory Interface

-- FPGA ID Value == 02 & FPGA Major Value == 02 FPGA Minor Value == 02
-- Corrected handling of Exp70-AP2 Rev 1.0 LEDs' & 

-- FPGA ID Value == 02 & FPGA Major Value == 02 FPGA Minor Value == 03
-- Corrected swapping of the input enable and output bit swapping on -D8 module

-- FPGA ID Value == 02 & FPGA Major Value == 02 FPGA Minor Value == 04
-- Corrected the CPUConfig register write inhibit caused by ~DRV_DIS == 0

-- FPGA ID Value == 02/03 & FPGA Major Value == 02 FPGA Minor Value == 05
-- Incorporated support for the Exp70-Q1 modules

-- FPGA ID Value == 02/03 & FPGA Major Value == 02 FPGA Minor Value == 06
-- Fixed bug in which there was a 1/30,000 chance of the Loop Tick
-- corrupting the HomeLatch signal and breaking the homing sequence

-- FPGA ID Value == 02/03 & FPGA Major Value == 02 Minor Value == 07
-- corrected analog sampling time for 250us loop times

-- FPGA ID Value == 02/03 & FPGA Major Value == 02 Minor Value == 08
-- corrected the SSI 375KHz output clock frequency

-- FPGA ID Value == 02/03 & FPGA Major Value == 02 Minor Value == 09
-- The PROFIBUS slave address logic was left out of the RMC75S/P build
-- This logic has been replaced

-- FPGA ID Value == 02/03 & FPGA Major Value == 02 Minor Value == 0a
-- The broken wire detection logic was sampling the line_low too soon
-- This has been changed to 1 bit time.

-- FPGA ID Value == 02/03 & FPGA Major Value == 02 Minor Value == 0b
-- The WDT is completely disabled if a system RESET occurs

-- FPGA ID Value == 03(Enet) & FPGA Major Value == 02, Minor Value == 00
-- Ported design to Spartan 6 and modified numerous asynchronous resets and eliminated S/P support

-- FPGA ID Value == 04 (Rev 2.0 board w/Spartan 6) FPGA Major Value == 02, Minor Value == 01
-- Found a problem where the pull-down resistor was too strong for the EEPROM on the Expansion bus 
-- analog modules. This was changed to a pull-up on ExpData[1] only. ExpD[0], ExpD[2:5] are still pull-downs.

-- FPGA ID Value == 04 (Rev 2.0 board w/Spartan 6) FPGA Major Value == 02, Minor Value == 02
-- modified the logic so the LED's on the control board and the expansion boards are disabled until the
-- state-machines which write to them are filled with a good value

-- FPGA ID Value == 05 (Rev 3.0 board w/Igloo2) FPGA Major Value == 02, Minor Value == 03
-- ported design to Igloo2. Added resets to some state machinges.

-- Mior Rev set to 04 for programming test verification.

-- Mior Rev set to 05 for WDT changes.

-- Minor Rev set to 07 for additional WDT changes

-- Minor Rev set to 08 for MDT interface timing violations fix

-- Minor Rev set to 09 for addition of a Read/Write register at address x007 for CPU to use to verify FPGA
--  is present and programmed.

-- Minor Rev set to 0A for bug fix in rev 09

-- Minor Rev set to 0B for addition of PowerUpDetect

-- Minor Rev set to 0C for adding initial condition to Axis and Expansion module ID control signals

-- Minor Rev set to 0D for adding reset to MDT interface to start state machine at state 0

-- Minor Rev set to 0E for refactoring SSI interface. Add more signals to reset in MDT. Add SysReset to TickSync.

-- Minor Rev set to 0F for adding reset to Analog interface

-- Minor Rev set to 0x10 for converting unused address lines to debug test points (For PCB rev 3.1)

-- Major rev set to 3 to indicate release version for PCB rev 3.1
-- Minor rev reset to 0

-- Minor rev set to 1 for reverting to previous analog interface without reset on state machine

-- Minor rev set to 2 for adding Reset to Serial Memory interface

	constant FPGA_CONST		: std_logic_vector(7 downto 0) := x"a5";
	constant FPGA_Major_Rev	: std_logic_vector(7 downto 0) := x"03";  -- Release for 75E PCB rev 3.1
	constant FPGA_Minor_Rev	: std_logic_vector(7 downto 0) := x"02";

-- The FPGA ID value is translated into a Rev letter such as
-- 01 = A, 02 = B, 03 = C, etc.
-- The RMC70S and RMC70P use rev letter 'B' (02)
-- The RMC70E board rev 1.4 and lower uses Rev letter 'C' (03)
-- The RMC70E board rev 2.x uses Rev letter 'D' (04)
-- The RMC75E board rev 3.x uses Rev letter 'E' (05)

	constant FPGA_ID		: std_logic_vector(7 downto 0) := x"05";   

	constant AP2			: std_logic_vector(7 downto 0) := x"40";

	constant A2				: std_logic_vector(7 downto 0) := x"41";

	constant DIO8			: std_logic_vector(7 downto 0) := x"42";

	constant Q1				: std_logic_vector(7 downto 0) := x"44";

	constant MDT1			: std_logic_vector(7 downto 0) := x"20";
	constant MDT2			: std_logic_vector(7 downto 0) := x"21";

	constant QUAD1			: std_logic_vector(7 downto 0) := x"22";
	constant QUAD2			: std_logic_vector(7 downto 0) := x"23";

	constant ANLG1			: std_logic_vector(7 downto 0) := x"24";
	constant ANLG2			: std_logic_vector(7 downto 0) := x"25";

	constant ENET			: std_logic_vector(7 downto 0) := x"03";

	-- Signal Declarations
	signal	ExpansionID0,
			ExpansionID1	: std_logic_vector (16 downto 0);	-- := "00000000000000000";
	signal	ExpansionID2,
			ExpansionID3	: std_logic_vector (16 downto 0);	-- := "00000000000000000";
	signal	ControlID		: std_logic_vector (16 downto 0);	-- := "00000000000000000";
	signal	intExp0Mux,
			intExp1Mux,
			intExp2Mux,
			intExp3Mux		: std_logic_vector (1 downto 0);	-- := "00";

begin

	ENET_Build <= '1' when FPGA_ID = ENET else '0';

	DiscCtrlID_1 : DiscoverControlID
		port map (
			RESET			=> RESET,
			SysClk			=> SysClk,
			SlowEnable		=> SlowEnable,
			ControlID		=> ControlID(16 downto 0),
			M_Card_ID_CLK	=> M_Card_ID_CLK,
			M_Card_ID_DATA	=> M_Card_ID_DATA,
			M_Card_ID_LATCH	=> M_Card_ID_LATCH,
			M_Card_ID_LOAD	=> M_Card_ID_LOAD 
		);

	DiscExpID_1 : DiscoverExpansionID
		port map (
			RESET			=> RESET,
			SysClk			=> SysClk,
			SlowEnable		=> SlowEnable, 
			ExpansionID0	=> ExpansionID0(16 downto 0),
			ExpansionID1	=> ExpansionID1(16 downto 0),
			ExpansionID2	=> ExpansionID2(16 downto 0),
			ExpansionID3	=> ExpansionID3(16 downto 0),
			Exp_ID_CLK		=> Exp_ID_CLK,
			Exp_ID_DATA		=> Exp_ID_DATA,
			Exp_ID_LATCH	=> Exp_ID_LATCH,
			Exp_ID_LOAD		=> Exp_ID_LOAD
		);

	-- ControlID(16) is set when the ID read sequence from the control module is complete
	discoverIdDataOut(31 downto 0) <= FPGA_CONST & FPGA_ID & FPGA_Major_Rev & FPGA_Minor_Rev when FPGAIDRead='1' else 
									"000000000000000" & ControlID(16 downto 0) when ControlCardIDRead='1' else 
									"000000000000000" & ExpansionID0(16 downto 0) when Expansion1IDRead='1' else
									"000000000000000" & ExpansionID1(16 downto 0) when Expansion2IDRead='1' else
									"000000000000000" & ExpansionID2(16 downto 0) when Expansion3IDRead='1' else
									"000000000000000" & ExpansionID3(16 downto 0) when Expansion4IDRead='1' else
									X"0000_0000";

	intExp0Mux <= "01" when ((ExpansionID0(15 downto 8) = AP2) or (ExpansionID0(15 downto 8) = A2)) else 
					 "10" when (ExpansionID0(15 downto 8) = DIO8) else 
					 "11" when (ExpansionID0(15 downto 8) = Q1) else "00";

	intExp1Mux <= "01" when ((ExpansionID1(15 downto 8) = AP2) or (ExpansionID1(15 downto 8) = A2)) else
					 "10" when (ExpansionID1(15 downto 8) = DIO8) else 
					 "11" when (ExpansionID1(15 downto 8) = Q1) else "00";

	intExp2Mux <= "01" when ((ExpansionID2(15 downto 8) = AP2) or (ExpansionID2(15 downto 8) = A2)) else
					 "10" when (ExpansionID2(15 downto 8) = DIO8) else 
					 "11" when (ExpansionID2(15 downto 8) = Q1) else "00";

	intExp3Mux <= "01" when ((ExpansionID3(15 downto 8) = AP2) or (ExpansionID3(15 downto 8) = A2)) else
					 "10" when (ExpansionID3(15 downto 8) = DIO8) else 
					 "11" when (ExpansionID3(15 downto 8) = Q1) else "00";

	MDTPresent <= '1' when (ControlID(15 downto 8) = MDT1) or (ControlID(15 downto 8) = MDT2) else '0';
--	MDTPresent <= '1'; -- simulate the presence of an MDT module
	ANLGPresent <= '1' when (ControlID(15 downto 8) = ANLG1) or (ControlID(15 downto 8) = ANLG2) else '0';
--	ANLGPresent <= '1'; -- simulate the presence of an ANLG module
	QUADPresent <= '1' when (ControlID(15 downto 8) = QUAD1) or (ControlID(15 downto 8) = QUAD2) else '0';
--	QUADPresent <= '1'; -- simulate the presence of an QUAD module

	Exp0Mux <= intExp0Mux;
	Exp1Mux <= intExp1Mux;
	Exp2Mux <= intExp2Mux;
	Exp3Mux <= intExp3Mux;

--	Exp0Mux <= "01";	 -- simulate the presence of a -AP2 module
--	Exp1Mux <= "01";	 -- simulate the presence of a -AP2 module
--	Exp2Mux <= "01";	 -- simulate the presence of a -AP2 module
--	Exp3Mux <= "01";	 -- simulate the presence of a -AP2 module
--	Exp0Mux <= "10";	 -- simulate the presense of a -DIO8 module
--	Exp3Mux <= "10";	 -- simulate the presense of a -DIO8 module
--	Exp2Mux <= "10";	 -- simulate the presense of a -DIO8 module
--	Exp3Mux <= "10";	 -- simulate the presense of a -DIO8 module
--	Exp0Mux <= "11";	 -- simulate the presence of a -Q1 module

	ExpOldAP2(0) <= '1' when intExp0Mux="01" and ExpansionID0(3 downto 0)=X"0" else '0';
	ExpOldAP2(1) <= '1' when intExp1Mux="01" and ExpansionID1(3 downto 0)=X"0" else '0';
	ExpOldAP2(2) <= '1' when intExp2Mux="01" and ExpansionID2(3 downto 0)=X"0" else '0';
	ExpOldAP2(3) <= '1' when intExp3Mux="01" and ExpansionID3(3 downto 0)=X"0" else '0';

	-- The DiscoveryComplete line is used to control the mux for the Expansion Module LED's
	-- The lines are turned over to LED control after the discovery process is complete
	DiscoveryComplete <= '1' when ExpansionID3(16)='1' else '0';

end DiscoverID_arch;