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

end tb_all_arch;



