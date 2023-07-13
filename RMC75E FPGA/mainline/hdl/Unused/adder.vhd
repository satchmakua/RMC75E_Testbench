-- Adder will essentially average two consecutive readings from the A2D converter
-- There are two channels that are being read simultaneously. These two 16-bit 
-- channels are located in the upper and lower halves of the S2P_Data word.  

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Adder is
	port (
		H1_CLK: in std_logic;
		LoadAddBufferEN: in std_logic;
		AdderEN: in std_logic;
		S2P_Data: in std_logic_vector (31 downto 0);
		AveragedData: out std_logic_vector (31 downto 0)
		);
end Adder;

architecture Adder_arch of Adder is

-- component declarations here

-- all new signals are inserted here
signal AddBuffer0, AddBuffer1: std_logic_vector(15 downto 0) := X"0000";
signal Sum_Latched0, Sum_Latched1: std_logic_vector(31 downto 0) := X"00000000";

begin  -- internal architecture logic description

process (H1_CLK, LoadAddBufferEN)
begin
	if rising_edge(H1_CLK) then
		if LoadAddBufferEN ='1' then
			AveragedData(15 downto 0) <= S2P_Data(15 downto 0);
			AveragedData(31 downto 16) <= S2P_Data(31 downto 16);
--			AddBuffer0(15 downto 0) <= S2P_Data(15 downto 0);
--			AddBuffer1(15 downto 0) <= S2P_Data(31 downto 16);
		end if;
	end if;
end process;

-- Add the counters together. The sequencing and CLK enable is handled by the state machine
process (H1_CLK)
begin
	if	rising_edge(H1_CLK) then
		if AdderEN = '1' then
			Sum_Latched0(16 downto 0) <= ('0' & S2P_Data(15 downto 0)) + ('0' & AddBuffer0(15 downto 0));
			Sum_Latched1(16 downto 0) <= ('0' & S2P_Data(15 downto 0)) + ('0' & AddBuffer1(15 downto 0));
		end if;
	end if;
end process;

-- The data is shifted over by one for the divide by two
-- and the MSB is inverted to be compatible with the previous
-- data formats (12- and 16-bit analog cards). See the data
-- sheet for the ADS8320 A2D converter

--AveragedData(15 downto 0) <= not Sum_Latched0(16) & Sum_Latched0(15 downto 1);
--AveragedData(31 downto 16) <= not Sum_Latched1(16) & Sum_Latched1(15 downto 1);

--AveragedData(15 downto 0) <= Sum_Latched0(16 downto 1);
--AveragedData(31 downto 16) <= Sum_Latched1(16 downto 1);

end Adder_arch;