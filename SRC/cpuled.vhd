--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		CPULED
--	File					cpuled.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		The CPU LED implementation is extremely straightforward.
--		The bits are latched and driven out of the FPGA.
--		If modulation is required, then that can be implemented 
--		in this module as well.
--
--	Revision: 1.2
--
--	File history:
--		Rev 1.2 : 08/31/2022 :	Condensed CPUStatLEDDrive logic.
--		Rev 1.1 : 06/07/2022 :	Updated formatting
--														Changed how RESET is used
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CPULED is
	Port (   
		RESET				: in std_logic;
		H1_CLKWR			: in std_logic;
		intDATA				: in std_logic_vector(31 downto 0);
		cpuLedDataOut		: out std_logic_vector(31 downto 0);
		CPULEDWrite			: in std_logic;
		CPUStatLEDDrive		: out std_logic_vector(1 downto 0)
	);
end CPULED;

architecture CPULED_arch of CPULED is

	signal CPUStatusLED : std_logic_vector (1 downto 0);	-- := "00";

begin

	cpuLedDataOut(31 downto 0) <= X"00000" & "00" & '0' & '0' & "000000" & CPUStatusLED(1 downto 0);

	process(H1_CLKWR, RESET)
	begin
		if RESET then
			CPUStatusLED(1 downto 0) <= "00";
		elsif rising_edge(H1_CLKWR) then
			if CPULEDWrite then
--				CPUStatusLED(0) <= intDATA(0);
--				CPUSTatusLED(1) <= intDATA(1);
				CPUStatusLED <= intDATA(1 downto 0);
			end if;
		end if;
	end process;

	-- State 00 is undefined and will result in a Hi-Z output.
	-- External circuity will force the LED's to turn Red when the FPGA isn't 
	-- driving LED. This is by design.
--	CPUStatLEDDrive(0) <=	'1' when CPUStatusLED(0) = '0' and CPUStatusLED(1) = '1' else
--							'0' when CPUStatusLED(0) = '1' and CPUStatusLED(1) = '0' else
--							'0' when CPUStatusLED(0) = '1' and CPUStatusLED(1) = '1' else
--							'Z';

--	CPUStatLEDDrive(1) <=	'0' when CPUStatusLED(0) = '0' and CPUStatusLED(1) = '1' else
--							'1' when CPUStatusLED(0) = '1' and CPUStatusLED(1) = '0' else
--							'0' when CPUStatusLED(0) = '1' and CPUStatusLED(1) = '1' else 
--							'Z';
	CPUStatLEDDrive <=	"ZZ" when CPUStatusLED = "00" else
						not CPUStatusLED;

end CPULED_arch;

