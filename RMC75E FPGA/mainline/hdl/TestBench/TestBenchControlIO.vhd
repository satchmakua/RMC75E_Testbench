
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:25:58 02/01/2006
-- Design Name:   ControlIO
-- Module Name:   TestBenchControlIO.vhd
-- Project Name:  RMC70FPGA150-Unified
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ControlIO
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

ENTITY TestBenchControlIO_vhd IS
END TestBenchControlIO_vhd;

ARCHITECTURE behavior OF TestBenchControlIO_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT ControlIO
	PORT(
		H1_CLK : IN std_logic;
		H1_CLKWR : IN std_logic;
		SysClk : IN std_logic;
		Enable : IN std_logic;
		SlowEnable : IN std_logic;
		SynchedTick : IN std_logic;
		intDATA : INOUT std_logic_vector(31 downto 0);      
		Axis0LEDStatusRead : IN std_logic;
		Axis0LEDConfigWrite : IN std_logic;
		Axis0IORead : IN std_logic;
		Axis0IOWrite : IN std_logic;
		Axis0IOConfigWrite : IN std_logic;
		Axis1LEDStatusRead : IN std_logic;
		Axis1LEDConfigWrite : IN std_logic;
		Axis1IORead : IN std_logic;
		Axis1IOWrite : IN std_logic;
		Axis1IOConfigWrite : IN std_logic;
		M_IO_OE : OUT std_logic;
		M_IO_LOAD : OUT std_logic;
		M_IO_LATCH : OUT std_logic;
		M_IO_CLK : OUT std_logic;
		M_IO_DATAOut : OUT std_logic;
		M_IO_DATAIn : IN std_logic;
		M_ENABLE : OUT std_logic_vector(1 downto 0);
		M_FAULT : IN std_logic_vector(1 downto 0);
		PowerUp : IN std_logic;
		QUADPresent : IN std_logic;    
		QA0AxisFault : OUT std_logic_vector(2 downto 0);
		QA1AxisFault : OUT std_logic_vector(2 downto 0)
		);
	END COMPONENT;

	--Inputs
	SIGNAL H1_CLK :  std_logic := '0';
	SIGNAL H1_CLKWR :  std_logic := '0';
	SIGNAL SysClk :  std_logic := '0';
	SIGNAL Enable :  std_logic := '0';
	SIGNAL SlowEnable :  std_logic := '0';
	SIGNAL SynchedTick :  std_logic := '0';
	SIGNAL Axis0LEDStatusRead :  std_logic := '0';
	SIGNAL Axis0LEDConfigWrite :  std_logic := '0';
	SIGNAL Axis0IORead :  std_logic := '0';
	SIGNAL Axis0IOWrite :  std_logic := '0';
	SIGNAL Axis0IOConfigWrite :  std_logic := '0';
	SIGNAL Axis1LEDStatusRead :  std_logic := '0';
	SIGNAL Axis1LEDConfigWrite :  std_logic := '0';
	SIGNAL Axis1IORead :  std_logic := '0';
	SIGNAL Axis1IOWrite :  std_logic := '0';
	SIGNAL Axis1IOConfigWrite :  std_logic := '0';
	SIGNAL M_IO_DATAIn :  std_logic := '1';
	SIGNAL PowerUp :  std_logic := '0';
	SIGNAL QUADPresent :  std_logic := '1';
	SIGNAL M_FAULT :  std_logic_vector(1 downto 0) := (others=>'0');

	--BiDirs
	SIGNAL intDATA :  std_logic_vector(31 downto 0);

	--Outputs
	SIGNAL M_IO_OE :  std_logic;
	SIGNAL M_IO_LOAD :  std_logic;
	SIGNAL M_IO_LATCH :  std_logic;
	SIGNAL M_IO_CLK :  std_logic;
	SIGNAL M_IO_DATAOut :  std_logic;
	SIGNAL M_ENABLE :  std_logic_vector(1 downto 0);
	SIGNAL QA0AxisFault :  std_logic_vector(2 downto 0);
	SIGNAL QA1AxisFault :  std_logic_vector(2 downto 0);

	-- Constants
	constant H1ClockPeriod : TIME := 16.666 ns;
	constant SysClockPeriod : TIME := 33.333 ns;

BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut: ControlIO PORT MAP(
		H1_CLK => H1_CLK,
		H1_CLKWR => H1_CLKWR,
		SysClk => SysClk,
		Enable => Enable,
		SlowEnable => SlowEnable,
		SynchedTick => SynchedTick,
		intDATA => intDATA,
		Axis0LEDStatusRead => Axis0LEDStatusRead,
		Axis0LEDConfigWrite => Axis0LEDConfigWrite,
		Axis0IORead => Axis0IORead,
		Axis0IOWrite => Axis0IOWrite,
		Axis0IOConfigWrite => Axis0IOConfigWrite,
		Axis1LEDStatusRead => Axis1LEDStatusRead,
		Axis1LEDConfigWrite => Axis1LEDConfigWrite,
		Axis1IORead => Axis1IORead,
		Axis1IOWrite => Axis1IOWrite,
		Axis1IOConfigWrite => Axis1IOConfigWrite,
		M_IO_OE => M_IO_OE,
		M_IO_LOAD => M_IO_LOAD,
		M_IO_LATCH => M_IO_LATCH,
		M_IO_CLK => M_IO_CLK,
		M_IO_DATAOut => M_IO_DATAOut,
		M_IO_DATAIn => M_IO_DATAIn,
		M_ENABLE => M_ENABLE,
		M_FAULT => M_FAULT,
		PowerUp => PowerUp,
		QUADPresent => QUADPresent,
		QA0AxisFault => QA0AxisFault,
		QA1AxisFault => QA1AxisFault
	);

	-- set up the input clock
	H1_CLK <= not H1_CLK after H1ClockPeriod / 2;
	SysClk <= not SysClk after SysClockPeriod / 2;

	-- set up the Clk Enable signal
	Enable1 : process
	begin
	LE1:	loop 
			wait until SysClk = '1';
			Enable <= '0' after 100 ps;
			wait until SysClk = '1';
			wait until SysClk = '1';
			wait until SysClk = '1';
			Enable <= '1' after 100 ps;
		end loop LE1;
	end process;

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
		SynchedTick <= '1';
		wait for 50 ns;
		SynchedTick <= '0';

		wait for 200 ns;

		Axis0LEDConfigWrite <= '1';
		Axis1LEDConfigWrite <= '1';
		wait for 10 ns;
		H1_CLKWR <= '1';
		wait for 50 ns;
		H1_CLKWR <= '0';
		wait for 10 ns;
		Axis0LEDConfigWrite <= '0';
		Axis1LEDConfigWrite <= '0';
		
		wait for 200 ns;
		
		SynchedTick <= '1';
		wait for 50 ns;
		SynchedTick <= '0';

		wait for 5 us;
		
		Axis0LEDConfigWrite <= '1';
		wait for 10 ns;
		H1_CLKWR <= '1';
		wait for 50 ns;
		H1_CLKWR <= '0';
		wait for 10 ns;
		Axis0LEDConfigWrite <= '0';

		wait for 200 ns;
		
		SynchedTick <= '1';
		wait for 50 ns;
		SynchedTick <= '0';

		wait for 5 us;
		
		Axis0LEDConfigWrite <= '1';
		Axis1LEDConfigWrite <= '1';
		wait for 10 ns;
		H1_CLKWR <= '1';
		wait for 50 ns;
		H1_CLKWR <= '0';
		wait for 10 ns;
		Axis0LEDConfigWrite <= '0';
		Axis1LEDConfigWrite <= '0';

		wait for 200 ns;
		
		SynchedTick <= '1';
		wait for 50 ns;
		SynchedTick <= '0';

		wait; -- will wait forever
	END PROCESS;

END;
