-- AP2 Board LED Interface
-- This interface will write LED values to the analog Expansion boards.
-- Note that some of the control and data lines are multiplexed with
-- other functions (EEPROM and CardID) and the implementation will be 
-- complicated slightly.

-- The data is being clocked into a 74HC595 serial-to-parallel converter
-- chip on the AP2 and AR modules. Each of these devices require 8 bits.
-- and are clocked on the RISING edge as opposed to the falling edge that
-- the 74HC597 devices take. The data is clocked in the middle of the bit
-- to negate the potential differences in capacitive loading between the 
-- clock and the data lines. (The clock has more and therefore may be late
-- if the data is clocked at the end of the data bit)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ExpModuleLED is
    port (
          H1_CLK: in std_logic;
			 H1_CLKWR : in std_logic;
          SysClk: in std_logic;
          SlowEnable: in std_logic;
          SynchedTick: in std_logic;
          intDATA: inout std_logic_vector (31 downto 0);

          ExpALED0Write0: in std_logic;
          ExpALED1Write0: in std_logic;
          ExpALED0Read0: in std_logic;
          ExpALED1Read0: in std_logic;
          ExpALED0Write1: in std_logic;
          ExpALED1Write1: in std_logic;
          ExpALED0Read1: in std_logic;
          ExpALED1Read1: in std_logic;
          ExpALED0Write2: in std_logic;
          ExpALED1Write2: in std_logic;
          ExpALED0Read2: in std_logic;
          ExpALED1Read2: in std_logic;
          ExpALED0Write3: in std_logic;
          ExpALED1Write3: in std_logic;
          ExpALED0Read3: in std_logic;
          ExpALED1Read3: in std_logic;

          EEPROMAccessFlag: in std_logic;
          DiscoveryComplete: in std_logic; 

          ExpALEDOE: out std_logic;
          ExpALEDLatch: out std_logic;
          ExpALEDClk: out std_logic;
          ExpALEDData: out std_logic_vector (3 downto 0);
          ExpALEDSelect: out std_logic_vector (3 downto 0);
          ExpOldAP2: in std_logic_vector (3 downto 0)
          );
end ExpModuleLED;

architecture ExpModuleLED_arch of ExpModuleLED is

-- Component Declarations

-- Signal Declarations
signal ShiftRegister0, ShiftRegister1, ShiftRegister2, ShiftRegister3: std_logic_vector (7 downto 0) := X"00";
signal Count: std_logic_vector (3 downto 0) := X"0";
signal OutputClock, ShiftEnable, ShiftComplete: std_logic := '0';
signal StartStateMachine: std_logic := '0';
signal Exp0LED, Exp1LED, Exp2LED, Exp3LED: std_logic_vector (3 downto 0) := "0000";
signal ClearExpLEDLatch: std_logic := '0';
signal intExpALEDSelect: std_logic_vector (3 downto 0) := X"0";
signal intExp0LED, intExp1LED, intExp2LED, intExp3LED: std_logic_vector (3 downto 0) := X"0";

-- State Encoding
type STATE_TYPE is array (1 downto 0) of std_logic;
constant IdleState:   STATE_TYPE :="00";
constant ShiftState: STATE_TYPE :="01";
constant ClearState: STATE_TYPE :="10";
constant EndState:    STATE_TYPE :="11";

signal State: STATE_TYPE; -- state can be assigned the constants defined above in "State Encoding"

constant TerminalCountValue : bit_vector := B"1000";
constant TerminalCount : std_logic_vector (3 downto 0) := To_StdLogicVector(TerminalCountValue);

-- Architechure logic description
begin

-- This section was optimized to the logic below
--intDATA(31 downto 0)<=    Exp0LED(3 downto 2) & "000000000000000000000000000000" when ExpALED0Read0='1' else 
--                       Exp0LED(1 downto 0) & "000000000000000000000000000000" when ExpALED1Read0='1' else 
--                       Exp1LED(3 downto 2) & "000000000000000000000000000000" when ExpALED0Read1='1' else 
--                       Exp1LED(1 downto 0) & "000000000000000000000000000000" when ExpALED1Read1='1' else 
--                       Exp2LED(3 downto 2) & "000000000000000000000000000000" when ExpALED0Read2='1' else 
--                       Exp2LED(1 downto 0) & "000000000000000000000000000000" when ExpALED1Read2='1' else 
--                       Exp3LED(3 downto 2) & "000000000000000000000000000000" when ExpALED0Read3='1' else 
--                       Exp3LED(1 downto 0) & "000000000000000000000000000000" when ExpALED1Read3='1' else 
--                       "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"; 


       intDATA(31 downto 30) <=   Exp0LED(1 downto 0) when ExpALED0Read0='1' else 
                                  Exp0LED(3 downto 2) when ExpALED1Read0='1' else 
                                  Exp1LED(1 downto 0) when ExpALED0Read1='1' else 
                                  Exp1LED(3 downto 2) when ExpALED1Read1='1' else 
                                  Exp2LED(1 downto 0) when ExpALED0Read2='1' else 
                                  Exp2LED(3 downto 2) when ExpALED1Read2='1' else 
                                  Exp3LED(1 downto 0) when ExpALED0Read3='1' else 
                                  Exp3LED(3 downto 2) when ExpALED1Read3='1' else 
                                  "ZZ"; 

-- A buffer catches the data coming in from the processor
-- After this write occurs, a bit will be latched indicating 
-- that a write occurred and the state machine will then 
-- shift data out to the LED drivers
process (H1_CLKWR)
begin
    if rising_edge(H1_CLKWR) then
       if ExpALED0Write0 = '1' then
          Exp0LED(1 downto 0) <= intDATA(31 downto 30);
       end if;
    end if;  
end process;

process (H1_CLKWR)
begin
    if rising_edge(H1_CLKWR) then
       if ExpALED1Write0 = '1' then
          Exp0LED(3 downto 2) <= intDATA(31 downto 30);
       end if;
    end if;  
end process;

process (H1_CLKWR)
begin
    if rising_edge(H1_CLKWR) then
       if ExpALED0Write1 = '1' then
          Exp1LED(1 downto 0) <= intDATA(31 downto 30);
       end if;
    end if;  
end process;

process (H1_CLKWR)
begin
    if rising_edge(H1_CLKWR) then
       if ExpALED1Write1 = '1' then
          Exp1LED(3 downto 2) <= intDATA(31 downto 30);
       end if;
    end if;  
end process;

process (H1_CLKWR)
begin
    if rising_edge(H1_CLKWR) then
       if ExpALED0Write2 = '1' then
          Exp2LED(1 downto 0) <= intDATA(31 downto 30);
       end if;
    end if;  
end process;

process (H1_CLKWR)
begin
    if rising_edge(H1_CLKWR) then
       if ExpALED1Write2 = '1' then
          Exp2LED(3 downto 2) <= intDATA(31 downto 30);
       end if;
    end if;  
end process;

process (H1_CLKWR)
begin
    if rising_edge(H1_CLKWR) then
       if ExpALED0Write3 = '1' then
          Exp3LED(1 downto 0) <= intDATA(31 downto 30);
       end if;
    end if;  
end process;

process (H1_CLKWR)
begin
    if rising_edge(H1_CLKWR) then
       if ExpALED1Write3 = '1' then
          Exp3LED(3 downto 2) <= intDATA(31 downto 30);
       end if;
    end if;  
end process;

process (H1_CLK)
begin
    if rising_edge(H1_CLK) then
       intExpALEDSelect(0) <= ExpALED0Write0 or ExpALED1Write0 or (intExpALEDSelect(0) and not ClearExpLEDLatch);
       intExpALEDSelect(1) <= ExpALED0Write1 or ExpALED1Write1 or (intExpALEDSelect(1) and not ClearExpLEDLatch);
       intExpALEDSelect(2) <= ExpALED0Write2 or ExpALED1Write2 or (intExpALEDSelect(2) and not ClearExpLEDLatch);
       intExpALEDSelect(3) <= ExpALED0Write3 or ExpALED1Write3 or (intExpALEDSelect(3) and not ClearExpLEDLatch);
    end if;
end process;

ExpALEDSelect(0) <= '1' when intExpALEDSelect(0) = '1' else '0';
ExpALEDSelect(1) <= '1' when intExpALEDSelect(1) = '1' else '0';
ExpALEDSelect(2) <= '1' when intExpALEDSelect(2) = '1' else '0';
ExpALEDSelect(3) <= '1' when intExpALEDSelect(3) = '1' else '0';

process (SysClk)
begin
    if rising_edge(SysClk) then
          StartStateMachine <= ((intExpALEDSelect(0) or intExpALEDSelect(1) or intExpALEDSelect(2) or intExpALEDSelect(3)) and SynchedTick) or 
                               (StartStateMachine and (intExpALEDSelect(0) or intExpALEDSelect(1) or intExpALEDSelect(2) or intExpALEDSelect(3)));
    end if;
end process;

ExpALEDOE <= '0' when DiscoveryComplete = '1' else '1';

-- State Machine to control the write sequence to the LED driver
StateMachine : process(SysClk, SynchedTick, SlowEnable, EEPROMAccessFlag, DiscoveryComplete)
begin
    if SynchedTick = '1' then
       State <= IdleState; -- reset state, this will reset the state machine every ms
    elsif rising_edge(SysClk) then 
       if SlowEnable = '1' then
          case State is

             when  IdleState =>   
                         if StartStateMachine = '1' and DiscoveryComplete='1' and EEPROMAccessFlag='0' then
                            State <= ShiftState;
                            ShiftEnable <= '1';           -- enable the data shifting on detection of state transition
--                          ExpALEDOE <= '0';             -- Disable the LED outputs until the data shift is done
                         else
                            ShiftEnable <= '0';           -- disable the data shifting
                            ExpALEDLatch <= '0';          -- latch inactive (active on rising edge)
--                          ExpALEDOE <= '1';             -- Enable the LED outputs
                         end if;

             when  ShiftState => 
                         if ShiftComplete = '1' then
                            State <= ClearState;
                            ShiftEnable <= '0';
                         else
                            ExpALEDLatch <= '0';          -- register latch is still inactive
                            ShiftEnable <= '1';           -- enable the data shifting
                         end if;

             When ClearState =>
                         if State = ClearState then
                            State <= EndState;
                            if EEPROMAccessFlag = '0' then      -- If the EEPROM is being accessed restart LED
                               ClearExpLEDLatch <= '1';
                            end if;
                         end if;           

             when EndState =>  
                         if State = EndState then
                            if EEPROMAccessFlag = '0' then
                               ExpALEDLatch <= '1';       -- Don't latch the LED data if there is an access by the Serial EEPROM Module
                            end if;
                            ShiftEnable <= '0';
                            ClearExpLEDLatch <= '0';
                            State <= IdleState;
                         end if;

             when others => State <= IdleState;     -- default, reset state
          end case;
       end if;
    end if;
end process;

-- M_LED_CLK 
process (SysClk, SynchedTick)
begin
    if SynchedTick = '1' then -- set the output clock on the control loop tick
       OutputClock <= '0'; 
    elsif rising_edge(SysClk) then
       if ShiftEnable = '1' and SlowEnable = '1' then
          OutputClock <= not OutputClock;
       end if;
    end if;
end process;

ExpALEDClk <= OutputClock;

-- 4-bit synchronous counter with count enable and asynchronous reset
process (SysClk, SynchedTick, ShiftComplete)
begin
    if SynchedTick = '1' or ShiftComplete = '1' then
          Count (3 downto 0) <= "0000";
    elsif rising_edge(SysClk) then
       if ShiftEnable = '1' and OutputClock = '0' and SlowEnable = '1' then
          Count <= Count + 1;
       end if;
    end if;
end process;

process (SysClk, Count)
begin 
    if falling_edge(SysClk) then  -- This must be falling edge
       if Count = TerminalCount and SlowEnable = '1' then -- Terminal count at 8 + 1
          ShiftComplete <= '1';
       else
          ShiftComplete <= '0';
       end if;
    end if;
end process;

-- This is a bug fix for the -AP2 Rev 1.0 module in which the LEDs are swapped.
intExp0LED(3 downto 0) <= Exp0LED(3 downto 0) when ExpOldAP2(0)='0' else Exp0LED(1 downto 0) & Exp0LED(3 downto 2);
intExp1LED(3 downto 0) <= Exp1LED(3 downto 0) when ExpOldAP2(1)='0' else Exp1LED(1 downto 0) & Exp1LED(3 downto 2);
intExp2LED(3 downto 0) <= Exp2LED(3 downto 0) when ExpOldAP2(2)='0' else Exp2LED(1 downto 0) & Exp2LED(3 downto 2);
intExp3LED(3 downto 0) <= Exp3LED(3 downto 0) when ExpOldAP2(3)='0' else Exp3LED(1 downto 0) & Exp3LED(3 downto 2);

-- If the Enable for a particular LED isn't on then two consecutive 1's or 0's are
-- written into the LED driver to turn the LED off. Otherwise, one of the bits is 
-- inverted from the other to cause current flow in one direction or the other.

-- 8 bit shift register and databuffer
process (SysClk)
begin
    if rising_edge(SysClk) then
       if (ShiftEnable = '1' and OutputClock = '1' and SlowEnable = '1') then
          ShiftRegister0(7 downto 0) <= ShiftRegister0(6 downto 0) & '0';
          ShiftRegister1(7 downto 0) <= ShiftRegister1(6 downto 0) & '0';
          ShiftRegister2(7 downto 0) <= ShiftRegister2(6 downto 0) & '0';
          ShiftRegister3(7 downto 0) <= ShiftRegister3(6 downto 0) & '0';

       elsif (SlowEnable = '1' and StartStateMachine = '1' and State = IdleState) then
          ShiftRegister0(7 downto 0) <= X"0" & intExp0LED(3 downto 0);
          ShiftRegister1(7 downto 0) <= X"0" & intExp1LED(3 downto 0);
          ShiftRegister2(7 downto 0) <= X"0" & intExp2LED(3 downto 0);
          ShiftRegister3(7 downto 0) <= X"0" & intExp3LED(3 downto 0);
       end if;
    end if;
end process;

-- Assign the OutputData to the ExpALEDData when pertinent
ExpALEDData(0) <= ShiftRegister0(7) when State = ShiftState else '0';
ExpALEDData(1) <= ShiftRegister1(7) when State = ShiftState else '0';
ExpALEDData(2) <= ShiftRegister2(7) when State = ShiftState else '0';
ExpALEDData(3) <= ShiftRegister3(7) when State = ShiftState else '0';

end ExpModuleLED_arch;
