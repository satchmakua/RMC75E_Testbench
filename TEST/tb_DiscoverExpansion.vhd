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
	-- DUT:
	-- The DUT in question is the DiscoverExpansionID component, which is a part of the RMC75E modular motion controller.
	-- The DiscoverExpansionID component is responsible for managing the expansion ID information in the controller.
	-- It receives input signals such as RESET, SysClk, SlowEnable, and Exp_ID_DATA.
	-- It provides output signals ExpansionID0, ExpansionID1, ExpansionID2, ExpansionID3, 
	-- Exp_ID_CLK, Exp_ID_LATCH, and Exp_ID_LOAD. The component operates based on a state
	-- machine that controls the write sequence to the LED driver, allowing for the serial communication of expansion ID data.

	-- Test Bench:
	-- The test bench, tb_DiscoverExpansionID, is designed to verify the functionality of the DiscoverExpansionID
	-- component in the RMC75E modular motion controller. It instantiates the DiscoverExpansionID component and
	-- connects the necessary signals. The test bench includes stimulus generation processes to simulate different
	-- scenarios and test cases. It provides appropriate input stimuli to the DUT and observes its output signals.
	-- The test bench also includes clock generation to provide the required clock signals for the DUT.
	-- By simulating different input scenarios and verifying the DUT's outputs, the test bench ensures
	-- that the DiscoverExpansionID component functions as expected.
	
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
