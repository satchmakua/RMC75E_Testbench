--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		StateMachine
--	File			stateMachine.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		The state machine controls the sampling of the data from the A2D converter
--
--		In this particular implementation there will be four samples taken each
--		sample time. Two samples from channel 0 and two samples from channel 1.
--		The spacing (time) between sample groups will be controlled by the 
--		LoopTimeFlag signal. 
--
--		Conversion sequence is as follows ch0 & ch1, ch0 & ch1 wait(1 or 2), ch0 & ch1, ch0 & ch1 wait....
--
--	Revision: 1.2
--
--	File history:
--		Rev 1.2 : 12/19/2022 :	Initialized signals, added comments, cleaned up
--		Rev 1.1 : 06/06/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity StateMachine is
	port (
		SysReset			: in std_logic;			-- System Reset or PLL not locked
		SysClk				: in std_logic;			-- 30 MHz system clock
		SlowEnable			: in std_logic;			-- Enable every 8th system clock (3.75 MHz)
		SynchedTick			: in std_logic;			-- Loop tick synchronized to system clock
		LoopTime			: in std_logic_vector (2 downto 0);	-- Specifies loop time (000 => 1/8 ms ... 101 => 4 ms)
		ExpA_CS_L			: out std_logic;		-- Chip Select for ADC
		ExpA_CLK			: out std_logic;		-- Clock for ADC
		Serial2ParallelEN	: out std_logic;		-- Enable for shift register for ADC output
		Serial2ParallelCLR	: out std_logic;		-- Clear Shifte register for ADC output
		WriteConversion		: out std_logic			-- End of conversion indicator
	);
end StateMachine;

architecture StateMachine_arch of StateMachine is

	type STATE_TYPE is array (2 downto 0) of std_logic;
	-- state encoding
	constant StartState				: STATE_TYPE :="000";
	constant SampleHoldState		: STATE_TYPE :="001";
	constant ConvertState			: STATE_TYPE :="011";
	constant ConvertWaitState1		: STATE_TYPE :="010";
	constant ConvertWaitState2		: STATE_TYPE :="110";
	constant ConvertDoneState		: STATE_TYPE :="111";
	constant IncConvCountState		: STATE_TYPE :="101";
	constant InterConvDelayState	: STATE_TYPE :="100";

	-- The following delay times are used to spread the data samples over the entire control loop
	-- period. 
	-- Each conversions takes 14us. There are 8 conversions per loop time so 
	-- 8 x 14us = 104us. 1ms - 104us = 896us. 896us is the total gap that
	-- must be filled with 8 delay periods. 896us/8 = 112us/period. 
	-- The delay counter uses the SlowEnable clock enable line which runs at 3.75MHz
	-- so, 112us/266.7ns = 419 clocks = 419 counts.

	-- The same logic is applied to the 2ms loop time. 
	-- 2ms - 120us = 1.880ms.
	-- 1.880ms/8 = 235us
	-- 235us/266.7ns = 881 counts.

	-- 500us loop time is 180 counts of interconversion delay
	-- 250us loop time is 60 counts of interconversion delay
	-- 125us loop time is 5 counts of interconversion delay

	constant eighth_ms_interconversion_delay	: std_logic_vector (10 downto 0) := "00000000101";	-- 5 counts
	constant quarter_ms_interconversion_delay	: std_logic_vector (10 downto 0) := "00001000000";	-- 60 counts
	constant half_ms_interconversion_delay		: std_logic_vector (10 downto 0) := "00010110100";	-- 180 counts
	constant one_ms_interconversion_delay		: std_logic_vector (10 downto 0) := "00110011100";	-- 412 counts
	constant two_ms_interconversion_delay		: std_logic_vector (10 downto 0) := "01101110001";	-- 881 counts
	constant four_ms_interconversion_delay		: std_logic_vector (10 downto 0) := "11100011100";	-- 1820 counts

	constant eighth_ms	: std_logic_vector (2 downto 0) := "000";
	constant quarter_ms	: std_logic_vector (2 downto 0) := "001";
	constant half_ms	: std_logic_vector (2 downto 0) := "010";	
	constant one_ms		: std_logic_vector (2 downto 0) := "011";	  	
	constant two_ms		: std_logic_vector (2 downto 0) := "100";  		
	constant four_ms	: std_logic_vector (2 downto 0) := "101";		

	signal	State						: STATE_TYPE; -- state can be assigned the constants s0-s4
	signal	EndDelay,
--			SampleHoldDone,
			ConversionDone				: std_logic;	-- :='0';
	signal	ConversionCounterEN,
			ExpA_CLK_EN					: std_logic;	-- :='0';
	signal	intExpA_CLK					: std_logic_vector (1 downto 0);	-- := "00";
	signal	ConversionCounter			: std_logic_vector (3 downto 0);	-- := X"0";
	signal	CycleCounter				: std_logic_vector (4 downto 0);	-- := "00000";
	signal	InterConversionDelayCNTR	: std_logic_vector (10 downto 0);	-- := "00000000000";
	signal	InterConversionDelayEN,
			InterConversionDelayTC,
			intConverting,
			Converting					: std_logic;	-- := '0';
	signal	intWriteConversion,
			intWriteConversion2,
			intSerial2ParallelEN		: std_logic;	-- := '0';
	signal	WriteEn						: std_logic;	-- := '0';
	signal	ResetCycleCounter			: std_logic;	-- := '0';

begin  -- internal architecure logic description

	-- "Converting" begins the conversion state machine
	intConverting <= '1' when SynchedTick = '1' or (Converting = '1' and ConversionCounter /= "1000") else '0';

	process (SysClk)
	begin
		if rising_edge(SysClk) then
			Converting <= intConverting;
		end if;
	end process;

	StateMachine : process(SysClk)
	begin
		if rising_edge(SysClk) then 
			if SysReset or SynchedTick then
				State <= StartState;			-- reset state, this will reset the state machine every loop time
			elsif SlowEnable = '1' then
				case State is

					when StartState =>
						if Converting then
							ExpA_CS_L <= '0';  					-- converter chip select active
							Serial2ParallelCLR <= '0';
							ConversionCounterEN <= '0';
							State <= SampleHoldState;
						else 
							ExpA_CS_L <= '1';					-- converter chip select inactive
							Serial2ParallelCLR <= '1';
							InterConversionDelayEN <= '0';	
							ConversionCounterEN <= '0';
						end if;

					when SampleHoldState =>
						--	Sample and Hold is Done after 6 cycles
						if CycleCounter = "00110" then 			-- wait 'til sample/hold is complete (5 clocks)
							intSerial2ParallelEN <= '1'; 		-- converter data is being received
							State <= ConvertState;
						else
							ExpA_CS_L <= '0';     				-- converter chip select still active
						end if;							

					when ConvertState =>
						-- Conversion is done after 22 (6 + 16) cycles
						if CycleCounter = "10110" then 			-- stay here until conversion is done
							ExpA_CS_L <= '1';     				-- converter chip select turned off
							intSerial2ParallelEN <= '0'; 		-- converter data is finished
							intWriteConversion <= '1';
							State <= ConvertWaitState1;
						else 
							ExpA_CS_L <= '0';     				-- converter chip select still active
							intSerial2ParallelEN <= '1'; 		-- converter data is being received
						end if;

					-- Serial2Parallel Conversion complete
					when ConvertWaitState1 =>
						intWriteConversion <= '0';
						State <= ConvertWaitState2;

					when ConvertWaitState2 =>	
						State <= ConvertDoneState;

					when ConvertDoneState => 
						if not EndDelay then					-- have to delay one clock to allow
							ConversionCounterEN <= '1';			-- the last data write to RAM
							State <= IncConvCountState;	
						else
							Serial2ParallelCLR <= '1';
						end if;

					when IncConvCountState =>					-- After every conversion, there will be a
						ConversionCounterEN <= '0';				-- delay that is dictated by the loop time	
						State <= InterConvDelayState;

					-- this state adds a delay between every conversion
					when InterConvDelayState =>	
						if InterConversionDelayTC then
							InterConversionDelayEN <= '0';
							State <= StartState;
						else
							InterConversionDelayEN <= '1';
						end if;

					when others =>
						State <= StartState;					-- default, reset state
				end case;
			end if;
		end if;
	end process;

	process (SysClk)
	begin
		if rising_edge(SysClk) then
			if (State = StartState) then
				EndDelay <= '0';
			elsif (State = ConvertDoneState and SlowEnable = '1') then			
				EndDelay <= '1';
			end if;

			if ((State = SampleHoldState or State = ConvertState) and CycleCounter < "10110") then --(26 clocks)
				ExpA_CLK_EN <= '1';
			else
				ExpA_CLK_EN <= '0';
			end if;

			if not ExpA_CLK_EN then
				intExpA_CLK(0) <= '0';
			elsif SlowEnable then
				intExpA_CLK(0) <= not intExpA_CLK(0);
			end if;

			intExpA_CLK(1) <= intExpA_CLK(0);
			ExpA_CLK <= intExpA_CLK(1);

			-- the conversion counter counts the # of conversions that have occurred this loop time
			if SynchedTick then
				ConversionCounter <= X"0";
			elsif ConversionCounterEN and SlowEnable then
				ConversionCounter <= ConversionCounter + '1';
			end if;

			if (State = StartState or State = InterConvDelayState) then
				ResetCycleCounter <= '1';
			else
				ResetCycleCounter <= '0';
			end if;
			
			-- the cycle counter is used to keep track of the logic sequence during the individual
			-- conversions. State s0 or InterConvDelay resets the counter. Any other state allows it to count
			if ResetCycleCounter = '1' then
				CycleCounter <= "00000";
			elsif SlowEnable = '1' and intExpA_CLK(0) = '1' and (State /= StartState or State /= InterConvDelayState) then			
				CycleCounter <= CycleCounter + '1';
			end if;

			-- the InterConversionDelayCNTR is used to insert a delay between conversions
			if SynchedTick or InterConversionDelayTC then
				InterConversionDelayCNTR <= "00000000000";
			elsif SlowEnable and InterConversionDelayEN then
				InterConversionDelayCNTR <= InterConversionDelayCNTR + '1';
			end if;

			-- The time between conversions (terminal count) is dictated by the LoopTime.
			if SlowEnable = '1' and
					((InterConversionDelayCNTR >= eighth_ms_interconversion_delay	and LoopTime = eighth_ms)	or
					(InterConversionDelayCNTR >= quarter_ms_interconversion_delay	and LoopTime = quarter_ms)	or
					(InterConversionDelayCNTR >= half_ms_interconversion_delay		and LoopTime = half_ms)		or
					(InterConversionDelayCNTR = one_ms_interconversion_delay		and LoopTime = one_ms)		or
					(InterConversionDelayCNTR = two_ms_interconversion_delay		and LoopTime = two_ms)		or
					(InterConversionDelayCNTR = four_ms_interconversion_delay		and LoopTime = four_ms))	 then
				InterConversionDelayTC <= '1';
			else
				InterConversionDelayTC <= '0';
			end if;

			-- WriteConversion is active for only one clock cycle after every conversion. It is used to trigger the
			-- databuffer writes from every channel 4 modules x 2 channels each (8 conversions) 
			-- plus the two Control Axis conversions.
			intWriteConversion2 <= intWriteConversion;
			if not intWriteConversion2 and intWriteConversion then
				WriteConversion <= '1';--WriteEN;
			else
				WriteConversion <= '0';
			end if;

		end if;
	end process;

	Serial2ParallelEN <= '1' when intSerial2ParallelEN = '1' and intExpA_CLK(0) = '1' and SlowEnable = '1' else '0';

--	SampleHoldDone <= '1' when CycleCounter = "00110" else '0'; -- 6 cycles for Sample and Hold

end StateMachine_arch;