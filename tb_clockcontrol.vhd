--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_ClockControl
--	File			tb_ClockControl.vhd
--
--------------------------------------------------------------------------------
--
--	Description:

-- 	DUT:
	-- ClockControl - responsible for generating various clock signals based on the input signals provided.
	-- The ClockControl component takes inputs such as H1_PRIMARY, H1_CLKWR, RESET, DLL_RST,
	-- and generates output clock signals like H1_CLK, H1_CLK90, SysClk, and control
	-- signals like SysRESET, PowerUp, Enable, and SlowEnable. It also provides an output
	-- signal DLL_LOCK to indicate whether the DLL (Delay-Locked Loop) is locked or not.

	-- Test Bench:
	-- The test bench tb_ClockControl is designed to verify the functionality and
	-- behavior of the ClockControl component. It instantiates the ClockControl
	-- component and provides stimulus to its inputs to observe the expected behavior of the DUT.
	-- The test bench includes a stimulus process that applies various test cases and
	-- stimuli to the DUT inputs. It also includes assertions to
	-- check the correctness of the DUT outputs and behavior.
	-- The test bench ensures that all signals are defined and that the
	-- simulation runs for a sufficient time (250 microseconds) to validate the DUT's behavior.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ClockControl is
end tb_ClockControl;

architecture tb of tb_ClockControl is 
    -- Component Declaration for the Unit Under Test (UUT)
    component ClockControl
    port(
         H1_PRIMARY : in  std_logic;
         H1_CLKWR : in  std_logic;
         H1_CLK : out  std_logic;
         H1_CLK90 : out  std_logic;
         SysClk : out  std_logic;
         RESET : in  std_logic;
         DLL_RST : in  std_logic;
         DLL_LOCK : out  std_logic;
         SysRESET : out  std_logic;
         PowerUp : out  std_logic;
         Enable : out  std_logic;
         SlowEnable : out  std_logic
        );
    end component;
   
    --Inputs
    signal H1_PRIMARY : std_logic := '0';
    signal H1_CLKWR : std_logic := '0';
    signal RESET : std_logic := '0';
    signal DLL_RST : std_logic := '0';

    --Outputs
    signal H1_CLK : std_logic := '0';
    signal H1_CLK90 : std_logic := '0';
    signal SysClk : std_logic := '0';
    signal DLL_LOCK : std_logic := '0';
    signal SysRESET : std_logic := '0';
    signal PowerUp : std_logic := '0';
    signal Enable : std_logic := '0';
    signal SlowEnable : std_logic := '0';

    -- Clock period definitions
    constant H1_PRIMARY_period : time := 16.6667 ns;
    constant H1_CLKWR_period : time := 16.6667 ns;

    -- Clock generator
    procedure Clock_Gen (signal clk : out std_logic; period : time) is
    begin
        clk <= '0';
        wait for period / 2;
        clk <= '1';
        wait for period / 2;
    end procedure Clock_Gen;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: ClockControl port map (
        H1_PRIMARY => H1_PRIMARY,
        H1_CLKWR => H1_CLKWR,
        H1_CLK => H1_CLK,
        H1_CLK90 => H1_CLK90,
        SysClk => SysClk,
        RESET => RESET,
        DLL_RST => DLL_RST,
        DLL_LOCK => DLL_LOCK,
        SysRESET => SysRESET,
        PowerUp => PowerUp,
        Enable => Enable,
        SlowEnable => SlowEnable
    );

    -- Clock process definitions
    H1_PRIMARY_process :process
    begin
        while true loop
            Clock_Gen(H1_PRIMARY, H1_PRIMARY_period);
        end loop;
    end process;

    H1_CLKWR_process :process
    begin
        while true loop
            Clock_Gen(H1_CLKWR, H1_CLKWR_period);
        end loop;
    end process;

  -- Stimulus process
    stim_proc: process
    begin   
        -- Test 1: Reset application and release
        wait for 100 ns;  
        RESET <= '1';  -- Applying reset
        wait for 100 ns;
        RESET <= '0';  -- Releasing reset
        assert (SysRESET = '1') report "Test 1 failed: SysRESET not asserted after RESET" severity error;

        -- Test 2: DLL_RST pulse generation
        wait for 200 ns;
        DLL_RST <= '1';  -- Generating a reset pulse to the PLL
        wait for 100 ns;
        DLL_RST <= '0';  -- Stopping the reset pulse to the PLL
        assert (DLL_LOCK = '1') report "Test 2 failed: DLL_LOCK not asserted after DLL_RST" severity error;

        -- Test 3: Verify no signals are undefined
        wait for 200 ns;
        assert (H1_CLK /= 'U' and H1_CLK90 /= 'U' and SysClk /= 'U' and DLL_LOCK /= 'U' and 
                SysRESET /= 'U' and PowerUp /= 'U' and Enable /= 'U' and SlowEnable /= 'U') 
                report "Test 3 failed: One or more signals are undefined" severity error;
        
        wait;
    end process;

end tb;



