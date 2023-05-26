--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_DiscoverControlID
--	File			tb_disccontID.vhd	
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- This testbench provides a clock signal to DiscoverControlID and controls the RESET, SlowEnable and M_Card_ID_DATA signals.
	-- Each sequence represents a state transition in the FSM of DiscoverControlID. After the reset sequence,
	-- the SlowEnable signal is asserted and then random data is fed to the DiscoverControlID module.

	-- We will probably want to feed more complex sequences
	-- of data to the module and check if ControlID is updated as expected.
	
--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_DiscoverControlID is
end tb_DiscoverControlID;

architecture testbench of tb_DiscoverControlID is
    signal RESET, SysClk, SlowEnable, M_Card_ID_DATA : std_logic := '0';
    signal ControlID : std_logic_vector(16 downto 0) := (others => '0');
    signal M_Card_ID_CLK, M_Card_ID_LATCH, M_Card_ID_LOAD : std_logic;

begin

    DUT: entity work.DiscoverControlID
    port map (
        RESET => RESET,
        SysClk => SysClk,
        SlowEnable => SlowEnable,
        ControlID => ControlID,
        M_Card_ID_CLK => M_Card_ID_CLK,
        M_Card_ID_DATA => M_Card_ID_DATA,
        M_Card_ID_LATCH => M_Card_ID_LATCH,
        M_Card_ID_LOAD => M_Card_ID_LOAD
    );

    clk_stimulus: process
    begin
        wait for 10 ns; SysClk <= not SysClk;
    end process;

    process
    begin
        -- Reset sequence
        RESET <= '1';
        wait for 50 ns;
        RESET <= '0';
        wait for 50 ns;
        
        -- Test sequence 1: SlowEnable is 1
        SlowEnable <= '1';
        wait for 100 ns;
        
        -- Test sequence 2: Feed in random data
        M_Card_ID_DATA <= '1';
        wait for 100 ns;
        M_Card_ID_DATA <= '0';
        wait for 100 ns;
        M_Card_ID_DATA <= '1';
        wait for 100 ns;
        M_Card_ID_DATA <= '1';
        wait for 100 ns;
        
        -- Test sequence 3: SlowEnable is 0
        SlowEnable <= '0';
        wait for 100 ns;

        -- End of testbench
        assert false report "End of testbench" severity note;
        wait;
    end process;
end testbench;

