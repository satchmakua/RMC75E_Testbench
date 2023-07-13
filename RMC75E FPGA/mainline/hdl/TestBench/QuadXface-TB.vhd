
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:51:01 02/01/2006
-- Design Name:   QuadXface
-- Module Name:   QuadXface-TB.vhd
-- Project Name:  RMC70FPGA150-Unified
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: QuadXface
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY QuadXface-TB_vhd IS
END QuadXface-TB_vhd;

ARCHITECTURE behavior OF QuadXface-TB_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT QuadXface
	PORT(
		H1_CLKWR : IN std_logic;
		SysClk : IN std_logic;
		SynchedTick : IN std_logic;
		CountRead : IN std_logic;
		LEDStatusRead : IN std_logic;
		LEDStatusWrite : IN std_logic;
		InputRead : IN std_logic;
		HomeRead : IN std_logic;
		Latch0Read : IN std_logic;
		Latch1Read : IN std_logic;
		Home : IN std_logic;
		RegistrationX : IN std_logic;
		RegistrationY : IN std_logic;
		LineFault : IN std_logic_vector(2 downto 0);
		A : IN std_logic;
		B : IN std_logic;
		Z : IN std_logic;       
		intDATA : INOUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	--Inputs
	SIGNAL H1_CLKWR :  std_logic := '0';
	SIGNAL SysClk :  std_logic := '0';
	SIGNAL SynchedTick :  std_logic := '0';
	SIGNAL CountRead :  std_logic := '0';
	SIGNAL LEDStatusRead :  std_logic := '0';
	SIGNAL LEDStatusWrite :  std_logic := '0';
	SIGNAL InputRead :  std_logic := '0';
	SIGNAL HomeRead :  std_logic := '0';
	SIGNAL Latch0Read :  std_logic := '0';
	SIGNAL Latch1Read :  std_logic := '0';
	SIGNAL Home :  std_logic := '0';
	SIGNAL RegistrationX :  std_logic := '0';
	SIGNAL RegistrationY :  std_logic := '0';
	SIGNAL A :  std_logic := '0';
	SIGNAL B :  std_logic := '0';
	SIGNAL Z :  std_logic := '0';
	SIGNAL LineFault :  std_logic_vector(2 downto 0) := (others=>'0');

	--BiDirs
	SIGNAL intDATA :  std_logic_vector(31 downto 0);

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: QuadXface PORT MAP(
		H1_CLKWR => H1_CLKWR,
		SysClk => SysClk,
		SynchedTick => SynchedTick,
		intDATA => intDATA,
		CountRead => CountRead,
		LEDStatusRead => LEDStatusRead,
		LEDStatusWrite => LEDStatusWrite,
		InputRead => InputRead,
		HomeRead => HomeRead,
		Latch0Read => Latch0Read,
		Latch1Read => Latch1Read,
		Home => Home,
		RegistrationX => RegistrationX,
		RegistrationY => RegistrationY,
		LineFault => LineFault,
		A => A,
		B => B,
		Z => Z
	);

	tb : PROCESS
	BEGIN

		-- Wait 100 ns for global reset to finish
		wait for 100 ns;

		-- Place stimulus here

		wait; -- will wait forever
	END PROCESS;

END;
