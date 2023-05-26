--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_analog_v2
--	File			tb_analog_v2.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

--	SysClk: The system clock signal; toggles between '0' and '1' every 10 ns.

--  SysReset, H1_CLKWR, SlowEnable, SynchedTick, SynchedTick60, AnlgPositionRead0,
--  AnlgPositionRead1, ExpA0ReadCh0, ExpA0ReadCh1, ExpA1ReadCh0, ExpA1ReadCh1, ExpA2ReadCh0,
--  ExpA2ReadCh1, ExpA3ReadCh0, ExpA3ReadCh1:
	
--	All of these signals are set to '0'. Their waveforms
--  will be a flat line at the '0' level. If any of these signals change, it's an indication
--  that the device-under-test (DUT) is modifying them.

--  LoopTime: Set to "000". If it changes, the DUT has modified the loop time.

--  CtrlAxisData: Set to "00". If it changes, the DUT has changed control axis data.

--  ExpA_DATA: Set to "00000000". Changes in this signal mean the DUT has modified expansion data.

-- ExpA_CS_L, ExpA_CLK: These signals are not initialized in the testbench.
-- However, as they are inputs to the DUT, their waveforms can indicate how the DUT responds to changes in these signals.	
--
--	Revision: 2.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_analog_v2 is
end tb_analog_v2;

architecture tb of tb_analog_v2 is 
    component Analog is
        port(
            SysReset            : in std_logic;
            H1_CLKWR            : in std_logic;
            SysClk              : in std_logic;
            SlowEnable          : in std_logic;
            SynchedTick         : in std_logic;
            SynchedTick60       : in std_logic;
            LoopTime            : in std_logic_vector (2 downto 0);
            AnlgDATA            : out std_logic_vector (31 downto 0);
            AnlgPositionRead0   : in std_logic;
            AnlgPositionRead1   : in std_logic;
            ExpA0ReadCh0        : in std_logic;
            ExpA0ReadCh1        : in std_logic;
            ExpA1ReadCh0        : in std_logic;
            ExpA1ReadCh1        : in std_logic;
            ExpA2ReadCh0        : in std_logic;
            ExpA2ReadCh1        : in std_logic;
            ExpA3ReadCh0        : in std_logic;
            ExpA3ReadCh1        : in std_logic;
            ExpA_CS_L           : out std_logic;
            ExpA_CLK            : out std_logic;
            CtrlAxisData        : in std_logic_vector (1 downto 0);
            ExpA_DATA           : in std_logic_vector (7 downto 0)
        );
    end component Analog;

  -- Initialize all signals
    signal SysReset            : std_logic := '0';
    signal H1_CLKWR            : std_logic := '0';
    signal SysClk              : std_logic := '0';
    signal SlowEnable          : std_logic := '0';
    signal SynchedTick         : std_logic := '0';
    signal SynchedTick60       : std_logic := '0';
    signal LoopTime            : std_logic_vector (2 downto 0) := (others => '0');
    signal AnlgDATA            : std_logic_vector (31 downto 0);
    signal AnlgPositionRead0   : std_logic := '0';
    signal AnlgPositionRead1   : std_logic := '0';
    signal ExpA0ReadCh0        : std_logic := '0';
    signal ExpA0ReadCh1        : std_logic := '0';
    signal ExpA1ReadCh0        : std_logic := '0';
    signal ExpA1ReadCh1        : std_logic := '0';
    signal ExpA2ReadCh0        : std_logic := '0';
    signal ExpA2ReadCh1        : std_logic := '0';
    signal ExpA3ReadCh0        : std_logic := '0';
    signal ExpA3ReadCh1        : std_logic := '0';
    signal ExpA_CS_L           : std_logic;
    signal ExpA_CLK            : std_logic;
    signal CtrlAxisData        : std_logic_vector (1 downto 0) := (others => '0');
    signal ExpA_DATA           : std_logic_vector (7 downto 0) := (others => '0');

begin 
    uut: Analog port map(
		SysReset            => SysReset,
        H1_CLKWR            => H1_CLKWR,
        SysClk              => SysClk,
        SlowEnable          => SlowEnable,
        SynchedTick         => SynchedTick,
        SynchedTick60       => SynchedTick60,
        LoopTime            => LoopTime,
        AnlgDATA            => AnlgDATA,
        AnlgPositionRead0   => AnlgPositionRead0,
        AnlgPositionRead1   => AnlgPositionRead1,
        ExpA0ReadCh0        => ExpA0ReadCh0,
        ExpA0ReadCh1        => ExpA0ReadCh1,
        ExpA1ReadCh0        => ExpA1ReadCh0,
        ExpA1ReadCh1        => ExpA1ReadCh1,
        ExpA2ReadCh0        => ExpA2ReadCh0,
        ExpA2ReadCh1        => ExpA2ReadCh1,
        ExpA3ReadCh0        => ExpA3ReadCh0,
        ExpA3ReadCh1        => ExpA3ReadCh1,
        ExpA_CS_L           => ExpA_CS_L,
        ExpA_CLK            => ExpA_CLK,
        CtrlAxisData        => CtrlAxisData,
        ExpA_DATA           => ExpA_DATA
    );

    stimulus: process
    begin  
        -- Reset signal
        SysReset <= '1';
        wait for 10 ns;
        SysReset <= '0';
        wait for 10 ns;

        -- Enable signals
        SlowEnable <= '1';
        SynchedTick <= '1';
        SynchedTick60 <= '1';

        -- Vary LoopTime to create different scenarios
        LoopTime <= "000";
        wait for 100 ns;
        LoopTime <= "001";
        wait for 100 ns;
        LoopTime <= "010";
        wait for 100 ns;
        LoopTime <= "011";
        wait for 100 ns;
        -- Continue for other LoopTime values
        
        wait;
    end process;
end tb;
