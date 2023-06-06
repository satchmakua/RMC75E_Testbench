library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.std_logic_unsigned.all;

library smartfusion2;
use smartfusion2.all;

entity tb_ClockControl_v2 is
end tb_ClockControl_v2;

architecture tb of tb_ClockControl_v2 is
    -- signals for inputs
    signal H1_PRIMARY	: std_logic := '0';
    signal H1_CLKWR	: std_logic := '0';
    signal RESET	: std_logic := '0';
    signal DLL_RST	: std_logic := '0';
    -- signals for outputs
    signal H1_CLK	: std_logic;
    signal H1_CLK90	: std_logic;
    signal SysClk	: std_logic;
    signal DLL_LOCK	: std_logic;
    signal SysRESET	: std_logic;
    signal PowerUp	: std_logic;
    signal Enable	: std_logic;
    signal SlowEnable	: std_logic;
    
    -- clock period declaration
    constant clock_period : time := 16.6667 ns; -- 60 MHz frequency for primary clock and clkwr
    
begin
    -- Instantiate DUT
    DUT: entity work.ClockControl port map(
        H1_PRIMARY => H1_PRIMARY,
        H1_CLKWR => H1_CLKWR,
        RESET => RESET,
        DLL_RST => DLL_RST,
        H1_CLK => H1_CLK,
        H1_CLK90 => H1_CLK90,
        SysClk => SysClk,
        DLL_LOCK => DLL_LOCK,
        SysRESET => SysRESET,
        PowerUp => PowerUp,
        Enable => Enable,
        SlowEnable => SlowEnable
    );
    
    -- Test bench stimulus process
    stim_proc: process
    begin
        -- Test Case 1: Reset scenario
        -- Drive the RESET signal properly
        RESET <= '1';
        wait for clock_period;
        RESET <= '0';
        
        -- Drive the primary clock and clock write signals
        H1_PRIMARY <= '0';
        H1_CLKWR <= '0';
        wait for clock_period;
        H1_PRIMARY <= '1';
        H1_CLKWR <= '1';
        wait for clock_period;
        
        -- Repeat the process
        while TRUE loop
            H1_PRIMARY <= not H1_PRIMARY;
            H1_CLKWR <= not H1_CLKWR;
            wait for clock_period;
        end loop;
    end process;
    
end tb;