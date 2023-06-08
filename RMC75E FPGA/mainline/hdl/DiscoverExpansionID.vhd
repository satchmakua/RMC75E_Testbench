--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		DiscoverExpansionID
--	File			DiscoverExpansionID.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		After reset, quary ID information from Expansion modules.
--
--	Revision: 1.2
--
--	File history:
--		Rev 1.2 : 11/01/2022 :	Initialized Latch and SiftEnable signals on Reset
--		Rev 1.1 : 06/01/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DiscoverExpansionID is
	Port ( 
		RESET			: in std_logic;
	 	SysClk			: in std_logic;
	 	SlowEnable		: in std_logic;
		ExpansionID0	: inout std_logic_vector(16 downto 0);
		ExpansionID1	: inout std_logic_vector(16 downto 0);
		ExpansionID2	: inout std_logic_vector(16 downto 0);
		ExpansionID3	: inout std_logic_vector(16 downto 0);
		Exp_ID_CLK		: out std_logic;
		Exp_ID_DATA		: in std_logic;
		Exp_ID_LATCH	: out std_logic;
		Exp_ID_LOAD		: out std_logic
	);
end DiscoverExpansionID;

architecture DiscoverExpansionID_arch of DiscoverExpansionID is

	constant TerminalCountValue : bit_vector := "111111";
	constant TerminalCount : std_logic_vector (5 downto 0) := To_StdLogicVector(TerminalCountValue);

	-- State Encoding
	type STATE_TYPE is array (2 downto 0) of std_logic;
	constant s0_LatchState	:	STATE_TYPE :="000";
	constant s1_DelayState1	:	STATE_TYPE :="001";
	constant s2_LoadState	:	STATE_TYPE :="010";
	constant s3_DelayState2	:	STATE_TYPE :="011";
	constant s4_ClockState	:	STATE_TYPE :="100";
	constant s5_StopState	:	STATE_TYPE :="101";

	signal	State			: STATE_TYPE; -- state can be assigned the constants defined above in "State Encoding"
	signal	Count			: std_logic_vector (5 downto 0);	-- := "000000";
	signal	OutputClock,
			ShiftEnable,
			ShiftComplete	: std_logic;	-- := '0';

begin

-- Slow enable provides a 3.75MHz clock output for the serial comm
-- State Machine to control the write sequence to the LED driver
	StateMachine : process(SysClk)
	begin
		if rising_edge(SysClk) then 
			if RESET then
				State <= s0_LatchState;
				Exp_ID_LOAD <= '1';
				Exp_ID_LATCH <= '0';
				ShiftEnable <= '0';
			elsif (SlowEnable = '1') then
				case State is

					when s0_LatchState =>
						Exp_ID_LOAD <= '1';
						Exp_ID_LATCH <= '1';
						ShiftEnable <= '0';
						State <= s1_DelayState1;

					when s1_DelayState1 =>
						Exp_ID_LATCH <= '0';
						State <= s2_LoadState;

					when s2_LoadState =>
						Exp_ID_LOAD <= '0';
						State <= s3_DelayState2;

					when s3_DelayState2 =>
						Exp_ID_LOAD <= '1';
						State <= s4_ClockState;

					when s4_ClockState =>
						if ShiftComplete = '1' then
							ShiftEnable <= '0';
							State <= s5_StopState;
						else
							State <= s4_ClockState;
							ShiftEnable <= '1';
						end if;

					when s5_StopState =>
						ShiftEnable <= '0';
--						State <= s0_LatchState;
						State <= s5_StopState;

					when others =>
						State <= s0_LatchState;		-- default, reset state
				end case;
			end if;
		end if;
	end process;

	process (SysClk)
	begin
		if rising_edge(SysClk) then
			-- Exp_ID_CLK 
			if ShiftEnable = '0' then
				OutputClock <= '0';
			elsif ShiftEnable = '1' and SlowEnable = '1' then
				OutputClock <= not OutputClock;
			end if;

			-- 6-bit synchronous counter with count enable
			if (State = s0_LatchState or ShiftEnable = '0') then
					Count (5 downto 0) <= "000000";
			elsif (ShiftEnable = '1' and OutputClock = '1' and SlowEnable = '1') then
				Count <= Count + 1;
			end if;

			if Count(5 downto 0) = TerminalCount and SlowEnable = '1' then -- Terminal count at 64 + 1
				ShiftComplete <= '1';
			else
				ShiftComplete <= (ShiftComplete and ShiftEnable);
			end if;

			-- 64-bit shift register
			if (ShiftEnable = '1' and OutputClock = '0' and SlowEnable = '1') then
				ExpansionID3(15 downto 0) <= Exp_ID_DATA & ExpansionID3(15 downto 1);
				ExpansionID2(15 downto 0) <= ExpansionID3(0) & ExpansionID2(15 downto 1);
				ExpansionID1(15 downto 0) <= ExpansionID2(0) & ExpansionID1(15 downto 1);
				ExpansionID0(15 downto 0) <= ExpansionID1(0) & ExpansionID0(15 downto 1);
			end if;
		end if;
	end process;

	Exp_ID_CLK <= OutputClock;

	-- bit 16 acts as a data valid flag
	ExpansionID0(16) <= '1' when State = s5_StopState else '0';
	ExpansionID1(16) <= ExpansionID0(16);
	ExpansionID2(16) <= ExpansionID0(16);
	ExpansionID3(16) <= ExpansionID0(16);

end DiscoverExpansionID_arch;