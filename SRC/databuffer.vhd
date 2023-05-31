--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		DataBuffer
--	File			dataBuffer.vhd
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
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity DataBuffer is
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
end DataBuffer;

architecture DataBuffer_arch of DataBuffer is

	component RAM128x16 is
		port (
			clk	: in std_logic;
			we	: in std_logic;
			a	: in std_logic_vector(6 downto 0);
			d	: in std_logic_vector(15 downto 0);
			o	: out std_logic_vector(15 downto 0)
		);
	end component;

--	component blk_mem_128x16 IS
--		port (
--			clka	: IN STD_LOGIC;
--			wea		: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
--			addra	: IN STD_LOGIC_VECTOR(6 DOWNTO 0);
--			dina	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--			douta	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
--		);
--	end component;

	signal	BankSelect,
			WriteEnable,
			WriteBank0,
			WriteBank1				: std_logic;	-- := '0';
	signal	DetectRead,
			DecrementReadPointer	: std_logic;	-- := '0';
	signal	ReadPointer,
			WritePointer			: std_logic_vector (2 downto 0);	-- := "000";
	signal	ReadEnableEncode		: std_logic_vector (9 downto 0);	-- := "0000000000";
	signal	ModuleSelect			: std_logic_vector (3 downto 0);	-- := X"0";

	signal	AddrBank1,
			AddrBank0		: std_logic_vector (6 downto 0);	-- := "0000000";
	signal	RAMAddr0,
			RAMAddr1		: std_logic_vector (6 downto 0);	-- := "0000000";
	signal	DataOut0,
			DataOut1		: std_logic_vector (15 downto 0);	-- := X"0000";

	signal	LatchWrite,
			WriteDone		: std_logic;	-- := '0';

begin

	RAMAddr0(6 downto 0) <= (AddrBank0(6 downto 0));
	RAMAddr1(6 downto 0) <= (AddrBank1(6 downto 0));

	RAM_1 : RAM128x16
		port map (
			clk	=> SysClk,
			we	=> WriteBank0,
			a	=> RAMAddr0(6 downto 0),
			d	=> S2P_Data(15 downto 0),
			o	=> DataOut0(15 downto 0)
		);

	RAM_2 : RAM128x16
		port map (
			clk	=> SysClk,
			we	=> WriteBank1,
			a	=> RAMAddr1(6 downto 0),
			d	=> S2P_Data(15 downto 0),
			o	=> DataOut1(15 downto 0)
		);

	-- Note that Bit 15 is inverted to create a signed value of the A2D conversions
	-- Refer to the ADS8320 data sheet for more information regarding this
	DataOut(15 downto 0) <=	not DataOut0(15) & DataOut0(14 downto 0) when BankSelect = '1' else 
							not DataOut1(15) & DataOut1(14 downto 0); 

	-- The fflop BankSelect will toggle each time I get a "SynchedTick" input 
	-- if BankSelect is '0' then A2D data goes to buffer 0 and 
	-- processor read come from buffer 1 and vice versa.
	process (SysClk)
	begin
		if rising_edge(SysClk) then
			if SynchedTick='1' then
				BankSelect <= not BankSelect;
			end if;
		end if;
	end process;

	-- Generate the write pulses to the BUFFERS
	-- StateMachine & Serial2Parallel will be writing to these
	WriteBank0 <= '1' when BankSelect = '0' and WriteEnable = '1' else '0';
	WriteBank1 <= '1' when BankSelect = '1' and WriteEnable = '1' else '0';

	process (SysClk)
	begin
		if rising_edge(SysClk) then
			if SynchedTick = '1' then
				LatchWrite <= '0';
			else
				LatchWrite <= WriteConversion or (LatchWrite and not WriteDone);
			end if;

			if LatchWrite = '0' then
				WriteEnable <= '0';
			elsif LatchWrite = '1' then
				WriteEnable <= not WriteEnable;
			end if;

			if SynchedTick = '1' then
				S2P_Addr(3 downto 0) <= X"0";
			elsif WriteEnable = '1' then
				S2P_Addr(3 downto 0) <= S2P_Addr(3 downto 0) + 1;
			end if;

			if SynchedTick = '1' then
				WritePointer <= "000";
			elsif WriteDone = '1' then
				WritePointer <= WritePointer + 1;
			end if;

		end if;
	end process;
	
	WriteDone <= '1' when S2P_Addr(3 downto 0) = X"9" and WriteEnable = '1' else '0';

	-- generate the ADDRESSES for the buffer during a read
	-- decoding for AddrBank0
	process (BankSelect, ModuleSelect, S2P_Addr, WritePointer, ReadPointer)
	begin
		if BankSelect = '0' then
			AddrBank0(6 downto 0) <= S2P_Addr(3 downto 0) & WritePointer(2 downto 0);
			AddrBank1(6 downto 0) <= ModuleSelect(3 downto 0) & ReadPointer(2 downto 0);
		else
			AddrBank0(6 downto 0) <= ModuleSelect(3 downto 0) & ReadPointer(2 downto 0);
			AddrBank1(6 downto 0) <= S2P_Addr(3 downto 0) & WritePointer(2 downto 0);
		end if;
	end process;

	process (H1_CLKWR)
	begin
		if rising_edge(H1_CLKWR) then
			if DecrementReadPointer = '1' then
				DetectRead <= '0';
			elsif ReadEnableEncode(9 downto 0) /= "0000000000" then
				DetectRead <= '1';
			end if;
			
			-- generate the ADDRESSES for the buffer during a read
			if SynchedTick60 = '1' then
				ReadPointer <= "111";
			elsif DecrementReadPointer = '1' then
				ReadPointer <= ReadPointer - 1;
			end if;
		end if;
	end process;

	DecrementReadPointer <= '1' when DetectRead = '1' and ReadEnableEncode(9 downto 0) = "0000000000" else '0';

	ReadEnableEncode(9 downto 0) <=	ExpA3ReadCh1 & ExpA3ReadCh0 & 
									ExpA2ReadCh1 & ExpA2ReadCh0 & 
									ExpA1ReadCh1 & ExpA1ReadCh0 & 
									ExpA0ReadCh1 & ExpA0ReadCh0 & 
									AnlgPositionRead1 & AnlgPositionRead0;

	process(ReadEnableEncode(9 downto 0))
	begin
		case ReadEnableEncode(9 downto 0) is
			when "0000000001" => ModuleSelect(3 downto 0) <= X"0";
			when "0000000010" => ModuleSelect(3 downto 0) <= X"1";
			when "0000000100" => ModuleSelect(3 downto 0) <= X"2";
			when "0000001000" => ModuleSelect(3 downto 0) <= X"3";
			when "0000010000" => ModuleSelect(3 downto 0) <= X"4";
			when "0000100000" => ModuleSelect(3 downto 0) <= X"5";
			when "0001000000" => ModuleSelect(3 downto 0) <= X"6";
			when "0010000000" => ModuleSelect(3 downto 0) <= X"7";
			when "0100000000" => ModuleSelect(3 downto 0) <= X"8";
			when "1000000000" => ModuleSelect(3 downto 0) <= X"9";
			when others => ModuleSelect(3 downto 0) <= X"0";
		end case;
	end process;

end DataBuffer_arch;
