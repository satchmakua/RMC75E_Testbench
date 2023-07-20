--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_WDT
--	File			tb_watchdogtimer.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- DUT: WatchDogTimer
	
	-- Test bench creates instances of the necessary clock signals and the DUT.
	-- Stimulus is then applied through a stimulus process, which allows for
	-- different input patterns to be applied to the DUT. 
	
--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_WDT is
end tb_WDT;

architecture tb of tb_WDT is

    -- Clock period definitions
    constant H1_CLK_period : time := 16.6667 ns;
    constant SysClk_period : time := 33.3333 ns;
		
		signal tb_clk: std_logic := '0';
		signal tb_reset: std_logic := '0';
		signal tb_sysreset: std_logic := '0';
		signal tb_h1_clkwr: std_logic := '0';
		signal tb_sysclk: std_logic := '0';
		signal tb_intdata: std_logic_vector(31 downto 0) := (others => '0');
		signal tb_wdtdataout: std_logic_vector(31 downto 0);
		signal tb_fpgaprogdout: std_logic_vector(31 downto 0);
		signal tb_fpgaaccess: std_logic := '0';
		signal tb_wdtconfigwrite: std_logic := '0';
		signal tb_fpgaprogrammedwrite: std_logic := '0';
		signal tb_slowenable: std_logic := '0';
		signal tb_halt_drive_l: std_logic := '0';
		signal tb_wd_tickle: std_logic := '0';
		signal tb_wd_rst_l: std_logic := '1';

		component WDT
		port(
				RESET				: in std_logic;
				SysRESET			: in std_logic;
				H1_CLKWR			: in std_logic;
				SysClk				: in std_logic;
				intDATA				: in std_logic_vector(31 downto 0);
				wdtDataOut			: out std_logic_vector(31 downto 0);
				FPGAProgDOut		: out std_logic_vector(31 downto 0);
				FPGAAccess			: in std_logic;	
				WDTConfigWrite		: in std_logic;
				FPGAProgrammedWrite	: in std_logic;	
				SlowEnable			: in std_logic;
				HALT_DRIVE_L		: in std_logic;		
				WD_TICKLE			: in std_logic;		
				WD_RST_L			: out std_logic		
		);
		end component;

		begin
    UUT: WDT port map(
        RESET => tb_reset,
        SysRESET => tb_sysreset,
        H1_CLKWR => tb_h1_clkwr,
        SysClk => tb_sysclk,
        intDATA => tb_intdata,
        wdtDataOut => tb_wdtdataout,
        FPGAProgDOut => tb_fpgaprogdout,
        FPGAAccess => tb_fpgaaccess,
        WDTConfigWrite => tb_wdtconfigwrite,
        FPGAProgrammedWrite => tb_fpgaprogrammedwrite,
        SlowEnable => tb_slowenable,
        HALT_DRIVE_L => tb_halt_drive_l,
        WD_TICKLE => tb_wd_tickle,
        WD_RST_L => tb_wd_rst_l
    );

    -- Clock process definitions
    H1_CLKWR_process : process
    begin
        tb_H1_CLKWR <= '0';
        wait for H1_CLK_period/2;
        tb_H1_CLKWR <= '1';
        wait for H1_CLK_period/2;
    end process;

    SysClk_process : process
    begin
        tb_SysClk <= '0';
        wait for SysClk_period/2;
        tb_SysClk <= '1';
        wait for SysClk_period/2;
    end process;

    -- SlowEnable signal process definition
    SlowEnable_process : process
    begin
        tb_SlowEnable <= '0';
        wait for 7 * SysClk_period;
        tb_SlowEnable <= '1';
        wait for SysClk_period;
    end process;

    -- Stimulus process
    StimProc: process
    begin
        -- hold reset state for 100 ns.
        tb_reset <= '0';
        tb_sysreset <= '0';
        wait for 100 ns;
        
        tb_reset <= '1';
        tb_sysreset <= '1';
        wait for 100 ns;
        
        tb_reset <= '0';
        tb_sysreset <= '0';
        tb_intdata <= "11111111111111111111111111111111";
        tb_fpgaaccess <= '1';
        tb_wdtconfigwrite <= '1';
        tb_fpgaprogrammedwrite <= '1';
        tb_halt_drive_l <= '1';
        tb_wd_tickle <= '1';
        wait for 100 ns;
        
        -- other test cases goes here
        
        wait;
    end process;

end tb;
