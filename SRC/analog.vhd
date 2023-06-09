--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		Analog
--	File			analog.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		Top level of analog inputs
--
--	Revision: 1.2
--
--	File history:
--		Rev 1.2 : 02/07/2023 :	Added SysReset and made ExpA_CLK an out
--		Rev 1.1 : 06/10/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Analog is
	port (
		SysReset			: in std_logic;			-- System Reset or PLL not locked
		H1_CLKWR			: in std_logic;
		SysClk				: in std_logic;
		SlowEnable			: in std_logic;
		SynchedTick			: in std_logic;
		SynchedTick60		: in std_logic;
		LoopTime			: in std_logic_vector (2 downto 0);
--		intDATA				: in std_logic_vector (31 downto 0);
		AnlgDATA			: out std_logic_vector (31 downto 0);
		AnlgPositionRead0	: in std_logic;
		AnlgPositionRead1	: in std_logic;
		ExpA0ReadCh0		: in std_logic;
		ExpA0ReadCh1		: in std_logic;
		ExpA1ReadCh0		: in std_logic;
		ExpA1ReadCh1		: in std_logic;
		ExpA2ReadCh0		: in std_logic;
		ExpA2ReadCh1		: in std_logic;
		ExpA3ReadCh0		: in std_logic;
		ExpA3ReadCh1		: in std_logic;
		ExpA_CS_L			: out std_logic;
		ExpA_CLK			: out std_logic;
		CtrlAxisData		: in std_logic_vector (1 downto 0);
		ExpA_DATA			: in std_logic_vector (7 downto 0)
	 );
end Analog;

architecture Analog_arch of Analog is

	component StateMachine is
		port (
			SysReset			: in std_logic;			-- System Reset or PLL not locked
			SysClk				: in std_logic;
			SlowEnable			: in std_logic;
			SynchedTick			: in std_logic;
			LoopTime			: in std_logic_vector (2 downto 0);
			ExpA_CS_L			: out std_logic;
			ExpA_CLK			: out std_logic;
			Serial2ParallelEN	: out std_logic;
			Serial2ParallelCLR	: out std_logic;
			WriteConversion		: out std_logic
		);
	end component;

	component Serial2Parallel is
		port (
			SysClk				: in std_logic;
			SynchedTick			: in std_logic;
			CtrlAxisData		: in std_logic_vector (1 downto 0);
			ExpA_Data			: in std_logic_vector (7 downto 0);
			Serial2ParallelEN	: in std_logic;
			Serial2ParallelCLR	: in std_logic;
			S2P_Addr			: in std_logic_vector (3 downto 0);
			S2P_Data			: out std_logic_vector (15 downto 0)
		);
	end component;

	component DataBuffer is
		port (
			H1_CLKWR			: in std_logic;
			SysClk				: in std_logic;
			SynchedTick			: in std_logic;
			SynchedTick60		: in std_logic;
			AnlgPositionRead0	: in std_logic;
			AnlgPositionRead1	: in std_logic;
			ExpA0ReadCh0		: in std_logic;
			ExpA0ReadCh1		: in std_logic;
			ExpA1ReadCh0		: in std_logic;
			ExpA1ReadCh1		: in std_logic;
			ExpA2ReadCh0		: in std_logic;
			ExpA2ReadCh1		: in std_logic;
			ExpA3ReadCh0		: in std_logic;
			ExpA3ReadCh1		: in std_logic;
			WriteConversion		: in std_logic;
			S2P_Addr			: inout std_logic_vector (3 downto 0);
			S2P_Data			: in std_logic_vector (15 downto 0);
			DataOut				: out std_logic_vector (15 downto 0)
		);
	end component;

	signal	Serial2ParallelEN,
			Serial2ParallelCLR	: std_logic;	-- := '0';
	signal	WriteConversion		: std_logic;	-- := '0';
	signal	SignExtend			: std_logic_vector(31 downto 16);	-- Used to sign extend DataOut value
	signal	DataOut				: std_logic_vector (15 downto 0);	-- := X"0000";
	signal	S2P_Addr			: std_logic_vector (3 downto 0);	-- := X"0";
	signal	S2P_Data			: std_logic_vector ( 15 downto 0);	-- := X"0000";

begin

	ExpA_CS_L <= '0';
    ExpA_CLK <= '0';
	
	SignExtend <=	DataOut(15) & DataOut(15) & DataOut(15) & DataOut(15) &
					DataOut(15) & DataOut(15) & DataOut(15) & DataOut(15) &
					DataOut(15) & DataOut(15) & DataOut(15) & DataOut(15) &
					DataOut(15) & DataOut(15) & DataOut(15) & DataOut(15);

	AnlgDATA <=	SignExtend & DataOut when AnlgPositionRead0 = '1' or AnlgPositionRead1 = '1' or 
								ExpA0ReadCh0 = '1' or ExpA0ReadCh1 = '1' or ExpA1ReadCh0 = '1' or ExpA1ReadCh1 = '1' or
								ExpA2ReadCh0 = '1' or ExpA2ReadCh1 = '1' or ExpA3ReadCh0 = '1' or ExpA3ReadCh1 = '1' else 
				X"0000_0000";

	StateMach_1 : StateMachine
		port map (
			SysReset			=> SysReset,
			SysClk				=> SysClk,
			SlowEnable			=> SlowEnable,
			SynchedTick			=> SynchedTick,
			LoopTime			=> LoopTime(2 downto 0),
			ExpA_CS_L			=> ExpA_CS_L,
			ExpA_CLK			=> ExpA_CLK,
			Serial2ParallelEN	=> Serial2ParallelEN,
			Serial2ParallelCLR	=> Serial2ParallelCLR,
			WriteConversion		=> WriteConversion
		);

	Ser2Par_1 : Serial2Parallel
		port map (
			SysClk				=> SysClk,
			SynchedTick			=> SynchedTick,
			CtrlAxisData		=> CtrlAxisData(1 downto 0),
			ExpA_Data			=> ExpA_Data(7 downto 0),
			Serial2ParallelEN	=> Serial2ParallelEN,
			Serial2ParallelCLR	=> Serial2ParallelCLR,
			S2P_Addr			=> S2P_Addr(3 downto 0),
			S2P_Data			=> S2P_Data(15 downto 0)
		);

	DataBuf_1 : DataBuffer
		port map (
			H1_CLKWR			=> H1_CLKWR,
			SysClk				=> SysClk,
			SynchedTick			=> SynchedTick,
			SynchedTick60		=> SynchedTick60,
			AnlgPositionRead0	=> AnlgPositionRead0,
			AnlgPositionRead1	=> AnlgPositionRead1,
			ExpA0ReadCh0		=> ExpA0ReadCh0,
			ExpA0ReadCh1		=> ExpA0ReadCh1,
			ExpA1ReadCh0		=> ExpA1ReadCh0,
			ExpA1ReadCh1		=> ExpA1ReadCh1,
			ExpA2ReadCh0		=> ExpA2ReadCh0,
			ExpA2ReadCh1		=> ExpA2ReadCh1,
			ExpA3ReadCh0		=> ExpA3ReadCh0,
			ExpA3ReadCh1		=> ExpA3ReadCh1,
			WriteConversion		=> WriteConversion,
			S2P_Addr			=> S2P_Addr(3 downto 0),
			S2P_Data			=> S2P_Data(15 downto 0),
			DataOut				=> DataOut(15 downto 0)
		);

end Analog_arch;