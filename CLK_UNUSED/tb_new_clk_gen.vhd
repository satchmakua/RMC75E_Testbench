--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		
--	File			
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- Test bench for the drop-in clock_gen module (CLK_GEN_NEW.vhd)
	
--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_Clock_Gen is
end tb_Clock_Gen;

architecture behavior of tb_Clock_Gen is 
    -- Component Declaration for the Unit Under Test (UUT)
    component Clock_Gen
    port(
         CLK1_PAD : in  std_logic;
         PLL_ARST_N : in  std_logic;
         PLL_POWERDOWN_N : in  std_logic;
         GL0 : out std_logic;
         GL1 : out std_logic;
         GL2 : out std_logic;
         LOCK : out std_logic
        );
    end component;

   --Inputs
   signal CLK1_PAD : std_logic := '0';
   signal PLL_ARST_N : std_logic := '0';
   signal PLL_POWERDOWN_N : std_logic := '0';

    --Outputs
   signal GL0 : std_logic;
   signal GL1 : std_logic;
   signal GL2 : std_logic;
   signal LOCK : std_logic;

   -- Clock period definitions
   constant CLK1_PAD_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
   uut: Clock_Gen port map (
          CLK1_PAD => CLK1_PAD,
          PLL_ARST_N => PLL_ARST_N,
          PLL_POWERDOWN_N => PLL_POWERDOWN_N,
          GL0 => GL0,
          GL1 => GL1,
          GL2 => GL2,
          LOCK => LOCK
        );

   -- Clock process definitions
   CLK1_PAD_process :process
   begin
        CLK1_PAD <= '0';
        wait for CLK1_PAD_period/2;
        CLK1_PAD <= '1';
        wait for CLK1_PAD_period/2;
   end process;

   -- Testbench stimulus
   stimulus_process: process
   begin        
      -- Test 1: check default state
      wait for CLK1_PAD_period*2;
      assert LOCK = '0' report "Test 1: Failed - LOCK should be '0' at default state" severity error;
      assert GL0 = '0' report "Test 1: Failed - GL0 should be '0' at default state" severity error;
      assert GL1 = '0' report "Test 1: Failed - GL1 should be '0' at default state" severity error;
      assert GL2 = '0' report "Test 1: Failed - GL2 should be '0' at default state" severity error;

      -- Test 2: check clock generation when not in reset
      PLL_ARST_N <= '0';
      PLL_POWERDOWN_N <= '0';
      wait for CLK1_PAD_period*10;
      assert LOCK = '1' report "Test 2: Failed - LOCK should be '1' when not in reset or powerdown" severity error;
      
      -- Test 3: check clock generation when in reset
      PLL_ARST_N <= '1';
      wait for CLK1_PAD_period*10;
      assert LOCK = '0' report "Test 3: Failed - LOCK should be '0' when in reset" severity error;
      
      -- Test 4: check clock generation when in powerdown
      PLL_ARST_N <= '0';
      PLL_POWERDOWN_N <= '1';
      wait for CLK1_PAD_period*10;
      assert LOCK = '0' report "Test 4: Failed - LOCK should be '0' when in powerdown" severity error;

      -- Test 5: check phase of GL0 and GL1
	  -- We expect GL1 to transition on the falling edge of GL0, representing a 90-degree phase shift
	  PLL_ARST_N <= '0';
	  PLL_POWERDOWN_N <= '0';
	  wait until rising_edge(GL0);
	  wait for CLK1_PAD_period/4;  -- wait half a clock cycle (10ns / 4 = 2.5ns for a 40MHz reference clock)
	  assert (GL1 = '1') report "Test 5: Failed - GL1 should transition on falling edge of GL0" severity error;

      
      wait;
   end process;

end behavior;
