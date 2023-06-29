library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_SSITop is
end tb_SSITop;

architecture tb of tb_SSITop is

    -- Clock period definitions
    constant H1_CLK_period : time := 16.6667 ns;
    constant SysClk_period : time := 33.3333 ns;
    constant num_cycles : integer := 100;

    -- Signals declaration for all SSITop inputs and outputs
    signal SysClk_tb : std_logic := '0';
    signal SSI_CLK_tb : std_logic := '1';
    signal PositionRead_tb : std_logic := '0';
    signal SSISelect_tb : std_logic := '0';
    signal StatusRead_tb : std_logic := '0';
    signal SSI_DATA_tb : std_logic := '0';
    signal ParamWrite1_tb : std_logic := '0';
    signal ParamWrite2_tb : std_logic := '0';
    signal Enable_tb : std_logic := '0';
    signal SynchedTick_tb : std_logic := '0';
    signal H1_CLKWR_tb : std_logic := '0';
    signal intData_tb : std_logic_vector(31 downto 0) := (others => '0');
    signal ssiDataOut_tb : std_logic_vector(31 downto 0);
    signal SlowEnable_tb : std_logic := '0'; -- added as it seems to be required by the entity

begin

    uut: entity work.SSITop
    port map (
        SysClk => SysClk_tb,
        SSI_CLK => SSI_CLK_tb,
        PositionRead => PositionRead_tb,
        SSISelect => SSISelect_tb,
        StatusRead => StatusRead_tb,
        SSI_DATA => SSI_DATA_tb,
        ParamWrite1 => ParamWrite1_tb,
        ParamWrite2 => ParamWrite2_tb,
        Enable => Enable_tb,
        SynchedTick => SynchedTick_tb,
        H1_CLKWR => H1_CLKWR_tb,
        intData => intData_tb,
        ssiDataOut => ssiDataOut_tb,
        SlowEnable => SlowEnable_tb 
    );
    
    -- Clock process definitions
    H1_CLKWR_process : process
    begin
        H1_CLKWR_tb <= '0';
        wait for H1_CLK_period/2;
        H1_CLKWR_tb <= '1';
        wait for H1_CLK_period/2;
    end process;

    SysClk_process : process
    begin
        SysClk_tb <= '0';
        wait for SysClk_period/2;
        SysClk_tb <= '1';
        wait for SysClk_period/2;
    end process;

    -- Enable signal process definition
    Enable_process : process
    begin
        Enable_tb <= '0';
        wait for 4 * SysClk_period;
        Enable_tb <= '1';
        wait for 4 * SysClk_period;
    end process;

    -- SlowEnable signal process definition
    SlowEnable_process : process
    begin
        SlowEnable_tb <= '0';
        wait for 8 * SysClk_period;
        SlowEnable_tb <= '1';
        wait for 8 * SysClk_period;
    end process;

    init_gen: process
    begin
        wait for SysClk_period; -- wait for one 30 MHz clock cycle
        ParamWrite1_tb <= '1'; -- start of system configuration
        intData_tb(31 downto 0) <= "00000000000000000000100000000110";
        wait for SysClk_period;
        ParamWrite1_tb <= '0';
        wait for SysClk_period;
        
        ParamWrite2_tb <= '1';
        intData_tb(31 downto 0) <= "00000000000000100000000000000000";
        wait for SysClk_period;
        ParamWrite2_tb <= '0';
        wait for SysClk_period;
        
        SynchedTick_tb <= '1'; -- first tick
        wait for SysClk_period;
        SynchedTick_tb <= '0';
        wait for 1 us - 4 * H1_CLK_PERIOD;
        
        
        
        SSI_DATA_tb <= '1'; -- start of 8us pulse on SSI_DATA_tb
        wait for 8 us;
        wait for H1_CLK_PERIOD;
        SSI_DATA_tb <= '0'; -- end of 8us pulse on SSI_DATA_tb
        wait for 30 us - 1 us - 8 us;
				
				-- Begin SSI Read Cycle
        wait for 1 us;
        SynchedTick_tb <= '1'; -- second tick
        wait for H1_CLK_PERIOD;
				SynchedTick_tb <= '0'; -- second tick
        PositionRead_tb <= '1'; -- PositionRead active after the second SynchedTick
        wait for H1_CLK_PERIOD;
        PositionRead_tb <= '0';
        StatusRead_tb <= '1';
				wait for H1_CLK_PERIOD;
        wait for 30 us - 1 us - 2 * H1_CLK_PERIOD;
        
        -- Run for the desired number of cycles
        for i in 1 to num_cycles loop
            wait for H1_CLK_PERIOD;
        end loop;

        -- Stop the simulation
        wait;
    end process init_gen;
end tb;
