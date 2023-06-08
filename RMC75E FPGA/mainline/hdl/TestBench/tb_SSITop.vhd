--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:11:32 10/09/2009
-- Design Name:   
-- Module Name:   C:/Design/RMC70/RMC70FPGA150-Unified/tb_SSITop.vhd
-- Project Name:  RMC70FPGA150-Unified
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SSITop
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
 
ENTITY tb_SSITop IS
END tb_SSITop;
 
ARCHITECTURE behavior OF tb_SSITop IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SSITop
    PORT(
         H1_CLKWR : IN  std_logic;
         SysClk : IN  std_logic;
         Enable : IN  std_logic;
         SlowEnable : IN  std_logic;
         SynchedTick : IN  std_logic;
         intDATA : INOUT  std_logic_vector(31 downto 0);
         PositionRead : IN  std_logic;
         StatusRead : IN  std_logic;
         DelayRead : IN  std_logic;
         ParamWrite1 : IN  std_logic;
         ParamWrite2 : IN  std_logic;
         SSI_CLK : OUT  std_logic;
         SSI_DATA : IN  std_logic;
         SSISelect : INOUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal H1_CLKWR : std_logic := '0';
   signal SysClk : std_logic := '0';
   signal Enable : std_logic := '0';
   signal SlowEnable : std_logic := '0';
   signal SynchedTick : std_logic := '0';
   signal PositionRead : std_logic := '0';
   signal StatusRead : std_logic := '0';
   signal DelayRead : std_logic := '0';
   signal ParamWrite1 : std_logic := '0';
   signal ParamWrite2 : std_logic := '0';
   signal SSI_DATA : std_logic := '0';

	--BiDirs
   signal intDATA : std_logic_vector(31 downto 0);
   signal SSISelect : std_logic := '1';

 	--Outputs
   signal SSI_CLK : std_logic;

	-- Constants
	constant ClockPeriod : TIME := 16.666 ns;

	-- internal
	signal intEnable, intSlowEnable : std_logic := '0';
	signal EnableCount : std_logic_vector (2 downto 0) := "000";
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SSITop PORT MAP (
          H1_CLKWR => H1_CLKWR,
          SysClk => SysClk,
          Enable => Enable,
          SlowEnable => SlowEnable,
          SynchedTick => SynchedTick,
          intDATA => intDATA,
          PositionRead => PositionRead,
          StatusRead => StatusRead,
          DelayRead => DelayRead,
          ParamWrite1 => ParamWrite1,
          ParamWrite2 => ParamWrite2,
          SSI_CLK => SSI_CLK,
          SSI_DATA => SSI_DATA,
          SSISelect => SSISelect
        );
 
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
	-- set up the input clock
	H1_CLKWR <= not H1_CLKWR after ClockPeriod / 2;
	
	-- Set up the half speed system clock
	sys : process (H1_CLKWR)
	begin
		if rising_edge(H1_CLKWR) then
			SysClk <= not SysClk;
		end if;
	end process;
	
	-- Enable Counter to generate an enable pulse every 8th 30MHz clock cycle
	-- this will be used to clock the logic at 7.5MHz and yield a 3.75MHz output clock enable
	-- for the serial data shifting
	enCount : process (SysClk)
	begin 
		if rising_edge(SysClk) then
			EnableCount <= EnableCount + '1';
		end if;
	end process;

	intEnable <= '1' when EnableCount = "000" or EnableCount = "100" else '0';
	intSlowEnable <= '1' when EnableCount = "000" else '0';

	process (SysClk)
	begin
		if rising_edge(SysClk) then
			Enable <= intEnable after 500 ps;				-- Active every 133.3ns
		end if;
	end process;

	process (SysClk)
	begin
		if rising_edge(SysClk) then
			SlowEnable <= intSlowEnable after 500 ps;		-- Active every 266.6ns
		end if;
	end process;


   -- Stimulus process
   stim_proc: process
	
-- define a read procedure for reading registers from within the FPGA
--	procedure read(address: in std_logic_vector(23 downto 0)) is
--	begin
--		-- reads begin on the falling edge of H1_CLK
--		if falling_edge(H1_CLKWR) then
--			ExtADDR <= address(11 downto 0) after ClockPeriod / 10; -- pick off the address lines of interest
--			DATA <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" after ClockPeriod / 10;
--			STRB_L <= '0' after ClockPeriod / 10;
--			RD_L <= '0' after ClockPeriod / 10;
--			CS_L <= '0' after ClockPeriod / 10;
--		end if;
--	 	wait for ClockPeriod * 3;
--		STRB_L <= '1' after ClockPeriod / 10;
--		RD_L <= '1' after ClockPeriod / 10;
--		CS_L <= '1' after ClockPeriod / 10;
--	end read;


-- define a write procedure for writing registers from within the FPGA
	procedure write(WR_Data: in std_logic_vector(31 downto 0)) is
	begin
		-- writes begin on the falling edge of H1_CLK
		wait for ClockPeriod;
		intDATA <= WR_Data(31 downto 0) after ClockPeriod / 10;
		wait for ClockPeriod * 3;
		paramWrite1 <= '0' after ClockPeriod / 10;
		paramWrite2 <= '0' after ClockPeriod / 10;
	end write;

	
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		paramWrite2 <= '1';
		write(X"000A_0E85");		-- establish a short start delay
		paramWrite1 <= '1';
		write(X"0000_18_06");	-- Axis 1 is SSI std binary, 24 bit data, and 375kHz clock rate
		wait for 100 ns;

-- First Tick
		SynchedTick <= '1';
		wait for 50 ns;
		SynchedTick <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
