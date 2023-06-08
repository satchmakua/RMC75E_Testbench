
-- VHDL Test Bench Created from source file top.vhd -- 19:20:18 07/11/2002
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	component top
	port(
		
		DATA: inout std_logic_vector (31 downto 0);
		ExtADDR: in std_logic_vector (11 downto 0);
		RD_L: in std_logic;
		WR_L: in std_logic;
		CS_L: in std_logic;
		LOOPTICK: in std_logic;
		H1_CLK_IN: in std_logic;

		WD_RST_L: out std_logic;
		WD_TICKLE: in std_logic;
		RESET: in std_logic;

		M_DRV_EN_L: out std_logic;							-- pullup is placed on this pin external to the FPGA.
		HALT_DRIVE_L: in std_logic;
      
		M_OUT0_CLK: out std_logic;
		M_OUT0_DATA: out std_logic;
		M_OUT0_CONTROL: out std_logic;

		M_OUT1_CLK: out std_logic;
		M_OUT1_DATA: out std_logic;
		M_OUT1_CONTROL: out std_logic;

		M_AX0_0: out std_logic;									-- multiplexed output of M_AX0_INT_DATA and M_ADC_CLK
		M_AX0_RET_DATA: in std_logic;

		M_AX1_INT_CLK: out std_logic;
		M_AX1_RET_DATA: in std_logic;

		M_MUXED_ADC_CS_QA0_SIGA: inout std_logic;
		M_MUXED_ADC_DATA0_QA0_SIGB: in std_logic;
		M_MUXED_ADC_DATA1_QA1_SIGA: in std_logic;

--		M_ADC_CS: out std_logic;
--		M_ADC_DATA0: in std_logic;
--		M_ADC_DATA1: in std_logic;

	 	M_ENABLE: out std_logic_vector (1 downto 0);
		M_FAULT : in std_logic_vector (1 downto 0);

		M_Card_ID_LOAD: out std_logic;
		M_Card_ID_LATCH: out std_logic;
		M_Card_ID_CLK: out std_logic;
		M_Card_ID_DATA: in std_logic;

		Exp_Mxd_ID_LOAD: out std_logic;
		Exp_Mxd_ID_LATCH: out std_logic;
		Exp_Mxd_ID_CLK: out std_logic;
		Exp_ID_DATA: in std_logic;

		M_SPROM_CLK: out std_logic;
		M_SPROM_DATA: inout std_logic;

		CPUStatLEDDrive: out std_logic_vector (1 downto 0);
		CPUSerialXmitLED: inout std_logic;
		CPUSerialRcvLED: inout std_logic;

		PROFI_CLK: out std_logic;
		PROFI_DATA: in std_logic;
		PROFI_LATCH: out std_logic;
		PROFI_LOAD: out std_logic;

		Exp0Data: inout std_logic_vector (5 downto 0);
		Exp1Data: inout std_logic_vector (5 downto 0);
		Exp2Data: inout std_logic_vector (5 downto 0);
		Exp3Data: inout std_logic_vector (5 downto 0);
		
		M_IO_OE: out std_logic;
		M_IO_LOAD: out std_logic;
		M_IO_LATCH: out std_logic;
		M_IO_CLK: out std_logic;
		M_IO_DATAOut: out std_logic;
		M_IO_DATAIn: in std_logic;

--		QA0_SigA: in std_logic;			-- This signal is muxed with ADC_CS (See above)
--		QA0_SigB: in std_logic;			-- This signal is muxed with ADC_Data0 (See above)
		QA0_SigZ: in std_logic;
		QA0_Home: in std_logic;
		QA0_RegX_PosLmt: in std_logic;
		QA0_RegY_NegLmt: in std_logic;
		
--		QA1_SigA: in std_logic;			-- This signal is muxed with ADC_Data1 (See above)
		QA1_SigB: in std_logic;
		QA1_SigZ: in std_logic;
		QA1_Home: in std_logic;
		QA1_RegX_PosLmt: in std_logic;
		QA1_RegY_NegLmt: in std_logic
		
--		QA0_SigA_out : out std_logic;
--		QA0_SigB_out : out std_logic;
--		QA1_SigA_out : out std_logic;
--		QA1_SigB_out : out std_logic

		);
	end component;

	signal DATA : std_logic_vector(31 downto 0);
	signal ADDR : std_logic_vector(11 downto 0);
	signal RD_L : std_logic := '1';
	signal WR_L : std_logic := '1';
	signal CS_L : std_logic := '1';
	signal STRB_L: std_logic := '1';
	signal LOOPTICK : std_logic := '0';
	signal H1_CLK_IN : std_logic := '0';
	signal WD_RST_L : std_logic;
	signal WD_TICKLE : std_logic := '1';
	signal RESET : std_logic := '0';
	signal M_DRV_EN_L : std_logic;
	signal HALT_DRIVE_L : std_logic;
	signal M_OUT0_CLK : std_logic;
	signal M_OUT0_DATA : std_logic;
	signal M_OUT0_CONTROL : std_logic;
	signal M_OUT1_CLK : std_logic;
	signal M_OUT1_DATA : std_logic;
	signal M_OUT1_CONTROL : std_logic;
	signal M_AX0_0 : std_logic;
	signal M_AX0_RET_DATA : std_logic;
	signal M_AX1_INT_CLK : std_logic;
	signal M_AX1_RET_DATA : std_logic;

	signal M_MUXED_ADC_CS_QA0_SIGA : std_logic;
	signal M_MUXED_ADC_DATA0_QA0_SIGB : std_logic := '1';
	signal M_MUXED_ADC_DATA1_QA1_SIGA : std_logic := '0';

--	signal M_ADC_CS : std_logic;
--	signal M_ADC_DATA0 : std_logic := '1';
--	signal M_ADC_DATA1 : std_logic := '1';

	signal M_ENABLE: std_logic_vector(1 downto 0) := "00";
	signal M_FAULT: std_logic_vector(1 downto 0) := "00";

	signal M_Card_ID_LOAD: std_logic;
	signal M_Card_ID_LATCH: std_logic;
	signal M_Card_ID_CLK: std_logic;
	signal M_Card_ID_DATA: std_logic := '1';

	signal Exp_Mxd_ID_LOAD: std_logic;
	signal Exp_Mxd_ID_LATCH: std_logic;
	signal Exp_Mxd_ID_CLK: std_logic;
	signal Exp_ID_DATA: std_logic;

	signal M_IO_OE: std_logic;
	signal M_IO_LOAD: std_logic;
	signal M_IO_LATCH: std_logic;
	signal M_IO_CLK: std_logic;
	signal M_IO_DATAOut: std_logic;
	signal M_IO_DATAIn: std_logic;

	signal M_SPROM_CLK: std_logic;
	signal M_SPROM_DATA: std_logic := '0';

	signal CPUStatLEDDrive: std_logic_vector (1 downto 0);
	signal CPUSerialXmitLED: std_logic;
	signal CPUSerialRcvLED: std_logic;

	signal PROFI_CLK: std_logic;
	signal PROFI_DATA: std_logic;
	signal PROFI_LATCH: std_logic;
	signal PROFI_LOAD: std_logic;

	signal Exp0Data: std_logic_vector (5 downto 0);
	signal Exp1Data: std_logic_vector (5 downto 0);
	signal Exp2Data: std_logic_vector (5 downto 0);
	signal Exp3Data: std_logic_vector (5 downto 0);

	signal SSI0Data, SSI1Data: std_logic_vector (31 downto 0) := X"0000_0000";
	signal SSI0_DataLengthSet, SSI1_DataLengthSet: integer range 1 to 32;
	signal SSI0_Index, SSI1_Index: std_logic_vector (7 downto 0) := X"00";
	signal LoopCount0, LoopCount1: integer range 0 to 31;

	signal QA0_SigZ, QA0_Home, QA0_RegX_PosLmt, QA0_RegY_NegLmt : std_logic := '0';
	signal QA1_SigB, QA1_SigZ, QA1_Home, QA1_RegX_PosLmt, QA1_RegY_NegLmt : std_logic := '0';

	-- if the clockperiod is 16.667 ns the simulation breaks!! weird!
	constant ClockPeriod : TIME := 16.666 ns;

	signal CycleEnd: std_logic := '0';

BEGIN
	uut: top PORT MAP(
		DATA => DATA,
		ExtADDR(11 downto 0) => ADDR(11 downto 0),
		RD_L => RD_L,
		WR_L => WR_L,
		CS_L => CS_L,
		LOOPTICK => LOOPTICK,
		H1_CLK_IN => H1_CLK_IN,
		WD_RST_L => WD_RST_L,
		WD_TICKLE => WD_TICKLE,
		RESET => RESET,
		M_DRV_EN_L => M_DRV_EN_L,
		HALT_DRIVE_L => HALT_DRIVE_L,
		M_OUT0_CLK => M_OUT0_CLK,
		M_OUT0_DATA => M_OUT0_DATA,
		M_OUT0_CONTROL => M_OUT0_CONTROL,
		M_OUT1_CLK => M_OUT1_CLK,
		M_OUT1_DATA => M_OUT1_DATA,
		M_OUT1_CONTROL => M_OUT1_CONTROL,
		M_AX0_0 => M_AX0_0,
		M_AX0_RET_DATA => M_AX0_RET_DATA,
		M_AX1_INT_CLK => M_AX1_INT_CLK,
		M_AX1_RET_DATA => M_AX1_RET_DATA,

		M_MUXED_ADC_CS_QA0_SIGA => M_MUXED_ADC_CS_QA0_SIGA,
		M_MUXED_ADC_DATA0_QA0_SIGB => M_MUXED_ADC_DATA0_QA0_SIGB,
		M_MUXED_ADC_DATA1_QA1_SIGA => M_MUXED_ADC_DATA1_QA1_SIGA,

--			M_ADC_CS => M_ADC_CS,
--			M_ADC_DATA0 => M_ADC_DATA0,
--			M_ADC_DATA1 => M_ADC_DATA1,
		M_ENABLE(0) => M_ENABLE(0),
		M_ENABLE(1) => M_ENABLE(1),
		M_FAULT(0) => M_FAULT(0),
		M_FAULT(1) => M_FAULT(1),
		M_Card_ID_LOAD => M_Card_ID_LOAD,
		M_Card_ID_LATCH => M_Card_ID_LATCH,
		M_Card_ID_CLK => M_Card_ID_CLK,
		M_Card_ID_DATA => M_Card_ID_DATA,
		Exp_Mxd_ID_LOAD => Exp_Mxd_ID_LOAD,
		Exp_Mxd_ID_LATCH => Exp_Mxd_ID_LATCH,
		Exp_Mxd_ID_CLK => Exp_Mxd_ID_CLK,
		Exp_ID_DATA => Exp_ID_DATA,
		
		M_IO_OE => M_IO_OE,
		M_IO_LOAD => M_IO_LOAD,
		M_IO_LATCH => M_IO_LATCH,
		M_IO_CLK => M_IO_CLK,
		M_IO_DATAOut => M_IO_DATAOut,
		M_IO_DATAIn => M_IO_DATAIn,
		
		M_SPROM_CLK => M_SPROM_CLK,
		M_SPROM_DATA => M_SPROM_DATA,
		CPUStatLEDDrive => CPUStatLEDDrive,
		CPUSerialXmitLED => CPUSerialXmitLED,
		CPUSerialRcvLED => CPUSerialRcvLED,
		PROFI_CLK => PROFI_CLK,
		PROFI_DATA => PROFI_DATA,
		PROFI_LATCH => PROFI_LATCH,
		PROFI_LOAD => PROFI_LOAD,
		Exp0Data => Exp0Data,
		Exp1Data => Exp1Data,
		Exp2Data => Exp2Data,
		Exp3Data => Exp3Data,
		
		QA0_SigZ => QA0_SigZ, 
		QA0_Home => QA0_Home, 
		QA0_RegX_PosLmt => QA0_RegX_PosLmt, 
		QA0_RegY_NegLmt => QA0_RegY_NegLmt, 
		
		QA1_SigB => QA1_SigB, 
		QA1_SigZ => QA1_SigZ, 
		QA1_Home => QA1_Home, 
		QA1_RegX_PosLmt => QA1_RegX_PosLmt, 
		QA1_RegY_NegLmt => QA1_RegY_NegLmt

		);

-- set up the input clock
	H1_CLK_IN <= not H1_CLK_IN after ClockPeriod / 2;
	M_Card_ID_DATA <= 'H';
	Exp_ID_DATA <= 'H';
	PROFI_DATA <= '1';
	M_SPROM_DATA <= 'L';
	Exp0Data(1) <= '1';
--	Exp0Data(2) <= '1';
--	Exp0Data(3) <= '0';
--	Exp0Data(4) <= '1';
	HALT_DRIVE_L <= '1';

-- set up the Control loop time tick
	tt : Process
	begin

		LOOPTICK <= '0';
		wait for ClockPeriod * 100;
		wait until H1_CLK_IN = '0';
		LOOPTICK <= '1';
		wait for ClockPeriod;
		LOOPTICK <= '0';
		
--		wait for ClockPeriod * 750;
--		wait until H1_CLK_IN = '0';
--		LOOPTICK <= '1';
--		wait for ClockPeriod;
--		LOOPTICK <= '0';

--		wait for ClockPeriod * 750;
--		wait until H1_CLK_IN = '0';
--		LOOPTICK <= '1';
--		wait for ClockPeriod;
--		LOOPTICK <= '0';	  

		wait for ClockPeriod * 100000;

	end process;

	-- set up the MDT return pulses 
	mdt0 : Process
	begin
	-- first return pulse
		M_AX0_RET_DATA <= '0';
		wait until M_AX0_0 = '1';
		wait for (ClockPeriod * 25) + (ClockPeriod/2);
		M_AX0_RET_DATA <= '1';
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_AX0_RET_DATA <= '0';
		wait for (ClockPeriod * 500);

	-- second return pulse
		M_AX0_RET_DATA <= '1';
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_AX0_RET_DATA <= '0';

		wait for (ClockPeriod * 10);

--		wait until M_AX0_0 = '1';		-- This is my NoXducer cycle

	-- first return pulse
		M_AX0_RET_DATA <= '0';
		wait until M_AX0_0 = '1';
		wait for (ClockPeriod * 25) + (ClockPeriod/2);
		M_AX0_RET_DATA <= '1';
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_AX0_RET_DATA <= '0';
		wait for (ClockPeriod * 500);

	-- second return pulse
		M_AX0_RET_DATA <= '1';
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_AX0_RET_DATA <= '0';

	end process;


-- set up the MDT return pulses 
--	mdt1 : Process
--	begin
	-- first return pulse
--		M_AX1_RET_DATA <= '0';
--		wait until M_AX1_INT_CLK = '1';
--		wait until M_AX1_INT_CLK = '0';
--		wait for (ClockPeriod * 25) + (ClockPeriod/2);
--		M_AX1_RET_DATA <= '1';
--		wait for (ClockPeriod * 10) + (ClockPeriod/4);
--		M_AX1_RET_DATA <= '0';
--		wait for (ClockPeriod * 200);
--		M_AX1_RET_DATA <= '1';
--		wait for (ClockPeriod * 10) + (ClockPeriod/4);
--		M_AX1_RET_DATA <= '0';
--	end process;


-- set up the SSI Data
--	SSI0 : process
--	begin
--		if LOOPTICK='1' then
--			SSI0Data(31 downto 0) <= X"0081_1111"; 					-- This is my position data preload value
--			M_AX0_RET_DATA <= '1';											-- Hold the data line input high
--		end if; 

--L0:	loop
--			wait until M_AX0_0 = '0' or LOOPTICK='1';
--			exit L0 when LOOPTICK='1';
--			wait until M_AX0_0 = '1' or LOOPTICK='1';									
--			exit L0 when LOOPTICK='1';
--			M_AX0_RET_DATA <= SSI0Data(SSI0_DataLengthSet-1);
--	   	SSI0Data(31 downto 0) <= SSI0Data(30 downto 0) & '0';
--		end loop L0;
--	end process;


-- set up the SSI Data
	SSI1 : process
	begin
		if LOOPTICK='1' then
			SSI1Data(31 downto 0) <= X"0081_1111"; 					-- This is my position data preload value
			M_AX1_RET_DATA <= '1';											-- Hold the data line input high
		end if;
		
L1:	loop 
 			wait until M_AX1_INT_CLK = '0' or LOOPTICK='1';			-- These two statements find the rising edge of the clock
			exit L1 when LOOPTICK='1';
			wait until M_AX1_INT_CLK = '1' or LOOPTICK='1';									
			exit L1 when LOOPTICK='1';
			M_AX1_RET_DATA <= SSI1Data(SSI1_DataLengthSet-1);
		   SSI1Data(31 downto 0) <= SSI1Data(30 downto 0) & '0';
		end loop L1;
	end process;


-- *** Test Bench ***
   tb : Process
-- define a read procedure for reading registers from within the FPGA
	procedure read(address: in std_logic_vector(23 downto 0)) is
	begin
		-- reads begin on the falling edge of H1_CLK
		if falling_edge(H1_CLK_IN) then
			ADDR(11 downto 0) <= address(11 downto 0) after ClockPeriod / 10; -- pick off the address lines of interest
			DATA <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" after ClockPeriod / 10;
			STRB_L <= '0' after ClockPeriod / 10;
			RD_L <= '0' after ClockPeriod / 10;
			CS_L <= '0' after ClockPeriod / 10;
		end if;
	 	wait for ClockPeriod * 3;
		STRB_L <= '1' after ClockPeriod / 10;
		RD_L <= '1' after ClockPeriod / 10;
		CS_L <= '1' after ClockPeriod / 10;
	end read;


-- define a write procedure for writing registers from within the FPGA
	procedure write(address: in std_logic_vector(23 downto 0); WR_Data: in std_logic_vector(31 downto 0)) is
	begin
		-- writes begin on the falling edge of H1_CLK
		if falling_edge(H1_CLK_IN) then
			ADDR(11 downto 0) <= address(11 downto 0) after ClockPeriod / 10; -- pick off the address lines of interest
		end if;
		wait for ClockPeriod;
		STRB_L <= '0' after ClockPeriod / 10;
		WR_L <= '0' after ClockPeriod / 10;
		CS_L <= '0' after ClockPeriod / 10;
		DATA <= WR_Data(31 downto 0) after ClockPeriod / 10;
		wait for ClockPeriod * 3;
		STRB_L <= '1' after ClockPeriod / 10;
		WR_L <= '1' after ClockPeriod / 10;
		CS_L <= '1' after ClockPeriod / 10;
	end write;


--	************** Begin the test bench logic description *************************
   Begin
--		Initialize inputs
		STRB_L <= '1';
		RD_L <= '1';
		WR_L <= '1';
		CS_L <= '1';
		WD_TICKLE <= '1';
		M_FAULT(0) <= '0';
		M_FAULT(1) <= '0';
		--ADDR(11 downto 0) <= X"0AA";



-- Write some information into the DIO8 Memory area
		wait for ClockPeriod * 50;
		write(X"80A100", X"AAAA_0F50"); 	-- Axis 0 SSI delay count LED's on, lower 4 bits are inputs, upper 4 output bits w/0101 pattern 
		wait for ClockPeriod;
		write(X"80A120", X"AAAA_0FA0"); 	-- Axis 0 SSI delay count LED's on, lower 4 bits are inputs, upper 4 output bits w/0101 pattern 
		wait for ClockPeriod;
		write(X"80A140", X"AAAA_0FF0"); 	-- Axis 0 SSI delay count LED's on, lower 4 bits are inputs, upper 4 output bits w/0101 pattern 
		wait for ClockPeriod;
		write(X"80A160", X"AAAA_0F30"); 	-- Axis 0 SSI delay count LED's on, lower 4 bits are inputs, upper 4 output bits w/0101 pattern 
		wait for ClockPeriod;

-- Read the information back out
		read(X"80A100"); 	 
		wait for ClockPeriod;
		read(X"80A101"); 	 
		wait for ClockPeriod;
		read(X"80A120"); 	
		wait for ClockPeriod;
		read(X"80A121"); 	
		wait for ClockPeriod;
		read(X"80A140");
		wait for ClockPeriod;
		read(X"80A141");
		wait for ClockPeriod;
		read(X"80A160"); 
		wait for ClockPeriod;
		read(X"80A161"); 
		wait for ClockPeriod;

		wait until LOOPTICK = '1'; 
		wait for ClockPeriod * 200;

--		wait until LOOPTICK = '1'; 
--		wait for ClockPeriod * 50;
		
		wait for ClockPeriod * 2;
		read(X"80A000");						-- FPGA ID
		wait for ClockPeriod * 2;
		
		wait for ClockPeriod * 2;
		read(X"80A001");						-- CPU Config Read
		wait for ClockPeriod * 2;

		wait for ClockPeriod * 2;
		read(X"80A006");						-- Control Axis ID
		wait for ClockPeriod * 2;

		wait for ClockPeriod * 2;
		read(X"80A00A");						-- Exp0 ID
		wait for ClockPeriod * 2;

		wait for ClockPeriod * 2;
		read(X"80A00B");						-- Exp1 ID
		wait for ClockPeriod * 2;

		wait for ClockPeriod * 2;
		read(X"80A00C");						-- Exp2 ID
		wait for ClockPeriod * 2;

		wait for ClockPeriod * 2;
		read(X"80A00D");						-- Exp3 ID
		wait for ClockPeriod * 2;

		-- Set up the MDT Configuration
		write(X"80A011", X"A000_0001");  		-- Axis 0 is Start/Stop rising edge sensitive
		wait for ClockPeriod * 5;
		read(X"80A011");  						-- Axis 0 write validation
		wait for ClockPeriod;

--		write(X"80A021", X"A000_0001");	-- Axis 1 is Start/Stop rising edge sensitive
--		wait for ClockPeriod;

--		write(X"80A015", X"0000_0005"); 	-- Axis 0 SSI delay count
--		write(X"80A011", X"A000_18_06"); -- Axis 0 is SSI std binary and 24 bit data
--		SSI0_DataLengthSet <= 24;
--		wait for ClockPeriod;

		write(X"80A025", X"0000_0005"); 	-- Axis 1 SSI delay count
		write(X"80A021", X"A000_18_06");	-- Axis 1 is SSI std binary and 24 bit data
		SSI1_DataLengthSet <= 24;
		wait for ClockPeriod;

 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position
		wait for ClockPeriod;
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
 		write(X"80A011", X"6000_0000");			-- Axis 0 Status
		wait for ClockPeriod;
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position
		wait for ClockPeriod;
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position
		wait for ClockPeriod;
		
		
		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A021");						-- Axis 1 Status
		wait for ClockPeriod;

		wait for (ClockPeriod * 1750);

 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position

		-- set up the WDT
		write(X"80A003",X"00A0_0000");
		wait for ClockPeriod;
		write(X"80A003",X"0050_0010");
		wait for ClockPeriod;
		read(X"80A003");
		wait for Clockperiod;

		-- AP2 LED reads and writes
		read(X"80A101");
		write(X"80A101",X"8000_0000");
		write(X"80A105",X"C000_0000");
		write(X"80A121",X"C000_0000");
		write(X"80A125",X"8000_0000");
		write(X"80A141",X"4000_0000");
		write(X"80A145",X"4000_0000");
		write(X"80A161",X"C000_0000");
		write(X"80A165",X"8000_0000");

		wait for ClockPeriod * 10;

		read(X"80A101");
		read(X"80A105");
		read(X"80A121");
		read(X"80A125");
		read(X"80A141");
		read(X"80A145");
		read(X"80A161");
		read(X"80A165");

		wait for ClockPeriod * 10;
		
		-- Test reads and writes
		read(X"000000");
		wait for ClockPeriod;
		read(X"400000");
		wait for ClockPeriod;
		read(X"800000");
		wait for ClockPeriod;
		read(X"C00000");
		wait for ClockPeriod;
		write(X"000000", X"a5a5_a5a5");
		wait for ClockPeriod;
		write(X"400000", X"5a5a_5a5a");
		wait for ClockPeriod;
		write(X"800000", X"0000_0000");
		wait for ClockPeriod;
		write(X"C00000", X"ffff_ffff");
		wait for ClockPeriod;

		wait for ClockPeriod * 50;

		-- reset the WDT
		write(X"80A003",X"00A0_0000");
		wait for ClockPeriod;
		write(X"80A003",X"0050_0000");
		wait for ClockPeriod;

		-- set up the Drive Enable and the PROFI address read Enable
--		write(X"80A001", X"0000_0009");

		wait for ClockPeriod * 5;
		WD_TICKLE <= '0';
		wait for ClockPeriod * 100;
		WD_TICKLE <= '1';
																	
		-- Serial Memory Interface Testing

		write(X"80A005", X"012A_4000");	  -- only the read bit is set for the control module
		wait for ClockPeriod * 30000;
		write(X"80A005", X"002A_80AA");	  -- only the write bit is set for the control module
		wait for ClockPeriod * 30000;
--		write(X"80A005", X"012A_80AA");	  -- only the write bit is set for the control module
		read(X"80A005");
		wait for ClockPeriod * 1000;

		-- data read from position 0
		read(X"80A040");  		
		wait for ClockPeriod;
 	   -- data read from position 1
		read(X"80A0C0");	
		wait for ClockPeriod;
		-- data write to control output 0
		write(X"80A040", X"0000_5555");
		wait for ClockPeriod;
		-- data write to control output 1
		write(X"80A0C0", X"0000_1234"); 
		wait for ClockPeriod;
		-- turn the CPU status LED's on
		write(X"80A008", X"0000_0301");

		-- data read from -AP2 module
		wait for ClockPeriod;
		read(X"80A100");  		
		wait for ClockPeriod;
		read(X"80A101");  		
		wait for ClockPeriod;
		read(X"80A104");  		
		wait for ClockPeriod;
		read(X"80A105");
		wait for ClockPeriod;
  		
		wait for ClockPeriod;
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position
		wait for ClockPeriod;
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position
		wait for ClockPeriod;
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position
		wait for ClockPeriod;
		
		wait for ClockPeriod;
 		read(X"80A021");						-- Axis 1 Status
		wait for ClockPeriod;
		read(X"80A020");						-- Axis 1 Position
		wait for ClockPeriod;
 		read(X"80A021");						-- Axis 1 Status
		wait for ClockPeriod;
		read(X"80A020");						-- Axis 1 Position
		wait for ClockPeriod;
 		read(X"80A021");						-- Axis 1 Status
		wait for ClockPeriod;
		read(X"80A020");						-- Axis 1 Position
		wait for ClockPeriod;

		wait for ClockPeriod;
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position
		wait for ClockPeriod;
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position
		wait for ClockPeriod;
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position
		wait for ClockPeriod;

		wait for ClockPeriod;
 		read(X"80A021");						-- Axis 1 Status
		wait for ClockPeriod;
		read(X"80A020");						-- Axis 1 Position
		wait for ClockPeriod;
 		read(X"80A021");						-- Axis 1 Status
		wait for ClockPeriod;
		read(X"80A020");						-- Axis 1 Position
		wait for ClockPeriod;
 		read(X"80A021");						-- Axis 1 Status
		wait for ClockPeriod;
		read(X"80A020");						-- Axis 1 Position
		wait for ClockPeriod;

		wait for ClockPeriod;
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position
		wait for ClockPeriod;
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position
		wait for ClockPeriod;
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position
		wait for ClockPeriod;

		wait for ClockPeriod;
 		read(X"80A021");						-- Axis 1 Status
		wait for ClockPeriod;
		read(X"80A020");						-- Axis 1 Position
		wait for ClockPeriod;
 		read(X"80A021");						-- Axis 1 Status
		wait for ClockPeriod;
		read(X"80A020");						-- Axis 1 Position
		wait for ClockPeriod;
 		read(X"80A021");						-- Axis 1 Status
		wait for ClockPeriod;
		read(X"80A020");						-- Axis 1 Position
		wait for ClockPeriod;

		
		-- read the fault inputs
		read(X"80A012");
		wait for ClockPeriod;
 		read(X"80A022");
		wait for ClockPeriod;

		M_FAULT(0) <= '1';
		M_FAULT(1) <= '1';
		read(X"80A012");
		wait for ClockPeriod;
 		read(X"80A022");
		wait for ClockPeriod;
		
		M_FAULT(0) <= '0';
		read(X"80A012");
		wait for ClockPeriod;
 		read(X"80A022");
		wait for ClockPeriod;
		M_FAULT(0) <= '1';
		read(X"80A012");
		wait for ClockPeriod;
 		read(X"80A022");
		wait for ClockPeriod;
		
		-- read the fault inputs
		read(X"80A080");
		wait for ClockPeriod;
		read(X"80A080");
		wait for ClockPeriod;

		wait for (ClockPeriod * 20000);
 		read(X"80A011");						-- Axis 0 Status
		wait for ClockPeriod;
		read(X"80A010");						-- Axis 0 Position

	end process;

  -- *** End Test Bench - User Defined Section ***

END;


