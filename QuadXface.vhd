--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		QuadXface
--	File			QuadXface.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		
--
--	Revision: 1.1
--
--	File history:
--		Rev 1.1 : 06/10/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity QuadXface is
	Port (
		H1_CLKWR		: in std_logic;
		SysClk			: in std_logic;
		SynchedTick		: in std_logic;
		intDATA			: in std_logic_vector(31 downto 0);
		QuadDataOut		: out std_logic_vector(31 downto 0);
		CountRead		: in std_logic;
		LEDStatusRead	: in std_logic;
		LEDStatusWrite	: in std_logic;
		InputRead		: in std_logic;
		HomeRead		: in std_logic;
		Latch0Read		: in std_logic;
		Latch1Read		: in std_logic;
		Home			: in std_logic;
		RegistrationX	: in std_logic;
		RegistrationY	: in std_logic;
		LineFault		: in std_logic_vector(2 downto 0);
		A				: in std_logic;
		B				: in std_logic;
		Index			: in std_logic
		);
end QuadXface;

architecture QuadXface_arch of QuadXface is

	constant PosDir:					std_logic := '1';
	constant NegDir:					std_logic := '0';

	signal	Latch0Reg,
			Latch1Reg,
			HomeReg,
			QuadLatch,
			QuadCount				: std_logic_vector(15 downto 0);	-- := X"0000";
	signal	QuadSignExt,
			HomeSignExt,
			Latch0SignExt,
			Latch1SignExt			: std_logic_vector(31 downto 16);	-- := X"0000";
	signal	Increment,
			Decrement,
			QATransition,
			QBTransition			: std_logic;	-- := '0';
	signal	QZ,
			QH,
			QL0,
			QL1						: std_logic_vector(2 downto 0);	-- := "000";
	signal	QA,
			QB						: std_logic_vector(3 downto 0);	-- := "0000";
	signal	Latch0RisingArmed,
			Latch0FallingArmed		: std_logic;	-- := '0';
	signal	Latch1RisingArmed,
			Latch1FallingArmed		: std_logic;	-- := '0';
	signal	HomeRisingArmed,
			HomeFallingArmed,
			CaptureHomeCounts		: std_logic;	-- := '0';
	signal	RisingHome,
			FallingHome				: std_logic;	-- := '0';
	signal	RisingHomeEvent,
			FallingHomeEvent		: std_logic;	-- := '0';
	signal	RisingLatch0,
			FallingLatch0			: std_logic;	-- := '0';
	signal	RisingLatch1,
			FallingLatch1			: std_logic;	-- := '0';
	signal	RisingLatch0Event,
			FallingLatch0Event		: std_logic;	-- := '0';
	signal	RisingLatch1Event,
			FallingLatch1Event		: std_logic;	-- := '0';
	signal	PostCount,
			LatchedInc,
			LatchedDec				: std_logic;	-- := '0';
	signal	ZBreak,
			ABreak,
			BBreak					: std_logic;	-- := '0';
	signal	intAccumOverflow,
			AccumOverflow			: std_logic;	-- := '0';
	signal	HomeArm,
			HomePolarity,
			IndexPolarity,
			intHomeLat,
			HomeLat					: std_logic;	-- := '0';
	signal	Latch0ArmedState,
			Latch1ArmedState,
			HomeTriggerType			: std_logic_vector(2 downto 0);	-- := "000";
	signal	intIllegalTransition,
			IllegalTransitionLat,
			IllegalTransition		: std_logic;	-- := '0';
	signal	MaxPosNum,
			MaxNegNum,
			Latch0InSel,
			Latch1InSel				: std_logic;	-- := '0';
	signal	Latch0Input,
			Latch1Input,
			CaptureLatch0Counts,
			CaptureLatch1Counts		: std_logic;	-- := '0';
	signal	intLatch0Lat,
			intLatch1Lat,
			Latch0Lat,
			Latch1Lat				: std_logic;	-- := '0';
	signal	HomeIndexArmed,
			HomeIndexHomeArmed,
			HomeIndexNotHomeArmed	: std_logic;	-- := '0';
	signal	IndexEvent,
			IndexHomeEvent,
			IndexNotHomeEvent		: std_logic;	-- := '0';
	signal	IndexReg3,
			IndexLat				: std_logic;	-- := '0';
	signal	intLearnModeDone,
			LearnModeEnable,
			Direction,
			DirectionLat			: std_logic;	-- := '0';
	signal	IndexEdgeDetected,
			IndexEdgeEvent			: std_logic;	-- := '0';
	signal	RisingA,
			FallingA,
			EdgeDetectInput			: std_logic;	-- := '0';
	signal	CaptureHomeCountsLat,
			EdgeMode,
			intEdgeMode				: std_logic;	-- := '0';
	signal	clrLearnModeDone		: std_logic;	-- := '0';

begin

	-- These values are place holders until the actual logic can be implemented

	QuadSignExt(31 downto 16) <=	QuadLatch(15) & QuadLatch(15) & QuadLatch(15) & QuadLatch(15) & 
								QuadLatch(15) & QuadLatch(15) & QuadLatch(15) &	QuadLatch(15) &
								QuadLatch(15) & QuadLatch(15) & QuadLatch(15) &	QuadLatch(15) &
								QuadLatch(15) & QuadLatch(15) & QuadLatch(15) &	QuadLatch(15);

	HomeSignExt(31 downto 16) <=	HomeReg(15) & HomeReg(15) & HomeReg(15) & HomeReg(15) & 
								HomeReg(15) & HomeReg(15) & HomeReg(15) & HomeReg(15) &
								HomeReg(15) & HomeReg(15) & HomeReg(15) & HomeReg(15) &
								HomeReg(15) & HomeReg(15) & HomeReg(15) & HomeReg(15);

	Latch0SignExt(31 downto 16) <=	Latch0Reg(15) & Latch0Reg(15) & Latch0Reg(15) & Latch0Reg(15) & 
									Latch0Reg(15) & Latch0Reg(15) & Latch0Reg(15) &	Latch0Reg(15) &
									Latch0Reg(15) & Latch0Reg(15) & Latch0Reg(15) &	Latch0Reg(15) &
									Latch0Reg(15) & Latch0Reg(15) & Latch0Reg(15) &	Latch0Reg(15);

	Latch1SignExt(31 downto 16) <=	Latch1Reg(15) & Latch1Reg(15) & Latch1Reg(15) & Latch1Reg(15) & 
									Latch1Reg(15) & Latch1Reg(15) & Latch1Reg(15) &	Latch1Reg(15) &
									Latch1Reg(15) & Latch1Reg(15) & Latch1Reg(15) &	Latch1Reg(15) &
									Latch1Reg(15) & Latch1Reg(15) & Latch1Reg(15) &	Latch1Reg(15);

	QuadDataOut(31 downto 0) <=	QuadSignExt(31 downto 16) & QuadLatch(15 downto 0) when CountRead = '1' else
								-- the following 6 "Z's" must be kept here. The LED status is driven out of a separate module
								-- and if we drive anything else for those bits, we'll have internal bus contention
								"000000" & IllegalTransition & ZBreak & BBreak & ABreak & AccumOverflow & 
								'0' & Latch1Lat & Latch0Lat & HomeLat & DirectionLat & EdgeMode & LearnModeEnable & Latch1ArmedState(2 downto 0) & 
								Latch1InSel & Latch0ArmedState(2 downto 0) & Latch0InSel & HomeTriggerType(2 downto 0) & HomeArm & IndexPolarity & 
								HomePolarity when LEDStatusRead = '1' else
								X"000000" & '0' & IndexLat & B & A & RegistrationY & RegistrationX & Home & '0' -- This '0' is for the Fault Input that is driven from the ControlIO module
								when InputRead = '1' else
								HomeSignExt(31 downto 16) & HomeReg(15 downto 0) when HomeRead = '1' else
								Latch0SignExt(31 downto 16) & Latch0Reg(15 downto 0) when Latch0Read = '1' else
								Latch1SignExt(31 downto 16) & Latch1Reg(15 downto 0) when Latch1Read = '1' else
								X"0000_0000";

	process(H1_CLKWR)
	begin	
		if rising_edge(H1_CLKWR) then
			-- Configure the Polarity bits
			-- Configure the Home Arming bits
			if LEDStatusWrite then
				HomePolarity <= intDATA(0);
				IndexPolarity <= intDATA(1);
				HomeTriggerType(2 downto 0) <= intDATA(5 downto 3);
				Latch0InSel <= intDATA(6);
				Latch1InSel <= intDATA(10);
			end if;

			-- Configure the Home Arming bits
			if intHomeLat then
				HomeArm <= '0';
			elsif LEDStatusWrite then
				HomeArm <= intDATA(2);
			end if;

			-- Configure the Registration Arming bits
			if intLatch0Lat then
				Latch0ArmedState(2 downto 0) <= "000";
			elsif LEDStatusWrite then
				Latch0ArmedState(2 downto 0) <= intDATA(9 downto 7);
			end if;

			-- Configure the Registration Arming bits
			if intLatch1Lat then
				Latch1ArmedState(2 downto 0) <= "000";
			elsif LEDStatusWrite then
				Latch1ArmedState(2 downto 0) <= intDATA(13 downto 11);
			end if;

			-- Configure the Learn Z-Homing Edge Mode bit
			if clrLearnModeDone then
				LearnModeEnable <= '0';
			elsif LEDStatusWrite then
				LearnModeEnable <= intDATA(14);
			end if;
		end if;
	end process;

	Latch0RisingArmed	<= '1' when Latch0ArmedState(2 downto 0) = "010"  else '0';
	Latch0FallingArmed <= '1' when Latch0ArmedState(2 downto 0) = "001" else '0';

	Latch1RisingArmed	<= '1' when Latch1ArmedState(2 downto 0) = "010"  else '0';
	Latch1FallingArmed <= '1' when Latch1ArmedState(2 downto 0) = "001" else '0';

	-- The clocks on this process and the add/subtract functions MUST be out of phase
	-- Otherwise quad counts could(will) be lost.
	process (SysClk)
	begin
		if rising_edge(SysClk) then
			QA(3 downto 0) <= QA(2 downto 0) & A;
			QB(3 downto 0) <= QB(2 downto 0) & B;
			QZ(2 downto 0) <= QZ(1 downto 0) & Index;
		end if;
	end process;

	-- Using the two latched values of A & B, determine if an decrement is needed
	process (QA(2),QB(2),QA(1),QB(1))
	begin
		Decrement <=	(not QA(2) and not QB(2) and not QA(1) and QB(1)) or
						(not QA(2) and QB(2) and QA(1) and QB(1)) or
						(QA(2) and QB(2) and QA(1) and not QB(1)) or
						(QA(2) and not QB(2) and not QA(1) and not QB(1));
	end process;

	-- Using the two latched values of A & B, determine if an increment is needed
	process (QA(2),QB(2),QA(1),QB(1))
	begin
		Increment <= 	(not QA(2) and not QB(2) and QA(1) and not QB(1)) or
						(not QA(2) and QB(2) and not QA(1) and not QB(1)) or
						(QA(2) and QB(2) and not QA(1) and QB(1)) or
						(QA(2) and not QB(2) and QA(1) and QB(1));
	end process;

	-- Using the two latched values for A & B, determine if an illegal transition
	-- has occurred.
	QATransition <= '1' when QA(3 downto 1) = "001" or QA(3 downto 1) = "011" or QA(3 downto 1) = "110" or QA(3 downto 1) = "100" else '0';
	QBTransition <= '1' when QB(3 downto 1) = "001" or QB(3 downto 1) = "011" or QB(3 downto 1) = "110" or QB(3 downto 1) = "100" else '0';

	intIllegalTransition <= '1' when QATransition = '1' and QBTransition = '1' else '0';

	-- Latch the illegal transition bit until the looptick occurs
	-- After which the bit is passed up to the processor and reset in
	-- the FPGA
	process(SysClk)
	begin
		if rising_edge(SysClk) then
			if SynchedTick then
				IllegalTransitionLat <= '0';
			else
				IllegalTransitionLat <= intIllegalTransition or IllegalTransitionLat;
			end if;
		end if;
	end process;

	-- The latched value is necessary to accomodate the control loop clearing of the Quad Counter
	-- The out-of-phase clocking is also necessary to maintain the high-speed A/B counting
	process(SysClk)
	begin
		if falling_edge(SysClk) then
			LatchedInc <= Increment or (LatchedInc and not PostCount);
			LatchedDec <= Decrement or (LatchedDec and not PostCount);
		end if;
	end process;
	
	-- Increment or Decrement the counts based upon A/B sequence
	process(SysClk)
	begin
		if rising_edge(SysClk) then
			if SynchedTick then
				QuadCount(15 downto 0) <= X"0000";
			elsif LatchedInc then
				QuadCount(15 downto 0) <= QuadCount(15 downto 0) + '1';
				PostCount <= LatchedInc;
			elsif LatchedDec then
				QuadCount(15 downto 0) <= QuadCount(15 downto 0) - '1';
				PostCount <= LatchedDec;
			else
				PostCount <= '0';
			end if;
		end if;
	end process;

	-- Transfer the counts to the Latch when the control loop tick comes by
	process(SysClk)
	begin
		if rising_edge(SysClk) then
			if SynchedTick then
				QuadLatch(15 downto 0) <= QuadCount(15 downto 0);
			end if;
		end if;
	end process;

	-- Check for Overflow of the transition counter
	MaxPosNum <= '1' when QuadCount(15 downto 0) = X"7FFF" else '0';
	MaxNegNum <= '1' when QuadCount(15 downto 0) = X"8000" else '0';

	-- Logic for overflow detection
	process(SysClk)
	begin
		if rising_edge(SysClk) then
			if	SynchedTick then
				intAccumOverflow <= '0';
			else
				intAccumOverflow <=	(MaxPosNum and LatchedInc) or (MaxNegNum and LatchedDec) or 
									intAccumOverflow;
			end if;
		end if;
	end process;

	-- Keep track of the direction so we can use it in the homing routines
	-- '1' => PosDir; '0' => NegDir
	process(SysClk)
	begin
		if falling_edge(SysClk) then
			if Increment or Decrement then
				Direction <= Increment and not Decrement;
			end if;
		end if;
	end process;

	-- Home register logic
	HomeRisingArmed <= '1' when (HomeTriggerType(2 downto 0) = "000" and HomeArm = '1') else '0';
	HomeFallingArmed <= '1' when (HomeTriggerType(2 downto 0) = "001" and HomeArm = '1') else '0';
	HomeIndexArmed <= '1' when (HomeTriggerType(2 downto 0) = "010" and HomeArm = '1') else '0';
	HomeIndexHomeArmed <= '1' when (HomeTriggerType(2 downto 0) = "011" and HomeArm = '1') else '0';
	HomeIndexNotHomeArmed <= '1' when (HomeTriggerType(2 downto 0) = "100" and HomeArm = '1') else '0';

	-- edge detection for Home input
	process(SysClk)
	begin
		if rising_edge(SysClk) then
			QH(2 downto 0) <= QH(1 downto 0) & Home;
			RisingHome <= QH(1) and not QH(2);
			FallingHome <= not QH(1) and QH(2);
		end if;
	end process;

	-- Home input capture logic
	RisingHomeEvent 	<= '1' when RisingHome = '1' else '0'; -- If the Home Polarity is ever implemented it'd go here
	FallingHomeEvent 	<= '1' when FallingHome = '1' else '0'; -- If the Home Polarity is ever implemented it'd go here

	-- Here we'll do edge detection of the Index pulse (Z). This will be done based upon
	-- the direction of the axis. By default, we'll detect the rising edge of the Index Pulse
	-- when we're traveling in the positive direction and the falling edge of the Index Pulse
	-- when we're traveling in the negative direction.
	-- Using the latched values for Z, determine if a transition has occurred.
	IndexEdgeEvent 	<= '1' when	(QZ(2) = '0' and QZ(1) = '1' and Direction = '1') or
								(QZ(2) = '1' and QZ(1) = '0' and Direction = '0') else '0';

	EdgeDetectInput <= '1' when	(IndexEdgeEvent = '1' and (HomeIndexArmed = '1' or HomeIndexHomeArmed = '1' or 
								HomeIndexNotHomeArmed = '1')) else '0';

	-- Latch the fact that we've detected the edge of the Index Pulse
	-- only latch this if the index is used as part of the active homing routine
	process(SysClk)
	begin
		if rising_edge(SysClk) then
			IndexEdgeDetected <= EdgeDetectInput or (IndexEdgeDetected and not IndexEvent);
		end if;
	end process;

	-- We've found the edge of the index pulse, now we have to apply it according to the 
	-- EdgeMode bit and the actual direction of the axis.
	--  -------     -------
	-- A| 1 1 | 0 0 | 1 1 |
	-- --     -------     ----
	--     -------     -------
	-- B	 | 1 1 | 0 0 | 1 1 |
	-- ----      -------     ----
	--
	-- If the EdgeMode (0) Detection occurs when B = 1, then PosDir Homes on Rising A & NegDir Homes on Falling A
	-- If the EdgeMode (1) Detection occurs when B = 0, then PosDir Homes on Falling A & NegDir Homes on Rising A

	process(SysClk)
	begin
		if rising_edge(SysClk) then
			if (LearnModeEnable and IndexEdgeEvent) then
				intEdgeMode <= not QB(2);
			elsif clrLearnModeDone then
				intEdgeMode <= '0';
			end if;
		end if;
	end process;

	process(H1_CLKWR)
	begin
		if rising_edge(H1_CLKWR) then
			if (LearnModeEnable and SynchedTick) then
				EdgeMode <= intEdgeMode;
			elsif LEDStatusWrite then
				EdgeMode <= intDATA(15);
			end if;
		end if;
	end process;

	process(SysClk)
	begin
		if rising_edge(SysClk) then
			intLearnModeDone <= (IndexEdgeEvent and LearnModeEnable) or (intLearnModeDone and not clrLearnModeDone);

			clrLearnModeDone <= intLearnModeDone and SynchedTick;
		end if;
	end process;

	RisingA 	<= '1' when QA(2) = '0' and QA(1) = '1' else '0';
	FallingA <= '1' when QA(2) = '1' and QA(1) = '0' else '0';

	IndexEvent <= '1' when	((IndexEdgeDetected = '1' and EdgeMode = '0' and
							((RisingA = '1' and Direction = '1') or (FallingA = '1' and Direction = '0'))) or
							(IndexEdgeDetected = '1' and EdgeMode = '1' and
							((RisingA = '1' and Direction = '0') or (FallingA = '1' and Direction = '1')))) else '0';

	IndexHomeEvent 	<= '1' when IndexEvent = '1' and QH(2) = '1' else '0';
	IndexNotHomeEvent <= '1' when IndexEvent = '1' and QH(2) = '0' else '0';

	CaptureHomeCounts <= '1' when	(RisingHomeEvent = '1' and HomeRisingArmed = '1') or
									(FallingHomeEvent = '1' and HomeFallingArmed = '1') or
									(IndexEvent = '1' and HomeIndexArmed = '1') or
									(IndexHomeEvent = '1' and HomeIndexHomeArmed = '1') or
									(IndexNotHomeEvent = '1' and HomeIndexNotHomeArmed = '1') else '0';

	process(SysClk)
	begin
		if rising_edge(SysClk) then
			CaptureHomeCountsLat <= CaptureHomeCounts;

			-- Capture the current counts when an Event occurs
			if CaptureHomeCountsLat then 
				HomeReg(15 downto 0) <= QuadCount(15 downto 0);
				DirectionLat <= Direction;
			end if;

			-- Capture and hold the Index Input for one loop time.
			-- This will allow it to be displayed on the plots, but won't affect the Homing position
			IndexReg3 <= QZ(2) or (IndexReg3 and not SynchedTick);
			IndexLat <= (IndexReg3 and SynchedTick) or (IndexLat and not SynchedTick);

			-- Manage the status bits for Home latch
			if SynchedTick then
				HomeLat <= intHomeLat;
			end if;

			-- Be careful not to clear the intHomeLat when the CaptureHomeCount might be coming through
			if SynchedTick and not CaptureHomeCounts then
				intHomeLat <= '0';
			elsif
				CaptureHomeCounts then
					intHomeLat <= '1';
			end if;
		end if;
	end process;
	
	-- Latch0 register logic

	-- Select the input based upon the Latch0InSel value
	Latch0Input <= '1' when (Latch0InSel = '0' and RegistrationX = '1') or (Latch0InSel = '1' and RegistrationY = '1') else '0';

	-- edge detection for Latch0 input
	process(Sysclk)
	begin
		if rising_edge(SysClk) then
			QL0(2 downto 0) <= QL0(1 downto 0) & Latch0Input;
			RisingLatch0 <= QL0(1) and not QL0(2);
			FallingLatch0 <= not QL0(1) and QL0(2);
		end if;
	end process;

	-- Latch0 input capture logic
	RisingLatch0Event <= '1' when RisingLatch0 = '1' else '0';
	FallingLatch0Event <= '1' when FallingLatch0 = '1' else '0';
	CaptureLatch0Counts <= '1' when ((RisingLatch0Event = '1' and Latch0RisingArmed = '1') or (FallingLatch0Event = '1' and
										Latch0FallingArmed = '1')) else '0';

	process(SysClk)
	begin
		if rising_edge(SysClk) then
			if CaptureLatch0Counts then 
				Latch0Reg(15 downto 0) <= QuadCount(15 downto 0);
			end if;

			-- Manage the status bits for Latch0 latch
			if SynchedTick then
				Latch0Lat <= intLatch0Lat;
				intLatch0Lat <= '0';
			elsif CaptureLatch0Counts then
				intLatch0Lat <= '1';
			end if;
		end if;
	end process;

	-- Latch1 register logic
	-- Select the input based upon the Latch1InSel value
	Latch1Input <= '1' when (Latch1InSel = '0' and RegistrationX = '1') or (Latch1InSel = '1' and RegistrationY = '1') else '0';

	-- edge detection for Latch1 input
	process(Sysclk)
	begin
		if rising_edge(SysClk) then
			QL1(2 downto 0) <= QL1(1 downto 0) & Latch1Input;
			RisingLatch1 <= QL1(1) and not QL1(2);
			FallingLatch1 <= not QL1(1) and QL1(2);
		end if;
	end process;

	-- Latch1 input capture logic
	RisingLatch1Event <= '1' when RisingLatch1 = '1' else '0';

	FallingLatch1Event <= '1' when FallingLatch1 = '1' else '0';

	CaptureLatch1Counts <= '1' when	(RisingLatch1Event = '1' and Latch1RisingArmed = '1') or 
									(FallingLatch1Event = '1' and Latch1FallingArmed = '1') else '0';

	process(SysClk)
	begin
		if rising_edge(SysClk) then
			if CaptureLatch1Counts then 
				Latch1Reg(15 downto 0) <= QuadCount(15 downto 0);
			end if;

			-- Manage the status bits for Latch0 latch
			if SynchedTick then
				Latch1Lat <= intLatch1Lat;
				intLatch1Lat <= '0';
			elsif
				CaptureLatch1Counts then
					intLatch1Lat <= '1';
			end if;

			if SynchedTick then
				ABreak <= LineFault(0); 
				BBreak <= LineFault(1);
				ZBreak <= LineFault(2);
				AccumOverflow <= intAccumOverflow;
				IllegalTransition <= IllegalTransitionLat;
			end if;
		end if;
	end process;

end QuadXface_arch;