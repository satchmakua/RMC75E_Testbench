--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_DiscoverExpansionID
--	File			tb_DiscoverExpansion.vhd
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

entity tb_DiscoverExpansionID is
end tb_DiscoverExpansionID;

architecture tb of tb_DiscoverExpansionID is
    component DiscoverExpansionID
        Port ( 
            RESET            : in std_logic;
            SysClk           : in std_logic;
            SlowEnable       : in std_logic;
            ExpansionID0     : inout std_logic_vector(16 downto 0);
            ExpansionID1     : inout std_logic_vector(16 downto 0);
            ExpansionID2     : inout std_logic_vector(16 downto 0);
            ExpansionID3     : inout std_logic_vector(16 downto 0);
            Exp_ID_CLK       : out std_logic;
            Exp_ID_DATA      : in std_logic;
            Exp_ID_LATCH     : out std_logic;
            Exp_ID_LOAD      : out std_logic
        );
    end component;

    -- Testbench Signals
    signal tb_RESET, tb_SysClk, tb_SlowEnable, tb_Exp_ID_DATA : std_logic := '0';
    signal tb_ExpansionID0, tb_ExpansionID1, tb_ExpansionID2, tb_ExpansionID3 : std_logic_vector(16 downto 0);
    signal tb_Exp_ID_CLK, tb_Exp_ID_LATCH, tb_Exp_ID_LOAD : std_logic;

begin

    DUT: DiscoverExpansionID
        port map(
            RESET         => tb_RESET,
            SysClk        => tb_SysClk,
            SlowEnable    => tb_SlowEnable,
            ExpansionID0  => tb_ExpansionID0,
            ExpansionID1  => tb_ExpansionID1,
            ExpansionID2  => tb_ExpansionID2,
            ExpansionID3  => tb_ExpansionID3,
            Exp_ID_CLK    => tb_Exp_ID_CLK,
            Exp_ID_DATA   => tb_Exp_ID_DATA,
            Exp_ID_LATCH  => tb_Exp_ID_LATCH,
            Exp_ID_LOAD   => tb_Exp_ID_LOAD
        );

    -- Testbench Process
    stim_proc: process
    begin
        tb_RESET <= '1';
        wait for 100 ns;

        tb_RESET <= '0';
        wait for 100 ns;

        tb_SlowEnable <= '1';
        wait for 100 ns;

        tb_SlowEnable <= '0';
        wait for 100 ns;

        tb_Exp_ID_DATA <= '1';
        wait for 100 ns;

        tb_Exp_ID_DATA <= '0';
        wait for 100 ns;

        tb_SlowEnable <= '1';
        wait for 100 ns;

        tb_SlowEnable <= '0';
        wait for 100 ns;

        tb_RESET <= '1';
        wait for 100 ns;

        tb_RESET <= '0';
        wait for 100 ns;

        tb_Exp_ID_DATA <= '1';
        wait for 100 ns;

        tb_Exp_ID_DATA <= '0';
        wait;

    end process;

    -- Clock Generation
    clk_proc :process
    begin
        tb_SysClk <= '0';
        wait for 10 ns;
        tb_SysClk <= '1';
        wait for 10 ns;
    end process;

end architecture tb;
