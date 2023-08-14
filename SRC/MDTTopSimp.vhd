--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		MDTTopSimp
--	File			MDTTopSimp.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

--		MDT Interface:
--		The MDT Interface provides a signal interface to SPWM, Start/Stop and SSI type transducers. 
--
--		Currently, the incoming clock rate is 60MHz for all three clocks coming 
--		into the design. The SysClk0-90 are 90 degrees out of phase. This means
--		that each of these clocks can be used to drive a counter when the return
--		pulse signals a start. At the end of the count cycle the counters will
--		be added together.
--
	-- This module provides a signal interface for PWM, Start/Stop, and SSI type transducers.

	-- The module operates with three incoming clock signals: H1_CLK, H1_CLKWR, and H1_CLK90,
	-- all running at a rate of 60MHz. The H1_CLK signals are 90 degrees out of phase,
	-- allowing each clock to drive a counter when a start signal is received.
	-- At the end of the count cycle, the counters are added together.

	-- The architecture MDTTopSimp_arch defines the internal implementation of the MDTTopSimp module.
	-- It includes various signals and processes to control the MDT interface.

	-- The module includes a state machine (StateMachine) that controls the count sequence of the MDT counters.
	-- The state machine progresses through different states (s0, s1, s2, s3, s4, s5)
	-- based on different conditions and signals.
	-- The state machine handles the start and termination of the count cycle,
	-- detects return pulses, and sets various internal signals accordingly.

	-- The module also includes counters (CountRA, Delay) for counting clock cycles,
	-- debounce flops for capturing rising and falling edges of the return pulse signals,
	-- and various control signals for enabling and disabling count cycles, delaying pulses, and setting data validity.

	-- The position data is calculated and stored in the MDTPosition
	-- signal based on the count values and leading/trailing counts.
	-- The output data signal mdtSimpDataOut is set accordingly
	-- based on the input signals and the selection of SSI transducers.

	-- Overall, the MDTTopSimp module provides the interface and control for the
	-- MDT in the RMC75E modular motion controller, allowing communication with PWM, Start/Stop, and SSI type transducers.
	-- It handles the counting sequence, detects pulses, and calculates position data based on the received signals.

--	Revision: 1.4
--
--	File history:
--		Rev 1.4 : 11/15/2022 :	Add more signals to reset state in state machine to
--								 avoid generating spurious interrogation signals at startup
--		Rev 1.3 : 11/11/2022 :	Add Reset to start state machine in state s0
--		Rev 1.2 : 10/27/2022 :	Remove StopLatches signla which is causing timing violations
--		Rev 1.1 : 08/23/2022 :	Updated formatting
--								Added process XfrToH1_CLK to transfer "Edge" signal
--								  to the main clock domain without violating timing
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity MDTTopSimp is
	Port (
		SysReset		: in std_logic;		-- Main system Reset signal
		H1_CLK			: in std_logic;		-- 60MHz clock for MDT interface
		H1_CLKWR		: in std_logic;		-- CPU clock for read and writes
		H1_CLK90		: in std_logic;		-- 60MHz clock with 90 degree phase shift for MDT count
		SynchedTick60	: in std_logic;	-- Synchronized tick signal at 60MHz
		intDATA			: in std_logic_vector(31 downto 0); -- Input data signal (32 bits)
		mdtSimpDataOut	: out std_logic_vector(31 downto 0); 	-- Output data signal from the MDT (32 bits)
		PositionRead	: in std_logic; -- Signal indicating a position read operation
		StatusRead		: in std_logic; -- Signal indicating a status read operation
		ParamWrite		: in std_logic; -- Signal indicating a parameter write operation

		M_INT_CLK		: out std_logic; -- Output internal clock signa
		M_RET_DATA		: in std_logic; -- Input data signal for M_RET_DATA
		SSI_DATA		: out std_logic; -- Output SSI data signal
		SSISelect		: in std_logic -- Signal indicating the selection of SSI transducer
	);
end MDTTopSimp;

architecture MDTTopSimp_arch of MDTTopSimp is

	-- State Encoding
	type STATE_TYPE is array (2 downto 0) of std_logic;
	constant s0: STATE_TYPE :="000";
	constant s1: STATE_TYPE :="001";
	constant s2: STATE_TYPE :="010";
	constant s3: STATE_TYPE :="011";
	constant s4: STATE_TYPE :="111";
	constant s5: STATE_TYPE :="110";

	constant IntPulseLength : std_logic_vector (11 downto 0) := B"000001100100"; -- 100 counts at 60MHz (16.6ns) = 1.66us

	constant RetPulseDelay : std_logic_vector (11 downto 0) := B"101110111000"; -- 3000 counts at 60MHz (16.6ns) = 50us

	constant StartStopRisingEdgeXducer : std_logic_vector (1 downto 0) := B"01";

	constant StartStopFallingEdgeXducer : std_logic_vector (1 downto 0) := B"10";

	constant PWMXducer : std_logic_vector (1 downto 0) := B"11";

	constant OverFlowLoopLimit : std_logic_vector (1 downto 0) := B"10";

	signal	State: STATE_TYPE; -- state can be assigned the constants s0-s7
	signal	MDTPosition					: std_logic_vector (19 downto 0);	-- := X"00000";
	signal	CountRA						: std_logic_vector (17 downto 0);	-- := "000000000000000000";
	signal	TransducerSelect			: std_logic_vector (6 downto 0);	-- := "0000000";
	signal	StartInterrogation,
			SendInterrogationPulse		: std_logic;	-- := '0';
	signal	RisingA,
			RisingB,
			FallingA,
			FallingB					: std_logic_vector (3 downto 1);	-- := "000";
	signal	Delay						: std_logic_vector (11 downto 0);	-- := "000000000000";
	signal	ClearCounter,
			DelayDone,
			DelayCountEnable			: std_logic;	-- := '0';
	signal	StartStopRisingEdge,
			StartStopFallingEdge,
			PWM							: std_logic;	-- := '0';
	signal	RisingAPosEdgeFound,
			RisingANegEdgeFound,
			RisingACountEnable,
			RisingACountDisable,
			RisingACountEnableLatch		: std_logic;	-- := '0';
	signal	CounterOverFlow,
			intCounterOverFlow,
			CounterOverFlowRetrigger,
			intNoXducer,
			NoXducer,
			DataValid					: std_logic;	-- := '0';
	signal	SetDataValid,
			intDataValid,
			RetPulseDelayEnable,
			RetPulseDelayDone			: std_logic;	-- := '0';
	signal	PWMMagnetFaultLatch,
			PWMMagnetFault				: std_logic;	-- := '0'; 
	signal	MDTRead,
			MDTRead1,
			MDTSelect					: std_logic;	-- := '0';
	signal	LeadingCount,
			TrailingCount,
			LeadingCountDecode,
			TrailingCountDecode			: std_logic_vector (1 downto 0);	-- := "00";
	signal	RisingACountEnablePipe,
			RisingACountDisablePipe		: std_logic;	-- := '0';
	signal	Edge						: std_logic_vector ( 2 downto 0);	-- := "000";
	signal	intM_INT_CLK				: std_logic:= '1';

begin

	mdtSimpDataOut(31 downto 0) <=	X"000" & MDTPosition(19 downto 0) when PositionRead = '1' and SSISelect = '0' and (StartStopRisingEdge = '1' or StartStopFallingEdge = '1' or PWM = '1') else 
									X"0" & CounterOverFlow & NoXducer & DataValid & X"0000" & "00" & TransducerSelect(6 downto 0) when StatusRead = '1' and SSISelect = '0' else 
									X"0000_0000";

	-- Note that the MDT Status is also being driven from the ControlIO module

	SSI_DATA <= RisingA(1);

	-- A post read clear pulse must be generated for clearing the DataValid status bit
	process (H1_CLK)
	begin
		if rising_edge(H1_CLK) then
			MDTRead <= PositionRead;
			MDTRead1 <= MDTRead;
			-- Clear intDataValid on the loop tick and set it if SetDataValid is on and PWMMagnetFaultLatch is off
			if SynchedTick60 or PWMMagnetFaultLatch then
				intDataValid <= '0';
			elsif SetDataValid then
				intDataValid <= '1';
			end if;
			-- Transfer the internal Data Valid status to the CPU accessible status bit on the loop tick and
			--  clear the status bit on the falling edge of the position read.
			if MDTRead1 and not MDTRead then
				DataValid <= '0';
			elsif SynchedTick60 then
				DataValid <= intDataValid;
			end if;
			-- Transfer the internal NoXducer status to the CPU accessible status bit
			if SynchedTick60 then
				NoXducer <= intNoXducer;
			end if;
			-- Transfer the internal CounterOverFlow status to the CPU accessible registers
			if intCounterOverFlow then
				CounterOverFlow <= '1';       -- The intCounterOverFlow is only set on the SynchedTick60 so pass it through asynchronously
			elsif SynchedTick60 then
				CounterOverFlow <= intCounterOverFlow;
			end if;
		end if;
	end process;

	-- Set the Transducer type
	process (H1_CLKWR)
	begin
		if rising_edge(H1_CLKWR) then
			if SysReset then
				TransducerSelect(6 downto 0) <= (Others => '0');
			elsif ParamWrite then
				TransducerSelect(6 downto 0) <= intData(6 downto 0);
			end if;
		end if;
	end process;

	StartStopRisingEdge <= '1' when (TransducerSelect(1 downto 0) = StartStopRisingEdgeXducer) else '0';
	StartStopFallingEdge <= '1' when (TransducerSelect(1 downto 0) = StartStopFallingEdgeXducer) else '0';
	PWM <= '1' when (TransducerSelect(1 downto 0) = PWMXducer) else '0';

	MDTSelect <= StartStopRisingEdge or StartStopFallingEdge or PWM;

	-- State Machine to control the count sequence of the MDT counters
	StateMachine : process(H1_CLK)
	begin
		if rising_edge(H1_CLK) then 
			if SysReset then
				State <= s0;
				StartInterrogation <= '0';
				RetPulseDelayEnable <= '0';
				SendInterrogationPulse <= '0';
				CounterOverFlowRetrigger <= '0';
			else
				case State is

					-- Reset state wait here until a tick starts the machine
					when  s0 =>
						StartInterrogation <= ((SynchedTick60 and not RetPulseDelayEnable) or 
												CounterOverFlowRetrigger) and MDTSelect; 
						if StartInterrogation then
							ClearCounter <= '1';
							State <= s1;
						else
							ClearCounter <= '0';
						end if;

						SetDataValid <= '0';
						RetPulseDelayEnable <= '0';
						SendInterrogationPulse <= '0';
						CounterOverFlowRetrigger <= '0';-- This signal is used to restart the state machine on counter overflow failure

					when s1 =>
						ClearCounter <= '0';
						SendInterrogationPulse <= '1';
						State <= s2;

					-- Send the interrogation pulse and go to the next state (pulse takes 1.66us)
					-- The interrogation pulse is being sent while in this state
					when  s2 =>
						SendInterrogationPulse <= '0';
						State <= s3;

					-- Wait for the Counter to begin
					when  s3 =>
						if RisingACountEnableLatch or PWMMagnetFaultLatch then
							RetPulseDelayEnable <= '0';
							intNoXducer <= '0';					-- We have our first return pulse, so clear out the NoXducer bit
							State <= s4;
						else
							if RetPulseDelayDone then		-- There was no initial return pulse.  Set the intNoXducer bit and restart on the next control loop
								intNoXducer <= '1';				-- No return pulse, 
								RetPulseDelayEnable <= '0';		-- turn off the delay counter
								State <= s0;
							else
								RetPulseDelayEnable <= '1';
							end if; 
						end if;

					-- Wait for the terminating condition of the interrogation 
					when  s4 =>
						if not RisingACountEnableLatch and not PWMMagnetFaultLatch then            
							State <= s5;
						elsif SynchedTick60 then			-- A Control loop tick has arrived (This is bad)
							intCounterOverFlow <= '1';			-- We don't have our second return pulse, so set the overflow bit
							CounterOverFlowRetrigger <= '1';	-- This signal is used to restart the state machine on counter overflow failure
							State <= s0;
						end if;

					-- Sequence is finished
					when  s5 =>
						SetDataValid <= '1';
						intCounterOverFlow <= '0';			-- If we've made it here, then clear the overflow error
						State <= s0;

					when others =>
						State <= s0;							-- default, reset state
				end case;
			end if;
		end if;
	end process;

	process (H1_CLK)
	begin
		if rising_edge(H1_CLK) then
			if ClearCounter then
				DelayCountEnable <= '0';
			elsif SendInterrogationPulse then
				DelayCountEnable <= '1';
			elsif DelayDone then
				DelayCountEnable <= '0';
			end if;
		end if;
	end process;

	-- 12-bit synchronous counter with count enable and asynchronous reset
	process (H1_CLK)
	begin
		if rising_edge(H1_CLK) then
			if ClearCounter then
				Delay (11 downto 0) <= "000000000000";
			elsif DelayCountEnable or RetPulseDelayEnable then
				Delay <= Delay + 1;
			end if;
		end if;
	end process;

	-- DelayDone marks the end of the 1.6us Interrogation pulse
	DelayDone <= '1' when Delay = IntPulseLength else '0';

	-- RetPulseDelayDone marks the setting of the NoTransducer flag
	-- This is set if a ret pulse is not received within 50us of the start of the Interrogation pulse
	RetPulseDelayDone <= '1' when Delay = RetPulseDelay else '0';

	-- The M_INT_CLK pulse can be assigned the DelayCountEnable signal for now
	intM_INT_CLK <= DelayCountEnable;
	M_INT_CLK <= intM_INT_CLK;

	PWMMagnetFault <= '1' when	(PWM='1' and RisingA(2)='1' and RisingA(3)='1' and 
								 CounterOverFlow='1' and SendInterrogationPulse='1') else '0';

	process (H1_CLK)
	begin
		if rising_edge(H1_CLK) then
			PWMMagnetFaultLatch <= PWMMagnetFault or (PWMMagnetFaultLatch and not ClearCounter);
		end if;
	end process;

	-- Initial metastability debounce flops for the incoming RETURN pulse
	RisingEdgeA: process (H1_CLK)
	begin
		if rising_edge(H1_CLK) then
			RisingA(3 downto 1) <= RisingA(2 downto 1) & M_RET_DATA;
		end if;
	end process;

	RisingAPosEdgeFound <= '1' when RisingA(3)='0' and RisingA(2)='1' else '0';
	RisingANegEdgeFound <= '1' when RisingA(3)='1' and RisingA(2)='0' else '0';

	RisingACountEnable <= '1' when	(RisingACountEnableLatch='0' and RisingAPosEdgeFound='1' and (PWM='1' or StartStopRisingEdge='1')) or
									(RisingACountEnableLatch='0' and RisingANegEdgeFound='1' and StartStopFallingEdge='1') else '0';

	RisingACountDisable <= '1' when	(RisingACountEnableLatch='1' and RisingAPosEdgeFound='1' and StartStopRisingEdge='1') or
									(RisingACountEnableLatch='1' and RisingANegEdgeFound='1' and (PWM='1' or StartStopFallingEdge='1')) or
									ClearCounter='1' else '0';

	process (H1_CLK)
	begin
		if rising_edge(H1_CLK) then	
			RisingACountEnablePipe <= RisingACountEnable;
			RisingACountDisablePipe <= RisingACountDisable;

			RisingACountEnableLatch <= RisingACountEnablePipe or (RisingACountEnableLatch and not RisingACountDisablePipe);
		end if;
	end process;

	-- Counter runs at 60MHz 
	CountRisingA: process (H1_CLK)
	begin
		if rising_edge(H1_CLK) then
			if ClearCounter then
				CountRA <= "000000000000000000";
			elsif RisingACountEnableLatch then
				CountRA <= CountRA + '1';
			end if;
		end if;
	end process;

	-- This latches the counts at the start of the count cycle
	LeadingCountDecode(1 downto 0) <= 	"00" when Edge(2 downto 0)="000" and (StartStopRisingEdge='1' or PWM='1') else -- Add counts
										"01" when Edge(2 downto 0)="001" and (StartStopRisingEdge='1' or PWM='1') else -- Add counts
										"10" when Edge(2 downto 0)="011" and (StartStopRisingEdge='1' or PWM='1') else -- Add counts
										"11" when Edge(2 downto 0)="111" and (StartStopRisingEdge='1' or PWM='1') else -- Add counts
										"11" when Edge(2 downto 0)="000" and StartStopFallingEdge='1' else -- Add counts
										"10" when Edge(2 downto 0)="100" and StartStopFallingEdge='1' else -- Add counts
										"01" when Edge(2 downto 0)="110" and StartStopFallingEdge='1' else -- Add counts
										"00" when Edge(2 downto 0)="111" and StartStopFallingEdge='1' else -- Add counts
										"00";
										
	TrailingCountDecode(1 downto 0) <=	"00" when Edge(2 downto 0)="000" and StartStopRisingEdge='1' else -- Subtract counts
										"01" when Edge(2 downto 0)="001" and StartStopRisingEdge='1' else -- Subtract counts
										"10" when Edge(2 downto 0)="011" and StartStopRisingEdge='1' else -- Subtract counts
										"11" when Edge(2 downto 0)="111" and StartStopRisingEdge='1' else -- Subtract counts
										"11" when Edge(2 downto 0)="000" and (StartStopFallingEdge='1' or PWM='1') else -- Subtract counts
										"10" when Edge(2 downto 0)="100" and (StartStopFallingEdge='1' or PWM='1') else -- Subtract counts
										"01" when Edge(2 downto 0)="110" and (StartStopFallingEdge='1' or PWM='1') else -- Subtract counts
										"00" when Edge(2 downto 0)="111" and (StartStopFallingEdge='1' or PWM='1') else -- Subtract counts
										"00";

	LeadingCountA: process(H1_CLK)
	begin
		if rising_edge(H1_CLK) then
			if RisingACountEnablePipe = '1' then
				LeadingCount(1 downto 0) <= LeadingCountDecode(1 downto 0);
			end if;
		end if;
	end process;

	-- This latches the counts at the end of the count cycle
	TrailingCountA: process(H1_CLK)
	begin
		if rising_edge(H1_CLK) then
			if RisingACountDisablePipe = '1' then
				TrailingCount(1 downto 0) <= TrailingCountDecode(1 downto 0);
			end if;
		end if;
	end process;

	-- Initial metastability debounce flops for the incoming RETURN pulse
	FallingEdgeA: process (H1_CLK)
	begin
		if falling_edge(H1_CLK) then
				FallingA(3 downto 1) <= FallingA(2 downto 1) & M_RET_DATA;
		end if;
	end process;

	-- Initial metastability debounce flops for the incoming RETURN pulse
	RisingEdgeB: process (H1_CLK90)
	begin
		if rising_edge(H1_CLK90) then
				RisingB(3 downto 1) <= RisingB(2 downto 1) & M_RET_DATA;
		end if;
	end process;

	-- Initial metastability debounce flops for the incoming RETURN pulse
	FallingEdgeB: process (H1_CLK90)
	begin
		if falling_edge(H1_CLK90) then
				FallingB(3 downto 1) <= FallingB(2 downto 1) & M_RET_DATA;
		end if;
	end process;

	-- Transfer level of return signal captured on other 3 edges of A/B clocks to 
	-- the rising edge of the main clock.
	XfrToH1_CLK : process(H1_CLK)
	begin
		if rising_edge(H1_CLK) then
			Edge(2 downto 0) <= RisingB(3) & FallingA(3) & FallingB(3);
		end if;
	end process;

	-- Transfer the result of the CountRA and the Leading and Trailing counts to the position register
	process (H1_CLK)
	begin
		if rising_edge(H1_CLK) then
			if SynchedTick60='1' and intDataValid='1' then
				MDTPosition(19 downto 0)  <= (CountRA(17 downto 0) & "00") + LeadingCount(1 downto 0) - TrailingCount(1 downto 0);
			end if;
		end if;
	end process;

end MDTTopSimp_arch;
