
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:23:24 02/09/2006
-- Design Name:   MDTTopSimp
-- Module Name:   tb_MDTTopSimp.vhd
-- Project Name:  RMC70FPGA150-Unified
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MDTTopSimp
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

ENTITY tb_MDTTopSimp_vhd IS
END tb_MDTTopSimp_vhd;

ARCHITECTURE behavior OF tb_MDTTopSimp_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT MDTTopSimp
	PORT(
		H1_CLK : IN std_logic;
		H1_CLKWR : IN std_logic;
		H1_CLK90 : IN std_logic;
		SynchedTick : IN std_logic;
		PositionRead : IN std_logic;
		StatusRead : IN std_logic;
		ParamWrite : IN std_logic;
		M_RET_DATA : IN std_logic;
		SSISelect : IN std_logic;    
		intDATA : INOUT std_logic_vector(31 downto 0);      
		M_INT_CLK : OUT std_logic;
		SSI_DATA : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL H1_CLK :  std_logic := '0';
	SIGNAL H1_CLKWR :  std_logic := '1';
	SIGNAL H1_CLK90 :  std_logic := '0';
	SIGNAL SynchedTick :  std_logic := '0';
	SIGNAL PositionRead :  std_logic := '0';
	SIGNAL StatusRead :  std_logic := '0';
	SIGNAL ParamWrite :  std_logic := '0';
	SIGNAL M_RET_DATA :  std_logic := '0';
	SIGNAL SSISelect :  std_logic := '0';

	--BiDirs
	SIGNAL intDATA :  std_logic_vector(31 downto 0);

	--Outputs
	SIGNAL M_INT_CLK :  std_logic;
	SIGNAL SSI_DATA :  std_logic;

	-- Constants
	constant ClockPeriod : TIME := 16.666 ns;


BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: MDTTopSimp PORT MAP(
		H1_CLK => H1_CLK,
		H1_CLKWR => H1_CLKWR,
		H1_CLK90 => H1_CLK90,
		SynchedTick => SynchedTick,
		intDATA => intDATA,
		PositionRead => PositionRead,
		StatusRead => StatusRead,
		ParamWrite => ParamWrite,
		M_INT_CLK => M_INT_CLK,
		M_RET_DATA => M_RET_DATA,
		SSI_DATA => SSI_DATA,
		SSISelect => SSISelect
	);

	-- set up the input clock
	H1_CLK <= not H1_CLK after ClockPeriod / 2;

	clk : process
	begin
		wait until H1_CLK = '1';
		wait for ClockPeriod / 4;
		H1_CLK90 <= '1';
		wait until H1_CLK = '0';
		wait for ClockPeriod / 4;
		H1_CLK90 <= '0';
	end process;


	tb : PROCESS
	BEGIN
-- Wait 100 ns for global reset to finish
		wait for 100 ns;

-- First Tick
		SynchedTick <= '1';
		wait for 50 ns;
		SynchedTick <= '0';

-- Test pulse set #1
-- First return pulse
		M_RET_DATA <= '0';
		wait until M_INT_CLK = '1';
		wait for (ClockPeriod * 25) + (ClockPeriod/2);
		wait until H1_CLK = '1';
		wait for (ClockPeriod / 2);
		M_RET_DATA <= '1' after 100 ps;
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_RET_DATA <= '0' after 100 ps;
		
		wait for (ClockPeriod * 889);

-- Second return pulse
		wait until H1_CLK = '1';
		wait for ((3 * ClockPeriod) / 4);
		M_RET_DATA <= '1' after 100 ps;
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_RET_DATA <= '0' after 100 ps;

		wait for 5 us;


-- Second Tick
		SynchedTick <= '1';
		wait for 50 ns;
		SynchedTick <= '0';

-- Test pulse set #2
-- First return pulse
		M_RET_DATA <= '0';
		wait until M_INT_CLK = '1';
		wait for (ClockPeriod * 25) + (ClockPeriod/2);
		wait until H1_CLK = '1';
		wait for (ClockPeriod / 2);
		M_RET_DATA <= '1' after 100 ps;
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_RET_DATA <= '0' after 100 ps;
		
		wait for (ClockPeriod * 889);

-- Second return pulse
		wait until H1_CLK = '1';
		wait for (ClockPeriod / 2);
		M_RET_DATA <= '1' after 100 ps;
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_RET_DATA <= '0' after 100 ps;

		wait for 5 us;
		
-- Third Tick
		SynchedTick <= '1';
		wait for 50 ns;
		SynchedTick <= '0';

-- Test pulse set #3
-- First return pulse
		M_RET_DATA <= '0';
		wait until M_INT_CLK = '1';
		wait for (ClockPeriod * 25) + (ClockPeriod/2);
		wait until H1_CLK = '1';
		wait for (ClockPeriod / 2);
		M_RET_DATA <= '1' after 100 ps;
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_RET_DATA <= '0' after 100 ps;
		
		wait for (ClockPeriod * 889);

-- Second return pulse
		wait until H1_CLK = '1';
		wait for (ClockPeriod / 4);
		M_RET_DATA <= '1' after 100 ps;
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_RET_DATA <= '0' after 100 ps;

		wait for 5 us;
		
-- Fourth Tick
		SynchedTick <= '1';
		wait for 50 ns;
		SynchedTick <= '0';

-- Test pulse set #4
-- First return pulse
		M_RET_DATA <= '0';
		wait until M_INT_CLK = '1';
		wait for (ClockPeriod * 25) + (ClockPeriod/2);
		wait until H1_CLK = '1';
		wait for (ClockPeriod / 2);
		M_RET_DATA <= '1' after 100 ps;
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_RET_DATA <= '0' after 100 ps;
		
		wait for (ClockPeriod * 889);

-- Second return pulse
		wait until H1_CLK = '1';
--		wait for (ClockPeriod / 4);
		M_RET_DATA <= '1' after 100 ps;
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_RET_DATA <= '0' after 100 ps;

		wait for 5 us;

		SynchedTick <= '1';
		wait for 50 ns;
		SynchedTick <= '0';



		wait; -- will wait forever
	END PROCESS;

END;
