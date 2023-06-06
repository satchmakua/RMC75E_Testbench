library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all; -- Required for writing to the console
use std.textio.all; -- Required for writing to the console

library smartfusion2;
use smartfusion2.all;

entity tb_Clock_Gen is
-- This testbench doesn't need any ports as it interacts with the UUT (Unit Under Test) internally
end tb_Clock_Gen;

architecture test of tb_Clock_Gen is
    -- We declare a component of our design under test
    component Clock_Gen
        port(
            CLK1_PAD        : in  std_logic;
            PLL_ARST_N      : in  std_logic;
            PLL_POWERDOWN_N : in  std_logic;
            GL0             : out std_logic;
            GL1             : out std_logic;
            GL2             : out std_logic;
            LOCK            : out std_logic
        );
    end component;

    -- These signals will connect the testbench to the unit under test
    signal CLK1_PAD        : std_logic := '0';
    signal PLL_ARST_N      : std_logic := '0';
    signal PLL_POWERDOWN_N : std_logic := '0';
    signal GL0             : std_logic;
    signal GL1             : std_logic;
    signal GL2             : std_logic;
    signal LOCK            : std_logic;

begin
    -- Here is the instantiation of the unit under test
    UUT: Clock_Gen
    port map(
        CLK1_PAD        => CLK1_PAD,
        PLL_ARST_N      => PLL_ARST_N,
        PLL_POWERDOWN_N => PLL_POWERDOWN_N,
        GL0             => GL0,
        GL1             => GL1,
        GL2             => GL2,
        LOCK            => LOCK
    );

    -- This process applies a sequence of test inputs to the design
    Stimulus_Process : process
    begin
        -- Test Case 1: Default state
        wait for 100 ns;
        assert (LOCK = '0') report "Test Case 1: Lock should be '0' at start" severity error;

        -- Test Case 2: Assert PLL_ARST_N
        PLL_ARST_N <= '1';
        wait for 100 ns;
        assert (LOCK = '0') report "Test Case 2: Lock should be '0' when PLL_ARST_N is asserted" severity error;

        -- Test Case 3: Deassert PLL_ARST_N
        PLL_ARST_N <= '0';
        wait for 100 ns;

        -- Test Case 4: Assert CLK1_PAD
        CLK1_PAD <= '1';
        wait for 100 ns;

        -- Test Case 5: Deassert CLK1_PAD
        CLK1_PAD <= '0';
        wait for 100 ns;

        -- Test Case 6: Assert PLL_POWERDOWN_N
        PLL_POWERDOWN_N <= '1';
        wait for 100 ns;
        assert (LOCK = '0') report "Test Case 6: Lock should be '0' when PLL_POWERDOWN_N is asserted" severity error;

        -- Test Case 7: Deassert PLL_POWERDOWN_N
        PLL_POWERDOWN_N <= '0';
        wait for 100 ns;

        -- Add more test cases as needed

        -- Stop the simulation
        wait;
    end process Stimulus_Process;
end test;
