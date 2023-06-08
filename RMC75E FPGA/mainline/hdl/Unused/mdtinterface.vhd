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

entity MDTControl is
    Port (   H1_CLK : in std_logic;
             SysClk2x : in std_logic;
             SysClk2x90 : in std_logic;
             SynchedTick : in std_logic;
             intDATA : inout std_logic_vector(31 downto 0);
             MDTPositionRead : in std_logic;
             MDTStatusRead : in std_logic;
             MDTParamWrite : in std_logic;
             M_INT_CLK : out std_logic;
             M_RET_DATA : in std_logic
          );
end MDTControl;

architecture MDTControl_arch of MDTControl is

-- State Encoding
type STATE_TYPE is array (3 downto 0) of std_logic;
constant s0: STATE_TYPE :="0000";
constant s1: STATE_TYPE :="0001";
constant s2: STATE_TYPE :="0010";
constant s3: STATE_TYPE :="0011";
constant s4: STATE_TYPE :="0111";
constant s5: STATE_TYPE :="0110";
constant s6: STATE_TYPE :="0100";
constant s7: STATE_TYPE :="0101";
constant s8: STATE_TYPE :="1101";
constant s9: STATE_TYPE :="1001";

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

signal ResultRegister, CounterSum, MDTPosition : std_logic_vector (31 downto 0) := X"00000000";
signal CountRA, CountRB, CountFA, CountFB, AdderInput : std_logic_vector (17 downto 0) := "000000000000000000";
signal TransducerSelect : std_logic_vector (6 downto 0) := "0000000";
signal AdderEnable, AdderClear : std_logic := '0';
signal AdderSelect : std_logic_vector (1 downto 0) := "00";
signal StartInterrogation, StartInterrogationLatched, SendInterrogationPulse : std_logic := '0';
signal RisingA1, RisingA2, RisingA3, RisingB1, RisingB2, RisingB3 : std_logic := '0';
signal FallingA1, FallingA2, FallingA3, FallingB1, FallingB2, FallingB3 : std_logic := '0';
signal ClearCounter, PWMRisingEdgeFound, PWMFallingEdgeFound : std_logic := '0';
signal PWMEdge1, PWMEdge2, PWMEdge3 : std_logic := '0';
signal Delay: std_logic_vector (11 downto 0) := "000000000000";
signal DelayDone, DelayCountEnable : std_logic := '0';
signal StartStopRisingEdge, StartStopFallingEdge, PWM : std_logic := '0';
signal RisingAPosEdgeFound, RisingANegEdgeFound, RisingACountEnable, RisingACountDisable, RisingACountEnableLatch : std_logic := '0';
signal FallingAPosEdgeFound, FallingANegEdgeFound, FallingACountEnable, FallingACountDisable, FallingACountEnableLatch : std_logic := '0';
signal RisingBPosEdgeFound, RisingBNegEdgeFound, RisingBCountEnable, RisingBCountDisable, RisingBCountEnableLatch: std_logic := '0';
signal FallingBPosEdgeFound, FallingBNegEdgeFound, FallingBCountEnable, FallingBCountDisable, FallingBCountEnableLatch : std_logic := '0';
signal StateMachineCountEnableLatch, StateMachineEdge1, StateMachineEdge2, StateMachineEdge3 : std_logic := '0';
signal StateMachinePosEdgeFound, StateMachineNegEdgeFound, StateMachineCountEnable, StateMachineCountDisable : std_logic := '0'; 
signal IncrementOverFlowCounter, CounterOverFlow, intCounterOverFlow, CounterOverFlowRetrigger, intNoXducer, NoXducer, DataValid : std_logic := '0';
signal SetDataValid, intDataValid, RetPulseDelayEnable, RetPulseDelayDone : std_logic := '0';
signal PWMMagnetFaultLatch, PWMMagnetFault: std_logic := '0'; 
signal OverFlowCounter : std_logic_vector (2 downto 0) := "000";
signal SyncLatch, SyncLatch1, SynchedTick60 : std_logic := '0';
signal MDTRead, MDTRead1, PostReadClear : std_logic := '0';

begin

intDATA <=   MDTPosition(31 downto 0) when MDTPositionRead='1' else 
             "ZZZZ" & CounterOverFlow & NoXducer & DataValid & "ZZZZZZZZZZZZZZZZZZ" & 
             TransducerSelect(6 downto 0) when MDTStatusRead='1' else 
             "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
-- Note that the MDT Status is also being driven from the ControlIO module

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
       MDTRead <= MDTPositionRead;
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
       CounterOverFlow <= '1';       -- The intCounterOverFlow is only set on the SynchedTick60 so pass is through asynchronously
    elsif rising_edge(H1_CLK) then
    if SynchedTick60='1' then
       CounterOverFlow <= intCounterOverFlow;
       end if;
    end if;
end process;

process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
       if MDTParamWrite='1' then
          TransducerSelect(6 downto 0) <= intData(6 downto 0);
       end if;
    end if;
end process;

StartStopRisingEdge <= '1' when (TransducerSelect(1 downto 0) = StartStopRisingEdgeXducer(1 downto 0)) else '0';
StartStopFallingEdge <= '1' when (TransducerSelect(1 downto 0) = StartStopFallingEdgeXducer(1 downto 0)) else '0';
PWM <= '1' when (TransducerSelect(1 downto 0) = PWMXducer(1 downto 0)) else '0';

StartInterrogation <= '1' when ((SynchedTick60 = '1' and RetPulseDelayEnable = '0' and State = s0) or 
                                (CounterOverFlowRetrigger = '1')) and 
                                (StartStopRisingEdge = '1' or StartStopFallingEdge = '1' or PWM = '1') else '0'; 

process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
       StartInterrogationLatched <= StartInterrogation;
    end if;
end process;

-- State Machine to control the count sequence of the MDT counters
StateMachine : process(H1_CLK)
begin
    if rising_edge(H1_CLK) then 
       case State is

-- Reset state wait here until a tick starts the machine
          when  s0 => if StartInterrogationLatched = '1' then
                         ClearCounter <= '1';
                         State <= s1;
                      else
                         SendInterrogationPulse <= '0';
                         AdderEnable <= '0';
                         AdderSelect <= "00";
                         AdderClear <= '0';
                         ClearCounter <= '0';
                         SetDataValid <= '0';
                         RetPulseDelayEnable <= '0';
                         State <= s0;
                      end if;

                      CounterOverFlowRetrigger <= '0';       -- This signal is used to restart the state machine on counter overflow failure

          when s1 =>  if State = s1 then
                         AdderClear <= '1';                  -- reset the Adder
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
          when  s3 => if StateMachineCountEnableLatch = '1' or PWMMagnetFaultLatch = '1' then
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
                            AdderClear <= '0';
                         end if; 
                      end if;

-- Wait for the terminating condition of the interrogation 
-- and then add CountRA to the Adder
          when  s4 => if StateMachineCountEnableLatch = '0' and PWMMagnetFaultLatch = '0' then            
                         State <= s5;
                         AdderEnable <= '1';
                         AdderSelect (1 downto 0) <= "00";
                      elsif SynchedTick60 = '1' then         -- A Control loop tick has arrived (This is bad)
                         intCounterOverFlow <= '1';          -- We don't have our second return pulse, so set the overflow bit
                         CounterOverFlowRetrigger <= '1';    -- This signal is used to restart the state machine on counter overflow failure
                         State <= s0;
                      else
                         State <= s4;
                      end if;

-- Add CountFA to the Adder
          when  s5 => if SynchedTick60='1' then              -- A Control loop tick has arrived (This is bad)
                         intCounterOverFlow <= '1';          -- We don't have our second return pulse, so set the overflow bit
                         CounterOverFlowRetrigger <= '1';    -- This signal is used to restart the state machine on counter overflow failure
                         State <= s0;
                      else
                         AdderEnable <= '1';
                         intCounterOverFlow <= '0';          -- If we've made it here, then clear the overflow error
                         AdderSelect (1 downto 0) <= "01";
                         State <= s6;
                      end if;
                      
-- Add CountRB to the Adder
          when  s6 => if SynchedTick60='1' then              -- A Control loop tick has arrived (This is bad)
                         intCounterOverFlow <= '1';          -- We don't have our second return pulse, so set the overflow bit
                         CounterOverFlowRetrigger <= '1';    -- This signal is used to restart the state machine on counter overflow failure
                         State <= s0;
                      else
                         AdderEnable <= '1';
                         intCounterOverFlow <= '0';          -- If we've made it here, then clear the overflow error
                         AdderSelect (1 downto 0) <= "10";
                         State <= s7;
                      end if;
                      
-- Add CountFB to the Adder
          when  s7 => if SynchedTick60='1' then              -- A Control loop tick has arrived (This is bad)
                         intCounterOverFlow <= '1';          -- We don't have our second return pulse, so set the overflow bit
                         CounterOverFlowRetrigger <= '1';    -- This signal is used to restart the state machine on counter overflow failure
                         State <= s0;
                      else
                         AdderEnable <= '1';
                         intCounterOverFlow <= '0';          -- If we've made it here, then clear the overflow error
                         AdderSelect (1 downto 0) <= "11";
                         SetDataValid <= '1';                -- The Data Acquisition is complete, so set the DataValid bit
                         State <= s8;                        -- (This will happen with the SynchedTick60 signal)
                      end if;

-- Sequence is finished
          when  s8 => if State = s8 then
                         SetDataValid <= '1';
                         AdderEnable <= '0';
                         State <= s9;
                      end if;

          when  s9 => if State = s9 then
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
M_INT_CLK <= DelayCountEnable;

-- Find the rising and falling edges of the PWM signal
PWMEdge: process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
       StateMachineEdge1 <= M_RET_DATA;
       StateMachineEdge2 <= StateMachineEdge1;
       StateMachineEdge3 <= StateMachineEdge2;
    end if;
end process;

StateMachinePosEdgeFound <= '1' when (StateMachineEdge2='1' and StateMachineEdge3='0') else '0'; 

PWMMagnetFault <= '1' when (PWM='1' and StateMachineEdge2='1' and StateMachineEdge3='1' and 
                             CounterOverFlow='1' and SendInterrogationPulse='1') else '0';

StateMachineNegEdgeFound <= '1' when StateMachineEdge2='0' and StateMachineEdge3='1' else '0';

StateMachineCountEnable <= '1' when (StateMachineCountEnableLatch='0' and StateMachinePosEdgeFound='1' and (PWM='1' or StartStopRisingEdge='1')) or
                                     (StateMachineCountEnableLatch='0' and StateMachineNegEdgeFound='1' and StartStopFallingEdge='1') else '0';

StateMachineCountDisable <= '1' when (StateMachineCountEnableLatch='1' and StateMachinePosEdgeFound='1' and StartStopRisingEdge='1') or
                                     (StateMachineCountEnableLatch='1' and StateMachineNegEdgeFound='1' and (PWM='1' or StartStopFallingEdge='1')) or
                                     ClearCounter='1' else '0';

process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
       StateMachineCountEnableLatch <= StateMachineCountEnable or (StateMachineCountEnableLatch and not StateMachineCountDisable);
    end if;
end process;

process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
       PWMMagnetFaultLatch <= PWMMagnetFault or (PWMMagnetFaultLatch and not ClearCounter);
    end if;
end process;


-- Initial metastability debounce flops for the incoming RETURN pulse
RisingEdgeA: process (SysClk2x)
begin
    if rising_edge(SysClk2x) then
       RisingA1 <= M_RET_DATA;
       RisingA2 <= RisingA1;
       RisingA3 <= RisingA2;
    end if;
end process;

RisingAPosEdgeFound <= '1' when RisingA3='0' and RisingA2='1' else '0';
RisingANegEdgeFound <= '1' when RisingA3='1' and RisingA2='0' else '0';

RisingACountEnable <= '1' when (RisingACountEnableLatch='0' and RisingAPosEdgeFound='1' and (PWM='1' or StartStopRisingEdge='1')) or
                                (RisingACountEnableLatch='0' and RisingANegEdgeFound='1' and StartStopFallingEdge='1') else '0';

RisingACountDisable <= '1' when (RisingACountEnableLatch='1' and RisingAPosEdgeFound='1' and StartStopRisingEdge='1') or
                                (RisingACountEnableLatch='1' and RisingANegEdgeFound='1' and (PWM='1' or StartStopFallingEdge='1')) or
                                ClearCounter='1' else '0';

process (SysClk2x)
begin
    if rising_edge(SysClk2x) then
       RisingACountEnableLatch <= RisingACountEnable or (RisingACountEnableLatch and not RisingACountDisable);
    end if;
end process;

-- Initial metastability debounce flops for the incoming RETURN pulse
FallingEdgeA: process (SysClk2x)
begin
    if falling_edge(SysClk2x) then
       FallingA1 <= M_RET_DATA;
       FallingA2 <= FallingA1;
       FallingA3 <= FallingA2;
    end if;
end process;

FallingAPosEdgeFound <= '1' when FallingA3='0' and FallingA2='1' else '0';
FallingANegEdgeFound <= '1' when FallingA3='1' and FallingA2='0' else '0';

FAllingACountEnable <= '1' when (FallingACountEnableLatch='0' and FallingAPosEdgeFound='1' and (PWM='1' or StartStopRisingEdge='1')) or
                                 (FallingACountEnableLatch='0' and FallingANegEdgeFound='1' and StartStopFallingEdge='1') else '0';

FallingACountDisable <= '1' when (FallingACountEnableLatch='1' and FallingAPosEdgeFound='1' and StartStopRisingEdge='1') or
                                  (FallingACountEnableLatch='1' and FallingANegEdgeFound='1' and (PWM='1' or StartStopFallingEdge='1')) or
                                  ClearCounter='1' else '0';

process (SysClk2x)
begin
    if falling_edge(SysClk2x) then
       FallingACountEnableLatch <= FallingACountEnable or (FallingACountEnableLatch and not FallingACountDisable);
    end if;
end process;

-- Initial metastability debounce flops for the incoming RETURN pulse
RisingEdgeB: process (SysClk2x90)
begin
    if rising_edge(SysClk2x90) then
       RisingB1 <= M_RET_DATA;
       RisingB2 <= RisingB1;
       RisingB3 <= RisingB2;
    end if;
end process;

RisingBPosEdgeFound <= '1' when RisingB3='0' and RisingB2='1' else '0';
RisingBNegEdgeFound <= '1' when RisingB3='1' and RisingB2='0' else '0';

RisingBCountEnable <= '1' when (RisingBCountEnableLatch='0' and RisingBPosEdgeFound='1' and (PWM='1' or StartStopRisingEdge='1')) or
                                (RisingBCountEnableLatch='0' and RisingBNegEdgeFound='1' and StartStopFallingEdge='1') else '0';

RisingBCountDisable <= '1' when (RisingBCountEnableLatch='1' and RisingBPosEdgeFound='1' and StartStopRisingEdge='1') or
                                 (RisingBCountEnableLatch='1' and RisingBNegEdgeFound='1' and (PWM='1' or StartStopFallingEdge='1')) or
                                 ClearCounter='1' else '0';

process (SysClk2x90)
begin
    if rising_edge(SysClk2x90) then
       RisingBCountEnableLatch <= RisingBCountEnable or (RisingBCountEnableLatch and not RisingBCountDisable);
    end if;
end process;

-- Initial metastability debounce flops for the incoming RETURN pulse
FallingEdgeB: process (SysClk2x90)
begin
    if falling_edge(SysClk2x90) then
       FallingB1 <= M_RET_DATA;
       FallingB2 <= FallingB1;
       FallingB3 <= FallingB2;
    end if;
end process;

FallingBPosEdgeFound <= '1' when FallingB3='0' and FallingB2='1' else '0';
FallingBNegEdgeFound <= '1' when FallingB3='1' and FallingB2='0' else '0';

FallingBCountEnable <= '1' when (FallingBCountEnableLatch='0' and FallingBPosEdgeFound='1' and (PWM='1' or StartStopRisingEdge='1')) or
                                 (FallingBCountEnableLatch='0' and FallingBNegEdgeFound='1' and StartStopFallingEdge='1') else '0';

FallingBCountDisable <= '1' when (FallingBCountEnableLatch='1' and FallingBPosEdgeFound='1' and StartStopRisingEdge='1') or
                                  (FallingBCountEnableLatch='1' and FallingBNegEdgeFound='1' and (PWM='1' or StartStopFallingEdge='1')) or
                                  ClearCounter='1' else '0';

process (SysClk2x90)
begin
    if falling_edge(SysClk2x90) then
       FallingBCountEnableLatch <= FallingBCountEnable or (FallingBCountEnableLatch and not FallingBCountDisable);
    end if;
end process;

-- Counter runs at 120MHz 
CountRisingA: process (SysClk2x, RisingA2, ClearCounter)
begin
    if ClearCounter = '1' then
       CountRA <= "000000000000000000";
    elsif rising_edge(SysClk2x) then
       if RisingACountEnableLatch = '1' then
          CountRA <= CountRA + '1';
       end if;
    end if;
end process;

-- Counter runs at 120MHz
CountFallingA: process (SysClk2x, FallingA2, ClearCounter)
begin
    if ClearCounter = '1' then
       CountFA <= "000000000000000000";
    elsif falling_edge(SysClk2x) then
       if FallingACountEnableLatch = '1' then
          CountFA <= CountFA + '1';
       end if;
    end if;
end process;

-- Counter runs at 120MHz
CountRisingB: process (SysClk2x90, RisingB2, ClearCounter)
begin
    if ClearCounter = '1' then
       CountRB <= "000000000000000000";
    elsif rising_edge(SysClk2x90) then
       if RisingBCountEnableLatch = '1' then
          CountRB <= CountRB + '1';
       end if;
    end if;
end process;

-- Counter runs at 120MHz
CountFallingB: process (SysClk2x90, FallingB2, ClearCounter)
begin
    if ClearCounter = '1' then
       CountFB <= "000000000000000000";
    elsif falling_edge(SysClk2x90) then
       if FallingBCountEnableLatch = '1' then
          CountFB <= CountFB + '1';
       end if;
    end if;
end process;

-- Multiplexer controls the flow of data into the shift register
process (H1_CLK, AdderSelect, CountRA, CountFA, CountRB, CountFB)
begin
   case AdderSelect is
      when "00" => AdderInput (17 downto 0) <= CountRA (17 downto 0);
      when "01" => AdderInput (17 downto 0) <= CountFA (17 downto 0);
      when "10" => AdderInput (17 downto 0) <= CountRB (17 downto 0);
      when "11" => AdderInput (17 downto 0) <= CountFB (17 downto 0);
       when others => NULL;
   end case;
end process;

-- Add the counters together. The sequencing and CLK enable is handled by the state machine
process (H1_CLK, AdderClear)
begin
    if AdderClear = '1' then
       CounterSum <= X"00000000";
    elsif rising_edge(H1_CLK) then
          if AdderEnable = '1' then
             CounterSum <= CounterSum + AdderInput;
          end if;
    end if;
end process;

-- Transfer the Result of the counter addition to the result register
process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
    if SynchedTick60='1' and intDataValid='1' then
       MDTPosition  <= CounterSum;
      end if;
    end if;
end process;

end MDTControl_arch;
