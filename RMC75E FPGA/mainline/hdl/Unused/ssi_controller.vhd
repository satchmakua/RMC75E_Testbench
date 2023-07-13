--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		ssi_controller
--	File			ssi_controller.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		ssi_controller.vhd
--		this module accepts the StartRead input as a start to generate the pulse train
--		for the transducers and generate the shift_en signals for the ssi_xface0 and 1
--		the pulse train will be dictated by the value in DataLength
--
--	Revision: 1.1
--
--	File history:
--		Rev 1.1 : 06/09/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ssi_controller is
	port (
		SysClk			: in std_logic;						-- 30MHz system clock
	  	Enable			: in std_logic;						-- 7.5MHz system enable (active every 4th 30MHz clock)
		StartRead		: in std_logic;
		DataLength		: in std_logic_vector (5 downto 0);
		HalfPeriod		: in std_logic_vector (5 downto 0);
		Shift			: out std_logic;
		CheckDataHi		: out std_logic;
		CheckDataLo		: out std_logic;
		SSI_CLK			: out std_logic
	);
end ssi_controller;

architecture ssi_controller_arch of ssi_controller is

--	constant ThreeSeventyFivekHertzValue : bit_vector := B"00";
--	constant ThreeSeventyFivekHertz : std_logic_vector (1 downto 0) := To_StdLogicVector(ThreeSeventyFivekHertzValue);
--	constant ThreeSeventyFivekHertzDelayValue : bit_vector := B"001001";
--	constant ThreeSeventyFivekHertzDelay : std_logic_vector (5 downto 0) := To_StdLogicVector(ThreeSeventyFivekHertzDelayValue);
--
--	constant TwoFiftykHertzValue : bit_vector := B"01";
--	constant TwoFiftykHertz : std_logic_vector (1 downto 0) := To_StdLogicVector(TwoFiftykHertzValue);
--	constant TwoFiftykHertzDelayValue : bit_vector := B"001110";
--	constant TwoFiftykHertzDelay : std_logic_vector (5 downto 0) := To_StdLogicVector(TwoFiftykHertzDelayValue);
--
--	constant OneFiftykHertzValue : bit_vector := B"10";
--	constant OneFiftykHertz : std_logic_vector (1 downto 0) := To_StdLogicVector(OneFiftykHertzValue);
--	constant OneFiftykHertzDelayValue : bit_vector := B"011000";
--	constant OneFiftykHertzDelay : std_logic_vector (5 downto 0) := To_StdLogicVector(OneFiftykHertzDelayValue);
--
--	constant OneHundredkHertzValue : bit_vector := B"11";
--	constant OneHundredkHertz : std_logic_vector (1 downto 0) := To_StdLogicVector(OneHundredkHertzValue);
--	constant OneHundredkHertzDelayValue : bit_vector := B"100100";
--	constant OneHundredkHertzDelay : std_logic_vector (5 downto 0) := To_StdLogicVector(OneHundredkHertzDelayValue);

	signal	ShiftCounter	: std_logic_vector (5 downto 0);	-- := "000000";
	signal	CycleCounter	: std_logic_vector (5 downto 0);	-- := "000000";
	signal	CycleCountMatch,
			ClkOn,
			SequenceOn		: std_logic;	-- := '0';
	signal	ToggleEn,
			CheckDataDelay,
			intCheckDataLo	: std_logic;	-- := '0';
	signal	TurnShiftOn,
			ShiftOn,
			PreTurnShiftOff,
			TurnShiftOff	: std_logic;	-- := '0';
	signal	intShift		: std_logic;	-- := '0';
	signal	intSSI_CLK		: std_logic;	-- := '1';
	signal	LineBreakDelay	: std_logic;	-- := '0';

begin

	-- intX signals are used internal to the module
	-- they must be reassigned to be driven out of module
	SSI_CLK <= intSSI_CLK;
	CheckDataLo <= intCheckDataLo;

	-- Enables shifting in of external data into a holding register
	TurnShiftOn <= '1' when ClkOn='1' and ShiftOn='0' and intSSI_CLK='0' and ToggleEn='1' else '0';
--	TurnShiftOn <= '1' when ClkOn='1' and CycleCounter(4 downto 0)="00111" and ShiftOn='0' else '0';

	-- Terminates the process when the count reaches a predetermined length
	PreTurnShiftOff <= '1' when (DataLength(5 downto 0) = ShiftCounter(5 downto 0)) else '0';

	CycleCountMatch <= '1' when 	CycleCounter(5 downto 0) = HalfPeriod(5 downto 0) else '0';

--	CycleCountMatch <= '1' when	(ClockRate(1 downto 0)=ThreeSeventyFivekHertz and 
--								CycleCounter(5 downto 0)=ThreeSeventyFivekHertzDelay) or
--								(ClockRate(1 downto 0)=TwoFiftykHertz and 
--								CycleCounter(5 downto 0)=TwoFiftykHertzDelay) or
--								(ClockRate(1 downto 0)=OneFiftykHertz and 
--								CycleCounter(5 downto 0)=OneFiftykHertzDelay) or
--								(ClockRate(1 downto 0)=OneHundredkHertz and 
--								CycleCounter(5 downto 0)=OneHundredkHertzDelay) else '0';

	-- SHIFT is active whenever the toggle is active and the clock is low
	Shift <= intShift;
	intShift <= '1' when ToggleEn='1' and intSSI_CLK='0' and ShiftOn='1' else '0';

	LineBreakDelay <= '1' when ('0' & CycleCounter(5 downto 1)) = HalfPeriod(5 downto 0) else '0';

--	LineBreakDelay <= '1' when 	(ClockRate(1 downto 0)=ThreeSeventyFivekHertz and 
--								'0' & CycleCounter(5 downto 1)=ThreeSeventyFivekHertzDelay) or -- double the time 
--								(ClockRate(1 downto 0)=TwoFiftykHertz and 
--								'0' & CycleCounter(5 downto 1)=TwoFiftykHertzDelay) or -- double the time
--								(ClockRate(1 downto 0)=OneFiftykHertz and 
--								'0' & CycleCounter(5 downto 1)=OneFiftykHertzDelay) or -- double the time
--								(ClockRate(1 downto 0)=OneHundredkHertz and 
--								'0' & CycleCounter(5 downto 1)=OneHundredkHertzDelay) else '0'; -- double the time (10us + 2us)

	process (SysClk)
	begin
		if rising_edge(SysClk) then
			-- when the StartRead comes by; start the "machine"
			SequenceOn <= (SequenceOn and (not intCheckDataLo)) or StartRead;

			-- Enables the external SCLK functions
			ClkOn <= (ClkOn and (not TurnShiftOff)) or StartRead;

			ShiftOn <= (ShiftOn and (not TurnShiftOff)) or TurnShiftOn;

			if Enable = '1' then
				TurnShiftOff <= PreTurnShiftOff; 
			end if;

			if (SequenceOn='0' or ToggleEn='1') then
				CycleCounter(5 downto 0) <= "000000"; -- If we're not enabled, the sequence is over so zero the counts
			elsif Enable='1' then
				CycleCounter(5 downto 0) <= CycleCounter (5 downto 0) + '1';
			end if;

			-- ToggleEn must run at twice the frequency of the SSI clock in order to
			-- toggle the SSI clock at the requested ClockRate(1 downto 0)
			if ClkOn='1' and CycleCountMatch='1' and Enable='1' then
				ToggleEn <= '1';
			else
				ToggleEn <= '0';
			end if;

			-- shift_cntr counts the number of bits that have been shifted in
			if StartRead='1' or TurnShiftOff='1' then
				ShiftCounter <= "000000";
			elsif intShift='1' then
				ShiftCounter (5 downto 0) <= ShiftCounter (5 downto 0) + '1';
			end if;

			-- intSSI_CLK is the clock generated for the SSI DATA transfer
			if StartRead='1' and Enable='1' then
				intSSI_CLK <= '1';		  -- We should never have to force this high, but it's here in case of a glitch 
			elsif ToggleEn='1' and ClkOn='1' then
				intSSI_CLK <= not intSSI_CLK;
			end if;

			-- wire break detection; the data line must be high at start of read
			CheckDataHi <= StartRead;

			-- wire break detection; the data line must be low at end of read
			-- wait for at least one bit time plus a little before taking this sample
			if LineBreakDelay='1' and ClkOn='0' then -- delay for 1 bit time before sampling the line break detection bit
				CheckDataDelay <= '1';
			else
				CheckDataDelay <= '0';
			end if;

			intCheckDataLo <= CheckDataDelay;
		end if;
	end process;

end ssi_controller_arch;
