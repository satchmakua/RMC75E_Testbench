--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		WDT
--	File			WatchDogTimer.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		The WatchDogTimer unit will count down to zero from a user defined value.
--		When the counter crosses over 0x1 the WDT expiration value is set.
--
--	Revision: 1.6
--
--	File history:
--		Rev 1.6 : 10/28/2022 :	Run signla to device pin to keep logic from being 
--								 removed by optimizer.
--		Rev 1.5 : 10/27/2022 :	Added register at address 007 for CPU to write and read
--								 in order to detect FPGA exists and is programmed
--		Rev 1.4 : 10/26/2022 :	Fixed WDT status bits
--		Rev 1.3 : 10/20/2022 :	Added bit that CPU can write to reset module
--		Rev 1.2 : 10/18/2022 :	Consolidated logic and added power-up detection for Igloo2
--		Rev 1.1 : 06/07/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity WDT is
	Port (   
		RESET				: in std_logic;
		SysRESET			: in std_logic;
		H1_CLKWR			: in std_logic;
		SysClk				: in std_logic;
		intDATA				: in std_logic_vector(31 downto 0);
		wdtDataOut			: out std_logic_vector(31 downto 0);
		FPGAProgDOut		: out std_logic_vector(31 downto 0);
		FPGAAccess			: in std_logic;		-- Flag indicating CPU is reading or writing to FPGA
		WDTConfigWrite		: in std_logic;
		FPGAProgrammedWrite	: in std_logic;		--	Write and read to verify Igloo2 FPGA is programmed
		SlowEnable			: in std_logic;
		HALT_DRIVE_L		: in std_logic;		-- From Drive Enable hardware watchdog timer
		WD_TICKLE			: in std_logic;		-- From CPU to tickle the watchdog timer
		WD_RST_L			: out std_logic		-- Output to trigger module reset
	);
end WDT;

architecture WDT_ARCH of WDT is

	constant AccessKeyA : std_logic_vector(3 downto 0) := x"A";
	constant AccessKey5 : std_logic_vector(3 downto 0) := x"5";

	signal	WDTCounter				: std_logic_vector (21 downto 0);	-- := "00" & x"00000";
	signal	WDTDelay				: std_logic_vector (15 downto 0);	-- := X"0000";
	signal	FirstKey,
			AccessKey				: std_logic;	-- := '0';
	signal	AccessKeyReg1			: std_logic_vector (3 downto 0);	-- := X"0";
	signal	PreClearKey,
			ClearKey				: std_logic;	-- := '0'; 
	signal	DriveHaltStatus,
			FPGAResetStatus			: std_logic;	-- Bit indicating to CPU that FPGA WDT expired
	signal	WDTCounterLoad,
			WDTTerminalCount		: std_logic;	-- := '0';
	signal	WriteEnd,
			WriteEndLatch			: std_logic;	-- := '0';
	signal	WDTKick,
			WDTKick1				: std_logic;	-- := '0';
	signal	LoadWDTCount1,
			LoadWDTCount			: std_logic;	-- := '0';
	signal	ExternalResetStatus		: std_logic;	-- := '0'; 
	signal	WD_RST_SHIFT			: std_logic_vector( 7 downto 0);	-- := X"00";
	signal	WD_RST					: std_logic;	-- := '0';
	
	signal	WDTExpFlag				: std_logic;	-- Indicates that reset was caused by WDT expiring
	signal	PUReg					: std_logic_vector(19 downto 0);	-- Used to detect Power-Up condition

	signal	Res_Sync				: std_logic;	-- RESET synchronized to H1_CLKWR
	signal	IntReset				: std_logic_vector(2 downto 0);	-- Delayed version of RESET
	signal	Res_OS					: std_logic;	-- Single pule indicating falling edge of main RESET
	
	signal	RegAAAAA				: std_logic;
	
	signal	FPGA_RstReq				: std_logic;	-- bit written by CPU to cause module reset

	-- Keep PUReg from getting optimized down to two bits
	attribute syn_preserve : boolean;
	attribute syn_preserve of PUReg : signal is true;

begin

	wdtDataOut(31 downto 0) <= "0000000000000" & ExternalResetStatus & DriveHaltStatus & FPGAResetStatus & WDTDelay;

	process(SysClk, SysRESET)
	begin
		if SysRESET then
			WDTCounter <= "00" & x"00000";
			WDTTerminalCount <= '0';
			WD_RST_SHIFT(7 downto 0) <= X"00";
		elsif rising_edge(SysClk) then
			-- An edge detect must be conducted on the WDT in order to only reset the counter on the transitions
			-- This will prevent the WD counter from getting stopped if the WD_TICKLE pin is stuck low.
			if SlowEnable then
				-- Latch the WD_TICKLE from the CPU in order to generate a one-shot on each edge
				WDTKick <= WD_TICKLE;
				WDTKick1 <= WDTKick;

				-- Generate signal to restart the watchdog counter either from a hardware tickle from the CPU (WDTKick xor WDTKick1)
				--	or from a special sequence of writes to the WDT config register (LoadWDTCount)
				-- Do not reload the WDT if there's already been a timeout. The FPGAResetStatus must be cleared by the processor first.
				WDTCounterLoad <= ((WDTKick xor WDTKick1) or LoadWDTCount) and not FPGAResetStatus;
				
				-- The WDT "expires" when the count is "0001" vs "0000". "0000" is reserved for disabling the WDT.
				if WDTCounter = "0000000000000000000001" then
					WDTTerminalCount <= '1';
				end if;

				-- Load the WDT counter when it is kicked otherwise count down if it isn't zero.
				if WDTCounterLoad then
					WDTCounter <= WDTDelay & "000000";
				elsif WDTCounter /= "00" & x"00000" then
					WDTCounter <= WDTCounter - 1;
				end if;

				LoadWDTCount <= LoadWDTCount1;
			end if;
		
			-- The reset output is active until a reset input from the System Reset line
			-- clears the register.
			WD_RST_SHIFT(7 downto 0) <= WD_RST_SHIFT(6 downto 0) & WDTTerminalCount;
		end if;
	end process;

	WD_RST <= WD_RST_SHIFT(7);
	WD_RST_L <= not (WD_RST or FPGA_RstReq);

	-- Detect if PUReg = AAAAA
	RegAAAAA <= PUReg(19) and not PUReg(18) and PUReg(17) and not PUReg(16) and PUReg(15) and not PUReg(14) and PUReg(13) and not PUReg(12) and PUReg(11) and not PUReg(10) and PUReg(9) and not PUReg(8) and PUReg(7) and not PUReg(6) and PUReg(5) and not PUReg(4) and PUReg(3) and not PUReg(2) and PUReg(1) and not PUReg(0);

	-- Power-up detection
	-- If PUReg contains AAAAA when RESET goes inactive, then assume device did not just power up.
	-- After PUReg is read, a value of 55555 is written into it so next reset cycle we can determing if it is a power-up condition.
	-- This is needed because Igloo2 devices power up with random data in their registers (as opposed to Xilinx where initial content
	--  of registers can be specified). If we detect a specific pattern then we can assume the pattern was previously written so it
	--  isn't a power-up situation.
	PowerUp : process(RESET, H1_CLKWR)
	begin
		if RESET then
			IntReset <= (others => '1');
			Res_OS <= '0';
			WDTExpFlag <= '0';
		elsif rising_edge(H1_CLKWR) then
			-- Sync Reset signal to clock
			Res_Sync <= RESET;
			IntReset <= IntReset(1 downto 0) & Res_Sync;
			Res_OS <= IntReset(2) and not IntReset(1);
			-- On falling edge of Reset, verify content of PUReg and write 55555 to PUReg
			if Res_OS then
				-- If PUReg contain AAAAA it means we had an internal watchdog timeout
				if RegAAAAA then
					WDTExpFlag <= '1';
				-- If PUReg contains something other than AAAAA or 55555 it means we just powered up (FPGA contains random value)
				else
					WDTExpFlag <= '0';
				end if;
				PUReg <= x"55555";
			else
				WDTExpFlag <= '0';
				if WDTTerminalCount then
					PUReg <= x"AAAAA";
				end if;
			end if;
		end if;
	end process;

	process(H1_CLKWR, RESET, WD_RST)
	begin
		if RESET then
			WDTDelay <= x"0000";
			ExternalResetStatus <= '0';
			AccessKeyReg1(3 downto 0) <= X"0";
			FirstKey <= '0';
			FPGA_RstReq <= '0';
			FPGAResetStatus <= '0';
		elsif WD_RST = '1' then		-- WD_RST triggers a module reset, so this logic only has an effect if
			FirstKey <= '0';		--	watchdog disable jumper is installed
		elsif rising_edge(H1_CLKWR) then
			if WDTConfigWrite and AccessKey then
				WDTDelay <= intDATA(15 downto 0);
			end if;

			-- If FPGA just powered up then clear the FPGAResetStatus bit. Set the bit when the WDT expires.
			-- A keyed write to the WDT config register also will clear the bit.
			if WDTTerminalCount or WDTExpFlag then
				FPGAResetStatus <= '1';
			elsif WDTConfigWrite and AccessKey then
				FPGAResetStatus <= intDATA(16);
			end if;

			-- Latch the status of the Drive Enable hardware watchdog. CPU clears the bit by writing '0'.
			if not HALT_DRIVE_L then
				DriveHaltStatus <= '1';
			elsif WDTConfigWrite and AccessKey then
				DriveHaltStatus <= intDATA(17);
			end if;

			if WDTConfigWrite and AccessKey then
				FPGA_RstReq <= intDATA(19);
			end if;

			-- begin access keying process by writing "A" to bits 23-20 of the WDT config word and
			--	storing that as AccessKeyReg1
			if ClearKey then
				AccessKeyReg1(3 downto 0) <= X"0";
			elsif WDTConfigWrite and not FirstKey then
				AccessKeyReg1(3 downto 0) <= intDATA(23 downto 20);
			end if;

			-- Delay the write signal by two clock cycles
			WriteEndLatch <= WDTConfigWrite;
			WriteEnd <= WriteEndLatch and not FPGAAccess;

			-- Set flag (FirstKey) to indicate the "A" was written
			if AccessKeyReg1(3 downto 0) = AccessKeyA and WriteEnd = '1' then
				FirstKey <= '1';
			elsif ClearKey then
				FirstKey <= '0';
			end if;

			-- Prepare to clear the key on next FPGA access
			PreClearKey <= FPGAAccess and (PreClearKey or (FirstKey and not ClearKey));
			-- Generate signal to clear the key after the FPGA access
			ClearKey <= PreClearKey and not FPGAAccess;

			if AccessKey then
				LoadWDTCount1 <= '1';
			elsif LoadWDTCount then
				LoadWDTCount1 <= '0';
			end if;
			
			-- CPU writes to this register with different values to verify FPGA exists and is programmed.
			-- The data bytes are swapped to make sure the CPU isn't reading somethign that was left on the bus.
			if FPGAProgrammedWrite then
				FPGAProgDOut(31 downto 16) <= intDATA(15 downto 0);
				FPGAProgDOut(15 downto 0) <= intDATA(31 downto 16);
			end if;

		end if;
	end process;

	AccessKey <= '1' when FirstKey = '1' and intDATA(23 downto 20) = AccessKey5 and FPGAAccess = '1' else '0';

end WDT_ARCH;
