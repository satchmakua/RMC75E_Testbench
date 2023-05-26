--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		RAM128x16
--	File			ram128x16bits.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		create a 128x16 (128 words x 16 bits per word) synchronous write
--		synchronous read, single-port RAM
--
--	Revision: 1.1
--
--	File history:
--		Rev 1.1 : 05/30/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity RAM128x16 is
	port (
		clk	: in std_logic;
		we	: in std_logic;
		a	: in std_logic_vector(6 downto 0);
		d	: in std_logic_vector(15 downto 0);
		o	: out std_logic_vector(15 downto 0)
	);

end RAM128x16;

architecture RAM128x16_arch of RAM128x16 is

	type ram_type is array (127 downto 0) of std_logic_vector (15 downto 0); 
	signal RAM		: ram_type;	-- := (others => (others => '0')); 
	signal read_a	: std_logic_vector (6 downto 0);	-- := (others => '0');
	
begin 
	process (clk) 
	begin 
		if rising_edge(clk) then  
			if (we = '1') then 
				RAM(conv_integer(a)) <= d; 
			end if;
			read_a <= a; 
		end if; 
	end process; 
	
	o <= RAM(conv_integer(read_a));

end RAM128x16_arch;