library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Analog is
	port (
		H1_CLK: in std_logic;
		SysClk: in std_logic;
		Enable: in std_logic;
		SlowEnable: in std_logic;
		SynchedTick: in std_logic;
		intDATA: inout std_logic_vector (31 downto 0);
		AnlgPositionRead0: in std_logic;
		AnlgPositionRead1: in std_logic;
		ExpA0ReadCh0: in std_logic;
		ExpA0ReadCh1: in std_logic;
		ExpALED0Write0: in std_logic;
		ExpALED1Write0: in std_logic;
		ExpALED0Read0: in std_logic;
		ExpALED1Read0: in std_logic;
		ExpA1ReadCh0: in std_logic;
		ExpA1ReadCh1: in std_logic;
		ExpALED0Write1: in std_logic;
		ExpALED1Write1: in std_logic;
		ExpALED0Read1: in std_logic;
		ExpALED1Read1: in std_logic;
		ExpA2ReadCh0: in std_logic;
		ExpA2ReadCh1: in std_logic;
		ExpALED0Write2: in std_logic;
		ExpALED1Write2: in std_logic;
		ExpALED0Read2: in std_logic;
		ExpALED1Read2: in std_logic;
		ExpA3ReadCh0: in std_logic;
		ExpA3ReadCh1: in std_logic;
		ExpALED0Write3: in std_logic;
		ExpALED1Write3: in std_logic;
		ExpALED0Read3: in std_logic;
		ExpALED1Read3: in std_logic;
		ExpA_CS_L: out std_logic;
		ExpA_CLK: inout std_logic;
		CtrlAxisData : in std_logic_vector (1 downto 0);
		ExpA_DATA : in std_logic_vector (7 downto 0);
		ExpALEDSelect: out std_logic_vector (3 downto 0);
		ExpALEDOE: out std_logic;
		ExpALEDLatch: out std_logic;
		ExpALEDClk: out std_logic;
		ExpALEDData: out std_logic_vector (3 downto 0);
		EEPROMAccessFlag: in std_logic;
		DiscoveryComplete: in std_logic
			 );
end Analog;

architecture Analog_arch of Analog is

-- component declarations
component StateMachine is
	port (
		SysClk: in std_logic;
		SlowEnable: in std_logic;
		SynchedTick: in std_logic;
--		LoopTimeFlag: in std_logic;
		ExpA_CS_L: out std_logic;
		ExpA_CLK: inout std_logic;
		Serial2ParallelEN: out std_logic;
		Serial2ParallelCLR: out std_logic;
		WriteConversion: inout std_logic
		);
end component;

component Serial2Parallel is
	port (
		SysClk: in std_logic;
		SynchedTick: in std_logic;
		CtrlAxisData: in std_logic_vector (1 downto 0);
		ExpA_DATA: in std_logic_vector (7 downto 0);
		Serial2ParallelEN: in std_logic;
		Serial2ParallelCLR: in std_logic;
		S2P_Addr: in std_logic_vector (3 downto 0);
		S2P_Data: out std_logic_vector (15 downto 0)
		);
end component;

component DataBuffer is
	port (
		H1_CLK : in std_logic;
		SysClk : in std_logic;
		SynchedTick : in std_logic;
      AnlgPositionRead0 : in std_logic;
		AnlgPositionRead1 : in std_logic;
		ExpA0ReadCh0 : in std_logic;
      ExpA0ReadCh1 : in std_logic;
      ExpA1ReadCh0 : in std_logic;
      ExpA1ReadCh1 : in std_logic;
      ExpA2ReadCh0 : in std_logic;
      ExpA2ReadCh1 : in std_logic;
      ExpA3ReadCh0 : in std_logic;
      ExpA3ReadCh1 : in std_logic;
		WriteConversion : in std_logic;
		S2P_Addr : inout std_logic_vector (3 downto 0);
		S2P_Data : in std_logic_vector (15 downto 0);
		DataOut : out std_logic_vector (15 downto 0)
		);
end component;

component AP2Led is
	port (
		H1_CLK: in std_logic;
		SysClk: in std_logic;
		Enable: in std_logic;
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
		ExpALEDSelect: out std_logic_vector (3 downto 0)
		);
end component;


-- internal signal declarations
signal Serial2ParallelEN, Serial2ParallelCLR : std_logic := '0';
signal WriteConversion : std_logic := '0';
signal SignExtend, DataOut : std_logic_vector (15 downto 0) := X"0000";
signal S2P_Addr : std_logic_vector (3 downto 0) := X"0";
signal S2P_Data : std_logic_vector ( 15 downto 0) := X"0000";
signal OuputENBank0, OutputENBank1, ReadBufferEN0, ReadBufferEN1 : std_logic := '0';

begin

SignExtend(15 downto 0) <= DataOut(15) & DataOut(15) & DataOut(15) & DataOut(15) &
									DataOut(15) & DataOut(15) & DataOut(15) & DataOut(15) &
									DataOut(15) & DataOut(15) & DataOut(15) & DataOut(15) &
									DataOut(15) & DataOut(15) & DataOut(15) & DataOut(15);

intDATA(31 downto 0) <=	SignExtend(15 downto 0) & DataOut(15 downto 0) when AnlgPositionRead0='1' else 
								SignExtend(15 downto 0) & DataOut(15 downto 0) when AnlgPositionRead1='1' else 
								SignExtend(15 downto 0) & DataOut(15 downto 0) when ExpA0ReadCh0='1' else 
								SignExtend(15 downto 0) & DataOut(15 downto 0) when ExpA0ReadCh1='1' else 
								SignExtend(15 downto 0) & DataOut(15 downto 0) when ExpA1ReadCh0='1' else 
								SignExtend(15 downto 0) & DataOut(15 downto 0) when ExpA1ReadCh1='1' else 
								SignExtend(15 downto 0) & DataOut(15 downto 0) when ExpA2ReadCh0='1' else 
								SignExtend(15 downto 0) & DataOut(15 downto 0) when ExpA2ReadCh1='1' else 
								SignExtend(15 downto 0) & DataOut(15 downto 0) when ExpA3ReadCh0='1' else 
								SignExtend(15 downto 0) & DataOut(15 downto 0) when ExpA3ReadCh1='1' else 
								"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";

U1: StateMachine port map (	SysClk, SlowEnable, SynchedTick, ExpA_CS_L, ExpA_CLK,
										Serial2ParallelEN, Serial2ParallelCLR, WriteConversion);

U2: Serial2Parallel port map (	SysClk, SynchedTick, CtrlAxisData(1 downto 0), ExpA_Data(7 downto 0), Serial2ParallelEN,
							   			Serial2ParallelCLR, S2P_Addr(3 downto 0), S2P_Data(15 downto 0));

U3: DataBuffer port map (	H1_CLK, SysClk, SynchedTick, AnlgPositionRead0, AnlgPositionRead1, 
									ExpA0ReadCh0, ExpA0ReadCh1, ExpA1ReadCh0, ExpA1ReadCh1,
									ExpA2ReadCh0, ExpA2ReadCh1, ExpA3ReadCh0, ExpA3ReadCh1, 
									WriteConversion, S2P_Addr(3 downto 0), S2P_Data(15 downto 0), DataOut(15 downto 0));

U4: AP2Led port map (	H1_CLK, SysClk, Enable, SlowEnable, SynchedTick, intDATA(31 downto 0),
								ExpALED0Write0, ExpALED1Write0, ExpALED0Read0, ExpALED1Read0, 
								ExpALED0Write1, ExpALED1Write1, ExpALED0Read1, ExpALED1Read1, 
								ExpALED0Write2, ExpALED1Write2, ExpALED0Read2, ExpALED1Read2, 
								ExpALED0Write3, ExpALED1Write3, ExpALED0Read3, ExpALED1Read3, 
								EEPROMAccessFlag, DiscoveryComplete,
								ExpALEDOE, ExpALEDLatch, ExpALEDClk, ExpALEDData(3 downto 0), 
								ExpALEDSelect(3 downto 0));

end Analog_arch;