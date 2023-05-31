--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--  Target Device:  Microchip Igloo2 M2GL005-VF256
--
--	Entity Name		Top
--	File			top.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		This design provides the interface to all the axis modules and expansion
--		modules on the RMC75E as well as control of the LEDs on the CPU module.
--		The main components are
--			* bus interface to the MPC5200 processor
--			* sensor interface logic
--			* sensor I/O signal multiplexing
--
--	Revision: 1.8
--
-- File history:
--		Rev 1.8 : 02/28/2023 :	Added SysReset to SerialMemoryInterface
--		Rev 1.7 : 02/07/2023 :	Made ExpA_CLK an output from Analog component
--		Rev 1.6 : 12/30/2022 :	Converted ExtADDR 0 and 1 to Debug1 and Debug2
--		Rev 1.5 : 11/23/2022 :	Added Reset to analog input logic.
--		Rev 1.4 : 11/15/2022 :	Refactored SSI interface
--								Added SysReset to TickSync to initialize loop ticks low
--		Rev 1.3 : 11/11/2022 :	Added Reset to MDT interface to start state machine at state 0
--		Rev 1.2 : 10/28/2022 :	Add register for CPU handshaking
--								Route PowerUpDetect to device pin to force synthesizer to
--								 keep the logic behind it.
--		Rev 1.1 : 08/26/2022 :	Converted from Xilinx to Microchip
--								  Configured PLL to generate required clocks
--								  Added Reset logic to critical circuits because Microchip's
--								    internal flip-flops power up in unknown state.
--								Removed Profibus and serial interface logic.
--								Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--library unisim;
--use unisim.vcomponents.all;

entity Top is
	port (
		DATA						: inout std_logic_vector (31 downto 0);
		ExtADDR						: in std_logic_vector (11 downto 2);	-- CPU addresses are for 8-bit bus, but FPGA uses only 32-bit accesses.
		RD_L						: in std_logic;
		WR_L						: in std_logic;
		CS_L						: in std_logic;
		LOOPTICK					: in std_logic;
		H1_CLK_IN					: in std_logic;				-- 60 MHz clock input to CCC (PLL)
		-- Second input for 60 MHz clock added for Microchip so dedicated clock can go into CCC
		H1_CLKWR					: in std_logic;

		WD_RST_L					: out std_logic;
		WD_TICKLE					: in std_logic;
		RESET						: in std_logic;

		M_DRV_EN_L					: out std_logic;			-- pullup is placed on this pin external to the FPGA.
		HALT_DRIVE_L				: in std_logic;

		M_OUT0_CLK					: out std_logic;
		M_OUT0_DATA					: out std_logic;
		M_OUT0_CONTROL				: out std_logic;

		M_OUT1_CLK					: out std_logic;
		M_OUT1_DATA					: out std_logic;
		M_OUT1_CONTROL				: out std_logic;

		M_AX0_0						: out std_logic;			-- multiplexed output of M_AX0_INT_DATA and M_ADC_CLK
		M_AX0_RET_DATA				: in std_logic;

		M_AX1_INT_CLK				: out std_logic;
		M_AX1_RET_DATA				: in std_logic;

		M_MUXED_ADC_CS_QA0_SIGA		: inout std_logic;
		M_MUXED_ADC_DATA0_QA0_SIGB	: in std_logic;
		M_MUXED_ADC_DATA1_QA1_SIGA	: in std_logic;

	 	M_ENABLE					: out std_logic_vector (1 downto 0);
		M_FAULT						: in std_logic_vector (1 downto 0);

		M_Card_ID_LOAD				: out std_logic;
		M_Card_ID_LATCH				: out std_logic;
		M_Card_ID_CLK				: out std_logic;
		M_Card_ID_DATA				: in std_logic;

		Exp_Mxd_ID_LOAD				: out std_logic;
		Exp_Mxd_ID_LATCH			: out std_logic;
		Exp_Mxd_ID_CLK				: out std_logic;
		Exp_ID_DATA					: in std_logic;

		M_IO_OE						: out std_logic;			-- pullup is placed on this pin external to the FPGA.
		M_IO_LOAD					: out std_logic;			-- pullup is placed on this pin external to the FPGA.
		M_IO_LATCH					: out std_logic;
		M_IO_CLK					: out std_logic;
		M_IO_DATAOut				: out std_logic;
		M_IO_DATAIn					: in std_logic;

		M_SPROM_CLK					: out std_logic;
		M_SPROM_DATA				: inout std_logic;

		CPUStatLEDDrive				: out std_logic_vector (1 downto 0);

		Exp0Data					: inout std_logic_vector (5 downto 0);
		Exp1Data					: inout std_logic_vector (5 downto 0);
		Exp2Data					: inout std_logic_vector (5 downto 0);
		Exp3Data					: inout std_logic_vector (5 downto 0);
		
	--	QA0_SigA		-- This signal is muxed with ADC_CS (See M_MUXED_ADC_CS_QA0_SIGA above)
	--	QA0_SigB		-- This signal is muxed with ADC_Data0 (See M_MUXED_ADC_DATA0_QA0_SIGB above)
		QA0_SigZ					: in std_logic;
		QA0_Home					: in std_logic;
		QA0_RegX_PosLmt				: in std_logic;
		QA0_RegY_NegLmt				: in std_logic;
		
	--	QA1_SigA		-- This signal is muxed with ADC_Data1 (See M_MUXED_ADC_DATA1_QA1_SIGA above)
		QA1_SigB					: in std_logic;
		QA1_SigZ					: in std_logic;
		QA1_Home					: in std_logic;
		QA1_RegX_PosLmt				: in std_logic;
		QA1_RegY_NegLmt				: in std_logic;
		
		-- Unused pins (some can be used for debug)
		X_Reserved0					: out std_logic;			-- Goes to expansiotn bus, but is not used on expansion cards
		X_Reserved1					: out std_logic;			-- Goes to expansiotn bus, but is not used on expansion cards
		Debug0						: out std_logic;			-- Goes to test point D0
		Debug1						: out std_logic;			-- Goes to test point D1 (on PCB rev 3.1)
		Debug2						: out std_logic;			-- Goes to test point D2 (on PCB rev 3.1)
		FPGA_Test					: out std_logic;			-- Goes to CPU pin PSC6_3 (might be used to indicate FPGA status)
		TestClock					: out std_logic				-- Goes to test point by expansion bus connector
	);
end Top;

architecture Top_arch of Top is

	component TickSync
		port (
			SysReset		: in std_logic;		-- Main system Reset signal
			SysClk			: in std_logic;		-- 30MHz system clock
			H1_CLK			: in std_logic;		-- 60MHz System clock
			LOOPTICK		: in std_logic;
			SynchedTick		: out std_logic;	-- Control loop timing pulse synchronized with the
												-- 30MHz system clock. Valid from rising-edge to rising-edge
			SynchedTick60	: out std_logic		-- 60MHz system clock. Valid from rising-edge to rising-edge
		);
	end component;

	Component ClockControl is
		port (
			H1_PRIMARY	: in std_logic;		-- primary clk_in
			H1_CLKWR	: in std_logic;		-- 60MHz input clock for general use
			H1_CLK		: out std_logic;	-- 60MHz system clock 
			H1_CLK90	: out std_logic;	-- 60MHz system clock (90 degree phase lag)
			SysClk		: out std_logic;	-- 30MHz system clock
			RESET		: in std_logic;		-- Sysem reset from power monitor
			DLL_RST		: in std_logic;		-- PLL Reset pulse generated by command from CPU
			DLL_LOCK	: out std_logic;
			SysRESET	: out std_logic;	-- Active when RESET active or PLL not locked
			PowerUp		: out std_logic;
			Enable		: out std_logic;	-- 7.5MHz system enable (active every other 15MHz clock)
			SlowEnable	: out std_logic		-- 3.75MHz system enable (active every 4th 15MHz clock)
		);
	end component;

	component Decode is
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
	end component;

	component ControlOutput
		port (
			H1_CLKWR	 		: in std_logic;
			SysClk				: in std_logic;
			RESET				: in std_logic;
			SynchedTick			: in std_logic;
			intDATA				: in std_logic_vector (15 downto 0);
			ControlOutputWrite	: in std_logic;
			M_OUT_CLK			: out std_logic;
			M_OUT_DATA			: out std_logic;
			M_OUT_CONTROL		: out std_logic;
			PowerUp				: in std_logic;
			Enable				: in std_logic
		);
	end component;

	component MDTSSIRoute
		port (
			SSISelect		: in std_logic_vector (1 downto 0);
			M_AX0_INT_CLK	: out std_logic;
			M_AX1_INT_CLK	: out std_logic;
			M_AX0_SSI_CLK	: in std_logic;
			M_AX1_SSI_CLK	: in std_logic;
			M_AX0_MDT_INT	: in std_logic; 
			M_AX1_MDT_INT	: in std_logic 
		);
	end component;

	component MDTTopSimp
		port (
			SysReset		: in std_logic;		-- Main system Reset signal
			H1_CLK			: in std_logic;		-- 60 MHz clock for MDT interface
			H1_CLKWR		: in std_logic;		-- CPU clock forn read and writes
			H1_CLK90		: in std_logic;		-- 60 MHz clock with 90 degree pahse shift for MDT coun
			SynchedTick60	: in std_logic;
			intDATA			: in std_logic_vector(31 downto 0);
			mdtSimpDataOut	: out std_logic_vector(31 downto 0);
			PositionRead	: in std_logic;
			StatusRead		: in std_logic;
			ParamWrite		: in std_logic;
			M_INT_CLK		: out std_logic;
			M_RET_DATA		: in std_logic;
			SSI_DATA		: out std_logic;
			SSISelect		: in std_logic
		);
	end component;

	component SSITop
		port (
			H1_CLKWR		: in std_logic;							-- 60MHz system clock
			SysClk			: in std_logic;							-- 30MHz system clock
			Enable			: in std_logic;							-- 7.5MHz system enable (active every 4th 30MHz clock)
			SlowEnable		: in std_logic;							-- 3.75MHz system enable (active every 8th 30MHz clock)
			SynchedTick		: in std_logic;							-- Control loop tick valid on rising edge of 30MHz clock
			intDATA			: in std_logic_vector (31 downto 0);
			ssiDataOut		: out std_logic_vector (31 downto 0);
			PositionRead	: in std_logic;
			StatusRead		: in std_logic;
			ParamWrite1		: in std_logic;
			ParamWrite2		: in std_logic;
			SSI_CLK			: out std_logic;
			SSI_DATA		: in std_logic;
			SSISelect		: out std_logic
		);
	end component;

	component ControlIO
		port (
			RESET				: in std_logic;
			H1_CLKWR			: in std_logic;
			SysClk				: in std_logic;
			Enable				: in std_logic;
			SynchedTick			: in std_logic;
			intDATA				: in std_logic_vector (31 downto 0);
			controlIoDataOut	: out std_logic_vector (31 downto 0);
			Axis0LEDStatusRead	: in std_logic;
			Axis0LEDConfigWrite	: in std_logic;
			Axis0IORead			: in std_logic;
			Axis0IOWrite		: in std_logic;
			Axis1LEDStatusRead	: in std_logic;
			Axis1LEDConfigWrite	: in std_logic;
			Axis1IORead			: in std_logic;
			Axis1IOWrite		: in std_logic;
			M_IO_OE				: out std_logic;
			M_IO_LOAD			: out std_logic;
			M_IO_LATCH			: out std_logic;
			M_IO_CLK			: out std_logic;
			M_IO_DATAOut		: out std_logic;
			M_IO_DATAIn			: in std_logic;
			M_ENABLE			: out std_logic_vector (1 downto 0);
			M_FAULT				: in std_logic_vector (1 downto 0);
			PowerUp				: in std_logic;
			QUADPresent			: in std_logic;
			QA0AxisFault		: out std_logic_vector (2 downto 0);
			QA1AxisFault		: out std_logic_vector (2 downto 0)
		);
	end component;

	component DiscoverID is
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
	end component;

	component CPULED
		port (
			RESET				: in std_logic;
			H1_CLKWR			: in std_logic;
			intDATA				: in std_logic_vector(31 downto 0);
			cpuLedDataOut		: out std_logic_vector(31 downto 0);
			CPULEDWrite			: in std_logic;
			CPUStatLEDDrive		: out std_logic_vector(1 downto 0)
		);
	end component;

	component CPUConfig
		port (
			RESET				: in std_logic;		-- External Reset from power monitor and watchdog IC.
			SysRESET			: in std_logic;		-- Main internal reset. Used to clear DLL_RST
			H1_CLKWR			: in std_logic;
			H1_PRIMARY			: in std_logic;							-- 60MHz system clock
			intDATA				: in std_logic_vector (31 downto 0);
			cpuConfigDataOut	: out std_logic_vector (31 downto 0);
			CPUConfigWrite		: in std_logic;
			M_DRV_EN_L			: out std_logic;						-- Control Output Enable Line
			HALT_DRIVE_L		: in std_logic;
			DLL_LOCK			: in std_logic;
			DLL_RST				: out std_logic;	-- Was for resetting DLL. Now used to clear SysRESET. Generated by command from CPU.
			LoopTime			: out std_logic_vector (2 downto 0);	-- Control Loop Time Selection
			ENET_Build			: in std_logic
		);
	end component;

	component WDT
		port (
			RESET				: in std_logic;
			SysRESET			: in std_logic;
			H1_CLKWR			: in std_logic;
			SysClk				: in std_logic;
			intDATA				: in std_logic_vector(31 downto 0);
			wdtDataOut			: out std_logic_vector(31 downto 0);
			FPGAProgDOut		: out std_logic_vector(31 downto 0);
			FPGAAccess			: in std_logic;
			WDTConfigWrite		: in std_logic;
			FPGAProgrammedWrite	: in std_logic;		--	Write and read to verify Igloo2 FPGA is programmed
			SlowEnable			: in std_logic;
			HALT_DRIVE_L		: in std_logic;
			WD_TICKLE			: in std_logic;
			WD_RST_L			: out std_logic
		);
	end component;

	component ExpSigRoute
		port (
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
	end component;

	component RtdExpIDLED 
		port (
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
	end component;

	component Analog 
		port (
			SysReset			: in std_logic;			-- System Reset or PLL not locked
			H1_CLKWR			: in std_logic;
			SysClk				: in std_logic;
			SlowEnable			: in std_logic;
			SynchedTick			: in std_logic;
			SynchedTick60		: in std_logic;
			LoopTime			: in std_logic_vector (2 downto 0);
			AnlgDATA			: out std_logic_vector (31 downto 0);
			AnlgPositionRead0	: in std_logic;
			AnlgPositionRead1	: in std_logic;
			ExpA0ReadCh0		: in std_logic;
			ExpA0ReadCh1		: in std_logic;
			ExpA1ReadCh0		: in std_logic;
			ExpA1ReadCh1		: in std_logic;
			ExpA2ReadCh0		: in std_logic;
			ExpA2ReadCh1		: in std_logic;
			ExpA3ReadCh0		: in std_logic;
			ExpA3ReadCh1		: in std_logic;
			ExpA_CS_L			: out std_logic;
			ExpA_CLK			: out std_logic;
			CtrlAxisData		: in std_logic_vector (1 downto 0);
			ExpA_DATA			: in std_logic_vector (7 downto 0)
		);
	end component;

	component SerialMemoryInterface is
		port (
			SysReset				: in std_logic;			-- System Reset or PLL not locked
			H1_CLK					: in std_logic;
			SysClk					: in std_logic;
			SlowEnable				: in std_logic;
			intDATA					: in std_logic_vector(31 downto 0);
			serialMemDataOut		: out std_logic_vector(31 downto 0);
			SerialMemXfaceWrite		: in std_logic;
			SerialMemoryDataIn		: in std_logic;
			SerialMemoryDataOut		: out std_logic;
			SerialMemoryDataControl	: out std_logic;
			SerialMemoryClk			: out std_logic;
			Exp0SerialSelect		: out std_logic;
			Exp1SerialSelect		: out std_logic;
			Exp2SerialSelect		: out std_logic;
			Exp3SerialSelect		: out std_logic;
			EEPROMAccessFlag		: out std_logic;
			M_SPROM_CLK				: out std_logic;
			M_SPROM_DATA			: inout std_logic
		);
	end component;

	component DIO8
		port (
			RESET				: in std_logic;
			H1_CLKWR			: in std_logic;
			SysClk				: in std_logic;
			SlowEnable			: in std_logic;
			SynchedTick			: in std_logic;
			intDATA				: in std_logic_vector(31 downto 0);
			d8DataOut			: out std_logic_vector(31 downto 0);
			ExpDIO8ConfigRead	: in std_logic_vector(3 downto 0);
			ExpDIO8ConfigWrite	: in std_logic_vector(3 downto 0);
			ExpDIO8DinRead		: in std_logic_vector(3 downto 0);
			Exp0D8_DataIn		: in std_logic;
			Exp0D8_Clk			: out std_logic;
			Exp0D8_DataOut		: out std_logic;
			Exp0D8_OE			: out std_logic;
			Exp0D8_Load			: out std_logic;
			Exp0D8_Latch		: out std_logic;
			Exp1D8_DataIn		: in std_logic;
			Exp1D8_Clk			: out std_logic;
			Exp1D8_DataOut		: out std_logic;
			Exp1D8_OE			: out std_logic;
			Exp1D8_Load			: out std_logic;
			Exp1D8_Latch		: out std_logic;
			Exp2D8_DataIn		: in std_logic;
			Exp2D8_Clk			: out std_logic;
			Exp2D8_DataOut		: out std_logic;
			Exp2D8_OE			: out std_logic;
			Exp2D8_Load			: out std_logic;
			Exp2D8_Latch		: out std_logic;
			Exp3D8_DataIn		: in std_logic;
			Exp3D8_Clk			: out std_logic;
			Exp3D8_DataOut		: out std_logic;
			Exp3D8_OE			: out std_logic;
			Exp3D8_Load			: out std_logic;
			Exp3D8_Latch		: out std_logic
		);
	end component;

	component LatencyCounter
		port (
			H1_CLK				: in std_logic;
			SynchedTick			: in std_logic;
			latencyDataOut		: out std_logic_vector (31 downto 0);
			LatencyCounterRead	: in std_logic
		);
	end component;

	component Quad 
		Port ( 	
			H1_CLKWR				: in std_logic;
			SysClk					: in std_logic;
			SynchedTick				: in std_logic;
			intDATA					: in std_logic_vector(31 downto 0);
			Exp0QuadDataOut			: out std_logic_vector(31 downto 0);
			Exp1QuadDataOut			: out std_logic_vector(31 downto 0);
			Exp2QuadDataOut			: out std_logic_vector(31 downto 0);
			Exp3QuadDataOut			: out std_logic_vector(31 downto 0);
			QuadA0DataOut			: out std_logic_vector(31 downto 0);
			QuadA1DataOut			: out std_logic_vector(31 downto 0);
			Exp0QuadCountRead		: in std_logic;
			Exp0QuadLEDStatusRead	: in std_logic;
			Exp0QuadLEDStatusWrite	: in std_logic;
			Exp0QuadInputRead		: in std_logic;
			Exp0QuadHomeRead		: in std_logic;
			Exp0QuadLatch0Read		: in std_logic;
			Exp0QuadLatch1Read		: in std_logic;
			Exp1QuadCountRead		: in std_logic;
			Exp1QuadLEDStatusRead	: in std_logic;
			Exp1QuadLEDStatusWrite	: in std_logic;
			Exp1QuadInputRead		: in std_logic;
			Exp1QuadHomeRead		: in std_logic;
			Exp1QuadLatch0Read		: in std_logic;
			Exp1QuadLatch1Read		: in std_logic;
			Exp2QuadCountRead		: in std_logic;
			Exp2QuadLEDStatusRead	: in std_logic;
			Exp2QuadLEDStatusWrite	: in std_logic;
			Exp2QuadInputRead		: in std_logic;
			Exp2QuadHomeRead		: in std_logic;
			Exp2QuadLatch0Read		: in std_logic;
			Exp2QuadLatch1Read		: in std_logic;
			Exp3QuadCountRead		: in std_logic;
			Exp3QuadLEDStatusRead	: in std_logic;
			Exp3QuadLEDStatusWrite	: in std_logic;
			Exp3QuadInputRead		: in std_logic;
			Exp3QuadHomeRead		: in std_logic;
			Exp3QuadLatch0Read		: in std_logic;
			Exp3QuadLatch1Read		: in std_logic;
			Exp0Quad_A				: in std_logic;
			Exp0Quad_B				: in std_logic;
			Exp0Quad_Reg			: in std_logic;
			Exp0Quad_FaultA			: in std_logic;
			Exp0Quad_FaultB			: in std_logic;
			Exp1Quad_A				: in std_logic;
			Exp1Quad_B				: in std_logic;
			Exp1Quad_Reg			: in std_logic;
			Exp1Quad_FaultA			: in std_logic;
			Exp1Quad_FaultB			: in std_logic;
			Exp2Quad_A				: in std_logic;
			Exp2Quad_B				: in std_logic;
			Exp2Quad_Reg			: in std_logic;
			Exp2Quad_FaultA			: in std_logic;
			Exp2Quad_FaultB			: in std_logic;
			Exp3Quad_A				: in std_logic;
			Exp3Quad_B				: in std_logic;
			Exp3Quad_Reg			: in std_logic;
			Exp3Quad_FaultA			: in std_logic;
			Exp3Quad_FaultB			: in std_logic;

			QA0CountRead			: in std_logic;
			QA0LEDStatusRead		: in std_logic;
			QA0LEDStatusWrite		: in std_logic;
			QA0InputRead			: in std_logic;
			QA0HomeRead				: in std_logic;
			QA0Latch0Read			: in std_logic;
			QA0Latch1Read			: in std_logic;

			QA1CountRead			: in std_logic;
			QA1LEDStatusRead		: in std_logic;
			QA1LEDStatusWrite		: in std_logic;
			QA1InputRead			: in std_logic;
			QA1HomeRead				: in std_logic;
			QA1Latch0Read			: in std_logic;
			QA1Latch1Read			: in std_logic;

			QA0_SigA				: in std_logic;
			QA0_SigB				: in std_logic;
			QA0_SigZ				: in std_logic;
			QA0_Home				: in std_logic;
			QA0_RegX_PosLmt			: in std_logic;
			QA0_RegY_NegLmt			: in std_logic;
			QA1_SigA				: in std_logic;
			QA1_SigB				: in std_logic;
			QA1_SigZ				: in std_logic;
			QA1_Home				: in std_logic;
			QA1_RegX_PosLmt			: in std_logic;
			QA1_RegY_NegLmt			: in std_logic;
			QA0AxisFault			: in std_logic_vector(2 downto 0);
			QA1AxisFault			: in std_logic_vector(2 downto 0)
		);
	end component;

	component ExpModuleLED
	   port (
			Reset				: in std_logic;
			H1_CLKWR			: in std_logic;
			SysClk				: in std_logic;
			SlowEnable			: in std_logic;
			SynchedTick			: in std_logic;
			intDATA				: in std_logic_vector (31 downto 0);
			expLedDataOut		: out std_logic_vector(3 downto 0);
			Exp0LEDWrite		: in std_logic;
			Exp0LED0Write		: in std_logic;
			Exp0LED1Write		: in std_logic;
			Exp0LEDRead			: in std_logic;
			Exp0LED0Read		: in std_logic;
			Exp0LED1Read		: in std_logic;
			Exp1LEDWrite		: in std_logic;
			Exp1LED0Write		: in std_logic;
			Exp1LED1Write		: in std_logic;
			Exp1LEDRead			: in std_logic;
			Exp1LED0Read		: in std_logic;
			Exp1LED1Read		: in std_logic;
			Exp2LEDWrite		: in std_logic;
			Exp2LED0Write		: in std_logic;
			Exp2LED1Write		: in std_logic;
			Exp2LEDRead			: in std_logic;
			Exp2LED0Read		: in std_logic;
			Exp2LED1Read		: in std_logic;
			Exp3LEDWrite		: in std_logic;
			Exp3LED0Write		: in std_logic;
			Exp3LED1Write		: in std_logic;
			Exp3LEDRead			: in std_logic;
			Exp3LED0Read		: in std_logic;
			Exp3LED1Read		: in std_logic;

			EEPROMAccessFlag	: in std_logic;
			DiscoveryComplete	: in std_logic; 

			ExpLEDOE			: out std_logic;
			ExpLEDLatch			: out std_logic;
			ExpLEDClk			: out std_logic;
			ExpLEDData			: out std_logic_vector (3 downto 0);
			ExpLEDSelect		: out std_logic_vector (3 downto 0);
			ExpOldAP2			: in std_logic_vector (3 downto 0)
		);
	end component;

	signal	IntADDR					: std_logic_vector (11 downto 0);

	signal	intData,
			AnlgDATA,
			cpuConfigDataOut,
			discoverIdDataOut,
			cpuLedDataOut,
			wdtDataOut,
			FPGAProgDOut,
			serialMemDataOut,
			d8DataOut,
			latencyDataOut,
			controlIoDataOut,
			mdtSimpDataOut0,
			mdtSimpDataOut1,
			ssiDataOut0,
			ssiDataOut1,
			Exp0QuadDataOut,
			Exp1QuadDataOut,
			Exp2QuadDataOut,
			Exp3QuadDataOut,
			QuadA0DataOut,
			QuadA1DataOut				: std_logic_vector(31 downto 0);	-- := X"0000_0000";
	signal	expLedDataOut				: std_logic_vector(3 downto 0);	-- := "0000";
	signal	H1_CLK,
			H1_CLK90,
			SysClk,
			SysRESET,				-- Combination of RESET pin and PLL not locked
			PowerUp						: std_logic;	-- := '0';
	signal	SynchedTick,
			SynchedTick60,
			Enable,
			SlowEnable,
			DLL_RST,
			DLL_LOCK					: std_logic;	-- := '0';
	signal	FPGAAccess,				-- Active when there is any read or write to the FPGA
			CPUConfigRead,
			CPUConfigWrite,
			WDTConfigRead,
			WDTConfigWrite,
			CPULEDRead,
			CPULEDWrite,
			FPGAProgrammedRead,
			FPGAProgrammedWrite			: std_logic;	-- := '0';
	signal	SerialMemXfaceWrite,
			SerialMemXfaceRead			: std_logic;	-- := '0';
	signal	ControlCardIDRead,
			Expansion1IDRead,
			Expansion2IDRead,
			Expansion3IDRead,
			Expansion4IDRead			: std_logic;	-- := '0';
	signal	Axis0LEDStatusRead,
			Axis0ControlOutputWrite		: std_logic;	-- := '0';
	signal	Axis0LEDConfigWrite,
			MDT_SSIDelayRead0,
			MDT_SSIDelayWrite0			: std_logic;	-- := '0';
	signal	MDT_SSIConfigWrite0,
			MDT_SSIConfigWrite1			: std_logic;	-- := '0';
	signal	Axis0IORead,
			Axis0IOWrite				: std_logic;	-- := '0';
	signal	Axis1LEDStatusRead,
			Axis1ControlOutputWrite		: std_logic;	-- := '0';
	signal	Axis1LEDConfigWrite,
			MDT_SSIDelayRead1,
			MDT_SSIDelayWrite1			: std_logic;	-- := '0';
	signal	Axis1IORead,
			Axis1IOWrite				: std_logic;	-- := '0';
	signal	PROFIBUSAddrRead,
			FPGAIDRead					: std_logic;	-- := '0';
	signal	Exp0LEDWrite,
			Exp1LEDWrite,
			Exp2LEDWrite,
			Exp3LEDWrite				: std_logic;	-- := '0';
	signal	Exp0LEDRead,
			Exp1LEDRead,
			Exp2LEDRead,
			Exp3LEDRead					: std_logic;	-- := '0';
	signal	Exp0LED0Write,
			Exp1LED0Write,
			Exp2LED0Write,
			Exp3LED0Write				: std_logic;	-- := '0';
	signal	Exp0LED1Write,
			Exp1LED1Write,
			Exp2LED1Write,
			Exp3LED1Write				: std_logic;	-- := '0';
	signal	Exp0LED0Read,
			Exp1LED0Read,
			Exp2LED0Read,
			Exp3LED0Read				: std_logic;	-- := '0';
	signal	Exp0LED1Read,
			Exp1LED1Read,
			Exp2LED1Read,
			Exp3LED1Read				: std_logic;	-- := '0';
	signal	ExpA0ReadCh0,
			ExpA0ReadCh1,
			ExpA1ReadCh0,
			ExpA1ReadCh1				: std_logic;	-- := '0';
	signal	ExpA2ReadCh0,
			ExpA2ReadCh1,
			ExpA3ReadCh0,
			ExpA3ReadCh1				: std_logic;	-- := '0';
	signal	Exp0SerialSelect,
			Exp1SerialSelect,
			Exp2SerialSelect,
			Exp3SerialSelect			: std_logic;	-- := '0';
	signal	Exp0D8_OE,
			Exp1D8_OE,
			Exp2D8_OE,
			Exp3D8_OE					: std_logic;	-- := '1';
	signal	Exp0D8_Clk,
			Exp0D8_DataIn,
			Exp0D8_DataOut,
			Exp0D8_Load,
			Exp0D8_Latch				: std_logic;	-- := '0';
	signal	Exp1D8_Clk,
			Exp1D8_DataIn,
			Exp1D8_DataOut,
			Exp1D8_Load,
			Exp1D8_Latch				: std_logic;	-- := '0';
	signal	Exp2D8_Clk,
			Exp2D8_DataIn,
			Exp2D8_DataOut,
			Exp2D8_Load,
			Exp2D8_Latch				: std_logic;	-- := '0';
	signal	Exp3D8_Clk,
			Exp3D8_DataIn,
			Exp3D8_DataOut,
			Exp3D8_Load,
			Exp3D8_Latch				: std_logic;	-- := '0';
	signal	ExpDIO8ConfigRead,
			ExpDIO8ConfigWrite			: std_logic_vector(3 downto 0);	--:= X"0";
	signal	ExpDIO8DinRead				: std_logic_vector(3 downto 0);	--:= X"0";
	signal	Exp0Q1_A,
			Exp0Q1_B,
			Exp0Q1_Reg,
			Exp0Q1_FaultA,
			Exp0Q1_FaultB				: std_logic;	-- := '0';
	signal	Exp1Q1_A,
			Exp1Q1_B,
			Exp1Q1_Reg,
			Exp1Q1_FaultA,
			Exp1Q1_FaultB				: std_logic;	-- := '0';
	signal	Exp2Q1_A,
			Exp2Q1_B,
			Exp2Q1_Reg,
			Exp2Q1_FaultA,
			Exp2Q1_FaultB				: std_logic;	-- := '0';
	signal	Exp3Q1_A,
			Exp3Q1_B,
			Exp3Q1_Reg,
			Exp3Q1_FaultA,
			Exp3Q1_FaultB				: std_logic;	-- := '0';
	signal	ExpA_CS_L,
			ExpA_CLK					: std_logic;	-- := '0';
	signal	ExpLEDSelect,
			ExpLEDData					: std_logic_vector (3 downto 0);	-- := X"0";
	signal	Exp0Mux,
			Exp1Mux,
			Exp2Mux,
			Exp3Mux						: std_logic_vector (1 downto 0);	-- := "00";
	signal	ExpA_DATA					: std_logic_vector (7 downto 0);	-- := X"00";
	signal	SerialMemoryClk,
			SerialMemoryDataIn,
			SerialMemoryDataOut,
			SerialMemoryDataControl		: std_logic;	-- := '0';
	signal	EEPROMAccessFlag,
			DiscoveryComplete			: std_logic;	-- := '0';
	signal	Exp_ID_CLK,
			Exp_ID_LATCH,
			Exp_ID_LOAD					: std_logic;	-- := '0';
	signal	ExpLEDOE,
			ExpLEDLatch,
			ExpLEDClk					: std_logic;	-- := '0'; 
	signal	LatencyCounterRead,
			MDTPresent,
			ANLGPresent,
			QUADPresent					: std_logic;	-- := '0';
	signal	SSISelect,
			SSI_Data,
			CtrlAxisData				: std_logic_vector (1 downto 0);	-- := "00";
	signal	MDT_SSIPositionRead0,
			MDT_SSIPositionRead1,
			MDT_SSIStatusRead0,
			MDT_SSIStatusRead1			: std_logic;	-- := '0';
	signal	AnlgPositionRead0,
			AnlgPositionRead1,
			AnlgStatusRead0,
			AnlgStatusRead1,
			ANLGAccess					: std_logic;	-- := '0';
	signal	M_AX0_SSI_CLK,
			M_AX1_SSI_CLK,
			M_AX0_INT_CLK,
			M_ADC_CLK					: std_logic;	-- := '0';
	signal	M_AX0_MDT_INT,
			M_AX1_MDT_INT				: std_logic;	-- := '0';
	signal	LoopTime					: std_logic_vector (2 downto 0);	-- := "000";
	signal	ExpOldAP2					: std_logic_vector (3 downto 0);	-- := X"0";
	signal	Exp0QuadCountRead,
			Exp0QuadLEDStatusRead,
			Exp0QuadLEDStatusWrite,
			Exp0QuadInputRead,
			Exp0QuadHomeRead,
			Exp0QuadLatch0Read,
			Exp0QuadLatch1Read			: std_logic;	-- := '0'; 
	signal	Exp1QuadCountRead,
			Exp1QuadLEDStatusRead,
			Exp1QuadLEDStatusWrite,
			Exp1QuadInputRead,
			Exp1QuadHomeRead,
			Exp1QuadLatch0Read,
			Exp1QuadLatch1Read			: std_logic;	-- := '0'; 
	signal	Exp2QuadCountRead,
			Exp2QuadLEDStatusRead,
			Exp2QuadLEDStatusWrite,
			Exp2QuadInputRead,
			Exp2QuadHomeRead,
			Exp2QuadLatch0Read,
			Exp2QuadLatch1Read			: std_logic;	-- := '0'; 
	signal	Exp3QuadCountRead,
			Exp3QuadLEDStatusRead,
			Exp3QuadLEDStatusWrite,
			Exp3QuadInputRead,
			Exp3QuadHomeRead,
			Exp3QuadLatch0Read,
			Exp3QuadLatch1Read			: std_logic;	-- := '0'; 
	signal	M_ADC_CS,
			M_ADC_DATA0,
			M_ADC_DATA1					: std_logic;	-- := '0';
	signal	QA0CountRead,
			QA0LEDStatusRead,
			QA0LEDStatusWrite,
			QA0InputRead,
			QA0HomeRead,
			QA0Latch0Read,
			QA0Latch1Read				: std_logic;	-- := '0';
	signal	QA1CountRead,
			QA1LEDStatusRead,
			QA1LEDStatusWrite,
			QA1InputRead,
			QA1HomeRead,
			QA1Latch0Read,
			QA1Latch1Read				: std_logic;	-- := '0';
	signal	QA0_SigA,
			QA0_SigB,
			QA1_SigA					: std_logic;	-- := '0';
	signal	QA0AxisFault,
			QA1AxisFault				: std_logic_vector (2 downto 0);	-- := "000";
	signal	ENET_Build					: std_logic;	-- := '0';

begin

	-- Test Points
	X_Reserved0 <= '0';
	X_Reserved1 <= '0';
	Debug0 <= '0';
	Debug1 <= '0';
	Debug2 <= '0';
	TestClock <= '0';
--	X_Reserved0 <= wdt_debug(0);
--	X_Reserved1 <= wdt_debug(1);
--	Debug0 <= wdt_debug(3);
--	TestClock <= Reg55555;

	FPGA_Test <= '1';

	CtrlAxisData(1 downto 0) <= M_ADC_DATA1 & M_ADC_DATA0;
	M_ADC_CLK <= ExpA_CLK;
	M_ADC_CS <= ExpA_CS_L;

	M_AX0_0 <= 	M_AX0_INT_CLK when MDTPresent='1' else
			M_ADC_CLK when ANLGPresent='1' else 'Z';

	-- The M_MUXED_ADC_CS_QA0_SIGA is an input which will be used by the QAx module
	-- when the ANLG module isn't present
	M_MUXED_ADC_CS_QA0_SIGA <= M_ADC_CS when ANLGPresent='1' else 'Z';

	QA0_SigA <= M_MUXED_ADC_CS_QA0_SIGA;		-- create alias
	QA0_SigB <= M_MUXED_ADC_DATA0_QA0_SIGB;		-- create alias
	QA1_SigA <= M_MUXED_ADC_DATA1_QA1_SIGA;		-- create alias

	M_ADC_DATA0 <= M_MUXED_ADC_DATA0_QA0_SIGB;	-- create alias
	M_ADC_DATA1 <= M_MUXED_ADC_DATA1_QA1_SIGA;	-- create alias

	ClkCtrl_1 : ClockControl
		port map (
			H1_PRIMARY	=> H1_CLK_IN, 		-- 60MHz input clock for CCC (PLL)
			H1_CLKWR	=> H1_CLKWR,		-- 60MHz input clock for general use
			H1_CLK		=> H1_CLK, 			-- 60MHz output clock
			H1_CLK90	=> H1_CLK90, 		-- 60MHz 90 deg output clock
			SysClk		=> SysClk, 			-- 30MHz output clock
			RESET		=> RESET,			-- Sysem reset from power monitor
			DLL_RST		=> DLL_RST, 		-- PLL Reset pulse generated by command from CPU
			DLL_LOCK	=> DLL_LOCK, 
			SysRESET	=> SysRESET,		-- Active when RESET active or PLL not locked
			PowerUp		=> PowerUp, 
			Enable		=> Enable, 			-- 7.5MHz system enable
			SlowEnable	=> SlowEnable		-- 3.75MHz system enable
		);

	TickSync_1 : TickSync
		port map (
			SysReset		=> SysRESET,		-- Main system Reset signal
			SysClk			=> SysClk,			-- 30MHz system clock
			H1_CLK			=> H1_CLK,			-- 60MHz System clock
			LOOPTICK		=> LOOPTICK,
			SynchedTick		=> SynchedTick,		-- Control loop timing pulse synchronized with the
												-- 30MHz system clock. Valid from rising-edge to rising-edge
			SynchedTick60	=> SynchedTick60	-- 60MHz system clock. Valid from rising-edge to rising-edge0
		);

	IntADDR <= "00" & ExtADDR(11 downto 2);		-- Convert External byte addresses to internal 32-bit word addresses


	Decode_1 : Decode
		port map (
			ADDR					=> IntADDR(11 downto 0),
			RD_L					=> RD_L,
			WR_L					=> WR_L,
			CS_L					=> CS_L,
			MDTPresent				=> MDTPresent,
			ANLGPresent				=> ANLGPresent,
			QUADPresent				=> QUADPresent,
			Exp0Mux					=> Exp0Mux(1 downto 0),
			Exp1Mux					=> Exp1Mux(1 downto 0),
			Exp2Mux					=> Exp2Mux(1 downto 0),
			Exp3Mux					=> Exp3Mux(1 downto 0), 
			FPGAAccess				=> FPGAAccess,
			ANLGAccess				=> ANLGAccess,
			FPGAIDRead				=> FPGAIDRead,
			CPUConfigRead			=> CPUConfigRead,
			CPUConfigWrite			=> CPUConfigWrite, 
			WDTConfigRead			=> WDTConfigRead,
			WDTConfigWrite			=> WDTConfigWrite,
			CPULEDRead				=> CPULEDRead,
			CPULEDWrite				=> CPULEDWrite,
			FPGAProgrammedRead		=> FPGAProgrammedRead,
			FPGAProgrammedWrite		=> FPGAProgrammedWrite,
			ControlCardIDRead		=> ControlCardIDRead, 
			Expansion1IDRead		=> Expansion1IDRead,
			Expansion2IDRead		=> Expansion2IDRead,
			Expansion3IDRead		=> Expansion3IDRead,
			Expansion4IDRead		=> Expansion4IDRead, 
			MDT_SSIPositionRead0	=> MDT_SSIPositionRead0,
			MDT_SSIStatusRead0		=> MDT_SSIStatusRead0,
			MDT_SSIConfigWrite0		=> MDT_SSIConfigWrite0,
			ANLGPositionRead0		=> AnlgPositionRead0,
			AnlgStatusRead0			=> AnlgStatusRead0,
			Axis0ControlOutputWrite	=> Axis0ControlOutputWrite,
			Axis0LEDStatusRead		=> Axis0LEDStatusRead,
			Axis0LEDConfigWrite		=> Axis0LEDConfigWrite,
			MDT_SSIDelayRead0		=> MDT_SSIDelayRead0,
			MDT_SSIDelayWrite0		=> MDT_SSIDelayWrite0,
			Axis0IORead				=> Axis0IORead,
			Axis0IOWrite			=> Axis0IOWrite, 
			MDT_SSIPositionRead1	=> MDT_SSIPositionRead1,
			MDT_SSIStatusRead1		=> MDT_SSIStatusRead1,
			MDT_SSIConfigWrite1		=> MDT_SSIConfigWrite1,
			ANLGPositionRead1		=> AnlgPositionRead1,
			AnlgStatusRead1			=> AnlgStatusRead1,
			Axis1ControlOutputWrite	=> Axis1ControlOutputWrite,
			Axis1LEDStatusRead		=> Axis1LEDStatusRead,
			Axis1LEDConfigWrite		=> Axis1LEDConfigWrite, 
			MDT_SSIDelayRead1		=> MDT_SSIDelayRead1,
			MDT_SSIDelayWrite1		=> MDT_SSIDelayWrite1,
			Axis1IORead				=> Axis1IORead,
			Axis1IOWrite			=> Axis1IOWrite, 
			LatencyCounterRead		=> LatencyCounterRead,
			PROFIBUSAddrRead		=> PROFIBUSAddrRead,
			SerialMemXfaceRead		=> SerialMemXfaceRead,
			SerialMemXfaceWrite		=> SerialMemXfaceWrite,  
			ExpA0ReadCh0			=> ExpA0ReadCh0,
			ExpA0ReadCh1			=> ExpA0ReadCh1,
			ExpA1ReadCh0			=> ExpA1ReadCh0,
			ExpA1ReadCh1			=> ExpA1ReadCh1, 
			ExpA2ReadCh0			=> ExpA2ReadCh0,
			ExpA2ReadCh1			=> ExpA2ReadCh1,
			ExpA3ReadCh0			=> ExpA3ReadCh0,
			ExpA3ReadCh1			=> ExpA3ReadCh1, 
			ExpDIO8ConfigRead		=> ExpDIO8ConfigRead(3 downto 0),
			ExpDIO8ConfigWrite		=> ExpDIO8ConfigWrite(3 downto 0),
			ExpDIO8DinRead			=> ExpDIO8DinRead(3 downto 0),
			Exp0QuadCountRead		=> Exp0QuadCountRead,
			Exp0QuadLEDStatusRead	=> Exp0QuadLEDStatusRead,
			Exp0QuadLEDStatusWrite	=> Exp0QuadLEDStatusWrite,
			Exp0QuadInputRead		=> Exp0QuadInputRead, 
			Exp0QuadHomeRead		=> Exp0QuadHomeRead,
			Exp0QuadLatch0Read		=> Exp0QuadLatch0Read,
			Exp0QuadLatch1Read		=> Exp0QuadLatch1Read, 
			Exp1QuadCountRead		=> Exp1QuadCountRead,
			Exp1QuadLEDStatusRead	=> Exp1QuadLEDStatusRead,
			Exp1QuadLEDStatusWrite	=> Exp1QuadLEDStatusWrite,
			Exp1QuadInputRead		=> Exp1QuadInputRead, 
			Exp1QuadHomeRead		=> Exp1QuadHomeRead,
			Exp1QuadLatch0Read		=> Exp1QuadLatch0Read,
			Exp1QuadLatch1Read		=> Exp1QuadLatch1Read,
			Exp2QuadCountRead		=> Exp2QuadCountRead,
			Exp2QuadLEDStatusRead	=> Exp2QuadLEDStatusRead,
			Exp2QuadLEDStatusWrite	=> Exp2QuadLEDStatusWrite,
			Exp2QuadInputRead		=> Exp2QuadInputRead, 
			Exp2QuadHomeRead		=> Exp2QuadHomeRead,
			Exp2QuadLatch0Read		=> Exp2QuadLatch0Read,
			Exp2QuadLatch1Read		=> Exp2QuadLatch1Read,
			Exp3QuadCountRead		=> Exp3QuadCountRead,
			Exp3QuadLEDStatusRead	=> Exp3QuadLEDStatusRead,
			Exp3QuadLEDStatusWrite	=> Exp3QuadLEDStatusWrite,
			Exp3QuadInputRead		=> Exp3QuadInputRead, 
			Exp3QuadHomeRead		=> Exp3QuadHomeRead,
			Exp3QuadLatch0Read		=> Exp3QuadLatch0Read,
			Exp3QuadLatch1Read		=> Exp3QuadLatch1Read,
			Exp0LEDWrite			=> Exp0LEDWrite,
			Exp0LED0Write			=> Exp0LED0Write,
			Exp0LED1Write			=> Exp0LED1Write,
			Exp0LEDRead				=> Exp0LEDRead,
			Exp0LED0Read			=> Exp0LED0Read,
			Exp0LED1Read			=> Exp0LED1Read,
			Exp1LEDWrite			=> Exp1LEDWrite,
			Exp1LED0Write			=> Exp1LED0Write,
			Exp1LED1Write			=> Exp1LED1Write,
			Exp1LEDRead				=> Exp1LEDRead,
			Exp1LED0Read			=> Exp1LED0Read,
			Exp1LED1Read			=> Exp1LED1Read,
			Exp2LEDWrite			=> Exp2LEDWrite,
			Exp2LED0Write			=> Exp2LED0Write,
			Exp2LED1Write			=> Exp2LED1Write,
			Exp2LEDRead				=> Exp2LEDRead,
			Exp2LED0Read			=> Exp2LED0Read,
			Exp2LED1Read			=> Exp2LED1Read,
			Exp3LEDWrite			=> Exp3LEDWrite,
			Exp3LED0Write			=> Exp3LED0Write,
			Exp3LED1Write			=> Exp3LED1Write,
			Exp3LEDRead				=> Exp3LEDRead,
			Exp3LED0Read			=> Exp3LED0Read,
			Exp3LED1Read			=> Exp3LED1Read,

			QA0CountRead			=> QA0CountRead,
			QA0LEDStatusRead		=> QA0LEDStatusRead,
			QA0LEDStatusWrite		=> QA0LEDStatusWrite,
			QA0InputRead			=> QA0InputRead,
			QA0HomeRead				=> QA0HomeRead,
			QA0Latch0Read			=> QA0Latch0Read,
			QA0Latch1Read			=> QA0Latch1Read,

			QA1CountRead			=> QA1CountRead,
			QA1LEDStatusRead		=> QA1LEDStatusRead,
			QA1LEDStatusWrite		=> QA1LEDStatusWrite,
			QA1InputRead			=> QA1InputRead,
			QA1HomeRead				=> QA1HomeRead,
			QA1Latch0Read			=> QA1Latch0Read,
			QA1Latch1Read			=> QA1Latch1Read
		);

	CtrlOut_1 : ControlOutput
		port map (
			H1_CLKWR	 		=> H1_CLKWR,
			SysClk				=> SysClk,
			RESET				=> SysRESET,
			SynchedTick			=> SynchedTick,
			intDATA				=> intDATA(15 downto 0),
			ControlOutputWrite	=> Axis0ControlOutputWrite,
			M_OUT_CLK			=> M_OUT0_CLK,
			M_OUT_DATA			=> M_OUT0_DATA,
			M_OUT_CONTROL		=> M_OUT0_CONTROL,
			PowerUp				=> PowerUp,
			Enable				=> Enable
		);

	CtrlOut_2 : ControlOutput
		port map (
			H1_CLKWR	 		=> H1_CLKWR,
			SysClk				=> SysClk,
			RESET				=> SysRESET,
			SynchedTick			=> SynchedTick,
			intDATA				=> intDATA(15 downto 0),
			ControlOutputWrite	=> Axis1ControlOutputWrite,
			M_OUT_CLK			=> M_OUT1_CLK,
			M_OUT_DATA			=> M_OUT1_DATA,
			M_OUT_CONTROL		=> M_OUT1_CONTROL,
			PowerUp				=> PowerUp,
			Enable				=> Enable
		);

	MDTSSIRoute_1 : MDTSSIRoute
		port map (
			SSISelect		=> SSISelect(1 downto 0),
			M_AX0_INT_CLK	=> M_AX0_INT_CLK,
			M_AX1_INT_CLK	=> M_AX1_INT_CLK,
			M_AX0_SSI_CLK	=> M_AX0_SSI_CLK,
			M_AX1_SSI_CLK	=> M_AX1_SSI_CLK, 
			M_AX0_MDT_INT	=> M_AX0_MDT_INT,
			M_AX1_MDT_INT	=> M_AX1_MDT_INT
		);

	MDTTop_1 : MDTTopSimp
		port map (
			SysReset					=> SysRESET,
			H1_CLK						=> H1_CLK, 
			H1_CLKWR					=> H1_CLKWR,
			H1_CLK90					=> H1_CLK90,
			SynchedTick60				=> SynchedTick60,
			intDATA (31 downto 0)		=> intDATA(31 downto 0),
			mdtSimpDataOut(31 downto 0)	=> mdtSimpDataOut0(31 downto 0),
			PositionRead				=> MDT_SSIPositionRead0,	
			StatusRead					=> MDT_SSIStatusRead0,
			ParamWrite					=> MDT_SSIConfigWrite0,
			M_INT_CLK					=> M_AX0_MDT_INT, 
			M_RET_DATA					=> M_AX0_RET_DATA,
			SSI_Data					=> SSI_Data(0),
			SSISelect					=> SSISelect(0)
		);

	MDTTop_2 : MDTTopSimp
		port map (
			SysReset					=> SysRESET,
			H1_CLK						=> H1_CLK, 
			H1_CLKWR					=> H1_CLKWR,
			H1_CLK90					=> H1_CLK90,
			SynchedTick60				=> SynchedTick60,
			intDATA (31 downto 0)		=> intDATA(31 downto 0),
			mdtSimpDataOut(31 downto 0)	=> mdtSimpDataOut1(31 downto 0),
			PositionRead				=> MDT_SSIPositionRead1,	
			StatusRead					=> MDT_SSIStatusRead1,
			ParamWrite					=> MDT_SSIConfigWrite1,
			M_INT_CLK					=> M_AX1_MDT_INT, 
			M_RET_DATA					=> M_AX1_RET_DATA,
			SSI_Data					=> SSI_Data(1),
			SSISelect					=> SSISelect(1)
		);

	SSITop_1 : SSITop
		port map (
			H1_CLKWR					=> H1_CLKWR,
			SysClk						=> SysClk,
			Enable						=> Enable,
			SlowEnable					=> SlowEnable,
			SynchedTick					=> SynchedTick,
			intDATA (31 downto 0)		=> intDATA(31 downto 0),
			ssiDataOut(31 downto 0)		=> ssiDataOut0(31 downto 0),
			PositionRead				=> MDT_SSIPositionRead0,
			StatusRead					=> MDT_SSIStatusRead0,
			ParamWrite1					=> MDT_SSIConfigWrite0,
			ParamWrite2					=> MDT_SSIDelayWrite0,
			SSI_CLK						=> M_AX0_SSI_CLK,
			SSI_DATA					=> SSI_Data(0),
			SSISelect					=> SSISelect(0)
		);

	SSITop_2 : SSITop
		port map (
			H1_CLKWR					=> H1_CLKWR,
			SysClk						=> SysClk,
			Enable						=> Enable,
			SlowEnable					=> SlowEnable,
			SynchedTick					=> SynchedTick,
			intDATA (31 downto 0)		=> intDATA(31 downto 0),
			ssiDataOut(31 downto 0)		=> ssiDataOut1(31 downto 0),
			PositionRead				=> MDT_SSIPositionRead1,
			StatusRead					=> MDT_SSIStatusRead1,
			ParamWrite1					=> MDT_SSIConfigWrite1,
			ParamWrite2					=> MDT_SSIDelayWrite1,
			SSI_CLK						=> M_AX1_SSI_CLK,
			SSI_DATA					=> SSI_Data(1),
			SSISelect					=> SSISelect(1)
		);

	CtrlIO_1 : ControlIO
		port map (
			RESET				=> SysRESET,
			H1_CLKWR			=> H1_CLKWR,
			SysClk				=> SysClk,
			Enable				=> Enable,
			SynchedTick			=> SynchedTick,
			intDATA				=> intDATA(31 downto 0),
			controlIoDataOut	=> controlIoDataOut(31 downto 0),
			Axis0LEDStatusRead	=> Axis0LEDStatusRead,
			Axis0LEDConfigWrite	=> Axis0LEDConfigWrite,
			Axis0IORead			=> Axis0IORead,
			Axis0IOWrite		=> Axis0IOWrite, 
			Axis1LEDStatusRead	=> Axis1LEDStatusRead,
			Axis1LEDConfigWrite	=> Axis1LEDConfigWrite,
			Axis1IORead			=> Axis1IORead,
			Axis1IOWrite		=> Axis1IOWrite, 
			M_IO_OE				=> M_IO_OE,
			M_IO_LOAD			=> M_IO_LOAD,
			M_IO_LATCH			=> M_IO_LATCH,
			M_IO_CLK			=> M_IO_CLK,
			M_IO_DATAOut		=> M_IO_DATAOut,
			M_IO_DATAIn			=> M_IO_DATAIn, 
			M_ENABLE			=> M_ENABLE(1 downto 0),
			M_FAULT				=> M_FAULT(1 downto 0),
			PowerUp				=> PowerUp,
			QUADPresent			=> QUADPresent,
			QA0AxisFault		=> QA0AxisFault(2 downto 0),
			QA1AxisFault		=> QA1AxisFault(2 downto 0)
		);

	DiscID_1 : DiscoverID
		port map (
			RESET				=> SysRESET,
			SysClk				=> SysClk,
			SlowEnable			=> SlowEnable,
			discoverIdDataOut	=> discoverIdDataOut(31 downto 0),
			FPGAIDRead			=> FPGAIDRead,
			ControlCardIDRead	=> ControlCardIDRead, 
			Expansion1IDRead	=> Expansion1IDRead,
			Expansion2IDRead	=> Expansion2IDRead,
			Expansion3IDRead	=> Expansion3IDRead,
			Expansion4IDRead	=> Expansion4IDRead,
			M_Card_ID_CLK		=> M_Card_ID_CLK,
			M_Card_ID_DATA		=> M_Card_ID_DATA,
			M_Card_ID_LATCH		=> M_Card_ID_LATCH,
			M_Card_ID_LOAD		=> M_Card_ID_LOAD, 
			Exp_ID_CLK			=> Exp_ID_CLK,
			Exp_ID_DATA			=> Exp_ID_DATA,
			Exp_ID_LATCH		=> Exp_ID_LATCH,
			Exp_ID_LOAD			=> Exp_ID_LOAD, 
			Exp0Mux				=> Exp0Mux(1 downto 0),
			Exp1Mux				=> Exp1Mux(1 downto 0),
			Exp2Mux				=> Exp2Mux(1 downto 0),
			Exp3Mux				=> Exp3Mux(1 downto 0), 
			MDTPresent			=> MDTPresent,
			ANLGPresent			=> ANLGPresent,
			QUADPresent			=> QUADPresent,
			DiscoveryComplete	=> DiscoveryComplete, 
			ExpOldAP2			=> ExpOldAP2(3 downto 0),
			ENET_Build			=> ENET_Build
		);

	RtdExpIDLED_1 : RtdExpIDLED
		port map (
			DiscoveryComplete	=> DiscoveryComplete,
			Exp_ID_CLK			=> Exp_ID_CLK,
			Exp_ID_LATCH		=> Exp_ID_LATCH,
			Exp_ID_LOAD			=> Exp_ID_LOAD,

			ExpLEDOE			=> ExpLEDOE,
			ExpLEDLatch			=> ExpLEDLatch,
			ExpLEDClk			=> ExpLEDClk,

			Exp_Mxd_ID_CLK		=> Exp_Mxd_ID_CLK,
			Exp_Mxd_ID_LATCH	=> Exp_Mxd_ID_LATCH,
			Exp_Mxd_ID_LOAD		=> Exp_Mxd_ID_LOAD
		);

	CPULED_1 : CPULED
		port map (
			RESET				=> SysRESET,
			H1_CLKWR			=> H1_CLKWR,
			intDATA				=> intDATA(31 downto 0),
			cpuLedDataOut		=> cpuLedDataOut(31 downto 0),
			CPULEDWrite			=> CPULEDWrite,
			CPUStatLEDDrive		=> CPUStatLEDDrive(1 downto 0)
		);

	CPUCnf_1 : CPUConfig
		port map (
			RESET							=> RESET,		-- External Reset from power monitor and watchdog IC.
			SysRESET						=> SysRESET,	-- Main internal reset. Used to clear DLL_RST
			H1_CLKWR						=> H1_CLKWR,
			H1_PRIMARY						=> H1_CLKWR,   -- Added for Microchip
			intDATA(31 downto 0)			=> intDATA(31 downto 0), 
			cpuConfigDataOut(31 downto 0)	=> cpuConfigDataOut(31 downto 0),
			CPUConfigWrite					=> CPUConfigWrite,
			M_DRV_EN_L						=> M_DRV_EN_L,
			HALT_DRIVE_L					=> HALT_DRIVE_L,
			DLL_LOCK						=> DLL_LOCK,
			DLL_RST							=> DLL_RST,
			LoopTime(2 downto 0)			=> LoopTime(2 downto 0),
			ENET_Build						=> ENET_Build
		);

	WDT_1 : WDT
		port map (
			RESET						=> RESET,
			SysRESET					=> SysRESET,
			H1_CLKWR					=> H1_CLKWR,
			SysClk						=> SysClk, 
			intDATA(31 downto 0)		=> intDATA(31 downto 0),
			wdtDataOut(31 downto 0)		=> wdtDataOut(31 downto 0),
			FPGAProgDOut(31 downto 0)	=> FPGAProgDOut(31 downto 0),
			FPGAAccess					=> FPGAAccess,
			WDTConfigWrite				=> WDTConfigWrite, 
			FPGAProgrammedWrite			=> FPGAProgrammedWrite,		--	Write and read to verify Igloo2 FPGA is programmed
			SlowEnable					=> SlowEnable,
			HALT_DRIVE_L				=> HALT_DRIVE_L,
			WD_TICKLE					=> WD_TICKLE,
			WD_RST_L					=> WD_RST_L
		);

	ExpSigRoute_1 : ExpSigRoute
		port map (
			ExpMux(1 downto 0)		=> Exp0Mux(1 downto 0), 
			ExpSerialSelect			=> Exp0SerialSelect, 
			ExpLEDSelect			=> ExpLEDSelect(0), 
			ExpLEDData				=> ExpLEDData(0), 
			ExpData(5 downto 0)		=> Exp0Data(5 downto 0),
--			ExpData(5 downto 0)		=> open,
			ExpA_CS_L				=> ExpA_CS_L, 
			ExpA_CLK				=> ExpA_CLK, 
			ExpA_DATA(1 downto 0)	=> ExpA_DATA(1 downto 0), 
			SerialMemoryDataIn		=> SerialMemoryDataIn, 
			SerialMemoryDataOut		=> SerialMemoryDataOut, 
			SerialMemoryDataControl	=> SerialMemoryDataControl, 
			SerialMemoryClk			=> SerialMemoryClk,
			ExpD8_DataIn			=> Exp0D8_DataIn, 
			ExpD8_Clk				=> Exp0D8_Clk, 
			ExpD8_DataOut			=> Exp0D8_DataOut, 
			ExpD8_OE				=> Exp0D8_OE,	
			ExpD8_Load				=> Exp0D8_Load, 
			ExpD8_Latch				=> Exp0D8_Latch,
			ExpQ1_A					=> Exp0Q1_A, 
			ExpQ1_B					=> Exp0Q1_B, 
			ExpQ1_Reg				=> Exp0Q1_Reg, 
			ExpQ1_FaultA			=> Exp0Q1_FaultA, 
			ExpQ1_FaultB			=> Exp0Q1_FaultB
		);

	ExpSigRoute_2 : ExpSigRoute
		port map (
			ExpMux(1 downto 0)		 => Exp1Mux(1 downto 0), 
			ExpSerialSelect			 => Exp1SerialSelect, 
			ExpLEDSelect			 => ExpLEDSelect(1), 
			ExpLEDData				 => ExpLEDData(1), 
			ExpData(5 downto 0)		 => Exp1Data(5 downto 0), 
--			ExpData(5 downto 0)		 => open, 
			ExpA_CS_L				 => ExpA_CS_L, 
			ExpA_CLK				 => ExpA_CLK, 
			ExpA_DATA(1 downto 0)	 => ExpA_DATA(3 downto 2), 
			SerialMemoryDataIn		 => SerialMemoryDataIn, 
			SerialMemoryDataOut		 => SerialMemoryDataOut, 
			SerialMemoryDataControl	 => SerialMemoryDataControl, 
			SerialMemoryClk			 => SerialMemoryClk,
			ExpD8_DataIn			 => Exp1D8_DataIn, 
			ExpD8_Clk				 => Exp1D8_Clk, 
			ExpD8_DataOut			 => Exp1D8_DataOut, 
			ExpD8_OE				 => Exp1D8_OE, 
			ExpD8_Load				 => Exp1D8_Load, 
			ExpD8_Latch				 => Exp1D8_Latch,
			ExpQ1_A					 => Exp1Q1_A, 
			ExpQ1_B					 => Exp1Q1_B, 
			ExpQ1_Reg				 => Exp1Q1_Reg, 
			ExpQ1_FaultA			 => Exp1Q1_FaultA, 
			ExpQ1_FaultB			 => Exp1Q1_FaultB
		);

	ExpSigRoute_3 : ExpSigRoute
		port map (
			ExpMux(1 downto 0)		=> Exp2Mux(1 downto 0), 
			ExpSerialSelect			=> Exp2SerialSelect, 
			ExpLEDSelect			=> ExpLEDSelect(2), 
			ExpLEDData				=> ExpLEDData(2), 
			ExpData(5 downto 0)		=> Exp2Data(5 downto 0),
			ExpA_CS_L				=> ExpA_CS_L, 
			ExpA_CLK				=> ExpA_CLK, 
			ExpA_DATA(1 downto 0)	=> ExpA_DATA(5 downto 4), 
			SerialMemoryDataIn		=> SerialMemoryDataIn, 
			SerialMemoryDataOut		=> SerialMemoryDataOut, 
			SerialMemoryDataControl	=> SerialMemoryDataControl, 
			SerialMemoryClk			=> SerialMemoryClk,
			ExpD8_DataIn			=> Exp2D8_DataIn, 
			ExpD8_Clk				=> Exp2D8_Clk, 
			ExpD8_DataOut			=> Exp2D8_DataOut, 
			ExpD8_OE				=> Exp2D8_OE, 
			ExpD8_Load				=> Exp2D8_Load, 
			ExpD8_Latch				=> Exp2D8_Latch,
			ExpQ1_A					=> Exp2Q1_A, 
			ExpQ1_B					=> Exp2Q1_B, 
			ExpQ1_Reg				=> Exp2Q1_Reg, 
			ExpQ1_FaultA			=> Exp2Q1_FaultA, 
			ExpQ1_FaultB			=> Exp2Q1_FaultB
		);

	ExpSigRoute_4 : ExpSigRoute
		port map (
			ExpMux(1 downto 0)		 => Exp3Mux(1 downto 0), 
			ExpSerialSelect			 => Exp3SerialSelect, 
			ExpLEDSelect			 => ExpLEDSelect(3), 
			ExpLEDData				 => ExpLEDData(3), 
			ExpData(5 downto 0)		 => Exp3Data(5 downto 0),
			ExpA_CS_L				 => ExpA_CS_L, 
			ExpA_Clk				 => ExpA_CLK, 
			ExpA_DATA(1 downto 0)	 => ExpA_DATA(7 downto 6), 
			SerialMemoryDataIn		 => SerialMemoryDataIn, 
			SerialMemoryDataOut		 => SerialMemoryDataOut, 
			SerialMemoryDataControl	 => SerialMemoryDataControl, 
			SerialMemoryClk			 => SerialMemoryClk,
			ExpD8_DataIn			 => Exp3D8_DataIn, 
			ExpD8_Clk				 => Exp3D8_Clk, 
			ExpD8_DataOut			 => Exp3D8_DataOut, 
			ExpD8_OE				 => Exp3D8_OE, 
			ExpD8_Load				 => Exp3D8_Load, 
			ExpD8_Latch				 => Exp3D8_Latch,
			ExpQ1_A					 => Exp3Q1_A, 
			ExpQ1_B					 => Exp3Q1_B, 
			ExpQ1_Reg				 => Exp3Q1_Reg, 
			ExpQ1_FaultA			 => Exp3Q1_FaultA, 
			ExpQ1_FaultB			 => Exp3Q1_FaultB
		);

	Analog_1 : Analog
		port map (
			SysReset			=> SysRESET,
			H1_CLKWR			=> H1_CLKWR,
			SysClk				=> SysClk,
			SlowEnable			=> SlowEnable,
			SynchedTick			=> SynchedTick,
			SynchedTick60		=> SynchedTick60,
			LoopTime			=> LoopTime(2 downto 0),
			AnlgDATA			=> AnlgDATA(31 downto 0),
			AnlgPositionRead0	=> AnlgPositionRead0,
			AnlgPositionRead1	=> AnlgPositionRead1, 
			ExpA0ReadCh0		=> ExpA0ReadCh0,
			ExpA0ReadCh1		=> ExpA0ReadCh1,
			ExpA1ReadCh0		=> ExpA1ReadCh0,
			ExpA1ReadCh1		=> ExpA1ReadCh1, 
			ExpA2ReadCh0		=> ExpA2ReadCh0,
			ExpA2ReadCh1		=> ExpA2ReadCh1,
			ExpA3ReadCh0		=> ExpA3ReadCh0,
			ExpA3ReadCh1		=> ExpA3ReadCh1, 
			ExpA_CS_L			=> ExpA_CS_L,
			ExpA_CLK			=> ExpA_CLK,
			CtrlAxisData		=> CtrlAxisData(1 downto 0), 
			ExpA_DATA			=> ExpA_DATA(7 downto 0)
		);

	SerMemInt_1 : SerialMemoryInterface
		port map (
			SysReset				=> SysRESET,
			H1_CLK					=> H1_CLK,
			SysClk					=> SysClk,
			SlowEnable				=> SlowEnable,
			intDATA					=> intDATA(31 downto 0),
			serialMemDataOut		=> serialMemDataOut(31 downto 0), 
			SerialMemXfaceWrite		=> SerialMemXfaceWrite,
			SerialMemoryDataIn		=> SerialMemoryDataIn,
			SerialMemoryDataOut		=> SerialMemoryDataOut, 
			SerialMemoryDataControl	=> SerialMemoryDataControl,
			SerialMemoryClk			=> SerialMemoryClk,
			Exp0SerialSelect		=> Exp0SerialSelect,
			Exp1SerialSelect		=> Exp1SerialSelect, 
			Exp2SerialSelect		=> Exp2SerialSelect,
			Exp3SerialSelect		=> Exp3SerialSelect,
			EEPROMAccessFlag		=> EEPROMAccessFlag,
			M_SPROM_CLK				=> M_SPROM_CLK,
			M_SPROM_DATA			=> M_SPROM_DATA
		);

	DIO8_1 : DIO8
		port map (
			RESET				=> SysRESET,
			H1_CLKWR			=> H1_CLKWR,
			SysClk				=> SysClk,
			SlowEnable			=> SlowEnable,
			SynchedTick			=> SynchedTick,
			intDATA				=> intDATA(31 downto 0),
			d8DataOut			=> d8DataOut(31 downto 0), 
			ExpDIO8ConfigRead	=> ExpDIO8ConfigRead(3 downto 0),
			ExpDIO8ConfigWrite	=> ExpDIO8ConfigWrite(3 downto 0),
			ExpDIO8DinRead		=> ExpDIO8DinRead(3 downto 0),
			Exp0D8_DataIn		=> Exp0D8_DataIn,
			Exp0D8_Clk			=> Exp0D8_Clk,
			Exp0D8_DataOut		=> Exp0D8_DataOut,
			Exp0D8_OE			=> Exp0D8_OE,
			Exp0D8_Load			=> Exp0D8_Load,
			Exp0D8_Latch		=> Exp0D8_Latch,
			Exp1D8_DataIn		=> Exp1D8_DataIn,
			Exp1D8_Clk			=> Exp1D8_Clk,
			Exp1D8_DataOut		=> Exp1D8_DataOut,
			Exp1D8_OE			=> Exp1D8_OE,
			Exp1D8_Load			=> Exp1D8_Load,
			Exp1D8_Latch		=> Exp1D8_Latch,
			Exp2D8_DataIn		=> Exp2D8_DataIn,
			Exp2D8_Clk			=> Exp2D8_Clk,
			Exp2D8_DataOut		=> Exp2D8_DataOut,
			Exp2D8_OE			=> Exp2D8_OE,
			Exp2D8_Load			=> Exp2D8_Load,
			Exp2D8_Latch		=> Exp2D8_Latch,
			Exp3D8_DataIn		=> Exp3D8_DataIn,
			Exp3D8_Clk			=> Exp3D8_Clk,
			Exp3D8_DataOut		=> Exp3D8_DataOut,
			Exp3D8_OE			=> Exp3D8_OE,
			Exp3D8_Load			=> Exp3D8_Load,
			Exp3D8_Latch		=> Exp3D8_Latch
		); 

	Quad_1 : Quad
		port map (
			H1_CLKWR						=> H1_CLKWR, 
			SysClk							=> SysClk, 
			SynchedTick						=> SynchedTick, 
			intDATA(31 downto 0)			=> intDATA(31 downto 0),
			Exp0QuadDataOut(31 downto 0)	=> Exp0QuadDataOut(31 downto 0),
			Exp1QuadDataOut(31 downto 0)	=> Exp1QuadDataOut(31 downto 0),
			Exp2QuadDataOut(31 downto 0)	=> Exp2QuadDataOut(31 downto 0),
			Exp3QuadDataOut(31 downto 0)	=> Exp3QuadDataOut(31 downto 0),
			QuadA0DataOut(31 downto 0)		=> QuadA0DataOut(31 downto 0),
			QuadA1DataOut(31 downto 0)		=> QuadA1DataOut(31 downto 0),
			Exp0QuadCountRead				=> Exp0QuadCountRead, 
			Exp0QuadLEDStatusRead			=> Exp0QuadLEDStatusRead, 
			Exp0quadLEDStatusWrite			=> Exp0QuadLEDStatusWrite, 
			Exp0QuadInputRead				=> Exp0QuadInputRead, 
			Exp0QuadHomeRead				=> Exp0QuadHomeRead, 
			Exp0QuadLatch0Read				=> Exp0QuadLatch0Read, 
			Exp0QuadLatch1Read				=> Exp0QuadLatch1Read, 
			Exp1QuadCountRead				=> Exp1QuadCountRead, 
			Exp1QuadLEDStatusRead			=> Exp1QuadLEDStatusRead, 
			Exp1QuadLEDStatusWrite			=> Exp1QuadLEDStatusWrite, 
			Exp1QuadInputRead				=> Exp1QuadInputRead, 
			Exp1QuadHomeRead				=> Exp1QuadHomeRead, 
			Exp1QuadLatch0Read				=> Exp1QuadLatch0Read, 
			Exp1QuadLatch1Read				=> Exp1QuadLatch1Read,
			Exp2quadCountRead				=> Exp2QuadCountRead, 
			Exp2QuadLEDStatusRead			=> Exp2QuadLEDStatusRead, 
			Exp2QuadLEDStatusWrite			=> Exp2QuadLEDStatusWrite, 
			Exp2QuadInputRead				=> Exp2QuadInputRead, 
			Exp2QuadHomeRead				=> Exp2QuadHomeRead, 
			Exp2QuadLatch0Read				=> Exp2QuadLatch0Read, 
			Exp2QuadLatch1Read				=> Exp2QuadLatch1Read,
			Exp3QuadCountRead				=> Exp3QuadCountRead, 
			Exp3QuadLEDStatusRead			=> Exp3QuadLEDStatusRead, 
			Exp3QuadLEDStatusWrite			=> Exp3QuadLEDStatusWrite, 
			Exp3QuadInputRead				=> Exp3QuadInputRead, 
			Exp3QuadHomeRead				=> Exp3QuadHomeRead, 
			Exp3QuadLatch0Read				=> Exp3QuadLatch0Read, 
			Exp3QuadLatch1Read				=> Exp3QuadLatch1Read,
			Exp0Quad_A						=> Exp0Q1_A, 
			Exp0Quad_B						=> Exp0Q1_B, 
			Exp0Quad_Reg					=> Exp0Q1_Reg, 
			Exp0Quad_FaultA					=> Exp0Q1_FaultA, 
			Exp0Quad_FaultB					=> Exp0Q1_FaultB,
			Exp1Quad_A						=> Exp1Q1_A, 
			Exp1Quad_B						=> Exp1Q1_B, 
			Exp1Quad_Reg					=> Exp1Q1_Reg, 
			Exp1Quad_FaultA					=> Exp1Q1_FaultA, 
			Exp1Quad_FaultB					=> Exp1Q1_FaultB,
			Exp2Quad_A						=> Exp2Q1_A, 
			Exp2Quad_B						=> Exp2Q1_B, 
			Exp2Quad_Reg					=> Exp2Q1_Reg, 
			Exp2Quad_FaultA					=> Exp2Q1_FaultA, 
			Exp2Quad_FaultB					=> Exp2Q1_FaultB,
			Exp3Quad_A						=> Exp3Q1_A, 
			Exp3Quad_B						=> Exp3Q1_B, 
			Exp3Quad_Reg					=> Exp3Q1_Reg, 
			Exp3Quad_FaultA					=> Exp3Q1_FaultA, 
			Exp3Quad_FaultB					=> Exp3Q1_FaultB,
			QA0CountRead					=> QA0CountRead, 
			QA0LEDStatusRead				=> QA0LEDStatusRead, 
			QA0LEDStatusWrite				=> QA0LEDStatusWrite, 
			QA0InputRead					=> QA0InputRead,
			QA0HomeRead						=> QA0HomeRead, 
			QA0Latch0Read					=> QA0Latch0Read, 
			QA0Latch1Read					=> QA0Latch1Read,
			QA1CountRead					=> QA1CountRead, 
			QA1LEDStatusRead				=> QA1LEDStatusRead, 
			QA1LEDStatusWrite				=> QA1LEDStatusWrite, 
			QA1InputRead					=> QA1InputRead,
			QA1HomeRead						=> QA1HomeRead, 
			QA1Latch0Read					=> QA1Latch0Read, 
			QA1latch1Read					=> QA1Latch1Read,
			QA0_SigA						=> QA0_SigA, 
			QA0_SigB						=> QA0_SigB, 
			QA0_SigZ						=> QA0_SigZ, 
			QA0_Home						=> QA0_Home, 
			QA0_RegX_PosLmt					=> QA0_RegX_PosLmt, 
			QA0_RegY_NegLmt					=> QA0_RegY_NegLmt,
			QA1_SigA						=> QA1_SigA, 
			QA1_SigB						=> QA1_SigB, 
			QA1_SigZ						=> QA1_SigZ, 
			QA1_Home						=> QA1_Home, 
			QA1_RegX_PosLmt					=> QA1_RegX_PosLmt, 
			QA1_RegY_NegLmt					=> QA1_RegY_NegLmt,
			QA0AxisFault(2 downto 0)		=> QA0AxisFault(2 downto 0), 
			QA1AxisFault(2 downto 0)		=> QA1AxisFault(2 downto 0)
		);

	-- Latency counter is used for debug purposes only and is used to measure the amount of time that it
	-- takes for the CPU to respond to interrupts.
	LatCnt_1 : LatencyCounter
		port map (
			H1_CLK				=> H1_CLK,
			SynchedTick			=> SynchedTick,
			latencyDataOut		=> latencyDataOut(31 downto 0),
			LatencyCounterRead	=> LatencyCounterRead
		);

	ExpModLED_1 : ExpModuleLED
		port map (
			Reset						=> SysRESET,
			H1_CLKWR					=> H1_CLKWR, 
			SysClk						=> SysClk, 
			SlowEnable					=> SlowEnable, 
			SynchedTick					=> SynchedTick, 
			intDATA(31 downto 0)		=> intDATA(31 downto 0), 
			expLedDataOut(3 downto 0)	=> expLedDataOut(3 downto 0),
			Exp0LEDWrite				=> Exp0LEDWrite, 
			Exp0LED0Write				=> Exp0LED0Write, 
			Exp0LED1Write				=> Exp0LED1WRite, 
			Exp0LEDRead					=> Exp0LEDRead, 
			Exp0LED0Read				=> Exp0LED0Read, 
			Exp0LED1Read				=> Exp0LED1Read, 
			Exp1LEDWrite				=> Exp1LEDWrite, 
			Exp1LED0Write				=> Exp1LED0Write, 
			Exp1LED1Write				=> Exp1LED1Write, 
			Exp1LEDRead					=> Exp1LEDRead, 
			Exp1LED0Read				=> Exp1LED0Read, 
			Exp1LED1Read				=> Exp1LED1Read, 
			Exp2LEDWrite				=> Exp2LEDWrite, 
			Exp2LED0Write				=> Exp2LED0Write, 
			Exp2LED1Write				=> Exp2LED1Write, 
			Exp2LEDRead					=> Exp2LEDRead, 
			Exp2LED0Read				=> Exp2LED0Read, 
			Exp2LED1Read				=> Exp2LED1Read, 
			Exp3LEDWrite				=> Exp3LEDWrite, 
			Exp3LED0Write				=> Exp3LED0Write, 
			Exp3LED1Write				=> Exp3LED1Write, 
			Exp3LEDRead					=> Exp3LEDRead, 
			Exp3LED0Read				=> Exp3LED0Read, 
			Exp3LED1Read				=> Exp3LED1Read, 
			EEPROMAccessFlag			=> EEPROMAccessFlag, 
			DiscoveryComplete			=> DiscoveryComplete, 
			ExpLEDOE					=> ExpLEDOE,								
			ExpLEDLatch					=> ExpLEDLatch, 
			ExpLEDClk					=> ExpLEDClk, 
			ExpLEDData(3 downto 0)		=> ExpLEDData(3 downto 0), 
			ExpLEDSelect(3 downto 0)	=> ExpLEDSelect(3 downto 0), 
			ExpOldAP2(3 downto 0)		=> ExpOldAP2(3 downto 0)
		);

	-- Bus Interface and Tristate Logic
	-- Drive the individual source buses onto the external DATA bus whenever a read from the FPGA occurrs
-- TODO: There is a mixed bus of LED read and status reads still to resolve. 
	DATA(31 downto 0) <= 	discoverIdDataOut(31 downto 0) when FPGAIDRead = '1' or ControlCardIDRead = '1' or Expansion1IDRead = '1' or Expansion2IDRead = '1' or Expansion3IDRead = '1' or Expansion4IDRead = '1' else
							
							cpuConfigDataOut(31 downto 0) when CPUConfigRead = '1' else
							
							cpuLedDataOut(31 downto 0) when CPULEDRead = '1' else
							
							wdtDataOut(31 downto 0) when WDTConfigRead = '1' else
							
							FPGAProgDOut(31 downto 0) when FPGAProgrammedRead = '1' else
							
							serialMemDataOut(31 downto 0) when SerialMemXfaceRead = '1' else
							
							d8DataOut(31 downto 0) when ExpDIO8ConfigRead(3) = '1' or ExpDIO8ConfigRead(2) = '1' or ExpDIO8ConfigRead(1) = '1' or ExpDIO8ConfigRead(0) = '1' or
														ExpDIO8DinRead(3) = '1' or ExpDIO8DinRead(2) = '1' or ExpDIO8DinRead(1) = '1' or ExpDIO8DinRead(0) = '1' else
							
							latencyDataOut(31 downto 0) when LatencyCounterRead = '1' else
							
--							profiDataOut(31 downto 0) when PROFIBUSAddrRead='1' else
							
							mdtSimpDataOut0(31 downto 0) when MDT_SSIPositionRead0 = '1' and SSISelect(0) = '0' else
							controlIoDataOut(31 downto 27) & mdtSimpDataOut0(26 downto 0) when MDT_SSIStatusRead0 = '1' and SSISelect(0) = '0'else
							
							mdtSimpDataOut1(31 downto 0) when MDT_SSIPositionRead1 = '1' and SSISelect(1) = '0' else
							controlIoDataOut(31 downto 27) & mdtSimpDataOut1(26 downto 0) when MDT_SSIStatusRead1 = '1' and SSISelect(1) = '0' else
							
							ssiDataOut0(31 downto 0) when MDT_SSIPositionRead0 = '1' and SSISelect(0) = '1' else
							controlIoDataOut(31 downto 27) & ssiDataOut0(26 downto 0) when MDT_SSIStatusRead0 = '1' and SSISelect(0) = '1' else
							
							ssiDataOut1(31 downto 0) when MDT_SSIPositionRead1 = '1' and SSISelect(1) = '1' else
							controlIoDataOut(31 downto 27) & ssiDataOut1(26 downto 0) when MDT_SSIStatusRead1 = '1' and SSISelect(1) = '1' else
							
							controlIoDataOut(31 downto 27) & QuadA0DataOut(26 downto 0) when QA0LEDStatusRead = '1'else
							QuadA0DataOut(31 downto 0) when	QA0CountRead = '1' or QA0HomeRead = '1' or QA0Latch0Read = '1' or QA0Latch1Read = '1' else
							QuadA0DataOut(31 downto 1) & controlIoDataOut(0) when QA0InputRead = '1' else
							
							controlIoDataOut(31 downto 27) & QuadA1DataOut(26 downto 0) when QA1LEDStatusRead = '1' else
							QuadA1DataOut(31 downto 0) when QA1CountRead = '1' or QA1HomeRead = '1' or QA1Latch0Read = '1' or QA1Latch1Read = '1' else
							QuadA1DataOut(31 downto 1) & controlIoDataOut(0) when QA1InputRead = '1'else
							
							expLedDataOut(3 downto 0) & Exp0QuadDataOut(27 downto 0) when Exp0QuadLEDStatusRead = '1' else 
							Exp0QuadDataOut(31 downto 0) when 	Exp0QuadCountRead = '1' or Exp0QuadLEDStatusRead = '1' or Exp0QuadInputRead = '1' or
																Exp0QuadHomeRead = '1' or Exp0QuadLatch0Read = '1' or Exp0QuadLatch1Read = '1' else 
							
							expLedDataOut(3 downto 0) & Exp1QuadDataOut(27 downto 0) when Exp1QuadLEDStatusRead = '1' else
							Exp1QuadDataOut(31 downto 0) when 	Exp1QuadCountRead = '1' or Exp1QuadLEDStatusRead = '1' or Exp1QuadInputRead = '1' or
																Exp1QuadHomeRead = '1' or Exp1QuadLatch0Read = '1' or Exp1QuadLatch1Read = '1' else
							
							expLedDataOut(3 downto 0) & Exp2QuadDataOut(27 downto 0) when Exp2QuadLEDStatusRead = '1' else
							Exp2QuadDataOut(31 downto 0) when 	Exp2QuadCountRead = '1' or Exp2QuadLEDStatusRead = '1' or Exp2QuadInputRead = '1' or
																Exp2QuadHomeRead = '1' or Exp2QuadLatch0Read = '1' or Exp2QuadLatch1Read = '1' else
							
							expLedDataOut(3 downto 0) & Exp3QuadDataOut(27 downto 0) when Exp3QuadLEDStatusRead = '1' else
							Exp3QuadDataOut(31 downto 0) when 	Exp3QuadCountRead = '1' or Exp3QuadLEDStatusRead = '1' or Exp3QuadInputRead = '1' or
																Exp3QuadHomeRead = '1' or Exp3QuadLatch0Read = '1' or Exp3QuadLatch1Read = '1' else
							
							controlIoDataOut(31 downto 0) when AnlgStatusRead0 = '1' or AnlgStatusRead1 = '1' or (Axis0IORead = '1' and QUADPresent = '0') or (Axis1IORead = '1' and QUADPresent = '0') else
							
							AnlgDATA (31 downto 0) when ANLGAccess = '1' else 
							"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
						
	-- Drive the external DATA onto the intDATA bus whenever a write to the FPGA occurs.
	intDATA(31 downto 0) <= DATA(31 downto 0); -- when CS_L='0' and WR_L='0' else X"0000_0000";

end Top_arch;