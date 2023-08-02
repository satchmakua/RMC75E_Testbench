--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		SerialMemoryInterface
--	File			serial_mem.vhd
--
--------------------------------------------------------------------------------
--	Note: commented out logic on lines 321, 351, & 387 to allow for complete
-- 	data transfer on M_SPROM_DATA line. Rewrite of state machine logic for better
--	logical seperation and organization is recommended.

--	Description: 
--		Serial memory interface for the RMC75E modular motion controller.
--		The module provides communication with an external serial EEPROM, specifically the AT24C01A device.
--		The SerialMemoryInterface component converts data from parallel to
--		serial format before sending it to the EEPROM (Electrically Erasable Programmable Read-Only Memory).
--		This conversion is necessary because many EEPROM devices communicate
--		using a serial protocol, which means they expect data to be sent one bit at a time.

--
--		Data is clocked into the Serial EEPROM device on the positive edge
--		Data is clocked out of the Serial EEPROM device on the negative edge
--
--	Revision: 1.2
--
--	File history:
--		Rev 1.2 : 02/28/2023 :	Add SysReset to reset state machine and various logic
--								  control signals.
--		Rev 1.1 : 06/02/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity SerialMemoryInterface is
	port (
		SysReset				: in std_logic;			-- System Reset or PLL not locked
		H1_CLK					: in std_logic; 		-- 60 MHz clock
		SysClk					: in std_logic; 		-- 30 MHz system clock
		SlowEnable				: in std_logic; 	-- Active every 8th tick of the system clock
		intDATA					: in std_logic_vector(31 downto 0);
		serialMemDataOut		: out std_logic_vector(31 downto 0);
		SerialMemXfaceWrite		: in std_logic;
		SerialMemoryDataIn		: in std_logic;
		SerialMemoryDataOut		: out std_logic;
		SerialMemoryDataControl	: out std_logic;
		SerialMemoryClk			: out std_logic;
		Exp0SerialSelect		: out std_logic;
		Exp1SerialSelect		: out std_logic;
		Exp2SerialSelect		: out std_logic;
		Exp3SerialSelect		: out std_logic;
		EEPROMAccessFlag		: out std_logic;
		M_SPROM_CLK				: out std_logic;
		M_SPROM_DATA			: inout std_logic
	);
end SerialMemoryInterface;

architecture SerialMemoryInterface_arch of SerialMemoryInterface is

	constant DeviceAddressValue : bit_vector (6 downto 0) := "1010000";
	constant DeviceAddress : std_logic_vector(6 downto 0) := To_StdLogicVector(DeviceAddressValue);

--	constant SerialMemoryClockTerminalCountValue : bit_vector (4 downto 0) := "01000"; -- 8 is terminal count
	constant SerialMemoryClockTerminalCountValue : bit_vector (4 downto 0) := "10011"; -- 19 is terminal count
	constant SerialMemoryClockTerminalCount : std_logic_vector(4 downto 0) := To_StdLogicVector(SerialMemoryClockTerminalCountValue);

--	constant SerialMemoryClockTerminalCountDiv2Value : bit_vector (4 downto 0) := "00100"; -- 4 is mid count
	constant SerialMemoryClockTerminalCountDiv2Value : bit_vector (4 downto 0) := "01001"; -- 9 is mid count
	constant SerialMemoryClockTerminalCountDiv2 : std_logic_vector(4 downto 0) := To_StdLogicVector(SerialMemoryClockTerminalCountDiv2Value);

	constant Exp0SelectValue : bit_vector (2 downto 0) := "000";
	constant Exp1SelectValue : bit_vector (2 downto 0) := "001";
	constant Exp2SelectValue : bit_vector (2 downto 0) := "010";
	constant Exp3SelectValue : bit_vector (2 downto 0) := "011";
	constant ControlModuleSelectValue : bit_vector (2 downto 0) := "100";

	constant Exp0SelectAddr : std_logic_vector(2 downto 0) := To_StdLogicVector(Exp0SelectValue);
	constant Exp1SelectAddr : std_logic_vector(2 downto 0) := To_StdLogicVector(Exp1SelectValue);
	constant Exp2SelectAddr : std_logic_vector(2 downto 0) := To_StdLogicVector(Exp2SelectValue);
	constant Exp3SelectAddr : std_logic_vector(2 downto 0) := To_StdLogicVector(Exp3SelectValue);
	constant ControlModuleSelectAddr : std_logic_vector(2 downto 0) := To_StdLogicVector(ControlModuleSelectValue);

	-- state encoding --
	type STATE_TYPE is (  IdleState, SignalStartState, DeviceAddrState, CheckDeviceAddrACKState, MemAddrState, 
						  CheckMemoryAddrACKState, OperationTypeState, WriteState, WriteAckState,
						  ReadState, ReadNoACKState, StopState, ClearState);

	signal	StateMachine: STATE_TYPE;

	signal	LoadDeviceAddr,
			LoadMemAddr,
			LoadWriteData,
			ShiftDone						: std_logic;	-- :='0'; 
	signal	SecondPassRead					: std_logic;	-- :='0';
	signal	ReadLatch,
			WriteLatch						: std_logic;	-- :='0';
	signal	WriteFlag,
			FLAG_CLR,
			intFLAG_CLR,
			FLAG_CLR_LAT,
			ReadFlag						: std_logic;	-- :='0';
	signal	SerialDataCounter				: std_logic_vector (2 downto 0);	-- :="000";
	signal	SerialMemoryClockEnableCounter	: std_logic_vector (4 downto 0);	-- := "00000";
	signal	SerialMemoryClockEnable,
			SerialDataInputEnable			: std_logic;	-- :='0';
	signal	intSerialMemoryDataIn,
			StartStopBit,
			ACK								: std_logic;	-- :='0';
	signal	MemoryAddress					: std_logic_vector (5 downto 0);	-- :="000000";
	signal	intModuleAddress				: std_logic_vector (2 downto 0);	-- :="000";
	signal	DataBuffer						: std_logic_vector (7 downto 0);	-- :="00000000";
	signal	intSerialMemoryClock,
			ShiftEnable,
			intSerialMemoryDataControl		: std_logic;	-- := '0';
	signal	intSerialMemoryDataOut			: std_logic;	-- := '0';
	signal	SerialMemoryClockFallingEdge	: std_logic;	-- := '0';
	signal	SerialMemoryMidClockEnable,
			intEEPROMAccessFlag,
			ControlSerialSelect				: std_logic;	-- := '0';
	signal	SerialDataInput					: std_logic_vector (7 downto 0):= X"00";
	signal	SerialDataOutputMux,
			SerialDataOutput				: std_logic_vector (7 downto 0);	-- := X"00";
	signal	IncOperationFaultCount,
			OperationFaultFlag,
			OperationFaultFlagInput,
			intOperationFaultFlagInput		: std_logic;	-- := '0';
	signal	OperationFaultCount				: std_logic_vector (1 downto 0);	-- := "00";

begin

	Exp0SerialSelect <= '1' when intModuleAddress=Exp0SelectAddr and intEEPROMAccessFlag='1' else '0';
	Exp1SerialSelect <= '1' when intModuleAddress=Exp1SelectAddr and intEEPROMAccessFlag='1' else '0';
	Exp2SerialSelect <= '1' when intModuleAddress=Exp2SelectAddr and intEEPROMAccessFlag='1' else '0';
	Exp3SerialSelect <= '1' when intModuleAddress=Exp3SelectAddr and intEEPROMAccessFlag='1' else '0';
	ControlSerialSelect <= '1' when intModuleAddress=ControlModuleSelectAddr and intEEPROMAccessFlag='1' else '0';

	-- -AA1 & -AA2 Serial EEPROM module connections
	intSerialMemoryDataIn <= M_SPROM_DATA when ControlSerialSelect='1' else SerialMemoryDataIn;  
	M_SPROM_DATA <= intSerialMemoryDataOut when ControlSerialSelect='1' and intSerialMemoryDataControl='1' else 'Z';
	M_SPROM_CLK <= intSerialMemoryClock when ControlSerialSelect='1' else '0';

	EEPROMAccessFlag <= intEEPROMAccessFlag;
	SerialMemoryDataControl <= intSerialMemoryDataControl;
	SerialMemoryDataOut <= intSerialMemoryDataout;

	serialMemDataOut(31 downto 0) <= ("0000000" & intModuleAddress(2 downto 0) & MemoryAddress(5 downto 0) & 
									WriteLatch & ReadLatch & OperationFaultFlag & "00000" & SerialDataInput(7 downto 0));

	-- Clock divide and generation

-- Generate the serial interface clock
-- This clock period cannot be greater than 100kHz
process(SysClk)
begin
	if rising_edge(SysClk) then
		if SerialMemoryClockEnable = '1' OR SysReset = '1' then
			SerialMemoryClockEnableCounter(4 downto 0) <= "00000";
		elsif SlowEnable='1' then
			SerialMemoryClockEnableCounter(4 downto 0) <= SerialMemoryClockEnableCounter(4 downto 0) + '1';
		end if;
	end if;
end process;

SerialMemoryClockEnable <= '1' when SerialMemoryClockEnableCounter(4 downto 0)=SerialMemoryClockTerminalCount(4 downto 0) and SlowEnable='1' else '0';
SerialMemoryMidClockEnable <= '1' when SerialMemoryClockEnableCounter(4 downto 0)=SerialMemoryClockTerminalCountDiv2(4 downto 0) and SlowEnable='1' else '0';

-- SM_CLK_GEN output is fed, buffered, to the SM_CLK input
process(SysClk)
begin
    if rising_edge(SysClk) then
		if SysReset = '1' then
			intSerialMemoryClock <= '0';
		elsif SerialMemoryClockEnable = '1' then
			intSerialMemoryClock <= not intSerialMemoryClock; -- after 50 ps;
		end if;
	end if;
end process;

SerialMemoryClk <= intSerialMemoryClock when WriteFlag='1' or ReadFlag='1' else '0';
SerialMemoryClockFallingEdge <= '1' when SerialMemoryClockEnable='1' and intSerialMemoryClock='1' and SlowEnable='1' else '0';

-- WR_FLAG is set when a write command is given and reset when the command is finished
process(H1_CLK)
begin
	if rising_edge(H1_CLK) then
		if OperationFaultFlagInput = '1' or FLAG_CLR = '1' OR SysReset = '1' then
			WriteLatch <= '0';
		elsif SerialMemXfaceWrite = '1' then
			WriteLatch <= intDATA(15);
		end if;
	end if;
end process;

process(SysClk)
begin
	if rising_edge(SysClk) then
		if OperationFaultFlagInput = '1' or FLAG_CLR = '1' OR SysReset = '1' then
			WriteFlag <= '0';
		elsif SerialMemoryClockFallingEdge = '1' then
			WriteFlag <= WriteLatch;
		end if;
	end if;
end process;

-- RD_FLAG is set when a read command is given and reset when the data is valid
process(H1_CLK)
begin
	if rising_edge(H1_CLK) then
		if OperationFaultFlagInput = '1' or FLAG_CLR = '1' OR SysReset = '1' then
			ReadLatch <= '0';
		elsif SerialMemXfaceWrite='1' then
			ReadLatch <= intDATA(14);
		end if;
	end if;
end process;

process(SysClk)
begin
	if rising_edge(SysClk) then
		if OperationFaultFlagInput = '1' or FLAG_CLR = '1' OR SysReset = '1' then
			ReadFlag <= '0';
		elsif SerialMemoryClockFallingEdge = '1' then
			ReadFlag <= ReadLatch;
		end if;
	end if;
end process;

process(H1_CLK)
begin
	if rising_edge(H1_CLK) then
		if SerialMemXfaceWrite = '1' then
			intModuleAddress(2 downto 0) <= intDATA(24 downto 22);
			MemoryAddress(5 downto 0) <= intDATA(21 downto 16);
			DataBuffer(7 downto 0) <= intDATA(7 downto 0);
		end if;
	end if;
end process;

--process(H1_CLK)
--begin
--    if rising_edge(H1_CLK) then
--       if SerialMemXfaceWrite='1' then
--          intModuleAddress(2 downto 0) <= intDATA(24 downto 22);
--       end if;
--    end if;
--end process;
--
--process(H1_CLK)
--begin
--    if rising_edge(H1_CLK) then
--       if SerialMemXfaceWrite='1' then
--          DataBuffer(7 downto 0) <= intDATA(7 downto 0);
--       end if;
--    end if;
--end process;

-- ACK is checked and latched on the falling edge of the SCLK
ACK <= not intSerialMemoryDataIn;

-- state machine controlling the serial communications with AT24C01A begins here
-- the SerialMemoryDataControl tristate controls are generated here
process(SysClk)
begin
    if rising_edge(SysClk) then
		if SysReset = '1' then
			StateMachine <= IdleState;
			intEEPROMAccessFlag <= '0';         -- Relinquish control over data line
			intFLAG_CLR <= '0';
			ShiftEnable <= '0';
			LoadMemAddr <= '0';
			LoadWriteData <= '0';
			intSerialMemoryDataControl <= '0';     -- Read the serial data pin
			intEEPROMAccessFlag <= '0';         -- Relinquish control over data line
			StartStopBit <= '1';
			LoadDeviceAddr <= '0';
			SecondPassRead <= '0';              -- Used by the Read operation to loop through the 
			IncOperationFaultCount <= '0';      -- If any operation restarts are required, then increment
		elsif SerialMemXfaceWrite = '1' then
			StateMachine <= IdleState;
       elsif SlowEnable='1' then
          case StateMachine is
             when IdleState => if (ReadFlag='1' or WriteFlag='1') and SerialMemoryMidClockEnable='1' and intSerialMemoryClock='0' then 
                                  StateMachine <= SignalStartState;
                                  intEEPROMAccessFlag <= '1';         -- Force control over data line
                                  intFLAG_CLR <= '0';
                                  IncOperationFaultCount <= '0';      -- If any operation restarts are required, then increment
                                                                      -- fault counter
                               else StateMachine <= IdleState;
                                  intFLAG_CLR <= '0';
                                  -- intSerialMemoryDataControl <= '0';     -- Read the serial data pin
                                  intEEPROMAccessFlag <= '0';         -- Relinquish control over data line
                                  StartStopBit <= '1';
                                  LoadDeviceAddr <= '0';
                                  SecondPassRead <= '0';              -- Used by the Read operation to loop through the 
                                                                      -- state machine multiple times
                               end if;

             when SignalStartState =>
                               intSerialMemoryDataControl <= '1';        -- Write the serial data pin
                               if intSerialMemoryClock='1' and SerialMemoryMidClockEnable='1' then
                                  StartStopBit <= '0';                -- Signal a Start condition
                               elsif SerialMemoryClockFallingEdge='1' then
                                  LoadDeviceAddr <= '1';              -- Load the Device Address into the shift register
                                  StateMachine <= DeviceAddrState;
                               else
                                  StateMachine <= SignalStartState;
                               end if;

             when DeviceAddrState =>
                               LoadDeviceAddr <= '0';
                               if ShiftDone='1' and SerialMemoryClockFallingEdge='1' then
                                  ShiftEnable <= '0';
                                  StateMachine <= CheckDeviceAddrACKState;
                               else
                                  StateMachine <= DeviceAddrState;
                                  ShiftEnable <= '1';                 -- Allow the Device Address to be sent to EEPROM
                               end if;
                      
             when CheckDeviceAddrACKState =>        
                               -- intSerialMemoryDataControl <= '0';        -- Read the serial data pin
                               if SerialMemoryClockFallingEdge='1' and ACK='1' then 
                                  if SecondPassRead='1' then
                                     StateMachine <= ReadState;
                                  else
                                     StateMachine <= MemAddrState;
                                     ShiftEnable <= '1';              -- Allow the Memory Address to be sent to EEPROM
                                     LoadMemAddr <= '1';              -- Load the Memory Address into the shift register
                                  end if;
                               elsif
                                  SerialMemoryClockFallingEdge='1' and ACK='0' then
                                  IncOperationFaultCount <= '1';
                                  StateMachine <= IdleState;          -- Start the entire operation over
                               else
                                  StateMachine <= CheckDeviceAddrACKState;
                               end if;

             when MemAddrState =>          
                               intSerialMemoryDataControl <= '1';        -- Write the serial data pin
                               LoadMemAddr <= '0';
                               if ShiftDone='1' and SerialMemoryClockFallingEdge='1' then 
                                  StateMachine <= CheckMemoryAddrACKState;
                                  ShiftEnable <= '0';
                               else 
                                  StateMachine <= MemAddrState;
                                  ShiftEnable <= '1';                 -- Allow the Memory Address to be sent to EEPROM
                               end if;

             when CheckMemoryAddrACKState =>        
                               -- intSerialMemoryDataControl <= '0';        -- Read the serial data pin
                               if SerialMemoryClockFallingEdge='1' and ACK='1' then 
                                  StateMachine <= OperationTypeState;
                               elsif
                                  SerialMemoryClockFallingEdge='1' and ACK='0' then
                                  IncOperationFaultCount <= '1';
                                  StateMachine <= IdleState;          -- Start the complete operation over
                                  LoadMemAddr <= '1';
                                  ShiftEnable <= '1';
                               else
                                  StateMachine <= CheckMemoryAddrACKState;
                               end if;

             when OperationTypeState =>
                               intSerialMemoryDataControl <= '1';        -- Write the serial data pin
                               if WriteFlag='1' then                  -- Do WRITE function
                                  LoadWriteData <= '1';               -- Load the data to write to the EEPROM
                                  StateMachine <= WriteState;         -- ADDR sent OK, now send DATA
                               else                                   -- Do READ function
                                  StateMachine <= SignalStartState;   -- Go to the READ function
                                  StartStopBit <= '1';
                                  SecondPassRead <= '1';
                               end if; 

-- Start of Write function
             when WriteState => 
                               LoadWriteData <= '0';                  -- Load the data to write to the EEPROM
                               ShiftEnable <= '1';                    -- Allow the Data to be sent to the EEPROM

                               if ShiftDone='1' and SerialMemoryClockFallingEdge='1' then 
                                  StateMachine <= WriteAckState;      -- WriteAckState verifies ACK and sends STOP 
                               else 
                                  StateMachine <= WriteState;         -- Stay here until the sequence is written
                                  intSerialMemoryDataControl <= '1';
                               end if;

             when WriteACKState => 
                               -- intSerialMemoryDataControl <= '0';        -- Read the serial data pin
                               ShiftEnable <= '0';
                               if SerialMemoryClockFallingEdge='1' and ACK='1' then 
                                  StateMachine <= StopState;
                               elsif SerialMemoryClockFallingEdge='1' and ACK='0' then
                                  IncOperationFaultCount <= '0';
                                  StateMachine <= IdleState;          -- Failed write, restart operation
                               end if;

-- Start of Read function
             when ReadState => ShiftEnable <= '1';                    -- Allow the counter to clock
                               intSerialMemoryDataControl <= '0';        -- Read the serial data pin
                               if ShiftDone='1' and SerialMemoryClockFallingEdge='1' then
                                  StateMachine <= ReadNoACKState; 
                               else 
                                  StateMachine <= ReadState;
                               end if;

             when ReadNoACKState => 
                               intSerialMemoryDataControl <= '1';        -- Write to the serial data pin
                               ShiftEnable <= '0';
                               StartStopBit <= '1';                   -- Ouput a 1
                               if SerialMemoryClockFallingEdge='1' then 
                                  StateMachine <= StopState;
                                  StartStopBit <= '0';                -- Reset the bit
                               else
                                  StateMachine <= ReadNoACKState;
                               end if;

             when StopState => 
                               intSerialMemoryDataControl <= '1';
                               if intSerialMemoryClock='1' and SerialMemoryMidClockEnable='1' then
                                  StartStopBit <= '1';               -- Signal a Stop condition
                               elsif SerialMemoryClockFallingEdge='1' then
                                  StateMachine <= ClearState;
                               else
                                  StateMachine <= StopState;
                               end if;

             when ClearState => 
                               intFLAG_CLR <= '1';
                               StateMachine <= IdleState;

             when others =>    StateMachine <= IdleState;
          end case;
       end if;
    end if;
end process;

-- Supporting logic for state machine


process(SysClk)
begin
	if rising_edge(SysClk) then
		if SysReset = '1' then
			FLAG_CLR_LAT <= '0';
		else
			FLAG_CLR_LAT <= intFLAG_CLR;
		end if;
	end if;
end process;

FLAG_CLR <= '1' when FLAG_CLR_LAT='1' and intFLAG_CLR='0' else '0';


-- The following logic feeds the SerialDataOutput shift register
-- The SecondPassRead Variable is used to signal a read operation
-- It will be low for writes and the first part of a read operation
SerialDataOutputMux <= (DeviceAddress & SecondPassRead) when LoadDeviceAddr='1' else
                        (DataBuffer) when LoadWriteData='1' else
                        ("00" & MemoryAddress) when LoadMemAddr='1' else
                        SerialDataOutput(6 downto 0) & '0'; 

process(SysClk)
begin
    if rising_edge(SysClk) then
       if SerialMemoryClockFallingEdge='1' or 
          ((LoadMemAddr='1' or LoadDeviceAddr='1' or LoadWriteData='1') and SlowEnable='1') then
          SerialDataOutput <= SerialDataOutputMux;
       end if;
    end if;
end process;

intSerialMemoryDataOut <= StartStopBit or (SerialDataOutput(7) and ShiftEnable); 

SerialDataInputEnable <= '1' when SerialMemoryClockFallingEdge='1' and StateMachine=ReadState else '0';

process(SysClk)
begin
    if rising_edge(SysClk) then
       if SerialDataInputEnable='1' then
          SerialDataInput(7 downto 0) <= SerialDataInput(6 downto 0) & intSerialMemoryDataIn;      -- Capture the input data
       end if;
    end if;
end process;

-- The following counter determines how many bits of data have been shifted out
-- and determines the terminal count condition
process(SysClk)
begin
	if rising_edge(SysClk) then
		if SysReset = '1' then
			SerialDataCounter <= "000";
		elsif SerialMemoryClockFallingEdge='1' then
			if ShiftEnable='0' then
				SerialDataCounter <= "000";
			else
				SerialDataCounter <= SerialDataCounter + 1;
			end if;
		end if;
	end if;
end process;

ShiftDone <= '1' when SerialDataCounter="111" else '0';

-- This piece of logic keeps track of the number of NO ACK's that are received for any given operation
-- After 2 failed operations, the Operation Failed flag is set for the CPU. A write from the CPU 
-- clears the counter and the flag.

process(SysClk) 
begin
    if rising_edge(SysClk) then
		 if SerialMemXfaceWrite='1' OR SysReset = '1' then
			 OperationFaultCount <= "00";
       elsif SlowEnable='1' and IncOperationFaultCount='1' then
          OperationFaultCount <= OperationFaultCount + 1;
       end if;
    end if;
end process;

intOperationFaultFlagInput <= '1' when OperationFaultCount > "01" or OperationFaultFlag='1' else '0';

process(SysClk)
begin
    if rising_edge(SysClk) then
       OperationFaultFlagInput <= intOperationFaultFlagInput;
    end if;
end process;

process(SysClk)
begin
    if rising_edge(SysClk) then
		 if SerialMemXfaceWrite='1' OR SysReset = '1' then
			 OperationFaultFlag <= '0';
       elsif SlowEnable='1' then
          OperationFaultFlag <= OperationFaultFlagInput;
       end if;
    end if;
end process;

end SerialMemoryInterface_arch;
