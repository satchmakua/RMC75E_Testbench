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

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tb_ExpModuleLED is
end tb_ExpModuleLED;

architecture tb of tb_ExpModuleLED is
    signal Reset : std_logic;
    signal H1_CLKWR, SysClk, SlowEnable, SynchedTick : std_logic;
    signal intDATA : std_logic_vector (31 downto 0);
    signal Exp0LEDWrite, Exp0LED0Write, Exp0LED1Write, Exp0LEDRead, Exp0LED0Read, Exp0LED1Read : std_logic;
    signal Exp1LEDWrite, Exp1LED0Write, Exp1LED1Write, Exp1LEDRead, Exp1LED0Read, Exp1LED1Read : std_logic;
    signal Exp2LEDWrite, Exp2LED0Write, Exp2LED1Write, Exp2LEDRead, Exp2LED0Read, Exp2LED1Read : std_logic;
    signal Exp3LEDWrite, Exp3LED0Write, Exp3LED1Write, Exp3LEDRead, Exp3LED0Read, Exp3LED1Read : std_logic;
    signal EEPROMAccessFlag, DiscoveryComplete : std_logic;
    signal ExpOldAP2 : std_logic_vector (3 downto 0);
    signal expLedDataOut : std_logic_vector(3 downto 0);
    signal ExpLEDOE, ExpLEDLatch, ExpLEDClk : std_logic;
    signal ExpLEDData : std_logic_vector (3 downto 0);
    signal ExpLEDSelect : std_logic_vector (3 downto 0);
	
begin
    DUT: entity work.ExpModuleLED
        port map (
            Reset => Reset,
            H1_CLKWR => H1_CLKWR,
            SysClk => SysClk,
            SlowEnable => SlowEnable,
            SynchedTick => SynchedTick,
            intDATA => intDATA,
            expLedDataOut => expLedDataOut,
            Exp0LEDWrite => Exp0LEDWrite,
            Exp0LED0Write => Exp0LED0Write,
            Exp0LED1Write => Exp0LED1Write,
            Exp0LEDRead => Exp0LEDRead,
            Exp0LED0Read => Exp0LED0Read,
            Exp0LED1Read => Exp0LED1Read,
            Exp1LEDWrite => Exp1LEDWrite,
            Exp1LED0Write => Exp1LED0Write,
            Exp1LED1Write => Exp1LED1Write,
            Exp1LEDRead => Exp1LEDRead,
            Exp1LED0Read => Exp1LED0Read,
            Exp1LED1Read => Exp1LED1Read,
            Exp2LEDWrite => Exp2LEDWrite,
            Exp2LED0Write => Exp2LED0Write,
            Exp2LED1Write => Exp2LED1Write,
            Exp2LEDRead => Exp2LEDRead,
            Exp2LED0Read => Exp2LED0Read,
            Exp2LED1Read => Exp2LED1Read,
            Exp3LEDWrite => Exp3LEDWrite,
            Exp3LED0Write => Exp3LED0Write,
            Exp3LED1Write => Exp3LED1Write,
			Exp3LEDRead => Exp3LEDRead,
            Exp3LED0Read => Exp3LED0Read,
            Exp3LED1Read => Exp3LED1Read,
            EEPROMAccessFlag => EEPROMAccessFlag,
            DiscoveryComplete => DiscoveryComplete,
            ExpOldAP2 => ExpOldAP2,
            ExpLEDOE => ExpLEDOE,
            ExpLEDLatch => ExpLEDLatch,
            ExpLEDClk => ExpLEDClk,
            ExpLEDData => ExpLEDData,
            ExpLEDSelect => ExpLEDSelect
        );

    stimulus: process
    begin
        -- Initialize signals
        Reset <= '1'; H1_CLKWR <= '0'; SysClk <= '0'; SlowEnable <= '0'; SynchedTick <= '0';
        intDATA <= (others => '0');
        Exp0LEDWrite <= '0'; Exp0LED0Write <= '0'; Exp0LED1Write <= '0'; Exp0LEDRead <= '0'; Exp0LED0Read <= '0'; Exp0LED1Read <= '0';
        Exp1LEDWrite <= '0'; Exp1LED0Write <= '0'; Exp1LED1Write <= '0'; Exp1LEDRead <= '0'; Exp1LED0Read <= '0'; Exp1LED1Read <= '0';
        Exp2LEDWrite <= '0'; Exp2LED0Write <= '0'; Exp2LED1Write <= '0'; Exp2LEDRead <= '0'; Exp2LED0Read <= '0'; Exp2LED1Read <= '0';
        Exp3LEDWrite <= '0'; Exp3LED0Write <= '0'; Exp3LED1Write <= '0'; Exp3LEDRead <= '0'; Exp3LED0Read <= '0'; Exp3LED1Read <= '0';
        EEPROMAccessFlag <= '0'; DiscoveryComplete <= '0'; ExpOldAP2 <= (others => '0');
        ExpLEDOE <= '0'; ExpLEDLatch <= '0'; ExpLEDClk <= '0'; ExpLEDData <= (others => '0'); ExpLEDSelect <= (others => '0');
        wait for 100 ns;
        
        -- Write your tb sequence here
        
        -- An example of a tb sequence might look like this:
        -- Reset <= '0';
        -- wait for 100 ns;
        -- Exp0LEDWrite <= '1';
        -- Exp0LED0Write <= '1';
        -- Exp0LED1Write <= '1';
        -- wait for 100 ns;
        -- Assert that the outputs are as expected
        -- wait;
    end process stimulus;
end architecture tb;

