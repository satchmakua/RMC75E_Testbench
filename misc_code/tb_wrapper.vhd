-------------------------------------------------------------------------------
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

entity tb_all is
end tb_all;

architecture tb_all_arch of tb_all is

architecture tb_all_arch of tb_all is

    -- Initialize all signals for tb_analog
    signal tb_analog_SysReset_in            : std_logic := '0';
    signal tb_analog_H1_CLKWR_in            : std_logic := '0';
    signal tb_analog_SysClk_in              : std_logic := '0';
    signal tb_analog_SlowEnable_in          : std_logic := '0';
    signal tb_analog_SynchedTick_in         : std_logic := '0';
    signal tb_analog_SynchedTick60_in       : std_logic := '0';
    signal tb_analog_LoopTime_in            : std_logic_vector (2 downto 0) := (others => '0');
    signal tb_analog_AnlgDATA_out           : std_logic_vector (31 downto 0);
    signal tb_analog_AnlgPositionRead0_in   : std_logic := '0';
    signal tb_analog_AnlgPositionRead1_in   : std_logic := '0';
    signal tb_analog_ExpA0ReadCh0_in        : std_logic := '0';
    signal tb_analog_ExpA0ReadCh1_in        : std_logic := '0';
    signal tb_analog_ExpA1ReadCh0_in        : std_logic := '0';
    signal tb_analog_ExpA1ReadCh1_in        : std_logic := '0';
    signal tb_analog_ExpA2ReadCh0_in        : std_logic := '0';
    signal tb_analog_ExpA2ReadCh1_in        : std_logic := '0';
    signal tb_analog_ExpA3ReadCh0_in        : std_logic := '0';
    signal tb_analog_ExpA3ReadCh1_in        : std_logic := '0';
    signal tb_analog_ExpA_CS_L_out          : std_logic := '0';
    signal tb_analog_ExpA_CLK_out           : std_logic := '0';
    signal tb_analog_CtrlAxisData_in        : std_logic_vector (1 downto 0) := (others => '0');
    signal tb_analog_ExpA_DATA_in           : std_logic_vector (7 downto 0) := (others => '0');
	
begin
    -- tb_CPUconfig: entity work.tb_CPUconfig
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_DIO8: entity work.tb_DIO8
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_DataBuffer: entity work.tb_DataBuffer
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_DiscoverExpansion: entity work.tb_DiscoverExpansion
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_ExpModuleLED: entity work.tb_ExpModuleLED
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_ExpSigRoute: entity work.tb_ExpSigRoute
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_FCCC: entity work.tb_FCCC
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_MDTTopSimp: entity work.tb_MDTTopSimp
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_QuadXFace: entity work.tb_QuadXFace
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_RtdExpIDLED: entity work.tb_RtdExpIDLED
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_SSITop: entity work.tb_SSITop
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_Serial2Parallel: entity work.tb_Serial2Parallel
    -- port map(
        -- -- Map your signals here
    -- );

    tb_analog: entity work.tb_analog
    port map(
        SysReset            => tb_analog_SysReset_in,
        H1_CLKWR            => tb_analog_H1_CLKWR_in,
        SysClk              => tb_analog_SysClk_in,
        SlowEnable          => tb_analog_SlowEnable_in,
        SynchedTick         => tb_analog_SynchedTick_in,
        SynchedTick60       => tb_analog_SynchedTick60_in,
        LoopTime            => tb_analog_LoopTime_in,
        AnlgDATA            => tb_analog_AnlgDATA_out,
        AnlgPositionRead0   => tb_analog_AnlgPositionRead0_in,
        AnlgPositionRead1   => tb_analog_AnlgPositionRead1_in,
        ExpA0ReadCh0        => tb_analog_ExpA0ReadCh0_in,
        ExpA0ReadCh1        => tb_analog_ExpA0ReadCh1_in,
        ExpA1ReadCh0        => tb_analog_ExpA1ReadCh0_in,
        ExpA1ReadCh1        => tb_analog_ExpA1ReadCh1_in,
        ExpA2ReadCh0        => tb_analog_ExpA2ReadCh0_in,
        ExpA2ReadCh1        => tb_analog_ExpA2ReadCh1_in,
        ExpA3ReadCh0        => tb_analog_ExpA3ReadCh0_in,
        ExpA3ReadCh1        => tb_analog_ExpA3ReadCh1_in,
        ExpA_CS_L           => tb_analog_ExpA_CS_L_out,
        ExpA_CLK            => tb_analog_ExpA_CLK_out,
        CtrlAxisData        => tb_analog_CtrlAxisData_in,
        ExpA_DATA           => tb_analog_ExpA_DATA_in
    );
	
    -- tb_clockcontrol: entity work.tb_clockcontrol
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_clockgen: entity work.tb_clockgen
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_controlio: entity work.tb_controlio
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_controloutput: entity work.tb_controloutput
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_cpuled: entity work.tb_cpuled
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_decode: entity work.tb_decode
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_disccontID: entity work.tb_disccontID
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_discovercontrol: entity work.tb_discovercontrol
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_latencyCounter: entity work.tb_latencyCounter
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_mdssiroute: entity work.tb_mdssiroute
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_quad: entity work.tb_quad
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_ram128x16bits: entity work.tb_ram128x16bits
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_serial_mem: entity work.tb_serial_mem
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_statemachine: entity work.tb_statemachine
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_ticksync: entity work.tb_ticksync
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_top: entity work.tb_top
    -- port map(
        -- -- Map your signals here
    -- );

    -- tb_watchdogtimer: entity work.tb_watchdogtimer
    -- port map(
        -- -- Map your signals here
    -- );

end tb_all_arch;
