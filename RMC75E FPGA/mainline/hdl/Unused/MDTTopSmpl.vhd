-- **************************************************************************
-- MDT Interface
-- The MDT Interface will provide a signal interface to 
-- PWM, Start/Stop and SSI type transducers. 
--
-- Currently, the incoming clock rate is 60MHz for all three clocks coming 
-- into the design. The SysClk0-90 are 90 degrees out of phase. This means
-- that each of these clocks can be used to drive a counter when the return
-- pulse signals a start. At the end of the count cycle the counters will
-- be added together.
-- **************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity MDTTopSmpl is
    Port (   H1_CLK : in std_logic;
	 			 H1_CLKWR : in std_logic;
             H1_CLK90 : in std_logic;
             SynchedTick : in std_logic;
             intDATA : inout std_logic_vector(31 downto 0);
             PositionRead : in std_logic;
             StatusRead : in std_logic;
             ParamWrite : in std_logic;
             M_INT_CLK : out std_logic;
             M_RET_DATA : in std_logic;
             SSI_DATA : out std_logic;
             SSISelect : in std_logic
          );
end MDTTopSmpl;

architecture MDTTopSmpl_arch of MDTTopSmpl is

-- State Encoding
type STATE_TYPE is array (2 downto 0) of std_logic;
constant s0: STATE_TYPE :="000";
constant s1: STATE_TYPE :="001";
constant s2: STATE_TYPE :="010";
constant s3: STATE_TYPE :="011";
constant s4: STATE_TYPE :="111";
constant s5: STATE_TYPE :="110";
constant s6: STATE_TYPE :="100";

constant IntPulseDelayTerminalCountValue : bit_vector := B"000001100100"; -- 100 counts at 60MHz (16.6ns) = 1.66us
constant IntPulseLength : std_logic_vector (11 downto 0) := To_StdLogicVector(IntPulseDelayTerminalCountValue);

constant RetPulseDelayTerminalCountValue : bit_vector := B"101110111000"; -- 3000 counts at 60MHz (16.6ns) = 50us
constant RetPulseDelay : std_logic_vector (11 downto 0) := To_StdLogicVector(RetPulseDelayTerminalCountValue);

constant StartStopRisingEdgeXducerValue : bit_vector := B"01";
constant StartStopRisingEdgeXducer : std_logic_vector (1 downto 0) := To_StdLogicVector(StartStopRisingEdgeXducerValue);

constant StartStopFallingEdgeXducerValue : bit_vector := B"10";
constant StartStopFallingEdgeXducer : std_logic_vector (1 downto 0) := To_StdLogicVector(StartStopFallingEdgeXducerValue);

constant PWMXducerValue : bit_vector := B"11";
constant PWMXducer : std_logic_vector (1 downto 0) := To_StdLogicVector(PWMXducerValue);

constant OverFlowLoopLimitValue : bit_vector := B"10";
constant OverFlowLoopLimit : std_logic_vector (1 downto 0) := To_StdLogicVector(OverFlowLoopLimitValue);

signal State: STATE_TYPE; -- state can be assigned the constants s0-s7

signal MDTPosition : std_logic_vector (19 downto 0) := X"00000";
signal CountRA : std_logic_vector (17 downto 0) := "000000000000000000";
signal TransducerSelect : std_logic_vector (6 downto 0) := "0000000";
signal StartInterrogation, StartInterrogationLatched, SendInterrogationPulse : std_logic := '0';
signal RisingA1, RisingA2, RisingA3, RisingA4, RisingB1, RisingB2, RisingB3 : std_logic := '0';
signal FallingA1, FallingA2, FallingA3, FallingB1, FallingB2, FallingB3 : std_logic := '0';
signal Delay: std_logic_vector (11 downto 0) := "000000000000";
signal ClearCounter, DelayDone, DelayCountEnable : std_logic := '0';
signal StartStopRisingEdge, StartStopFallingEdge, PWM : std_logic := '0';
signal StartingPosEdgeFound, StartingNegEdgeFound, StoppingPosEdgeFound, StoppingNegEdgeFound : std_logic := '0'; 
signal RisingACountEnable, RisingACountDisable, RisingACountEnableLatch : std_logic := '0';
signal CounterOverFlow, intCounterOverFlow, CounterOverFlowRetrigger, intNoXducer, NoXducer, DataValid : std_logic := '0';
signal SetDataValid, intDataValid, RetPulseDelayEnable, RetPulseDelayDone : std_logic := '0';
signal PWMMagnetFaultLatch, PWMMagnetFault: std_logic := '0'; 
signal SyncLatch, SyncLatch1, SynchedTick60 : std_logic := '0';
signal MDTRead, MDTRead1, PostReadClear, MDTSelect : std_logic := '0';
signal LeadingCount, TrailingCount, CountDecode : std_logic_vector (1 downto 0) := "00";
signal TrailingCountStopA, StateThree, StateFour : std_logic := '0';
signal intM_INT_CLK : std_logic := '1';

attribute keep : string;
attribute keep of TrailingCountStopA: signal is "true";
attribute keep of StateThree: signal is "true";
attribute keep of StateFour: signal is "true";

attribute keep of StartingPosEdgeFound: signal is "true";
attribute keep of StartingNegEdgeFound: signal is "true";
attribute keep of StoppingPosEdgeFound: signal is "true";
attribute keep of StoppingNegEdgeFound: signal is "true";

--attribute keep of RisingA3: signal is "true";
--attribute keep of RisingA4: signal is "true";
--attribute keep of FallingA3: signal is "true"; 
--attribute keep of RisingB3: signal is "true"; 
--attribute keep of FallingB3: signal is "true"; 

begin

intDATA <=   X"000" & MDTPosition(19 downto 0) when PositionRead='1' and SSISelect='0' and (StartStopRisingEdge='1' or 
             StartStopFallingEdge='1' or PWM='1') else 
             "ZZZZ" & CounterOverFlow & NoXducer & DataValid & "ZZZZZZZZZZZZZZZZZZ" & TransducerSelect(6 downto 0) when 
				 StatusRead='1' and SSISelect='0' else "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";

-- Note that the MDT Status is also being driven from the ControlIO module

SSI_DATA <= RisingA1;

-- The SynchedTick pulse must be re-synchronized to produce a single pulse at 60MHz
-- so the MDT data and status bits can all be updated on the same clock edge.
process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
       SyncLatch <= SynchedTick;
    end if;
end process;

process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
       SyncLatch1 <= SyncLatch;
    end if;
end process;

SynchedTick60 <= '1' when SyncLatch='0' and SyncLatch1='1' else '0';

-- A post read clear pulse must be generated for clearing the DataValid status bit
process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
       MDTRead <= PositionRead;
    end if;
end process;

process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
       MDTRead1 <= MDTRead;
    end if;
end process;

PostReadClear <= '1' when MDTRead='0' and MDTRead1='1' else '0';

process (H1_ClK)
begin
    if rising_edge(H1_CLK) then
       if SynchedTick60='1' then
          intDataValid <= '0';
       else                       
          intDataValid <= not PWMMagnetFaultLatch and (SetDataValid or intDataValid);
       end if;
    end if;
end process;

-- Transfer the internal Data Valid status to the CPU accessible registers
process (H1_CLK, PostReadClear)
begin
    if PostReadClear='1' then
       DataValid <= '0';
    elsif rising_edge(H1_CLK) then
    if SynchedTick60='1' then
       DataValid  <= intDataValid;
       end if;
    end if;
end process;

-- Transfer the internal NoXducer status to the CPU accessible registers
process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
    if SynchedTick60='1' then
       NoXducer <= intNoXducer;
       end if;
    end if;
end process;

-- Transfer the internal CounterOverFlow status to the CPU accessible registers
process (H1_CLK, intCounterOverFlow)
begin
    if intCounterOverFlow = '1' then
       CounterOverFlow <= '1';       -- The intCounterOverFlow is only set on the SynchedTick60 so pass it through asynchronously
    elsif rising_edge(H1_CLK) then
    if SynchedTick60='1' then
       CounterOverFlow <= intCounterOverFlow;
       end if;
    end if;
end process;

process (H1_CLKWR)
begin
    if rising_edge(H1_CLKWR) then
       if ParamWrite='1' then
          TransducerSelect(6 downto 0) <= intData(6 downto 0);
       end if;
    end if;
end process;

StartStopRisingEdge <= '1' when (TransducerSelect(1 downto 0) = StartStopRisingEdgeXducer(1 downto 0)) else '0';
StartStopFallingEdge <= '1' when (TransducerSelect(1 downto 0) = StartStopFallingEdgeXducer(1 downto 0)) else '0';
PWM <= '1' when (TransducerSelect(1 downto 0) = PWMXducer(1 downto 0)) else '0';

MDTSelect <= '1' when StartStopRisingEdge='1' or StartStopFallingEdge='1' or PWM='1' else '0';

StartInterrogation <= '1' when ((SynchedTick60 = '1' and RetPulseDelayEnable = '0' and State = s0) or 
                                (CounterOverFlowRetrigger = '1')) and MDTSelect = '1' else '0'; 

process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
       StartInterrogationLatched <= StartInterrogation;
    end if;
end process;

-- State Machine to control the count sequence of the MDT counters
StateMachine : process(H1_CLK, SynchedTick60)
begin
    if SynchedTick60='1' then
		State <= s0;
	 elsif rising_edge(H1_CLK) then 
       case State is

-- Reset state wait here until a tick starts the machine
          when  s0 => if StartInterrogationLatched = '1' then
                         ClearCounter <= '1';
                         State <= s1;
                      else
                         SendInterrogationPulse <= '0';
                         ClearCounter <= '0';
                         SetDataValid <= '0';
                         RetPulseDelayEnable <= '0';
                         State <= s0;
                      end if;

                      CounterOverFlowRetrigger <= '0';       -- This signal is used to restart the state machine on counter overflow failure

          when s1 =>  if State = s1 then
                         ClearCounter <= '0';
                         SendInterrogationPulse <= '1';
                         State <= s2;
                      end if;

-- Send the interrogation pulse and go to the next state (pulse takes 1.66us)
-- The interrogation pulse is being sent while in this state
          when  s2 => if State = s2 then
                         SendInterrogationPulse <= '0';
                         State <= s3;
                      end if;

-- Wait for the Counter to begin
--          when  s3 => if RisingACountEnableLatch = '1' or PWMMagnetFaultLatch = '1' then
          when  s3 => if 	(PWM='0' and StartingNegEdgeFound='1') or 
									(PWM='1' and RisingACountEnableLatch = '1') or 
									 PWMMagnetFaultLatch = '1' then
                         RetPulseDelayEnable <= '0';
                         intNoXducer <= '0';                 -- We have our first return pulse, so clear out the NoXducer bit
                         State <= s4;
                      else
                         if RetPulseDelayDone='1' then       -- There was no initial return pulse.  Set the intNoXducer bit and restart on the next control loop
                            intNoXducer <= '1';              -- No return pulse, 
                            RetPulseDelayEnable <= '0';      -- turn off the delay counter
                            State <= s0;                     
                         else
                            RetPulseDelayEnable <= '1';
                            State <= s3;
                         end if; 
                      end if;

-- Wait for the terminating condition of the interrogation 
          when  s4 => if RisingACountEnableLatch = '0' and PWMMagnetFaultLatch = '0' then            
                         State <= s5;
                      elsif SynchedTick60 = '1' then         -- A Control loop tick has arrived (This is bad)
                         intCounterOverFlow <= '1';          -- We don't have our second return pulse, so set the overflow bit
                         CounterOverFlowRetrigger <= '1';    -- This signal is used to restart the state machine on counter overflow failure
                         State <= s0;
                      else
                         State <= s4;
                      end if;

-- Sequence is finished
          when  s5 => if State = s5 then
                         SetDataValid <= '1';
                         intCounterOverFlow <= '0';          -- If we've made it here, then clear the overflow error
                         State <= s6;
                      end if;

          when  s6 => if State = s6 then
                         SetDataValid <= '1';
                         State <= s0;
                      end if;

          when others => State <= s0;                        -- default, reset state
       end case;
    end if;
end process;

process (H1_CLK, ClearCounter)
begin
    if ClearCounter='1' then
       DelayCountEnable <= '0';
    elsif rising_edge(H1_CLK) then
          DelayCountEnable <= SendInterrogationPulse or (DelayCountEnable and not DelayDone);
    end if;
end process;

-- 12-bit synchronous counter with count enable and asynchronous reset
process (H1_CLK, ClearCounter)
begin
    if ClearCounter='1' then
          Delay (11 downto 0) <= "000000000000";
    elsif rising_edge(H1_CLK) then
       if DelayCountEnable='1' or RetPulseDelayEnable='1' then
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

PWMMagnetFault <= '1' when (PWM='1' and RisingA3='1' and RisingA4='1' and 
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
       RisingA1 <= M_RET_DATA;
       RisingA2 <= RisingA1;
       RisingA3 <= RisingA2;
		 RisingA4 <= RisingA3;
    end if;
end process;

StateThree <= '1' when State=s3 else '0';
StateFour <= '1' when State=s4 else '0';

StartingPosEdgeFound <= '1' when RisingA4='0' and RisingA3='1' and StateThree='1' else '0';
StartingNegEdgeFound <= '1' when RisingA4='1' and RisingA3='0' and StateThree='1' else '0';
StoppingPosEdgeFound <= '1' when RisingA4='0' and RisingA3='1' and StateFour='1' else '0';
StoppingNegEdgeFound <= '1' when RisingA4='1' and RisingA3='0' and StateFour='1' else '0';

RisingACountEnable <= '1' when (StartingPosEdgeFound='1' and (PWM='1' or StartStopRisingEdge='1')) or
                               (StartingNegEdgeFound='1' and StartStopFallingEdge='1') else '0';

RisingACountDisable <= '1' when (StoppingPosEdgeFound='1' and StartStopRisingEdge='1') or
                                (StoppingNegEdgeFound='1' and (PWM='1' or StartStopFallingEdge='1')) or
                                 ClearCounter='1' else '0';

process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
       RisingACountEnableLatch <= RisingACountEnable or (RisingACountEnableLatch and not RisingACountDisable);
    end if;
end process;

-- Counter runs at 60MHz 
CountRisingA: process (H1_CLK, ClearCounter)
begin
    if ClearCounter = '1' then
       CountRA <= "000000000000000000";
    elsif rising_edge(H1_CLK) then
       if RisingACountEnableLatch = '1' and TrailingCountStopA='0' then
          CountRA <= CountRA + '1';
       end if;
    end if;
end process;

-- This latches the counts at the start of the count cycle
CountDecode(1 downto 0) <= "00" when RisingB3='0' and FallingA3='0' and FallingB3='0' and StartingPosEdgeFound='1' else -- Add counts
									"01" when RisingB3='0' and FallingA3='0' and FallingB3='1' and StartingPosEdgeFound='1' else -- Add counts
									"10" when RisingB3='0' and FallingA3='1' and FallingB3='1' and StartingPosEdgeFound='1' else -- Add counts
									"11" when RisingB3='1' and FallingA3='1' and FallingB3='1' and StartingPosEdgeFound='1' else -- Add counts

--									"11" when RisingB2='0' and FallingA2='0' and FallingB2='0' and StoppingPosEdgeFound='1' else -- Subtract counts
--									"10" when RisingB2='1' and FallingA2='0' and FallingB2='0' and StoppingPosEdgeFound='1' else -- Subtract counts
--									"01" when RisingB2='1' and FallingA2='1' and FallingB2='0' and StoppingPosEdgeFound='1' else -- Subtract counts
--									"00" when RisingB2='1' and FallingA2='1' and FallingB2='1' and StoppingPosEdgeFound='1' else -- Subtract counts

									"00" when RisingB3='0' and FallingA3='0' and FallingB3='0' and StoppingPosEdgeFound='1' else -- Add counts
									"11" when RisingB3='0' and FallingA3='0' and FallingB3='1' and StoppingPosEdgeFound='1' else -- Add counts
									"10" when RisingB3='0' and FallingA3='1' and FallingB3='1' and StoppingPosEdgeFound='1' else -- Add counts
									"01" when RisingB3='1' and FallingA3='1' and FallingB3='1' and StoppingPosEdgeFound='1' else -- Add counts

									"00";
process(H1_CLK)
begin
	if rising_edge(H1_CLK) then
		TrailingCountStopA <= (RisingB3 or FallingA3 or FallingB3) and State(2) and State(1) and State(0);
	end if;
end process;

LeadingCountA: process(H1_CLK)
begin
	if rising_edge(H1_CLK) then
		if RisingACountEnable = '1' then
			LeadingCount(1 downto 0) <= CountDecode(1 downto 0);
		end if;
	end if;
end process;

-- This latches the counts at the end of the count cycle
TrailingCountA: process(H1_CLK)
begin
	if rising_edge(H1_CLK) then
		if RisingACountDisable = '1' then
			TrailingCount(1 downto 0) <= CountDecode(1 downto 0);
		end if;
	end if;
end process;


-- Initial metastability debounce flops for the incoming RETURN pulse
FallingEdgeA: process (H1_CLK)
begin
    if falling_edge(H1_CLK) then
		if RisingACountDisable='0' and RisingACountEnable='0' then
			FallingA1 <= M_RET_DATA;
			FallingA2 <= FallingA1;
			FallingA3 <= FallingA2;
		end if;
	 end if;
end process;


-- Initial metastability debounce flops for the incoming RETURN pulse
RisingEdgeB: process (H1_CLK90)
begin
    if rising_edge(H1_CLK90) then
		if RisingACountDisable='0' and RisingACountEnable='0'  then
			RisingB1 <= M_RET_DATA;
			RisingB2 <= RisingB1;
			RisingB3 <= RisingB2;
		end if; 
	 end if;
end process;


-- Initial metastability debounce flops for the incoming RETURN pulse
FallingEdgeB: process (H1_CLK90)
begin
    if falling_edge(H1_CLK90) then
 		if RisingACountDisable='0' and RisingACountEnable='0' then
			FallingB1 <= M_RET_DATA;
			FallingB2 <= FallingB1;
			FallingB3 <= FallingB2;
		end if;
	 end if;
end process;

-- Transfer the result of the CountRA and the Leading and Trailing counts to the position register
process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
    if SynchedTick60='1' and intDataValid='1' then
       MDTPosition(19 downto 0)  <= (CountRA(17 downto 0) & "00") + LeadingCount(1 downto 0) + TrailingCount(1 downto 0);
      end if;
    end if;
end process;

end MDTTopSmpl_arch;
