--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		SSITop
--	File			SSITop.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		SSI Interface
--		The SSI Interface will provide a signal interface to 
--		Synchronous Serial Interface type linear and rotary transducers. 
--
--	Revision: 1.2
--
--	File history:
--		Rev 1.2 : 11/14/2022 :	Consolidated three sub-components into this entity
--		Rev 1.1 : 06/10/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity SSITop is
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
end SSITop;

architecture SSITop_arch of SSITop is

	constant SSIBinaryAnalogValue : bit_vector := B"0110";    --0x6
	constant SSIBinaryAnalogXducer : std_logic_vector (3 downto 0) := To_StdLogicVector(SSIBinaryAnalogValue);

	constant SSIGrayAnalogValue : bit_vector := B"0111";         --0x7
	constant SSIGrayAnalogXducer : std_logic_vector (3 downto 0) := To_StdLogicVector(SSIGrayAnalogValue);

	-- SSI internal signal declarations
	signal	SSIDataLatch		 : std_logic_vector (31 downto 0);	-- := X"0000_0000";
	signal	CheckDataLo,
			CheckDataHi			: std_logic;	-- := '0';
	signal	Shift				: std_logic;	-- := '0';
	signal	StartRead			: std_logic;	-- := '0';

	-- Local Parameter Storage
	signal	TransducerSelect	: std_logic_vector (4 downto 0);	-- := "00000";
	signal	DataLength			: std_logic_vector (5 downto 0);	-- := "000000";
	signal	ClockRate			: std_logic_vector (1 downto 0);	-- := "00";
	signal	DelayTerminalCount	: std_logic_vector (15 downto 0);	-- := X"0000";
	signal	HalfPeriod			: std_logic_vector (5 downto 0);	-- := "000000";

	-- mode signal declarations
	signal	SSIBinaryAnalog,
			SSIGrayAnalog		: std_logic;	-- := '0';
	signal	NoXducer,
			DataValid			: std_logic;	-- := '0';
	signal	intDataValid		: std_logic;	-- := '0';
	signal	SSIRead,
			SSIRead1			: std_logic;	-- := '0';

	-- Start Delay signals
	signal	DelayCntEn			: std_logic;	-- := '0';
	signal	DelayCounter		: std_logic_vector (15 downto 0);	-- := X"0000";

	-- SSI Xface signals
	signal	Serial2ParallelData		: std_logic_vector (31 downto 0);	-- := X"0000_0000";
	signal	MuxDataOut,
			DataLineHi,
			DatalineLo				: std_logic;	-- := '0';

	-- SSI controller signals
	signal	ShiftCounter	: std_logic_vector (5 downto 0);	-- := "000000";
	signal	CycleCounter	: std_logic_vector (5 downto 0); --:= "000000";
	signal	CycleCountMatch,
			ClkOn,
			SequenceOn		: std_logic;	-- := '0';
	signal	ToggleEn,
			CheckDataDelay	: std_logic; --:= '0';
	signal	ShiftOn,
			PreTurnShiftOff,
			TurnShiftOff	: std_logic:= '0';
	signal	intSSI_CLK		: std_logic;	-- := '1';
	signal	LineBreakDelay	: std_logic;	-- := '0';

begin

	-- Note that some SSI Status is also being driven from the ControlIO module
	ssiDataOut(31 downto 0) <=	SSIDataLatch(31 downto 0) when PositionRead = '1' and SSISelect = '1' else 
								X"0" & '0' & NoXducer & DataValid & X"00" & "0" & ClockRate(1 downto 0) &  Datalength(5 downto 0) & "000" & TransducerSelect(4 downto 0) when StatusRead = '1' and SSISelect = '1' else 
								X"0000_0000";

	process (H1_CLKWR)
	begin
		if rising_edge(H1_CLKWR) then
			if ParamWrite1 then
				TransducerSelect(4 downto 0) <= intData(4 downto 0);
				Datalength(5 downto 0) <= intData(13 downto 8);
				ClockRate(1 downto 0) <= intData(15 downto 14);
--				InterrogationMode <= intData(16);
--				MagnetCount(4 downto 0) <= intData(21 downto 17);
			end if;

			if ParamWrite2 then
				DelayTerminalCount(15 downto 0) <= intData(15 downto 0);
				HalfPeriod <= intData(21 downto 16);
			end if;

			SSIRead <= PositionRead;

			-- A post read clear pulse must be generated for clearing the DataValid status bit
			SSIRead1 <= SSIRead;

			-- On falling edge of PositionRead signal, clear internal DataValid State
			if not SSIRead and SSIRead1 then
				intDataValid <= '0';
			else
				intDataValid <= not (DataLineHi or DataLineLo);
			end if;

			-- On fallinge edge of PositionRead signal, Transfer the internal Data Valid status
			--  to the CPU accessible registers
			if not SSIRead and SSIRead1 then
				DataValid <= '0';
			elsif SynchedTick then
				DataValid  <= intDataValid;
			end if;
		end if;
	end process;

	SSIBinaryAnalog <= '1' when (TransducerSelect(3 downto 0) = SSIBinaryAnalogXducer(3 downto 0)) else '0';
	SSIGrayAnalog <= '1' when (TransducerSelect(3 downto 0) = SSIGrayAnalogXducer(3 downto 0)) else '0';
	SSISelect <= SSIBinaryAnalog or SSIGrayAnalog;

	process (SysClk)
	begin
		if rising_edge(SysClk) then
			-- Enable the dealy counter with loop tick and disable it when SSI read cycle starts
			if SynchedTick and SSISelect then
				DelayCntEn <= '1';
			elsif StartRead then
				DelayCntEn <= '0';
			end if;
			
			-- Reset the delay counter with loop tick or as soon as the counter expires 
			if SynchedTick = '1' or DelayCounter = DelayTerminalCount then
				DelayCounter <= (others => '0'); 
			elsif DelayCntEn and SlowEnable then
				DelayCounter <= DelayCounter + '1';
			end if;

			-- Generate a pulse to start the SSI read cycle when the delay timer expires.
			if DelayCounter = DelayTerminalCount then
				StartRead <= '1';
			else
				StartRead <= '0';
			end if;

			-- On the loop tick, latch the contents of the shift register and clear it in preparation
			--  for the next input cycle.
			if SynchedTick then
				SSIDataLatch(31 downto 0) <= Serial2ParallelData(31 downto 0);
				Serial2ParallelData(31 downto 0) <= X"0000_0000"; 
			-- shift data in to shift register to convert incoming data: serial in/parallel out
			elsif Shift then 
				Serial2ParallelData(31 downto 1) <= Serial2ParallelData(30 downto 0);
				-- If Gray Code is selected, XOR the input data bit with the previous data bit to 
				--   convert from Gray Code to binary.
				if SSIGrayAnalog then
					Serial2ParallelData(0) <= Serial2ParallelData(0) xor SSI_DATA;
				-- For binary input, simply shift in the new data bit
				else
					Serial2ParallelData(0) <= SSI_DATA;
				end if;
			end if;

			-- check and latch the data line status before data transfer
			if CheckDataHi then
				DataLineHi <= not SSI_DATA;
			end if;

			-- check and latch the data line status after data transfer
			if CheckDataLo then
				DataLineLo <= SSI_DATA;
			end if;


			-- when the StartRead comes by; start the "machine"
			SequenceOn <= (SequenceOn and (not CheckDataLo)) or StartRead;

			-- Enables the external SCLK functions
			ClkOn <= (ClkOn and (not TurnShiftOff)) or StartRead;

			-- Enables shifting in of external data into a holding register
			if ClkOn and not ShiftOn and not intSSI_CLK and ToggleEn then
				ShiftOn <= '1';
			elsif TurnShiftOff then
				ShiftOn <= '0';
			end if;

			if Enable = '1' then
				TurnShiftOff <= PreTurnShiftOff; 
			end if;

			if not SequenceOn or ToggleEn then
				CycleCounter <= "000000"; -- If we're not enabled, the sequence is over so zero the counts
			elsif Enable then
				CycleCounter <= CycleCounter + '1';
			end if;

			-- ToggleEn must run at twice the frequency of the SSI clock in order to
			-- toggle the SSI clock at the requested ClockRate(1 downto 0)
			if ClkOn and CycleCountMatch and Enable then
				ToggleEn <= '1';
			else
				ToggleEn <= '0';
			end if;

			-- shift_cntr counts the number of bits that have been shifted in
			if StartRead or TurnShiftOff then
				ShiftCounter <= "000000";
			elsif Shift then
				ShiftCounter <= ShiftCounter + '1';
			end if;

			-- intSSI_CLK is the clock generated for the SSI DATA transfer
			if StartRead and Enable then
				intSSI_CLK <= '1';		  -- We should never have to force this high, but it's here in case of a glitch 
			elsif ToggleEn and ClkOn then
				intSSI_CLK <= not intSSI_CLK;
			end if;

			-- wire break detection; the data line must be high at start of read
			CheckDataHi <= StartRead;

			-- wire break detection; the data line must be low at end of read
			-- wait for at least one bit time plus a little before taking this sample
			if LineBreakDelay and not ClkOn then -- delay for 1 bit time before sampling the line break detection bit
				CheckDataDelay <= '1';
			else
				CheckDataDelay <= '0';
			end if;

			CheckDataLo <= CheckDataDelay;
		end if;
	end process;

	NoXducer <= DataLineHi or DataLineLo;

	-- intX signals are used internal to the module
	-- they must be reassigned to be driven out of module
	SSI_CLK <= intSSI_CLK;

	-- Terminates the process when the count reaches a predetermined length
	PreTurnShiftOff <= '1' when (DataLength(5 downto 0) = ShiftCounter) else '0';

	CycleCountMatch <= '1' when CycleCounter = HalfPeriod else '0';

	-- SHIFT is active whenever the toggle is active and the clock is low
	Shift <= ToggleEn and not intSSI_CLK and ShiftOn;

	LineBreakDelay <= '1' when ('0' & CycleCounter(5 downto 1)) = HalfPeriod else '0';

end SSITop_arch;
