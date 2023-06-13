--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_SSITop
--	File			tb_SSITop.vhd
--
--------------------------------------------------------------------------------
--
--	Description:

	 -- The tb_SSITop entity represents a testbench for the SSITop module in the RMC75E modular motion controller.
	 -- It provides a simulated environment to test the functionality and behavior of
	 -- the SSITop module by generating stimuli and observing the module's responses.
	 -- The testbench instantiates the SSITop component and connects
	 -- the necessary signals to its ports for communication.
	 -- It includes a clock generation process to generate the required clock signals for the module.
	 -- The stimulus process generates various input stimuli by
	 -- toggling different control signals and updating the input data.
	 -- These stimuli simulate different scenarios to verify the behavior and functionality of the SSITop module.
	 -- The testbench is designed to run for a specific duration and can be extended
	 -- with additional tests for exhaustive verification of the module.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_SSITop is
end tb_SSITop;

architecture tb of tb_SSITop is
    -- constants for clock period
    constant H1_CLKWR_PERIOD: time := 16 ns; -- 60MHz
    constant SYS_CLK_PERIOD: time := 33 ns; -- 30MHz
    constant ENABLE_PERIOD: time := 133 ns; -- 7.5MHz
    constant SLOW_ENABLE_PERIOD: time := 266 ns; -- 3.75MHz

    signal H1_CLKWR: std_logic := '0';
    signal SysClk: std_logic := '0';
    signal Enable: std_logic := '0';
    signal SlowEnable: std_logic := '0';
    signal SynchedTick: std_logic := '0';
    signal intDATA: std_logic_vector(31 downto 0);
    signal ssiDataOut: std_logic_vector(31 downto 0);
    signal PositionRead: std_logic := '0';
    signal StatusRead: std_logic := '0';
    signal ParamWrite1: std_logic := '0';
    signal ParamWrite2: std_logic := '0';
    signal SSI_CLK: std_logic;
    signal SSI_DATA: std_logic := '0';
    signal SSISelect: std_logic;

begin
    -- Instance of the SSITop module
    uut: entity work.SSITop
        port map (
            H1_CLKWR => H1_CLKWR,
            SysClk => SysClk,
            Enable => Enable,
            SlowEnable => SlowEnable,
            SynchedTick => SynchedTick,
            intDATA => intDATA,
            ssiDataOut => ssiDataOut,
            PositionRead => PositionRead,
            StatusRead => StatusRead,
            ParamWrite1 => ParamWrite1,
            ParamWrite2 => ParamWrite2,
            SSI_CLK => SSI_CLK,
            SSI_DATA => SSI_DATA,
            SSISelect => SSISelect
        );

    -- Clock generation
    H1_CLKWR <= not H1_CLKWR after H1_CLKWR_PERIOD / 2;
    SysClk <= not SysClk after SYS_CLK_PERIOD / 2;
    Enable <= not Enable after ENABLE_PERIOD / 2;
    SlowEnable <= not SlowEnable after SLOW_ENABLE_PERIOD / 2;
    
    -- Stimulus process
    stimulus: process
    begin
        wait for 100 ns;
        PositionRead <= '1';
        wait for 100 ns;
        PositionRead <= '0';
        wait for 100 ns;
        StatusRead <= '1';
        wait for 100 ns;
        StatusRead <= '0';
        wait for 100 ns;
        ParamWrite1 <= '1';
        intDATA <= (others => '0');
        wait for 100 ns;
        ParamWrite1 <= '0';
        wait for 100 ns;
        ParamWrite2 <= '1';
        intDATA <= (others => '0');
        wait for 100 ns;
        ParamWrite2 <= '0';

        -- Exhaustive tests would continue here for all possible input combinations

        wait; -- Stop the process for simulation
    end process;

end tb;
