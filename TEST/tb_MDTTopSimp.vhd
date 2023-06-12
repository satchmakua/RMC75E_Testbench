--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_MDTTopSimp
--	File			tb_MDTTopSimp.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

-- This module serves as the test bench for the MDTTopSimp module
-- in the RMC75E modular motion controller.
-- It provides a platform to verify the functionality of the MDTTopSimp module
-- by simulating various input scenarios and monitoring the corresponding output signals.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_MDTTopSimp is
end tb_MDTTopSimp;

architecture tb of tb_MDTTopSimp is

component MDTTopSimp_arch
	port(
		H1_CLK : in std_logic;
		H1_CLK90 : in std_logic;
		M_RET_DATA : in std_logic;
		SynchedTick60 : in std_logic;
		intDataValid : in std_logic;
		RisingACountEnablePipe : in std_logic;
		RisingACountDisablePipe : in std_logic;
		LeadingCountDecode : in std_logic_vector(1 downto 0);
		TrailingCountDecode : in std_logic_vector(1 downto 0);
		CountRA : in std_logic_vector(17 downto 0);
		MDTPosition : out std_logic_vector(19 downto 0);
		LeadingCount : out std_logic_vector(1 downto 0);
		TrailingCount : out std_logic_vector(1 downto 0);
		Edge : out std_logic_vector(2 downto 0);
		RisingB : out std_logic_vector(3 downto 1);
		FallingA : out std_logic_vector(3 downto 1);
		FallingB : out std_logic_vector(3 downto 1)
	);
end component;

-- Stimulus signals
signal H1_CLK, H1_CLK90, M_RET_DATA, SynchedTick60, intDataValid, RisingACountEnablePipe, RisingACountDisablePipe : std_logic := '0';
signal LeadingCountDecode, TrailingCountDecode : std_logic_vector(1 downto 0) := (others => '0');
signal CountRA : std_logic_vector(17 downto 0) := (others => '0');

begin

	DUT: MDTTopSimp_arch 
		port map(
			H1_CLK => H1_CLK,
			H1_CLK90 => H1_CLK90,
			M_RET_DATA => M_RET_DATA,
			SynchedTick60 => SynchedTick60,
			intDataValid => intDataValid,
			RisingACountEnablePipe => RisingACountEnablePipe,
			RisingACountDisablePipe => RisingACountDisablePipe,
			LeadingCountDecode => LeadingCountDecode,
			TrailingCountDecode => TrailingCountDecode,
			CountRA => CountRA
		);
	
	-- Stimulus process
	stim_proc: process
	begin
        -- Initialize all signals
        H1_CLK <= '0';
        H1_CLK90 <= '0';
        M_RET_DATA <= '0';
        SynchedTick60 <= '0';
        intDataValid <= '0';
        RisingACountEnablePipe <= '0';
        RisingACountDisablePipe <= '0';
        LeadingCountDecode <= "00";
        TrailingCountDecode <= "00";
        CountRA <= (others => '0');
		wait for 10 ns;
        
        -- Start of test scenarios
        H1_CLK <= '1'; wait for 10 ns; H1_CLK <= '0'; wait for 10 ns; -- Toggle H1_CLK
        H1_CLK90 <= '1'; wait for 10 ns; H1_CLK90 <= '0'; wait for 10 ns; -- Toggle H1_CLK90
        M_RET_DATA <= '1'; wait for 10 ns; -- Set M_RET_DATA
        SynchedTick60 <= '1'; wait for 10 ns; -- Set SynchedTick60
        intDataValid <= '1'; wait for 10 ns; -- Set intDataValid
        RisingACountEnablePipe <= '1'; wait for 10 ns; -- Set RisingACountEnablePipe
        RisingACountDisablePipe <= '1'; wait for 10 ns; -- Set RisingACountDisablePipe
        LeadingCountDecode <= "11"; wait for 10 ns; -- Set LeadingCountDecode
        TrailingCountDecode <= "10"; wait for 10 ns; -- Set TrailingCountDecode
        CountRA <= "111111111111111111"; wait for 10 ns; -- Set CountRA
	end process;

end architecture tb;
