--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_MDTSSIRoute
--	File			tb_MDTSSIRoute.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- The MDTSSIRoute module describes the interface and behavior of the routing module
	-- for the Magnetostrictive Displacement Transducer (MDT) and Synchronous Serial Interface
	-- (SSI) clocks in the RMC75E modular motion controller.
	-- The module takes input signals related to the SSI select, internal MDT clock,
	-- SSI clock, and MDT interrupt, and provides output signals for the internal clocks of Axis0 and Axis1.
	-- The purpose of the MDTSSIRoute module is to control the routing of clock
	-- signals for the MDT and SSI based on the SSI select signal.
	-- It selects either the MDT internal clock or the SSI clock
	-- for each axis based on the value of the SSI select signal.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_MDTSSIRoute is
end tb_MDTSSIRoute;

architecture tb of tb_MDTSSIRoute is
    signal SSISelect         : std_logic_vector (1 downto 0);
    signal M_AX0_INT_CLK     : std_logic;
    signal M_AX1_INT_CLK     : std_logic;
    signal M_AX0_SSI_CLK     : std_logic;
    signal M_AX1_SSI_CLK     : std_logic;
    signal M_AX0_MDT_INT     : std_logic; 
    signal M_AX1_MDT_INT     : std_logic;
begin
    DUT: entity work.MDTSSIRoute
    port map (
        SSISelect       => SSISelect,
        M_AX0_INT_CLK   => M_AX0_INT_CLK,
        M_AX1_INT_CLK   => M_AX1_INT_CLK,
        M_AX0_SSI_CLK   => M_AX0_SSI_CLK,
        M_AX1_SSI_CLK   => M_AX1_SSI_CLK,
        M_AX0_MDT_INT   => M_AX0_MDT_INT,
        M_AX1_MDT_INT   => M_AX1_MDT_INT
    );

    -- Test sequence
    process
    begin
        -- Initialize signals
        SSISelect <= "00";
        M_AX0_SSI_CLK <= '0';
        M_AX1_SSI_CLK <= '0';
        M_AX0_MDT_INT <= '1';
        M_AX1_MDT_INT <= '1';
        wait for 10 ns;

        -- Change SSISelect
        SSISelect <= "01";
        wait for 10 ns;
        
        -- Change SSISelect
        SSISelect <= "10";
        wait for 10 ns;

        -- Change SSISelect
        SSISelect <= "11";
        wait for 10 ns;

        -- End test sequence
        wait;
    end process;

end tb;
