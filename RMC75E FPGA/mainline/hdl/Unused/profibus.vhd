-- Title: Profibus 

-- Overview:
-- This module is used to read the PROFIBUS address from the rotary switches
-- The PROFIBUS address is then used by the CPU to set the module slave address
-- The address is read periodically to allow for user modification of the unit's 
-- slave address

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity profibus is
    Port (
		  		SysClk : in std_logic;
			 	SlowEnable : in std_logic;
				profiDataOut : out std_logic_vector(31 downto 0);
				SynchedTick : in std_logic;
				PROFIAddrRead : in std_logic;
				PROFIEnable : in std_logic;
				PROFI_CLK : out std_logic;
				PROFI_DATA : in std_logic;
				PROFI_LATCH : out std_logic;
				PROFI_LOAD : out std_logic
			 );
end profibus;

architecture profibus_arch of profibus is

-- Signal Declarations
signal Count: std_logic_vector (2 downto 0) := "000";
signal OutputClock, ShiftEnable, ShiftComplete: std_logic := '0';

-- State Encoding
type STATE_TYPE is array (2 downto 0) of std_logic;
constant s0_LatchState	:	STATE_TYPE :="000";
constant s1_DelayState1	:	STATE_TYPE :="001";
constant s2_LoadState	:	STATE_TYPE :="011";
constant s3_DelayState2	:	STATE_TYPE :="010";
constant s4_ClockState	:	STATE_TYPE :="110";
constant s5_StopState	:	STATE_TYPE :="111";

constant TerminalCountValue : bit_vector := B"111";
constant TerminalCount : std_logic_vector (2 downto 0) := To_StdLogicVector(TerminalCountValue);

signal State: STATE_TYPE; -- state can be assigned the constants defined above in "State Encoding"
signal StartPROFIRead, intPROFI_CLK, intPROFI_LATCH, intPROFI_LOAD : std_logic := '0';
signal intPROFIAddr, PROFIAddr : std_logic_vector(7 downto 0) := X"00";

begin

profiDataOut(31 downto 0) <= "000000000000000000000000" & PROFIAddr (3 downto 0) & PROFIAddr (7 downto 4);

PROFI_CLK <= intPROFI_CLK when PROFIEnable='1' else 'Z';
PROFI_LATCH <= intPROFI_LATCH when PROFIEnable='1' else 'Z';
PROFI_LOAD <= intPROFI_LOAD when PROFIEnable='1' else 'Z';

process (SysClk)
begin
	if rising_edge(SysClk) then
		StartPROFIRead <= SynchedTick or (StartPROFIRead and not ShiftEnable);
	end if;
end process;

-- Slow enable provides a clock enable every 266.6ns 
StateMachine : process(SysClk)
begin
	if rising_edge(SysClk) then 
		if SynchedTick='1' then
			State <= s0_LatchState;
		elsif SlowEnable = '1' then
			case State is

				when s0_LatchState => 
												intPROFI_LOAD <= '1';
												intPROFI_LATCH <= '0';
												ShiftEnable <= '0';
												if StartPROFIRead='1' then
													State <= s1_DelayState1;
												else
													State <= s0_LatchState;
												end if;
	
				when s1_DelayState1 => 
												intPROFI_LOAD <= '0';
												intPROFI_LATCH <= '0';
												State <= s2_LoadState;

				when s2_LoadState => 
												intPROFI_LATCH <= '1';
												State <= s3_DelayState2;

				when s3_DelayState2 => 
												State <= s4_ClockState;
												intPROFI_LOAD <= '1';

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
												State <= s0_LatchState;

				when others =>	State <= s0_LatchState;		-- default, reset state
			end case;
		end if;
	end if;
end process;

process (SysClk)
begin
	if rising_edge(SysClk) then
		if ShiftEnable = '0' then
			OutputClock <= '0';
		elsif ShiftEnable = '1' and SlowEnable = '1' then
			OutputClock <= not OutputClock;
		end if;
	end if;
end process;

intPROFI_CLK <= OutputClock;

-- 3-bit synchronous counter with count enable and asynchronous reset
process (SysClk)
begin
	if	rising_edge(SysClk) then
		if State = s0_LatchState or ShiftEnable = '0' then
			Count(2 downto 0) <= "000";
		elsif ShiftEnable = '1' and OutputClock = '1' and SlowEnable = '1' then
			Count(2 downto 0) <= Count(2 downto 0) + 1;
		end if;
	end if;
end process;

process (SysClk)
begin 
	if rising_edge(SysClk) then
		if Count(2 downto 0) = TerminalCount and SlowEnable = '1' then -- Terminal count at 7 + 1
			ShiftComplete <= '1';
		else
			ShiftComplete <= (ShiftComplete and ShiftEnable);
		end if;
	end if;
end process;

-- 8-bit shift register
process (SysClk)
begin
	if rising_edge(SysClk) then
		if (ShiftEnable = '1' and OutputClock = '0' and SlowEnable = '1') then
			intPROFIAddr(7 downto 0) <= PROFI_DATA & intPROFIAddr(7 downto 1);
		end if;
	end if;
end process;

-- transfer the internal PROFIBUS address to a CPU readable latch
-- the PROFIAddrRead is evaluated to ensure that I don't clock new data into
-- the Address latch during the middle of a read. This could cause invalid data
-- to be read from the FPGA
process (SysClk)
begin
	if rising_edge(SysClk) then
		if (SynchedTick='1' and PROFIAddrRead = '0') then
			PROFIAddr(7 downto 0) <= intPROFIAddr(7 downto 0);
		end if;
	end if;
end process;

end profibus_arch;