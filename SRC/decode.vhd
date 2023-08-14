--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		Decode
--	File					decode.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		decode generates the WRITE control lines and READ control lines
--
--	Revision: 1.2
--
--	File history:
--		Rev 1.2 : 10/27/2022 :	- Added register at address 007 for CPU to write and read
--								 						in order to detect FPGA exists and is programmed

--														- Removed unnecessary Bit Vector constants

--		Rev 1.1 : 05/30/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Decode is
	port (
		ADDR					: in std_logic_vector (11 downto 0);
		RD_L					: in std_logic;
		WR_L					: in std_logic;
		CS_L					: in std_logic;
		MDTPresent				: in std_logic;
		ANLGPresent				: in std_logic;
		QUADPresent				: in std_logic;
		Exp0Mux					: in std_logic_vector (1 downto 0);
		Exp1Mux					: in std_logic_vector (1 downto 0);
		Exp2Mux					: in std_logic_vector (1 downto 0);
		Exp3Mux					: in std_logic_vector (1 downto 0);
		FPGAAccess				: out std_logic;
		ANLGAccess				: out std_logic;
		FPGAIDRead				: out std_logic;
		CPUConfigRead			: out std_logic;
		CPUConfigWrite			: out std_logic;
		WDTConfigRead			: out std_logic;
		WDTConfigWrite			: out std_logic;
		CPULEDRead				: out std_logic;
		CPULEDWrite				: out std_logic;
		FPGAProgrammedRead		: out std_logic;
		FPGAProgrammedWrite		: out std_logic;
		ControlCardIDRead		: out std_logic;
		Expansion1IDRead		: out std_logic;
		Expansion2IDRead		: out std_logic;
		Expansion3IDRead		: out std_logic;
		Expansion4IDRead		: out std_logic;
		MDT_SSIPositionRead0	: out std_logic;
		MDT_SSIStatusRead0		: out std_logic;
		MDT_SSIConfigWrite0		: out std_logic;
		ANLGPositionRead0		: inout std_logic;
		AnlgStatusRead0			: out std_logic;
		Axis0ControlOutputWrite	: out std_logic;
		Axis0LEDStatusRead		: out std_logic;
		Axis0LEDConfigWrite		: out std_logic;
		MDT_SSIDelayRead0		: out std_logic;
		MDT_SSIDelayWrite0		: out std_logic;
		Axis0IORead				: out std_logic;
		Axis0IOWrite			: out std_logic;
		MDT_SSIPositionRead1	: out std_logic;
		MDT_SSIStatusRead1		: out std_logic;
		MDT_SSIConfigWrite1		: out std_logic;
		ANLGPositionRead1		: inout std_logic;
		AnlgStatusRead1			: out std_logic;
		Axis1ControlOutputWrite	: out std_logic;
		Axis1LEDStatusRead		: out std_logic;
		Axis1LEDConfigWrite		: out std_logic;
		MDT_SSIDelayRead1		: out std_logic;
		MDT_SSIDelayWrite1		: out std_logic;
		Axis1IORead				: out std_logic;
		Axis1IOWrite			: out std_logic;
		LatencyCounterRead		: out std_logic;
		PROFIBUSAddrRead		: out std_logic;
		SerialMemXfaceRead		: out std_logic;
		SerialMemXfaceWrite		: out std_logic;
		ExpA0ReadCh0			: inout std_logic;
		ExpA0ReadCh1			: inout std_logic;
		ExpA1ReadCh0			: inout std_logic;
		ExpA1ReadCh1			: inout std_logic;
		ExpA2ReadCh0			: inout std_logic;
		ExpA2ReadCh1			: inout std_logic;
		ExpA3ReadCh0			: inout std_logic;
		ExpA3ReadCh1			: inout std_logic;
		ExpDIO8ConfigRead		: out std_logic_vector (3 downto 0);
		ExpDIO8ConfigWrite		: out std_logic_vector (3 downto 0);
		ExpDIO8DinRead			: out std_logic_vector (3 downto 0);
		Exp0QuadCountRead		: out std_logic;
		Exp0QuadLEDStatusRead	: inout std_logic;
		Exp0QuadLEDStatusWrite	: inout std_logic;
		Exp0QuadInputRead		: out std_logic;
		Exp0QuadHomeRead		: out std_logic;
		Exp0QuadLatch0Read		: out std_logic;
		Exp0QuadLatch1Read		: out std_logic;
		Exp1QuadCountRead		: out std_logic;
		Exp1QuadLEDStatusRead	: inout std_logic;
		Exp1QuadLEDStatusWrite	: inout std_logic;
		Exp1QuadInputRead		: out std_logic;
		Exp1QuadHomeRead		: out std_logic;
		Exp1QuadLatch0Read		: out std_logic;
		Exp1QuadLatch1Read		: out std_logic;
		Exp2QuadCountRead		: out std_logic;
		Exp2QuadLEDStatusRead	: inout std_logic;
		Exp2QuadLEDStatusWrite	: inout std_logic;
		Exp2QuadInputRead		: out std_logic;
		Exp2QuadHomeRead		: out std_logic;
		Exp2QuadLatch0Read		: out std_logic;
		Exp2QuadLatch1Read		: out std_logic;
		Exp3QuadCountRead		: out std_logic;
		Exp3QuadLEDStatusRead	: inout std_logic;
		Exp3QuadLEDStatusWrite	: inout std_logic;
		Exp3QuadInputRead		: out std_logic;
		Exp3QuadHomeRead		: out std_logic;
		Exp3QuadLatch0Read		: out std_logic;
		Exp3QuadLatch1Read		: out std_logic;
		Exp0LEDWrite			: out std_logic;
		Exp0LED0Write			: out std_logic;
		Exp0LED1Write			: out std_logic;
		Exp0LEDRead				: out std_logic;
		Exp0LED0Read			: out std_logic;
		Exp0LED1Read			: out std_logic;
		Exp1LEDWrite			: out std_logic;
		Exp1LED0Write			: out std_logic;
		Exp1LED1Write			: out std_logic;
		Exp1LEDRead				: out std_logic;
		Exp1LED0Read			: out std_logic;
		Exp1LED1Read			: out std_logic;
		Exp2LEDWrite			: out std_logic;
		Exp2LED0Write			: out std_logic;
		Exp2LED1Write			: out std_logic;
		Exp2LEDRead				: out std_logic;
		Exp2LED0Read			: out std_logic;
		Exp2LED1Read			: out std_logic;
		Exp3LEDWrite			: out std_logic;
		Exp3LED0Write			: out std_logic;
		Exp3LED1Write			: out std_logic;
		Exp3LEDRead				: out std_logic;
		Exp3LED0Read			: out std_logic;
		Exp3LED1Read			: out std_logic;

		QA0CountRead			: out std_logic;
		QA0LEDStatusRead		: out std_logic;
		QA0LEDStatusWrite		: out std_logic;
		QA0InputRead			: out std_logic;
		QA0HomeRead				: out std_logic;
		QA0Latch0Read			: out std_logic;
		QA0Latch1Read			: out std_logic;

		QA1CountRead			: out std_logic;
		QA1LEDStatusRead		: out std_logic;
		QA1LEDStatusWrite		: out std_logic;
		QA1InputRead			: out std_logic;
		QA1HomeRead				: out std_logic;
		QA1Latch0Read			: out std_logic;
		QA1Latch1Read			: out std_logic

	);
end Decode;

architecture Decode_arch of Decode is

	-- The follow constants correspond to a lower portion of the
	-- address which is decoded for register reads and writes

	constant FPGAIDAddr : 					std_logic_vector(11 downto 0) := x"000";
	constant CPUConfigAddr : 				std_logic_vector(11 downto 0) := x"001";
	constant CPULEDAddr : 					std_logic_vector(11 downto 0) := x"002";
	constant WDTConfigAddr : 				std_logic_vector(11 downto 0) := x"003";
	constant PROFIBUSAddr : 				std_logic_vector(11 downto 0) := x"004";
	constant SerialMemXfaceAddr : 			std_logic_vector(11 downto 0) := x"005";

	constant ControlCardIDAddr : 			std_logic_vector(11 downto 0) := x"006";

	constant FPGAProgrammedAddr :			std_logic_vector(11 downto 0) := x"007";	--	Write and read to verify Igloo2 FPGA is programmed

	constant Expansion1IDAddr : 			std_logic_vector(11 downto 0) := x"00A";
	constant Expansion2IDAddr : 			std_logic_vector(11 downto 0) := x"00B";
	constant Expansion3IDAddr : 			std_logic_vector(11 downto 0) := x"00C";
	constant Expansion4IDAddr : 			std_logic_vector(11 downto 0) := x"00D";

	constant LatencyCounterAddr : 			std_logic_vector(11 downto 0) := x"00F";

	constant Axis0x010Addr : 				std_logic_vector(11 downto 0) := x"010";
	constant Axis0x011Addr :		 		std_logic_vector(11 downto 0) := x"011";
	constant Axis0x012Addr : 				std_logic_vector(11 downto 0) := x"012";
	constant Axis0x013Addr : 				std_logic_vector(11 downto 0) := x"013";
	constant Axis0x014Addr : 				std_logic_vector(11 downto 0) := x"014";
	constant Axis0x015Addr : 				std_logic_vector(11 downto 0) := x"015";
	constant Axis0x016Addr : 				std_logic_vector(11 downto 0) := x"016";

	constant Axis1x020Addr : 				std_logic_vector(11 downto 0) := x"020";
	constant Axis1x021Addr : 				std_logic_vector(11 downto 0) := x"021";
	constant Axis1x022Addr : 				std_logic_vector(11 downto 0) := x"022";
	constant Axis1x023Addr : 				std_logic_vector(11 downto 0) := x"023";
	constant Axis1x024Addr :				std_logic_vector(11 downto 0) := x"024";
	constant Axis1x025Addr : 				std_logic_vector(11 downto 0) := x"025";
	constant Axis1x026Addr :				std_logic_vector(11 downto 0) := x"026";

	constant Expansion0Addr : 				std_logic_vector(7 downto 0) := x"10";
	constant Expansion1Addr : 				std_logic_vector(7 downto 0) := x"12";
	constant Expansion2Addr : 				std_logic_vector(7 downto 0) := x"14";
	constant Expansion3Addr : 				std_logic_vector(7 downto 0) := x"16";

	constant ExpD8ConfigAddr :				std_logic_vector(3 downto 0) := x"0";
	constant ExpD8DinAddr :					std_logic_vector(3 downto 0) := x"4";

	constant Exp0AnlgCh0Addr : 				std_logic_vector(3 downto 0) := x"0"; --X"100";
	constant Exp0AnlgLED0Addr : 			std_logic_vector(3 downto 0) := x"1"; --X"101";
	constant Exp0AnlgCh1Addr : 				std_logic_vector(3 downto 0) := x"4"; --X"104";
	constant Exp0AnlgLED1Addr : 			std_logic_vector(3 downto 0) := x"5"; --X"105";

	constant Exp1AnlgCh0Addr : 				std_logic_vector(3 downto 0) := x"0"; --X"120";
	constant Exp1AnlgLED0Addr : 			std_logic_vector(3 downto 0) := x"1"; --X"121";
	constant Exp1AnlgCh1Addr : 				std_logic_vector(3 downto 0) := x"4"; --X"124";
	constant Exp1AnlgLED1Addr : 			std_logic_vector(3 downto 0) := x"5"; --X"125";

	constant Exp2AnlgCh0Addr : 				std_logic_vector(3 downto 0) := x"0"; --X"140";
	constant Exp2AnlgLED0Addr : 			std_logic_vector(3 downto 0) := x"1"; --X"141";
	constant Exp2AnlgCh1Addr : 				std_logic_vector(3 downto 0) := x"4"; --X"144";
	constant Exp2AnlgLED1Addr : 			std_logic_vector(3 downto 0) := x"5"; --X"145";

	constant Exp3AnlgCh0Addr : 				std_logic_vector(3 downto 0) := x"0"; --X"160";
	constant Exp3AnlgLED0Addr : 			std_logic_vector(3 downto 0) := x"1"; --X"161";
	constant Exp3AnlgCh1Addr : 				std_logic_vector(3 downto 0) := x"4"; --X"164";
	constant Exp3AnlgLED1Addr : 			std_logic_vector(3 downto 0) := x"5"; --X"165";

	constant Exp0QuadCountAddr : 			std_logic_vector(3 downto 0) := x"0"; --X"100";
	constant Exp0QuadLEDStatusAddr :		std_logic_vector(3 downto 0) := x"1"; --X"101";
	constant Exp0InputAddr : 				std_logic_vector(3 downto 0) := x"2"; --X"102";
	constant Exp0HomeAddr : 				std_logic_vector(3 downto 0) := x"4"; --X"104";
	constant Exp0Latch0Addr :				std_logic_vector(3 downto 0) := x"5"; --X"105";
	constant Exp0Latch1Addr :				std_logic_vector(3 downto 0) := x"6"; --X"106";

	constant Exp1QuadCountAddr : 			std_logic_vector(3 downto 0) := x"0"; --X"120";
	constant Exp1QuadLEDStatusAddr :		std_logic_vector(3 downto 0) := x"1"; --X"121";
	constant Exp1InputAddr : 				std_logic_vector(3 downto 0) := x"2"; --X"122";
	constant Exp1HomeAddr : 				std_logic_vector(3 downto 0) := x"4"; --X"124";
	constant Exp1Latch0Addr : 				std_logic_vector(3 downto 0) := x"5"; --X"125";
	constant Exp1Latch1Addr : 				std_logic_vector(3 downto 0) := x"6"; --X"126";

	constant Exp2QuadCountAddr : 			std_logic_vector(3 downto 0) := x"0"; --X"140";
	constant Exp2QuadLEDStatusAddr :		std_logic_vector(3 downto 0) := x"1"; --X"141";
	constant Exp2InputAddr : 				std_logic_vector(3 downto 0) := x"2"; --X"142";
	constant Exp2HomeAddr : 				std_logic_vector(3 downto 0) := x"4"; --X"144";
	constant Exp2Latch0Addr : 				std_logic_vector(3 downto 0) := x"5"; --X"145";
	constant Exp2Latch1Addr : 				std_logic_vector(3 downto 0) := x"6"; --X"146";

	constant Exp3QuadCountAddr : 			std_logic_vector(3 downto 0) := x"0"; --X"160";
	constant Exp3QuadLEDStatusAddr : 		std_logic_vector(3 downto 0) := x"1"; --X"161";
	constant Exp3InputAddr : 				std_logic_vector(3 downto 0) := x"2"; --X"162";
	constant Exp3HomeAddr :					std_logic_vector(3 downto 0) := x"4"; --X"164";
	constant Exp3Latch0Addr : 				std_logic_vector(3 downto 0) := x"5"; --X"165";
	constant Exp3Latch1Addr : 				std_logic_vector(3 downto 0) := x"6"; --X"166";

	constant ExpAx:							std_logic_vector (1 downto 0) := "01";
	constant ExpDIO8:						std_logic_vector (1 downto 0) := "10";
	constant ExpQ1:							std_logic_vector (1 downto 0) := "11";

	signal	Axis0x010Read,
			Axis0x011Read,
			Axis0x012Read		: std_logic;	-- := '0';
	signal	Axis0x014Read,
			Axis0x015Read,
			Axis0x016Read		: std_logic;	-- := '0';
	signal	Axis0x010Write,
			Axis0x011Write,
			Axis0x012Write		: std_logic;	-- := '0';
	signal	Axis0x015Write		: std_logic;	-- := '0';
	signal	Axis1x020Read,
			Axis1x021Read,
			Axis1x022Read		: std_logic;	-- := '0';
	signal	Axis1x024Read,
			Axis1x025Read,
			Axis1x026Read		: std_logic;	-- := '0';
	signal	Axis1x020Write,
			Axis1x021Write,
			Axis1x022Write		: std_logic;	-- := '0';
	signal	Axis1x025Write		: std_logic;	-- := '0';

	signal	Exp0Read,
			Exp1Read,
			Exp2Read,
			Exp3Read,
			Exp0Write,
			Exp1Write,
			Exp2Write,
			Exp3Write			: std_logic;	-- := '0';
	signal	Exp0AnalogRead,
			Exp1AnalogRead,
			Exp2AnalogRead,
			Exp3AnalogRead		: std_logic;	-- := '0';
	signal	Exp0AnalogWrite,
			Exp1AnalogWrite,
			Exp2AnalogWrite,
			Exp3AnalogWrite		: std_logic;	-- := '0';
	signal	Exp0DIO8ConfigRead,
			Exp0DIO8ConfigWrite,
			Exp1DIO8ConfigRead,
			Exp1DIO8ConfigWrite	: std_logic;	-- := '0';
	signal	Exp2DIO8ConfigRead,
			Exp2DIO8ConfigWrite,
			Exp3DIO8ConfigRead,
			Exp3DIO8ConfigWrite	: std_logic;	-- := '0';
	signal	Exp0DIO8DinRead,
			Exp1DIO8DinRead,
			Exp2DIO8DinRead,
			Exp3DIO8DinRead		: std_logic;	-- := '0';
	signal	Exp0QuadRead,
			Exp0QuadWrite,
			Exp1QuadRead,
			Exp1QuadWrite		: std_logic;	-- := '0';
	signal	Exp2QuadRead,
			Exp2QuadWrite,
			Exp3QuadRead,
			Exp3QuadWrite		: std_logic;	-- := '0';
	signal	ExpA0LED0Read,
			ExpA0LED1Read,
			ExpA0LED0Write,
			ExpA0LED1Write		: std_logic;	-- := '0';
	signal	ExpA1LED0Read,
			ExpA1LED1Read,
			ExpA1LED0Write,
			ExpA1LED1Write		: std_logic;	-- := '0';
	signal	ExpA2LED0Read,
			ExpA2LED1Read,
			ExpA2LED0Write,
			ExpA2LED1Write		: std_logic;	-- := '0';
	signal	ExpA3LED0Read,
			ExpA3LED1Read,
			ExpA3LED0Write,
			ExpA3LED1Write		: std_logic;	-- := '0';

begin -- start of logic body

	FPGAAccess <= '1' when (CS_L='0' and (RD_L='0' or WR_L='0')) else '0';

-- **************     CPU Control Lines    *************************************

	-- CPU Board FPGA ID Read enable is decoded for WR_L, CS_L and ADDR
	FPGAIDRead <= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = FPGAIDAddr) else '0';

	-- CPU Board Configuration Read enable is decoded for WR_L, CS_L and ADDR
	CPUConfigRead <= '1' when (CS_L = '0' and RD_L = '0' and WR_L = '1' and ADDR(11 downto 0) = CPUConfigAddr) else '0';
				
	-- CPU Board Configuration Write enable is decoded for WR_L, CS_L and ADDR
	CPUConfigWrite <= '1' when (CS_L = '0' and RD_L = '1' and WR_L = '0' and ADDR(11 downto 0) = CPUConfigAddr) else '0';

	-- CPU Board LED Read enable is decoded for RD_l, CS_L and ADDR
	CPULEDRead <= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = CPULEDAddr) else '0';

	-- CPU Board LED Write enable is decoded for WR_L, CS_L and ADDR
	CPULEDWrite <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 0) = CPULEDAddr) else '0';

	-- Watch Dog Timer Write enable is decoded for WR_L, CS_L and ADDR
	WDTConfigWrite <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 0) = WDTConfigAddr) else '0';

	-- Watch Dog Timer Read enable is decoded for RD_L, CS_L and ADDR
	WDTConfigRead <= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = WDTConfigAddr) else '0';

	-- Register for the CPU to write and read to verify FPGA exists and is programmed
	FPGAProgrammedRead <= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = FPGAProgrammedAddr) else '0'; 
	FPGAProgrammedWrite <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 0) = FPGAProgrammedAddr) else '0';

	-- CPU Board Latency Counter Read enable is decoded for WR_L, CS_L and ADDR
	LatencyCounterRead <= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = LatencyCounterAddr) else '0';

	-- CPU Board PROFIBUS Address Read enable is decoded for WR_L, CS_L and ADDR
	PROFIBUSAddrRead <= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = PROFIBUSAddr) else '0';

	-- CPU Board Serial Memory Interface Access enable is decoded for RD_L & WR_L, CS_L and ADDR
	SerialMemXfaceRead <= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = SerialMemXfaceAddr) else '0';
	SerialMemXfaceWrite <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 0) = SerialMemXfaceAddr) else '0';


	-- **************     Module ID Control Lines    *************************************

	-- Read Enable for Control Card ID word
	ControlCardIDRead <= '1' when (CS_L = '0' and RD_L = '0' and WR_L = '1' and ADDR(11 downto 0) = ControlCardIDAddr) else '0';

	-- Read Enable for Expansion Card ID word
	Expansion1IDRead <= '1' when (CS_L = '0' and RD_L = '0' and WR_L = '1' and ADDR(11 downto 0) = Expansion1IDAddr) else '0';
	Expansion2IDRead <= '1' when (CS_L = '0' and RD_L = '0' and WR_L = '1' and ADDR(11 downto 0) = Expansion2IDAddr) else '0';
	Expansion3IDRead <= '1' when (CS_L = '0' and RD_L = '0' and WR_L = '1' and ADDR(11 downto 0) = Expansion3IDAddr) else '0';
	Expansion4IDRead <= '1' when (CS_L = '0' and RD_L = '0' and WR_L = '1' and ADDR(11 downto 0) = Expansion4IDAddr) else '0';


-- **************     Axis 0 Control Lines    *************************************

	-- generic read decode for the Axis 0 address locations
	Axis0x010Read 	<= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = Axis0x010Addr) else '0';
	Axis0x011Read 	<= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = Axis0x011Addr) else '0';
	Axis0x012Read 	<= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = Axis0x012Addr) else '0';
	Axis0x014Read 	<= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = Axis0x014Addr) else '0';
	Axis0x015Read 	<= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = Axis0x015Addr) else '0';
	Axis0x016Read 	<= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = Axis0x016Addr) else '0';
	
	-- generic write decode for the Axis 0 address locations
	Axis0x010Write <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 0) = Axis0x010Addr) else '0';
	Axis0x011Write <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 0) = Axis0x011Addr) else '0';
	Axis0x012Write <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 0) = Axis0x012Addr) else '0';
	Axis0x015Write <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 0) = Axis0x015Addr) else '0';


	-- After the addresses are decoded, they are then aliased to relevant names for easier reading
	Axis0ControlOutputWrite 	<= Axis0x010Write;
	Axis0LEDStatusRead 			<= Axis0x011Read;
	Axis0LEDConfigWrite 		<= Axis0x011Write;
	Axis0IORead 				<= Axis0x012Read;
	Axis0IOWrite 				<= Axis0x012Write;

	MDT_SSIPositionRead0 		<= (Axis0x010Read and MDTPresent);
	MDT_SSIStatusRead0			<= (Axis0x011Read and MDTPresent);
	MDT_SSIConfigWrite0			<= (Axis0x011Write and MDTPresent);
	MDT_SSIDelayRead0			<= (Axis0x015Read and MDTPresent);
	MDT_SSIDelayWrite0			<= (Axis0x015Write and MDTPresent);

	AnlgPositionRead0 			<= (Axis0x010Read and ANLGPresent);
	AnlgStatusRead0				<= (Axis0x011Read and ANLGPresent);

	QA0CountRead				<= (Axis0x010Read and QUADPresent);
	QA0LEDStatusRead			<= (Axis0x011Read and QUADPresent);
	QA0LEDStatusWrite			<= (Axis0x011Write and QUADPresent);
	QA0InputRead				<= (Axis0x012Read and QUADPresent);
	QA0HomeRead					<= (Axis0x014Read and QUADPresent);
	QA0Latch0Read				<= (Axis0x015Read and QUADPresent);
	QA0Latch1Read				<= (Axis0x016Read and QUADPresent);

	-- **************     Axis 1 Control Lines    *************************************

	-- generic read decode for the Axis 1 address locations
	Axis1x020Read 	<= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = Axis1x020Addr) else '0';
	Axis1x021Read 	<= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = Axis1x021Addr) else '0';
	Axis1x022Read 	<= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = Axis1x022Addr) else '0';
	Axis1x024Read 	<= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = Axis1x024Addr) else '0';
	Axis1x025Read 	<= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = Axis1x025Addr) else '0';
	Axis1x026Read 	<= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 0) = Axis1x026Addr) else '0';

	-- generic write decode for the Axis 1 address locations
	Axis1x020Write <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 0) = Axis1x020Addr) else '0';
	Axis1x021Write <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 0) = Axis1x021Addr) else '0';
	Axis1x022Write <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 0) = Axis1x022Addr) else '0';
	Axis1x025Write <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 0) = Axis1x025Addr) else '0';

	-- After the addresses are decoded, they are then aliased to relevant names for easier reading
	Axis1ControlOutputWrite 	<= Axis1x020Write;
	Axis1LEDStatusRead 			<= Axis1x021Read;
	Axis1LEDConfigWrite 		<= Axis1x021Write;
	Axis1IORead 				<= Axis1x022Read;
	Axis1IOWrite 				<= Axis1x022Write;

	MDT_SSIPositionRead1 		<= (Axis1x020Read and MDTPresent);
	MDT_SSIStatusRead1			<= (Axis1x021Read and MDTPresent);
	MDT_SSIConfigWrite1			<= (Axis1x021Write and MDTPresent);
	MDT_SSIDelayRead1			<= (Axis1x025Read and MDTPresent);
	MDT_SSIDelayWrite1			<= (Axis1x025Write and MDTPresent);

	AnlgPositionRead1 			<= (Axis1x020Read and ANLGPresent); 
	AnlgStatusRead1				<= (Axis1x021Read and ANLGPresent);

	QA1CountRead				<= (Axis1x020Read and QUADPresent);
	QA1LEDStatusRead			<= (Axis1x021Read and QUADPresent);
	QA1LEDStatusWrite			<= (Axis1x021Write and QUADPresent);
	QA1InputRead				<= (Axis1x022Read and QUADPresent);
	QA1HomeRead					<= (Axis1x024Read and QUADPresent);
	QA1Latch0Read				<= (Axis1x025Read and QUADPresent);
	QA1Latch1Read				<= (Axis1x026Read and QUADPresent);

	-- **************     General Expansion Control Lines    *************************************
	Exp0Read <= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 4) = Expansion0Addr) else '0';
	Exp1Read <= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 4) = Expansion1Addr) else '0';
	Exp2Read <= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 4) = Expansion2Addr) else '0';
	Exp3Read <= '1' when (CS_L = '0' and RD_L = '0' and ADDR(11 downto 4) = Expansion3Addr) else '0';

	Exp0Write <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 4) = Expansion0Addr) else '0';
	Exp1Write <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 4) = Expansion1Addr) else '0';
	Exp2Write <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 4) = Expansion2Addr) else '0';
	Exp3Write <= '1' when (CS_L = '0' and WR_L = '0' and ADDR(11 downto 4) = Expansion3Addr) else '0';

	Exp0AnalogRead <= '1' 	when (Exp0Mux(1 downto 0) = ExpAx and Exp0Read = '1') else '0';
	Exp0AnalogWrite <= '1' 	when (Exp0Mux(1 downto 0) = ExpAx and Exp0Write = '1') else '0';
	Exp1AnalogRead <= '1' 	when (Exp1Mux(1 downto 0) = ExpAx and Exp1Read = '1') else '0';
	Exp1AnalogWrite <= '1' 	when (Exp1Mux(1 downto 0) = ExpAx and Exp1Write = '1') else '0';
	Exp2AnalogRead <= '1' 	when (Exp2Mux(1 downto 0) = ExpAx and Exp2Read = '1') else '0';
	Exp2AnalogWrite <= '1' 	when (Exp2Mux(1 downto 0) = ExpAx and Exp2Write = '1') else '0';
	Exp3AnalogRead <= '1' 	when (Exp3Mux(1 downto 0) = ExpAx and Exp3Read = '1') else '0';
	Exp3AnalogWrite <= '1' 	when (Exp3Mux(1 downto 0) = ExpAx and Exp3Write = '1') else '0';

	Exp0DIO8ConfigRead <= '1' 	when (Exp0Mux(1 downto 0) = ExpDIO8 and ADDR(3 downto 0) = ExpD8ConfigAddr and Exp0Read = '1') else '0';
	Exp0DIO8ConfigWrite <= '1' 	when (Exp0Mux(1 downto 0) = ExpDIO8 and ADDR(3 downto 0) = ExpD8ConfigAddr and Exp0Write = '1') else '0';
	Exp1DIO8ConfigRead <= '1' 	when (Exp1Mux(1 downto 0) = ExpDIO8 and ADDR(3 downto 0) = ExpD8ConfigAddr and Exp1Read = '1') else '0';
	Exp1DIO8ConfigWrite <= '1' 	when (Exp1Mux(1 downto 0) = ExpDIO8 and ADDR(3 downto 0) = ExpD8ConfigAddr and Exp1Write = '1') else '0';
	Exp2DIO8ConfigRead <= '1' 	when (Exp2Mux(1 downto 0) = ExpDIO8 and ADDR(3 downto 0) = ExpD8ConfigAddr and Exp2Read = '1') else '0';
	Exp2DIO8ConfigWrite <= '1' 	when (Exp2Mux(1 downto 0) = ExpDIO8 and ADDR(3 downto 0) = ExpD8ConfigAddr and Exp2Write = '1') else '0';
	Exp3DIO8ConfigRead <= '1' 	when (Exp3Mux(1 downto 0) = ExpDIO8 and ADDR(3 downto 0) = ExpD8ConfigAddr and Exp3Read = '1') else '0';
	Exp3DIO8ConfigWrite <= '1' 	when (Exp3Mux(1 downto 0) = ExpDIO8 and ADDR(3 downto 0) = ExpD8ConfigAddr and Exp3Write = '1') else '0';

	Exp0DIO8DinRead <= '1' 	when (Exp0Mux(1 downto 0) = ExpDIO8 and ADDR(3 downto 0) = ExpD8DinAddr and Exp0Read = '1') else '0';
	Exp1DIO8DinRead <= '1' 	when (Exp1Mux(1 downto 0) = ExpDIO8 and ADDR(3 downto 0) = ExpD8DinAddr and Exp1Read = '1') else '0';
	Exp2DIO8DinRead <= '1' 	when (Exp2Mux(1 downto 0) = ExpDIO8 and ADDR(3 downto 0) = ExpD8DinAddr and Exp2Read = '1') else '0';
	Exp3DIO8DinRead <= '1' 	when (Exp3Mux(1 downto 0) = ExpDIO8 and ADDR(3 downto 0) = ExpD8DinAddr and Exp3Read = '1') else '0';

	Exp0QuadRead <= '1' 	when (Exp0Mux(1 downto 0) = ExpQ1 and Exp0Read = '1') else '0';
	Exp0QuadWrite <= '1' 	when (Exp0Mux(1 downto 0) = ExpQ1 and Exp0Write = '1') else '0';
	Exp1QuadRead <= '1' 	when (Exp1Mux(1 downto 0) = ExpQ1 and Exp1Read = '1') else '0';
	Exp1QuadWrite <= '1' 	when (Exp1Mux(1 downto 0) = ExpQ1 and Exp1Write = '1') else '0';
	Exp2QuadRead <= '1' 	when (Exp2Mux(1 downto 0) = ExpQ1 and Exp2Read = '1') else '0';
	Exp2QuadWrite <= '1' 	when (Exp2Mux(1 downto 0) = ExpQ1 and Exp2Write = '1') else '0';
	Exp3QuadRead <= '1' 	when (Exp3Mux(1 downto 0) = ExpQ1 and Exp3Read = '1') else '0';
	Exp3QuadWrite <= '1' 	when (Exp3Mux(1 downto 0) = ExpQ1 and Exp3Write = '1') else '0';

	-- **************     DIO8 Expansion Module #0 - #3 Control Lines    *************************************
	ExpDIO8ConfigRead(0) <= '1' when Exp0DIO8ConfigRead = '1' else '0';
	ExpDIO8ConfigRead(1) <= '1' when Exp1DIO8ConfigRead = '1' else '0';
	ExpDIO8ConfigRead(2) <= '1' when Exp2DIO8ConfigRead = '1' else '0';
	ExpDIO8ConfigRead(3) <= '1' when Exp3DIO8ConfigRead = '1' else '0';

	ExpDIO8ConfigWrite(0) <= '1' when Exp0DIO8ConfigWrite = '1' else '0';
	ExpDIO8ConfigWrite(1) <= '1' when Exp1DIO8ConfigWrite = '1' else '0';
	ExpDIO8ConfigWrite(2) <= '1' when Exp2DIO8ConfigWrite = '1' else '0';
	ExpDIO8ConfigWrite(3) <= '1' when Exp3DIO8ConfigWrite = '1' else '0';

	ExpDIO8DinRead(0) <= '1' when Exp0DIO8DinRead = '1' else '0';
	ExpDIO8DinRead(1) <= '1' when Exp1DIO8DinRead = '1' else '0';
	ExpDIO8DinRead(2) <= '1' when Exp2DIO8DinRead = '1' else '0';
	ExpDIO8DinRead(3) <= '1' when Exp3DIO8DinRead = '1' else '0';

	-- **************     Ax Expansion Module #0 Control Lines    *************************************
	ExpA0ReadCh0 <= '1' 	when Exp0AnalogRead = '1' and ADDR(3 downto 0) = Exp0AnlgCh0Addr else '0';
	ExpA0ReadCh1 <= '1' 	when Exp0AnalogRead = '1' and ADDR(3 downto 0) = Exp0AnlgCh1Addr else '0';
	ExpA0LED0Read <= '1'  	when Exp0AnalogRead = '1' and ADDR(3 downto 0) = Exp0AnlgLED0Addr else '0';
	ExpA0LED0Write <= '1' 	when Exp0AnalogWrite = '1' and ADDR(3 downto 0) = Exp0AnlgLED0Addr else '0';
	ExpA0LED1Read <= '1'  	when Exp0AnalogRead = '1' and ADDR(3 downto 0) = Exp0AnlgLED1Addr else '0';
	ExpA0LED1Write <= '1' 	when Exp0AnalogWrite = '1' and ADDR(3 downto 0) = Exp0AnlgLED1Addr else '0';

	-- **************     Ax Expansion Module #1 Control Lines    *************************************
	ExpA1ReadCh0 <= '1' 	when Exp1AnalogRead = '1' and ADDR(3 downto 0) = Exp1AnlgCh0Addr else '0';
	ExpA1ReadCh1 <= '1' 	when Exp1AnalogRead = '1' and ADDR(3 downto 0) = Exp1AnlgCh1Addr else '0';
	ExpA1LED0Read <= '1'  	when Exp1AnalogRead = '1' and ADDR(3 downto 0) = Exp1AnlgLED0Addr else '0';
	ExpA1LED0Write <= '1' 	when Exp1AnalogWrite = '1' and ADDR(3 downto 0) = Exp1AnlgLED0Addr else '0';
	ExpA1LED1Read <= '1'  	when Exp1AnalogRead = '1' and ADDR(3 downto 0) = Exp1AnlgLED1Addr else '0';
	ExpA1LED1Write <= '1' 	when Exp1AnalogWrite = '1' and ADDR(3 downto 0) = Exp1AnlgLED1Addr else '0';

	-- **************     Ax Expansion Module #2 Control Lines    *************************************
	ExpA2ReadCh0 <= '1' 	when Exp2AnalogRead = '1' and ADDR(3 downto 0) = Exp2AnlgCh0Addr else '0';
	ExpA2ReadCh1 <= '1' 	when Exp2AnalogRead = '1' and ADDR(3 downto 0) = Exp2AnlgCh1Addr else '0';
	ExpA2LED0Read <= '1'  	when Exp2AnalogRead = '1' and ADDR(3 downto 0) = Exp2AnlgLED0Addr else '0';
	ExpA2LED0Write <= '1' 	when Exp2AnalogWrite = '1' and ADDR(3 downto 0) = Exp2AnlgLED0Addr else '0';
	ExpA2LED1Read <= '1'  	when Exp2AnalogRead = '1' and ADDR(3 downto 0) = Exp2AnlgLED1Addr else '0';
	ExpA2LED1Write <= '1' 	when Exp2AnalogWrite = '1' and ADDR(3 downto 0) = Exp2AnlgLED1Addr else '0';

	-- **************     Ax Expansion Module #3 Control Lines    *************************************
	ExpA3ReadCh0 <= '1' 	when Exp3AnalogRead = '1' and ADDR(3 downto 0) = Exp3AnlgCh0Addr else '0';
	ExpA3ReadCh1 <= '1' 	when Exp3AnalogRead = '1' and ADDR(3 downto 0) = Exp3AnlgCh1Addr else '0';
	ExpA3LED0Read <= '1'  	when Exp3AnalogRead = '1' and ADDR(3 downto 0) = Exp3AnlgLED0Addr else '0';
	ExpA3LED0Write <= '1' 	when Exp3AnalogWrite = '1' and ADDR(3 downto 0) = Exp3AnlgLED0Addr else '0';
	ExpA3LED1Read <= '1'  	when Exp3AnalogRead = '1' and ADDR(3 downto 0) = Exp3AnlgLED1Addr else '0';
	ExpA3LED1Write <= '1' 	when Exp3AnalogWrite = '1' and ADDR(3 downto 0) = Exp3AnlgLED1Addr else '0';

	-- *************     Any Analog data access will trigger this output which is used to run the "special" analog bus.
	ANLGAccess <= '1' when 	AnlgPositionRead0 = '1' or AnlgPositionRead1 = '1' or 
							ExpA0ReadCh0 = '1' or ExpA0ReadCh1 = '1' or ExpA1ReadCh0 = '1' or ExpA1ReadCh1 = '1' or
							ExpA2ReadCh0 = '1' or ExpA2ReadCh1 = '1' or ExpA3ReadCh0 = '1' or ExpA3ReadCh1='1' else '0';

	-- **************     Q1 Expansion Module #0 Control Lines    *************************************
	Exp0QuadCountRead <= '1' 		when Exp0QuadRead = '1' and ADDR(3 downto 0) = Exp0QuadCountAddr else '0';
	Exp0QuadLEDStatusRead <= '1' 	when Exp0QuadRead = '1' and ADDR(3 downto 0) = Exp0QuadLEDStatusAddr else '0';
	Exp0QuadLEDStatusWrite <= '1' 	when Exp0QuadWrite = '1' and ADDR(3 downto 0) = Exp0QuadLEDStatusAddr else '0';
	Exp0QuadInputRead <= '1' 		when Exp0QuadRead = '1' and ADDR(3 downto 0) = Exp0InputAddr else '0';
	Exp0QuadHomeRead <= '1' 		when Exp0QuadRead = '1' and ADDR(3 downto 0) = Exp0HomeAddr else '0';
	Exp0QuadLatch0Read <= '1' 		when Exp0QuadRead = '1' and ADDR(3 downto 0) = Exp0Latch0Addr else '0';
	Exp0QuadLatch1Read <= '1' 		when Exp0QuadRead = '1' and ADDR(3 downto 0) = Exp0Latch1Addr else '0';

	-- **************     Q1 Expansion Module #1 Control Lines    *************************************
	Exp1QuadCountRead <= '1' 		when Exp1QuadRead = '1' and ADDR(3 downto 0) = Exp1QuadCountAddr else '0';
	Exp1QuadLEDStatusRead <= '1' 	when Exp1QuadRead = '1' and ADDR(3 downto 0) = Exp1QuadLEDStatusAddr else '0';
	Exp1QuadLEDStatusWrite <= '1' 	when Exp1QuadWrite = '1' and ADDR(3 downto 0) = Exp1QuadLEDStatusAddr else '0';
	Exp1QuadInputRead <= '1' 		when Exp1QuadRead = '1' and ADDR(3 downto 0) = Exp1InputAddr else '0';
	Exp1QuadHomeRead <= '1' 		when Exp1QuadRead = '1' and ADDR(3 downto 0) = Exp1HomeAddr else '0';
	Exp1QuadLatch0Read <= '1' 		when Exp1QuadRead = '1' and ADDR(3 downto 0) = Exp1Latch0Addr else '0';
	Exp1QuadLatch1Read <= '1' 		when Exp1QuadRead = '1' and ADDR(3 downto 0) = Exp1Latch1Addr else '0';

	-- **************     Q1 Expansion Module #2 Control Lines    *************************************
	Exp2QuadCountRead <= '1' 		when Exp2QuadRead = '1' and ADDR(3 downto 0) = Exp2QuadCountAddr else '0';
	Exp2QuadLEDStatusRead <= '1' 	when Exp2QuadRead = '1' and ADDR(3 downto 0) = Exp2QuadLEDStatusAddr else '0';
	Exp2QuadLEDStatusWrite <= '1'	when Exp2QuadWrite = '1' and ADDR(3 downto 0) = Exp2QuadLEDStatusAddr else '0';
	Exp2QuadInputRead <= '1' 		when Exp2QuadRead = '1' and ADDR(3 downto 0) = Exp2InputAddr else '0';
	Exp2QuadHomeRead <= '1' 		when Exp2QuadRead = '1' and ADDR(3 downto 0) = Exp2HomeAddr else '0';
	Exp2QuadLatch0Read <= '1' 		when Exp2QuadRead = '1' and ADDR(3 downto 0) = Exp2Latch0Addr else '0';
	Exp2QuadLatch1Read <= '1' 		when Exp2QuadRead = '1' and ADDR(3 downto 0) = Exp2Latch1Addr else '0';

	-- **************     Q1 Expansion Module #3 Control Lines    *************************************
	Exp3QuadCountRead <= '1' 		when Exp3QuadRead = '1' and ADDR(3 downto 0) = Exp3QuadCountAddr else '0';
	Exp3QuadLEDStatusRead <= '1' 	when Exp3QuadRead = '1' and ADDR(3 downto 0) = Exp3QuadLEDStatusAddr else '0';
	Exp3QuadLEDStatusWrite <= '1' 	when Exp3QuadWrite = '1' and ADDR(3 downto 0) = Exp3QuadLEDStatusAddr else '0';
	Exp3QuadInputRead <= '1' 		when Exp3QuadRead = '1' and ADDR(3 downto 0) = Exp3InputAddr else '0';
	Exp3QuadHomeRead <= '1' 		when Exp3QuadRead = '1' and ADDR(3 downto 0) = Exp3HomeAddr else '0';
	Exp3QuadLatch0Read <= '1' 		when Exp3QuadRead = '1' and ADDR(3 downto 0) = Exp3Latch0Addr else '0';
	Exp3QuadLatch1Read <= '1' 		when Exp3QuadRead = '1' and ADDR(3 downto 0) = Exp3Latch1Addr else '0';

	-- **************     Expansion LED Module #1 R/W lines *************************************
	Exp0LEDRead 	<= Exp0QuadLEDStatusRead;
	Exp0LED0Read 	<= ExpA0LED0Read;
	Exp0LED1Read 	<= ExpA0LED1Read;
	Exp0LEDWrite 	<= Exp0QuadLEDStatusWrite;
	Exp0LED0Write 	<= ExpA0LED0Write;
	Exp0LED1Write 	<= ExpA0LED1Write;

	-- **************     Expansion LED Module #2 R/W lines *************************************
	Exp1LEDRead 	<= Exp1QuadLEDStatusRead;
	Exp1LED0Read 	<= ExpA1LED0Read;
	Exp1LED1Read 	<= ExpA1LED1Read;
	Exp1LEDWrite 	<= Exp1QuadLEDStatusWrite;
	Exp1LED0Write 	<= ExpA1LED0Write;
	Exp1LED1Write 	<= ExpA1LED1Write;

	-- **************     Expansion LED Module #3 R/W lines *************************************
	Exp2LEDRead 	<= Exp2QuadLEDStatusRead;
	Exp2LED0Read 	<= ExpA2LED0Read;
	Exp2LED1Read 	<= ExpA2LED1Read;
	Exp2LEDWrite 	<= Exp2QuadLEDStatusWrite;
	Exp2LED0Write 	<= ExpA2LED0Write;
	Exp2LED1Write 	<= ExpA2LED1Write;

	-- **************     Expansion LED Module #4 R/W lines *************************************
	Exp3LEDRead 	<= Exp3QuadLEDStatusRead;
	Exp3LED0Read 	<= ExpA3LED0Read;
	Exp3LED1Read 	<= ExpA3LED1Read;
	Exp3LEDWrite 	<= Exp3QuadLEDStatusWrite;
	Exp3LED0Write 	<= ExpA3LED0Write;
	Exp3LED1Write 	<= ExpA3LED1Write;

end Decode_arch;