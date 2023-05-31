--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		Quad
--	File			Quad.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		
--
--	Revision: 1.1
--
--	File history:
--		Rev 1.1 : 06/10/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity Quad is
	Port (
		H1_CLKWR				: in std_logic;
		SysClk					: in std_logic;
		SynchedTick				: in std_logic;
		intDATA					: in std_logic_vector(31 downto 0);
		Exp0QuadDataOut			: out std_logic_vector(31 downto 0);
		Exp1QuadDataOut			: out std_logic_vector(31 downto 0);
		Exp2QuadDataOut			: out std_logic_vector(31 downto 0);
		Exp3QuadDataOut			: out std_logic_vector(31 downto 0);
		QuadA0DataOut			: out std_logic_vector(31 downto 0);
		QuadA1DataOut			: out std_logic_vector(31 downto 0);
--		Exp0Mux					: in std_logic_vector (1 downto 0);
--		Exp1Mux					: in std_logic_vector (1 downto 0);
--		Exp2Mux					: in std_logic_vector (1 downto 0);
--		Exp3Mux					: in std_logic_vector (1 downto 0);
		Exp0QuadCountRead		: in std_logic;
		Exp0QuadLEDStatusRead	: in std_logic;
		Exp0QuadLEDStatusWrite	: in std_logic;
		Exp0QuadInputRead		: in std_logic;
		Exp0QuadHomeRead		: in std_logic;
		Exp0QuadLatch0Read		: in std_logic;
		Exp0QuadLatch1Read		: in std_logic;
		Exp1QuadCountRead		: in std_logic;
		Exp1QuadLEDStatusRead	: in std_logic;
		Exp1QuadLEDStatusWrite	: in std_logic;
		Exp1QuadInputRead		: in std_logic;
		Exp1QuadHomeRead		: in std_logic;
		Exp1QuadLatch0Read		: in std_logic;
		Exp1QuadLatch1Read		: in std_logic;
		Exp2QuadCountRead		: in std_logic;
		Exp2QuadLEDStatusRead	: in std_logic;
		Exp2QuadLEDStatusWrite	: in std_logic;
		Exp2QuadInputRead		: in std_logic;
		Exp2QuadHomeRead		: in std_logic;
		Exp2QuadLatch0Read		: in std_logic;
		Exp2QuadLatch1Read		: in std_logic;
		Exp3QuadCountRead		: in std_logic;
		Exp3QuadLEDStatusRead	: in std_logic;
		Exp3QuadLEDStatusWrite	: in std_logic;
		Exp3QuadInputRead		: in std_logic;
		Exp3QuadHomeRead		: in std_logic;
		Exp3QuadLatch0Read		: in std_logic;
		Exp3QuadLatch1Read		: in std_logic;
		Exp0Quad_A				: in std_logic;
		Exp0Quad_B				: in std_logic;
		Exp0Quad_Reg			: in std_logic;
		Exp0Quad_FaultA			: in std_logic;
		Exp0Quad_FaultB			: in std_logic;
		Exp1Quad_A				: in std_logic;
		Exp1Quad_B				: in std_logic;
		Exp1Quad_Reg			: in std_logic;
		Exp1Quad_FaultA			: in std_logic;
		Exp1Quad_FaultB			: in std_logic;
		Exp2Quad_A				: in std_logic;
		Exp2Quad_B				: in std_logic;
		Exp2Quad_Reg			: in std_logic;
		Exp2Quad_FaultA			: in std_logic;
		Exp2Quad_FaultB			: in std_logic;
		Exp3Quad_A				: in std_logic;
		Exp3Quad_B				: in std_logic;
		Exp3Quad_Reg			: in std_logic;
		Exp3Quad_FaultA			: in std_logic;
		Exp3Quad_FaultB			: in std_logic;

		QA0CountRead			: in std_logic;
		QA0LEDStatusRead		: in std_logic;
		QA0LEDStatusWrite		: in std_logic;
		QA0InputRead			: in std_logic;
		QA0HomeRead				: in std_logic;
		QA0Latch0Read			: in std_logic;
		QA0Latch1Read			: in std_logic;

		QA1CountRead			: in std_logic;
		QA1LEDStatusRead		: in std_logic;
		QA1LEDStatusWrite		: in std_logic;
		QA1InputRead			: in std_logic;
		QA1HomeRead				: in std_logic;
		QA1Latch0Read			: in std_logic;
		QA1Latch1Read			: in std_logic;

		QA0_SigA				: in std_logic;
		QA0_SigB				: in std_logic;
		QA0_SigZ				: in std_logic;
		QA0_Home				: in std_logic;
		QA0_RegX_PosLmt			: in std_logic;
		QA0_RegY_NegLmt			: in std_logic;
		QA1_SigA				: in std_logic;
		QA1_SigB				: in std_logic;
		QA1_SigZ				: in std_logic;
		QA1_Home				: in std_logic;
		QA1_RegX_PosLmt			: in std_logic;
		QA1_RegY_NegLmt			: in std_logic;
		QA0AxisFault			: in std_logic_vector(2 downto 0);
		QA1AxisFault			: in std_logic_vector(2 downto 0)
	);
end Quad;

architecture Quad_arch of Quad is

	component QuadXface is
		Port (
			H1_CLKWR		: in std_logic;
			SysClk			: in std_logic;
			SynchedTick		: in std_logic;
			intDATA			: in std_logic_vector(31 downto 0);
			QuadDataOut		: out std_logic_vector(31 downto 0);
			CountRead		: in std_logic;
			LEDStatusRead	: in std_logic;
			LEDStatusWrite	: in std_logic;
			InputRead		: in std_logic;
			HomeRead		: in std_logic;
			Latch0Read		: in std_logic;
			Latch1Read		: in std_logic;
			Home			: in std_logic;
			RegistrationX	: in std_logic;
			RegistrationY	: in std_logic;
			LineFault		: in std_logic_vector(2 downto 0);
			A				: in std_logic;
			B				: in std_logic;
			Index			: in std_logic
		);
	end component;

--	signal Q1_0_LineFault, Q1_1_LineFault : std_logic_vector (2 downto 0);
--	signal Q1_0_FaultB, Q1_0_FaultA, Q1_1_FaultB, Q1_1_FaultA : std_logic := '0';
--	signal Q1_0_QuadCountRead, Q1_0_QuadLEDStatusRead : std_logic := '0';
--	signal Q1_0_QuadLEDStatusWrite, Q1_0_QuadInputRead : std_logic := '0';
--	signal Q1_0_QuadHomeRead, Q1_0_QuadLatch0Read, Q1_0_QuadLatch1Read : std_logic := '0';
--	signal Q1_1_QuadCountRead, Q1_1_QuadLEDStatusRead : std_logic := '0';
--	signal Q1_1_QuadLEDStatusWrite, Q1_1_QuadInputRead : std_logic := '0';
--	signal Q1_1_QuadHomeRead, Q1_1_QuadLatch0Read, Q1_1_QuadLatch1Read : std_logic := '0';
--	signal Q1_0_A, Q1_0_B, Q1_0_Reg, Q1_1_A, Q1_1_B, Q1_1_Reg : std_logic := '0';
-- 
	signal	Exp0_LineFault,
			Exp1_LineFault,
			Exp2_LineFault,
			Exp3_LineFault		 : std_logic_vector(2 downto 0);


begin

	-- (2 downto 0) corresponds to Z, B, A
	-- Polarity is reversed for the Exp70-Q1's only
	Exp0_LineFault(2 downto 0) <= '0' & not Exp0Quad_FaultB & not Exp0Quad_FaultA;
	Exp1_LineFault(2 downto 0) <= '0' & not Exp1Quad_FaultB & not Exp1Quad_FaultA;
	Exp2_LineFault(2 downto 0) <= '0' & not Exp2Quad_FaultB & not Exp2Quad_FaultA;
	Exp3_LineFault(2 downto 0) <= '0' & not Exp3Quad_FaultB & not Exp3Quad_FaultA;

	QuadXface_1 : QuadXface
		port map (
			H1_CLKWR => H1_CLKWR, 
			SysClk => SysClk,
			SynchedTick => SynchedTick,
			intDATA(31 downto 0) => intDATA(31 downto 0), 
			QuadDataOut(31 downto 0) => Exp0QuadDataOut(31 downto 0), 
			CountRead => Exp0QuadCountRead, 
			LEDStatusRead => Exp0QuadLEDStatusRead, 
			LEDStatusWrite => Exp0QuadLEDStatusWrite, 
			InputRead => Exp0QuadInputRead, 
			HomeRead => Exp0QuadHomeRead, 
			Latch0Read => Exp0QuadLatch0Read, 
			Latch1Read => Exp0QuadLatch1Read, 
			Home => Exp0Quad_Reg, 
			RegistrationX => Exp0Quad_Reg, 
			RegistrationY => '0', 
			LineFault(2 downto 0) => Exp0_LineFault(2 downto 0), 
			A => Exp0Quad_A, 
			B => Exp0Quad_B, 
			Index => '0'
		);

	QuadXface_2 : QuadXface
		port map (
			H1_CLKWR => H1_CLKWR, 
			SysClk => SysClk,
			SynchedTick => SynchedTick,
			intDATA(31 downto 0) => intDATA(31 downto 0), 
			QuadDataOut(31 downto 0) => Exp1QuadDataOut(31 downto 0), 
			CountRead => Exp1QuadCountRead, 
			LEDStatusRead => Exp1QuadLEDStatusRead, 
			LEDStatusWrite => Exp1QuadLEDStatusWrite, 
			InputRead => Exp1QuadInputRead, 
			HomeRead => Exp1QuadHomeRead, 
			Latch0Read => Exp1QuadLatch0Read, 
			Latch1Read => Exp1QuadLatch1Read, 
			Home => Exp1Quad_Reg, 
			RegistrationX => Exp1Quad_Reg, 
			RegistrationY => '0', 
			LineFault(2 downto 0) => Exp1_LineFault(2 downto 0), 
			A => Exp1Quad_A, 
			B => Exp1Quad_B, 
			Index => '0'
		);

	QuadXface_3 : QuadXface
		port map (
			H1_CLKWR => H1_CLKWR, 
			SysClk => SysClk,
			SynchedTick => SynchedTick,
			intDATA(31 downto 0) => intDATA(31 downto 0), 
			QuadDataOut(31 downto 0) => Exp2QuadDataOut(31 downto 0), 
			CountRead => Exp2QuadCountRead, 
			LEDStatusRead => Exp2QuadLEDStatusRead, 
			LEDStatusWrite => Exp2QuadLEDStatusWrite, 
			InputRead => Exp2QuadInputRead, 
			HomeRead => Exp2QuadHomeRead, 
			Latch0Read => Exp2QuadLatch0Read, 
			Latch1Read => Exp2QuadLatch1Read, 
			Home => Exp2Quad_Reg, 
			RegistrationX => Exp2Quad_Reg, 
			RegistrationY => '0', 
			LineFault(2 downto 0) => Exp2_LineFault(2 downto 0), 
			A => Exp2Quad_A, 
			B => Exp2Quad_B, 
			Index => '0'
		);

	QuadXface_4 : QuadXface
		port map (
			H1_CLKWR => H1_CLKWR, 
			SysClk => SysClk, 
			SynchedTick => SynchedTick, 
			intDATA(31 downto 0) => intDATA(31 downto 0), 
			QuadDataOut(31 downto 0) => Exp3QuadDataOut(31 downto 0), 
			CountRead => Exp3QuadCountRead, 
			LEDStatusRead => Exp3QuadLEDStatusRead, 
			LEDStatusWrite => Exp3QuadLEDStatusWrite, 
			InputRead => Exp3QuadInputRead, 
			HomeRead => Exp3QuadHomeRead, 
			Latch0Read => Exp3QuadLatch0Read, 
			Latch1Read => Exp3QuadLatch1Read, 
			Home => Exp3Quad_Reg, 
			RegistrationX => Exp3Quad_Reg, 
			RegistrationY => '0', 
			LineFault(2 downto 0) => Exp3_LineFault(2 downto 0), 
			A => Exp3Quad_A, 
			B => Exp3Quad_B, 
			Index => '0'
		);

	QuadXface_5 : QuadXface
		port map (
			H1_CLKWR => H1_CLKWR, 
			SysClk => SysClk, 
			SynchedTick => SynchedTick,
			intDATA(31 downto 0) => intDATA(31 downto 0),
			QuadDataOut(31 downto 0) => QuadA0DataOut(31 downto 0),
			CountRead => QA0CountRead, 
			LEDStatusRead => QA0LEDStatusRead, 
			LEDStatusWrite => QA0LEDStatusWrite, 
			InputRead => QA0InputRead, 
			HomeRead => QA0HomeRead,
			Latch0Read => QA0Latch0Read,
			Latch1Read => QA0Latch1Read, 
			Home => QA0_Home,
			RegistrationX => QA0_RegX_PosLmt,
			RegistrationY => QA0_RegY_NegLmt,
			LineFault(2 downto 0) => QA0AxisFault(2 downto 0),
			A => QA0_SigA, 
			B => QA0_SigB,
			Index => QA0_SigZ
		);

	QuadXface_6 : QuadXface
		port map (
			H1_CLKWR => H1_CLKWR, 
			SysClk => SysClk, 
			SynchedTick => SynchedTick,
			intDATA(31 downto 0) => intDATA(31 downto 0),
			QuadDataOut(31 downto 0) => QuadA1DataOut(31 downto 0),
			CountRead => QA1CountRead, 
			LEDStatusRead => QA1LEDStatusRead, 
			LEDStatusWrite => QA1LEDStatusWrite, 
			InputRead => QA1InputRead, 
			HomeRead => QA1HomeRead,
			Latch0Read => QA1Latch0Read,
			Latch1Read => QA1Latch1Read, 
			Home => QA1_Home,
			RegistrationX => QA1_RegX_PosLmt,
			RegistrationY => QA1_RegY_NegLmt,
			LineFault(2 downto 0) => QA1AxisFault(2 downto 0),
			A => QA1_SigA, 
			B => QA1_SigB,
			Index => QA1_SigZ
		);

end Quad_arch;