--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer (Satchel Hamilton)
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		ExpModuleLED
--	File			ExpModuleLED.vhd
--
--------------------------------------------------------------------------------
--
--	Description:
-- 
--		Expansion Module LED Interface
--		This interface will write LED values to the Expansion boards.
--		Note that some of the control and data lines are multiplexed with
--		other functions (EEPROM and CardID) and the implementation will be 
--		complicated slightly.
--
--		The data is being clocked into a 74HC595 serial-to-parallel converter
--		chip on the Expansion modules. Each of these devices require 8 bits.
--		and are clocked on the RISING edge as opposed to the falling edge that
--		the 74HC597 devices take. The data is clocked in the middle of the bit
--		to negate the potential differences in capacitive loading between the 
--		clock and the data lines. (The clock has more and therefore may be late
--		if the data is clocked at the end of the data bit)
--
--	Revision: 1.3
--
-- File history:

--		Rev 1.3 : 05/26/2023 :	Resolved the state encoding error by using an enumerated type
--								for the state encoding logic rather than a pseudo-array of constants.

--		Rev 1.3 : 05/26/2023 :	Added a ‘when others’ clause to the state machine logic
--								that should handle any unexpected states that might arise.

--		Rev 1.2 : 08/26/2022 :	Added Reset signal to keep LEDs off on power-up
--		Rev 1.1 : 06/01/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ExpModuleLED is
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
end ExpModuleLED;

architecture ExpModuleLED_arch of ExpModuleLED is

	signal	ShiftRegister0,
			ShiftRegister1,
			ShiftRegister2,
			ShiftRegister3		: std_logic_vector (7 downto 0);	-- := X"00";
	signal	Count				: std_logic_vector (3 downto 0);	-- := X"0";
	signal	OutputClock,
			ShiftEnable			: std_logic;	-- := '0';
--			ShiftComplete		: std_logic;	-- := '0';
	signal	StartStateMachine	: std_logic;	-- := '0';
	signal	Exp0LED,
			Exp1LED,
			Exp2LED,
			Exp3LED				: std_logic_vector (3 downto 0);	-- := "0000";
	signal	ClearExpLEDLatch	: std_logic;	-- := '0';
	signal	intExpLEDSelect		: std_logic_vector (3 downto 0);	-- := X"0";
	signal	intExp0LED,
			intExp1LED,
			intExp2LED,
			intExp3LED			: std_logic_vector (3 downto 0);	-- := X"0";
	signal	intExpLEDOE			: std_logic;	-- := '1';
	signal	EnableDelay			: std_logic;	-- Delay the Output eanable until the second time through the LED output state machine

	-- State Encoding now used an enumerated type rather than constants
	type STATE_TYPE is (IdleState, ShiftState, ClearState, EndState);
	signal State: STATE_TYPE; -- state can be assigned the constants defined above in "State Encoding"

	constant TerminalCountValue : bit_vector := B"1000";
	constant TerminalCount : std_logic_vector (3 downto 0) := To_StdLogicVector(TerminalCountValue);

begin

	ExpLEDOE <= intExpLEDOE;

	expLedDataOut(3 downto 2) <= 	Exp0LED(1 downto 0) when (Exp0LED0Read='1' or Exp0LEDRead='1') else 
									Exp0LED(3 downto 2) when  Exp0LED1Read='1' else 
									Exp1LED(1 downto 0) when (Exp1LED0Read='1' or Exp1LEDRead='1') else 
									Exp1LED(3 downto 2) when  Exp1LED1Read='1' else 
									Exp2LED(1 downto 0) when (Exp2LED0Read='1' or Exp2LEDRead='1') else 
									Exp2LED(3 downto 2) when  Exp2LED1Read='1' else 
									Exp3LED(1 downto 0) when (Exp3LED0Read='1' or Exp3LEDRead='1') else 
									Exp3LED(3 downto 2) when  Exp3LED1Read='1' else 
									"00"; 

	expLedDataOut(1 downto 0) <= 	Exp0LED(3 downto 2) when Exp0LEDRead='1' else 
									Exp1LED(3 downto 2) when Exp1LEDRead='1' else 
									Exp2LED(3 downto 2) when Exp2LEDRead='1' else 
									Exp3LED(3 downto 2) when Exp3LEDRead='1' else 
									"00"; 

	-- A buffer catches the data coming in from the processor
	-- After this write occurs, a bit will be latched indicating 
	-- that a write occurred and the state machine will then 
	-- shift data out to the LED drivers
	process (Reset, H1_CLKWR)
	begin
		if Reset then
			Exp0LED <= (others => '0');
			Exp1LED <= (others => '0');
			Exp2LED <= (others => '0');
			Exp3LED <= (others => '0');
		elsif rising_edge(H1_CLKWR) then
			if Exp0LED0Write = '1' or Exp0LEDWrite = '1' then
				Exp0LED(1 downto 0) <= intDATA(31 downto 30);
			end if;

			if Exp0LED1Write = '1' then
				Exp0LED(3 downto 2) <= intDATA(31 downto 30);
			elsif Exp0LEDWrite = '1' then
				Exp0LED(3 downto 2) <= intDATA(29 downto 28);
			end if;

			if Exp1LED0Write = '1' or Exp1LEDWrite = '1' then
				Exp1LED(1 downto 0) <= intDATA(31 downto 30);
			end if;

			if Exp1LED1Write = '1' then
				Exp1LED(3 downto 2) <= intDATA(31 downto 30);
			elsif Exp1LEDWrite = '1' then
				Exp1LED(3 downto 2) <= intDATA(29 downto 28);
			end if;

			if Exp2LED0Write = '1' or Exp2LEDWrite = '1' then
				Exp2LED(1 downto 0) <= intDATA(31 downto 30);
			end if;

			if Exp2LED1Write = '1' then
				Exp2LED(3 downto 2) <= intDATA(31 downto 30);
			elsif Exp2LEDWrite = '1' then
				Exp2LED(3 downto 2) <= intDATA(29 downto 28);
			end if;

			if Exp3LED0Write = '1' or Exp3LEDWrite = '1' then
				Exp3LED(1 downto 0) <= intDATA(31 downto 30);
			end if;

			if Exp3LED1Write = '1' then
				Exp3LED(3 downto 2) <= intDATA(31 downto 30);
			elsif Exp3LEDWrite = '1' then
				Exp3LED(3 downto 2) <= intDATA(29 downto 28);
			end if;

			intExpLEDSelect(0) <= Exp0LEDWrite or Exp0LED0Write or Exp0LED1Write or (intExpLEDSelect(0) and not ClearExpLEDLatch);
			intExpLEDSelect(1) <= Exp1LEDWrite or Exp1LED0Write or Exp1LED1Write or (intExpLEDSelect(1) and not ClearExpLEDLatch);
			intExpLEDSelect(2) <= Exp2LEDWrite or Exp2LED0Write or Exp2LED1Write or (intExpLEDSelect(2) and not ClearExpLEDLatch);
			intExpLEDSelect(3) <= Exp3LEDWrite or Exp3LED0Write or Exp3LED1Write or (intExpLEDSelect(3) and not ClearExpLEDLatch);
		end if;	
	end process;

	ExpLEDSelect <= intExpLEDSelect;
--	ExpLEDSelect(0) <= '1' when intExpLEDSelect(0) = '1' else '0';
--	ExpLEDSelect(1) <= '1' when intExpLEDSelect(1) = '1' else '0';
--	ExpLEDSelect(2) <= '1' when intExpLEDSelect(2) = '1' else '0';
--	ExpLEDSelect(3) <= '1' when intExpLEDSelect(3) = '1' else '0';

	process (SysClk)
	begin
		if rising_edge(SysClk) then
			StartStateMachine <= ((intExpLEDSelect(0) or intExpLEDSelect(1) or intExpLEDSelect(2) or intExpLEDSelect(3)) and 
										SynchedTick) or (StartStateMachine and (intExpLEDSelect(0) or intExpLEDSelect(1) or 
										intExpLEDSelect(2) or intExpLEDSelect(3)));
		end if;
	end process;

	-- State Machine to control the write sequence to the LED driver
	StateMachine: process(Reset, SysClk)
	begin
		if Reset then
			State <= IdleState; -- reset state
			ClearExpLEDLatch <= '0';
			intExpLEDOE <= '1';
			ExpLEDLatch <= '0';
			ShiftEnable <= '0';
			EnableDelay <= '0';
		elsif rising_edge(SysClk) then
			if SynchedTick = '1' then
				State <= IdleState; -- reset state, this will reset the state machine every ms
			elsif SlowEnable = '1' then
				case State is
					when IdleState =>
						if StartStateMachine = '1' and DiscoveryComplete = '1' and EEPROMAccessFlag = '0' then
							State <= ShiftState;
							ShiftEnable <= '1'; -- enable the data shifting on detection of state transition
						else
							ShiftEnable <= '0'; -- disable the data shifting
							ExpLEDLatch <= '0'; -- latch inactive (active on rising edge)
						end if;

					when ShiftState =>
						if Count = TerminalCount then
							State <= ClearState;
							ShiftEnable <= '0';
						else
							ExpLEDLatch <= '0'; -- register latch is still inactive
							ShiftEnable <= '1'; -- enable the data shifting
						end if;

					when ClearState =>
						State <= EndState;
						if EEPROMAccessFlag = '0' then -- If the EEPROM is being accessed restart LED
							ClearExpLEDLatch <= '1';
						end if;

					when EndState =>
						if EEPROMAccessFlag = '0' then
							ExpLEDLatch <= '1'; -- Don't latch the LED data if there is an access by the Serial EEPROM Module
						end if;
						ShiftEnable <= '0';
						ClearExpLEDLatch <= '0';
						if DiscoveryComplete = '1' then
							EnableDelay <= '1';
							intExpLEDOE <= not EnableDelay;
						else
							intExpLEDOE <= '1';
						end if;
						State <= IdleState;

					when others => 
						State <= IdleState; -- default, reset state
				end case;
			end if;
		end if;
	end process;

--	M_LED_CLK 
	process (Reset, SysClk)
	begin
		if Reset then
			OutputClock <= '0'; 
		elsif rising_edge(SysClk) then
			if SynchedTick = '1' then -- set the output clock on the control loop tick
				OutputClock <= '0'; 
			elsif ShiftEnable = '1' and SlowEnable = '1' then
				OutputClock <= not OutputClock;
			end if;

			-- 4-bit synchronous counter with count enable and asynchronous reset
--			if SynchedTick = '1' or ShiftComplete = '1' then
			if SynchedTick = '1' or (Count = TerminalCount and SlowEnable = '1') then
				Count (3 downto 0) <= "0000";
			elsif ShiftEnable = '1' and OutputClock = '0' and SlowEnable = '1' then
				Count <= Count + 1;
			end if;
		end if;
	end process;

	ExpLEDClk <= OutputClock;

--	process (SysClk)
--	begin 
--		if falling_edge(SysClk) then  -- This must be falling edge
--			if (Count = TerminalCount and SlowEnable = '1') then -- Terminal count at 8 + 1
--				ShiftComplete <= '1';
--			else
--				ShiftComplete <= '0';
--			end if;
--		end if;
--	end process;

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
	ExpLEDData(0) <= ShiftRegister0(7) when State = ShiftState else '0';
	ExpLEDData(1) <= ShiftRegister1(7) when State = ShiftState else '0';
	ExpLEDData(2) <= ShiftRegister2(7) when State = ShiftState else '0';
	ExpLEDData(3) <= ShiftRegister3(7) when State = ShiftState else '0';

end ExpModuleLED_arch;
