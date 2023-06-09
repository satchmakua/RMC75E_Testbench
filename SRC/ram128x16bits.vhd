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

	-- Creates a 128x16 (128 words x 16 bits per word) synchronous write synchronous read, single-port RAM.

	-- The RAM128x16 module is a component of the source code for the RMC75E modular motion controller.
	-- It serves as a 128x16-bit random access memory (RAM) module, capable
	-- of storing and retrieving data based on provided address and control signals.

	-- Components:

	-- Inputs:
	-- clk: The clock signal used for synchronous operations.
	-- we: The write enable signal that controls write operations.
	-- a: The address input signal used to specify the memory location to access.
	-- d: The data input signal containing the 16-bit data to be written into the specified memory location.

	-- Outputs:
	-- o: The data output signal that provides the 16-bit data read from the specified memory location.

	-- Architecture:

	-- The architecture of the RAM128x16 module, named RAM128x16_arch, consists of the following components:

	-- ram_type: This is a defined type representing an array of 128 elements,
	-- where each element is a 16-bit std_logic_vector. It serves as the main storage for the RAM module.

	-- RAM: A signal of type ram_type, representing the actual memory storage.
	-- It is an array with 128 elements, each capable of storing a 16-bit value.

	-- read_a: A signal of type std_logic_vector(6 downto 0), used to hold the current address input for read operations.

	-- The behavior of the RAM128x16 module is defined within a process block sensitive to the clk signal.
	-- The process handles both write and read operations based on the rising edge of the clock signal.

	-- During a rising edge of the clock, the module checks if we (write enable) is asserted.
	-- If so, the module writes the 16-bit data d into the memory location specified by the address a.

	-- The read_a signal is continuously updated with the current address a to ensure the correct
	-- data is read from the RAM during subsequent clock cycles.

	-- Finally, the output signal o is assigned the value stored in the
	-- RAM at the memory location specified by read_a, providing the requested 16-bit data output.

	-- The RAM128x16 module provides a reliable and efficient means of storing
	-- and retrieving data within the RMC75E modular motion controller,
	-- making it an integral component for various motion control operations.

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