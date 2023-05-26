--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		ControlIO
--	File			controlio.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		Control Board IO and LED Interface
--
--		The LED information is clocked out to 74HCT595 devices and is 
--		clocked on the rising edge of the clock.
--
--	Revision: 1.2
--
--	File history:
--		Rev 1.2 : 09/02/2022 :	Added RESET for M_IO_OE to keep LEDs off at start
--								Simplify state machine
--		Rev 1.1 : 06/01/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ControlIO is
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
		M_IO_OE				: out std_logic;	-- Enable outputs on shift register that controls LEDs on axis modules
		M_IO_LOAD			: out std_logic;	-- 0 = enable input latch, 1 = enable input shift register
		M_IO_LATCH			: out std_logic;	-- Transfer data from shift register to outputs and latch inputs
		M_IO_CLK			: out std_logic;	-- Clock input and output data through shift registers
		M_IO_DATAOut		: out std_logic;
		M_IO_DATAIn			: in std_logic;
		M_ENABLE			: out std_logic_vector (1 downto 0);
		M_FAULT				: in std_logic_vector (1 downto 0);
		PowerUp				: in std_logic;
		QUADPresent			: in std_logic;
		QA0AxisFault		: out std_logic_vector (2 downto 0);
		QA1AxisFault		: out std_logic_vector (2 downto 0)
	);
end ControlIO;

architecture ControlIO_arch of ControlIO is

	signal	ShiftOutRegister		: std_logic_vector (9 downto 0);	-- := "0000000000";
	signal	ShiftInRegister			: std_logic_vector (7 downto 0);	-- := "00000000";
	signal	DataBufferOut			: std_logic_vector (9 downto 0);	-- := "0000000000";
	signal	DataBufferIn			: std_logic_vector (7 downto 2);	-- := "000000";
	signal	Count					: std_logic_vector (3 downto 0);	-- := X"0";
	signal	ClearControlLED			: std_logic;	-- := '0';
	signal	OutputClock,
			ShiftEnable				: std_logic;	-- := '0';,
	signal	Axis0Status0,
			Axis0Status1,
			Axis0EnFlt0,
			Axis0EnFlt1				: std_logic;	-- := '0';
	signal	Axis1Status0,
			Axis1Status1,
			Axis1EnFlt0,
			Axis1EnFlt1				: std_logic;	-- := '0';
	signal	StartStateMachine,
			PowerUpLatch			: std_logic;	-- := '0';,
	signal	QA0DisableTermination,
			QA1DisableTermination	: std_logic;	-- := '0';
	signal	intM_IO_OE				: std_logic;	-- := '1';
	signal	EnableDelay				: std_logic;	-- Delay the Output eanable until the second time through the LED output state machine

	-- State Encoding
	type STATE_TYPE is array (2 downto 0) of std_logic;
	constant s0: STATE_TYPE :="000";
	constant s1: STATE_TYPE :="001";
	constant s2: STATE_TYPE :="011";
	constant s3: STATE_TYPE :="111";
	constant s4: STATE_TYPE :="110";

	signal State: STATE_TYPE; -- state can be assigned the constants defined above in "State Encoding"

	constant TerminalCount8 : std_logic_vector (3 downto 0) := B"1000";  -- 0x8
	constant TerminalCount10 : std_logic_vector (3 downto 0) := B"1010"; -- 0xA

begin

	QA0AxisFault(2 downto 0) <= DataBufferIn(4 downto 2); -- Z, B, A
	QA1AxisFault(2 downto 0) <= DataBufferin(7 downto 5); -- Z, B, A

	-- Note that the MDT Status will also be driven onto this bus from the MDTControl module
	-- Note that the Quad Status will also be driven onto this bus from the QUAD module
	controlIoDataOut(31 downto 0) <=	X"0000_000" & "000" & M_FAULT(0) when Axis0IORead='1' else 
										Axis0Status1 & Axis0Status0 & Axis0EnFlt1 & Axis0EnFlt0 & QA0DisableTermination & "000" & X"00_0000" when Axis0LEDStatusRead='1' else
										X"0000_000" & "000" & M_FAULT(1) when Axis1IORead='1' else
										Axis1Status1 & Axis1Status0 & Axis1EnFlt1 & Axis1EnFlt0 & QA1DisableTermination & "000" & X"00_0000" when Axis1LEDStatusRead='1' else
										X"0000_0000"; 

	-- A buffer catches the data coming in from the processor
	-- latch the enable outputs 
	process (RESET, H1_CLKWR)
	begin
		if RESET then
				M_ENABLE(0) <= '0';
				M_ENABLE(1) <= '0';
				QA0DisableTermination <= '0';
				Axis0EnFlt0 <= '0';
				Axis0EnFlt1 <= '0';
				Axis0Status0 <= '0';
				Axis0Status1 <= '0';
				QA1DisableTermination <= '0';
				Axis1EnFlt0 <= '0';
				Axis1EnFlt1 <= '0';
				Axis1Status0 <= '0';
				Axis1Status1 <= '0';
		elsif rising_edge(H1_CLKWR) then
			if Axis0IOWrite = '1' then
				M_ENABLE(0) <= intDATA(0);
			end if;

			if Axis1IOWrite = '1' then
				M_ENABLE(1) <= intDATA(0);
			end if;

			-- A buffer catches the data coming in from the processor
			if Axis0LEDConfigWrite = '1' then
				QA0DisableTermination <= intDATA(27);
				Axis0EnFlt0 <= intDATA(28);
				Axis0EnFlt1 <= intDATA(29);
				Axis0Status0 <= intDATA(30);
				Axis0Status1 <= intDATA(31);
			end if;

			-- A buffer catches the data coming in from the processor
			if Axis1LEDConfigWrite = '1' then
				QA1DisableTermination <= intDATA(27);
				Axis1EnFlt0 <= intDATA(28);
				Axis1EnFlt1 <= intDATA(29);
				Axis1Status0 <= intDATA(30);
				Axis1Status1 <= intDATA(31);
			end if;
		end if;  
	end process;

	process (RESET, SysClk)
	begin
		if RESET then
			PowerUpLatch <= '0';
			StartStateMachine <= '0';
		elsif rising_edge(SysClk) then
			PowerUpLatch <= PowerUp or PowerUpLatch;
	
			if ClearControlLED = '1' then
				StartStateMachine <= '0';
			else
				StartStateMachine <= (SynchedTick or PowerUp) or StartStateMachine;
			end if;
		end if;
	end process;

	-- State Machine to control the write sequence to the LED driver
	StateMachine : process(RESET, SysClk)
	begin
		if RESET then
			intM_IO_OE <= '1';
			M_IO_LOAD <= '0';
			M_IO_LATCH <= '0';
			State <= s0;		-- reset state
			ShiftEnable <= '0';
			ClearControlLED <= '0';
			EnableDelay <= '0';
		elsif rising_edge(SysClk) then 
			if SynchedTick = '1' then
				State <= s0;	-- reset state, this will reset the state machine every ms
			elsif Enable = '1' then
				case State is
					-- Wait for the signal to start the state machine to shift data in and out
					when  s0 =>
						if StartStateMachine = '1' then
							State <= s1;
							M_IO_LOAD <= '0';
						else
							ShiftEnable <= '0';			-- disable the data shifting
							M_IO_LATCH <= '0';			-- latch inactive (active on rising edge)
							ClearControlLED <= '0';
						end if;
					-- Load data into shift registers (rising edge of M_IO_LATCH)
					when  s1 =>
						State <= s2;
						M_IO_LATCH <= '1';
					-- Prepare to shift data ina and out
					when  s2 =>
						State <= s3;
						ShiftEnable <= '1';			-- enable the data shifting on detection of state transition
						M_IO_LOAD <= '1';

					when  s3 =>
						if (Count = TerminalCount8 and QUADPresent = '0') or 			-- Terminal count at 8 + 1
							(Count = TerminalCount10 and QUADPresent = '1') then
							State <= s4;
							ShiftEnable <= '0';
						else
							ClearControlLED <= '1';
						end if;

					when  s4 =>
						M_IO_LATCH <= '0';
						ClearControlLED <= '0';
						-- EnableDelay is set to 1 the first time through the state machine and then remains 1 forever
						EnableDelay <= '1';
						-- Delay setting intM_IO_OE low until the second time through the state machine because
						--   M_IO_LATCH is active before data is shifted out which means the first time through
						--   bogus data that happens to be in the device is latched on the outputs and the LEDs
						--   end up with random patterns momentarily.
						intM_IO_OE <= not EnableDelay;
						State <= s0;

					when others =>
						State <= s0;					-- default, reset state

				end case;
			end if;
		end if;
	end process;

	-- M_LED_CLK 
	process (RESET, SysClk)
	begin
		if RESET then
			OutputClock <= '0'; 
			Count <= (others => '0');
		elsif rising_edge(SysClk) then
			-- Generate the output clock 
			if SynchedTick = '1' then
				OutputClock <= '0'; 
			elsif ShiftEnable = '1' and Enable = '1' then
				OutputClock <= not OutputClock;
			end if;

			-- 4-bit synchronous counter with count enable and asynchronous reset
			if SynchedTick = '1' or (Enable = '1' and ((Count = TerminalCount8 and QUADPresent = '0') or 			-- Terminal count at 8 + 1
							(Count = TerminalCount10 and QUADPresent = '1'))) then
				Count <= "0000";
			elsif ShiftEnable = '1' and OutputClock = '0' and Enable = '1' then
				Count <= Count + 1;
			end if;

		end if;
	end process;

	M_IO_CLK <= OutputClock;

	M_IO_OE <= intM_IO_OE;

	-- If the Enable for a particular LED isn't on then two consecutive 1's or 0's are
	-- written into the LED driver to turn the LED off. Otherwise, one of the bits is 
	-- inverted from the other to cause current flow in one direction or the other.

	DataBufferOut(0) <= '1' when Axis0Status1 = '0' and Axis0Status0 = '1' else
						'0' when Axis0Status1 = '1' and Axis0Status0 = '0' else '0';

	DataBufferOut(1) <= '0' when Axis0Status1 = '0' and Axis0Status0 = '1' else
						'1' when Axis0Status1 = '1' and Axis0Status0 = '0' else '0';

	DataBufferOut(2) <= '1' when Axis0EnFlt1 = '0' and Axis0EnFlt0 = '1' else
						'0' when Axis0EnFlt1 = '1' and Axis0EnFlt0 = '0' else '0';

	DataBufferOut(3) <= '0' when Axis0EnFlt1 = '0' and Axis0EnFlt0 = '1' else
						'1' when Axis0EnFlt1 = '1' and Axis0EnFlt0 = '0' else '0';

	DataBufferOut(4) <= '1' when Axis1Status1 = '0' and Axis1Status0 = '1' else
						'0' when Axis1Status1 = '1' and Axis1Status0 = '0' else '0';

	DataBufferOut(5) <= '0' when Axis1Status1 = '0' and Axis1Status0 = '1' else
						'1' when Axis1Status1 = '1' and Axis1Status0 = '0' else '0';

	DataBufferOut(6) <= '1' when Axis1EnFlt1 = '0' and Axis1EnFlt0 = '1' else
						'0' when Axis1EnFlt1 = '1' and Axis1EnFlt0 = '0' else '0';

	DataBufferOut(7) <= '0' when Axis1EnFlt1 = '0' and Axis1EnFlt0 = '1' else
						'1' when Axis1EnFlt1 = '1' and Axis1EnFlt0 = '0' else '0';

	-- The following two bits only apply to the QAx module
	DataBufferOut(8) <= QA0DisableTermination;	

	DataBufferOut(9) <= QA1DisableTermination;	

	-- 10 bit output shift register
	-- Data is clocked out on the falling edge of the clock
	process (SysClk)
	begin
		if rising_edge(SysClk) then
			if SynchedTick = '1' then  
				ShiftOutRegister(9 downto 0) <= DataBufferOut(9 downto 0);
			elsif (ShiftEnable = '1' and OutputClock = '1' and Enable = '1') then
				ShiftOutRegister(9 downto 0) <= ShiftOutRegister(8 downto 0) & '0';
			end if;

			-- 8/10 bit input shift register
			-- Data is clocked in on the rising edge of the clock
			if SynchedTick = '1' then  
				DataBufferIn <= ShiftInRegister(7 downto 2);
			elsif (ShiftEnable = '1' and OutputClock = '0' and Enable = '1') then
				ShiftInRegister <= ShiftInRegister(6 downto 0) & M_IO_DATAIn;
			end if;
		end if;
	end process;

	-- Pick where the out going data bit is taken from based upon the presence
	-- of a QAx module
	M_IO_DATAOut <= '1' when 	(QUADPresent='1' and ShiftOutRegister(9)='1') or 
								(QUADPresent='0' and ShiftOutRegister(7)='1') else '0';

end ControlIO_arch;