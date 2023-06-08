
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:53:07 02/01/2006
-- Design Name:   QuadXface
-- Module Name:   TestBend-QX.vhd
-- Project Name:  QuadXface
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

ENTITY TestBenchQXface IS
END TestBenchQXface;

ARCHITECTURE behavior OF TestBenchQXface IS 

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
		Index : IN std_logic;       
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
	SIGNAL Index :  std_logic := '0';
	SIGNAL LineFault :  std_logic_vector(2 downto 0) := (others=>'0');
	SIGNAL Direction : std_logic := '0'; -- 1 is forward, 0 is backward

	--BiDirs
	SIGNAL intDATA :  std_logic_vector(31 downto 0);

	-- Constants
	constant ClockPeriod : TIME := 33.333 ns;
	constant ClockPeriod2x : TIME := 16.6667 ns;
	constant QuadPeriod : TIME := 500 ns;


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
		Index => Index
	);

	-- set up the System clock
	SysClk <= not SysClk after ClockPeriod / 2;
	H1_CLKWR <= not H1_CLKWR after ClockPeriod2x / 2;

	st : process
	begin
		wait until SysClk = '0';
		wait until SysClk = '1';
		SynchedTick <= '1' after 250 ps;
		wait until SysClk = '0';
		wait until SysClk = '1';
		SynchedTick <= '0' after 250 ps;
		wait for 25 us;
	end process;


	tb : PROCESS
	BEGIN

		-- Wait 100 ns for global reset to finish
		wait for 100 ns;

		-- Place stimulus here
		wait for 1 us;

		LEDStatusWrite <= '1';
		-- Set the LearnModeEnable bit(14)
		intDATA <= X"00004000";
		wait for 50 ns;
		LEDStatusWrite <= '0';
		wait until SysClk = '0';
		intDATA <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		
		wait for 1 us;
		
		wait until A='0';
		Index <= '1' after 100 ps;
		wait until A='1';
		wait until A='0';
		Index <= '0' after 100 ps;
		
		wait for 1.5 us;
		RegistrationX <= '1';
		Home <= '1';
		wait for 500 ns;
		wait until A='0';
		Index <= '1' after 100 ps;
		wait until A='1';
		wait until A='0';
		Index <= '0' after 100 ps;
		wait for 500 ns;
		RegistrationX <= '0';
		Home <= '0';
		
		wait for 5 us;
		
--		Direction <= '0';  -- This will generate illegal transitions 
		
--		wait for 1 us;
		
--		Direction <= '1';
		
		wait; -- will wait forever
	END PROCESS;


-- set up the Quadrature inputs
	Quad1 : process
	begin
		wait until SysClk = '1';
		Quad: loop
		if Direction = '1' then
--			Forward:	loop 
					wait for (QuadPeriod / 2);
					A <= '1' after 100 ps;
					wait for (QuadPeriod / 2);
					B <= '1' after 100 ps;
					wait for (QuadPeriod / 2);
					A <= '0' after 100 ps;
					wait for (QuadPeriod / 2);
					B <= '0' after 100 ps;
--				end loop Forward;
		else
--			Reverse: loop
					wait for (QuadPeriod / 2);
					B <= '1' after 100 ps;
					
-- REM out the following line to generate illegal transitions
					wait for (QuadPeriod / 2);

					A <= '1' after 100 ps;
					wait for (QuadPeriod / 2);
					A <= '1' after 100 ps;
					wait for (QuadPeriod / 2);
					B <= '0' after 100 ps;
					wait for (QuadPeriod / 2);
					A <= '0' after 100 ps;
--				end loop Reverse;
		end if;
		end loop Quad;
	end process;



END;
