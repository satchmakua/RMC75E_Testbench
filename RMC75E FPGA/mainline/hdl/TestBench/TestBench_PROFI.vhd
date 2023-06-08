
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:33:52 02/06/2006
-- Design Name:   profibus
-- Module Name:   TestBench_PROFI.vhd
-- Project Name:  RMC70FPGA150-Unified
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: profibus
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

ENTITY TestBench_PROFI_vhd IS
END TestBench_PROFI_vhd;

ARCHITECTURE behavior OF TestBench_PROFI_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT profibus
	PORT(
		SysClk : IN std_logic;
		SlowEnable : IN std_logic;
		SynchedTick : IN std_logic;
		PROFIAddrRead : IN std_logic;
		PROFIEnable : IN std_logic;
		PROFI_DATA : IN std_logic;          
		intDATA : OUT std_logic_vector(31 downto 0);
		PROFI_CLK : OUT std_logic;
		PROFI_LATCH : OUT std_logic;
		PROFI_LOAD : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL SysClk :  std_logic := '0';
	SIGNAL SlowEnable :  std_logic := '0';
	SIGNAL SynchedTick :  std_logic := '0';
	SIGNAL PROFIAddrRead :  std_logic := '0';
	SIGNAL PROFIEnable :  std_logic := '0';
	SIGNAL PROFI_DATA :  std_logic := '1';

	--Outputs
	SIGNAL intDATA :  std_logic_vector(31 downto 0);
	SIGNAL PROFI_CLK :  std_logic;
	SIGNAL PROFI_LATCH :  std_logic;
	SIGNAL PROFI_LOAD :  std_logic;

	-- Constants
	constant SysClockPeriod : TIME := 33.333 ns;


BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: profibus PORT MAP(
		SysClk => SysClk,
		SlowEnable => SlowEnable,
		intDATA => intDATA,
		SynchedTick => SynchedTick,
		PROFIAddrRead => PROFIAddrRead,
		PROFIEnable => PROFIEnable,
		PROFI_CLK => PROFI_CLK,
		PROFI_DATA => PROFI_DATA,
		PROFI_LATCH => PROFI_LATCH,
		PROFI_LOAD => PROFI_LOAD
	);

	-- set up the input clock
	SysClk <= not SysClk after SysClockPeriod / 2;

	-- set up the Clk Slow Enable signal
	Enable2 : process
	begin
	LE2:	loop 
			wait until SysClk = '1';
			SlowEnable <= '0' after 100 ps;
			wait until SysClk = '1';
			wait until SysClk = '1';
			wait until SysClk = '1';
			wait until SysClk = '1';
			wait until SysClk = '1';
			wait until SysClk = '1';
			wait until SysClk = '1';
			SlowEnable <= '1' after 100 ps;
		end loop LE2;
	end process;

	tb : PROCESS
	BEGIN

		-- Wait 100 ns for global reset to finish
		wait for 100 ns;

		-- Place stimulus here
		PROFIEnable <= '1';
		SynchedTick <= '1';
		wait for 50 ns;
		SynchedTick <= '0';

		wait for 10 us;
		
		SynchedTick <= '1';
		wait for 50 ns;
		SynchedTick <= '0';

		wait for 10 us;

		wait; -- will wait forever
	END PROCESS;

END;
