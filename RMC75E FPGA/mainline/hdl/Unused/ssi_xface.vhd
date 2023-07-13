--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		ssi_xface
--	File			ssi_xface.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		this module uses the SYNC_TIME pulse to enable the CLK's to transfer counter
--		data from the shift register to the parallel in/out holding registers
--		new data is shifted in serially when SHIFT goes active.
--		Incoming data is clocked in on the rising edge of SCLKOUT.
--
--	Revision: 1.1
--
-- File history:
--		Rev 1.1 : 06/02/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ssi_xface is
	port (
		SysClk				: in std_logic;							-- 30MHz system clock
		SynchedTick			: in std_logic;							-- Control loop tick valid on rising edge of 30MHz clock
		GrayCodeSelect		: in std_logic;
		SSIDataLatch		: out std_logic_vector (31 downto 0);
		SSI_DATA			: in std_logic;
		Shift				: in std_logic;
		CheckDataHi			: in std_logic;
		CheckDatalo			: in std_logic;
		DataLineStatusError	: out std_logic
	);
end ssi_xface;


architecture ssi_xface_arch of ssi_xface is

	signal	Serial2ParallelData		: std_logic_vector (31 downto 0);	-- := X"0000_0000";
	signal	MuxDataOut,
			DataLineHi,
			DatalineLo				: std_logic;	-- := '0';
	signal	ClearSSI2ParallelData	: std_logic;	-- := '0';

begin

	-- multiplexor determines whether the data is converted from gray code to binary
	-- or clocked straight in
	process (GrayCodeSelect, SSI_DATA, Serial2ParallelData(0))
	begin
		case GrayCodeSelect is
			when '0' => MuxDataOut <= SSI_DATA;
			when '1' => MuxDataOut <= (Serial2ParallelData(0) xor SSI_DATA);
--			when others => MuxDataOut <= '0';
		end case;
	end process;

	process (SysClk)
	begin
		if rising_edge(SysClk) then
			ClearSSI2ParallelData <= SynchedTick;

			-- shift register to convert incoming data: serial in/parallel out
			if ClearSSI2ParallelData = '1' then
				Serial2ParallelData(31 downto 0) <= X"0000_0000"; 
			elsif Shift='1' then 
				Serial2ParallelData(31 downto 0) <= (Serial2ParallelData(30 downto 0) & MuxDataOut); 
			end if;

			-- holding register parallel in/parallel out
			-- data is transferred from the shift register to the holding register on the 1ms tick
			if SynchedTick='1' then
				SSIDataLatch(31 downto 0) <= Serial2ParallelData(31 downto 0);
			end if;

			-- check and latch the data line status before data transfer
			if CheckDataHi = '1' then
				DataLineHi <= not SSI_DATA;
--			else
--				DataLineHi <= DataLineHi;
			end if;

			-- check and latch the data line status after data transfer
			if CheckDataLo = '1' then
				DataLineLo <= SSI_DATA;
--			else
--				DataLineLo <= DataLineLo;
			end if;
		end if;
	end process;

	DataLineStatusError <= DataLineHi or DataLineLo;

end ssi_xface_arch;
