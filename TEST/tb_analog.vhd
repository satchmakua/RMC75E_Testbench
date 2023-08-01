--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_analog
--	File					tb_analog.vhd
--
--------------------------------------------------------------------------------
--
--	Description:
 
--	DUT:
	-- The DUT is the analog component of the RMC75E source code.
	-- It represents a digital circuit that performs analog data processing.
	-- The DUT has several input and output ports, including control signals,
	-- clock signals, data signals, and various read and write signals.
	-- It includes internal components such as "StateMachine," "Serial2Parallel,"
	-- and "DataBuffer" to handle different functionalities of the ADC processing.

--
--
--	Revision: 1.1
--
--	File history:
--		Rev 1.1 : 06/13/2023 :	Fixed some erroneous signal declarations
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_analog is
end tb_analog;

architecture tb of tb_analog is

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

		component DataBuffer is
			port (
				H1_CLKWR			: in std_logic;
				SysClk				: in std_logic;
				SynchedTick			: in std_logic;
				SynchedTick60		: in std_logic;
				AnlgPositionRead0	: in std_logic;
				AnlgPositionRead1	: in std_logic;
				ExpA0ReadCh0		: in std_logic;
				ExpA0ReadCh1		: in std_logic;
				ExpA1ReadCh0		: in std_logic;
				ExpA1ReadCh1		: in std_logic;
				ExpA2ReadCh0		: in std_logic;
				ExpA2ReadCh1		: in std_logic;
				ExpA3ReadCh0		: in std_logic;
				ExpA3ReadCh1		: in std_logic;
				WriteConversion		: in std_logic;
				S2P_Addr			: inout std_logic_vector (3 downto 0);
				S2P_Data			: in std_logic_vector (15 downto 0);
				DataOut				: out std_logic_vector (15 downto 0)
			);
		end component;
	
    -- Clock period definitions
    constant H1_CLK_period : time := 16.6667 ns;
    constant SysClk_period : time := 33.3333 ns;

    -- Initialize all signals
    signal SysReset            : std_logic := '1';
    signal H1_CLKWR            : std_logic := '0';
    signal SysClk              : std_logic := '0';
    signal SlowEnable          : std_logic := '0';
    signal SynchedTick         : std_logic := '0';
    signal SynchedTick60       : std_logic := '0';
    signal LoopTime            : std_logic_vector (2 downto 0) := (others => '0');
    signal AnlgDATA            : std_logic_vector (31 downto 0) := (others => '0');
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
    signal ExpA_CS_L           : std_logic := '0';
    signal ExpA_CLK            : std_logic := '0';
    signal CtrlAxisData        : std_logic_vector (1 downto 0) := (others => '0');
    signal ExpA_DATA           : std_logic_vector (7 downto 0) := (others => '0');
		
		begin
    DUT: Analog port map(
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

    -- Clock process definitions
    H1_CLKWR_process : process
    begin
        H1_CLKWR <= '0';
        wait for H1_CLK_period/2;
        H1_CLKWR <= '1';
        wait for H1_CLK_period/2;
    end process;

    SysClk_process : process
    begin
        SysClk <= '0';
        wait for SysClk_period/2;
        SysClk <= '1';
        wait for SysClk_period/2;
    end process;

    -- SlowEnable signal process definition
    SlowEnable_process : process
    begin
        SlowEnable <= '0';
        wait for 7 * SysClk_period;
        SlowEnable <= '1';
        wait for SysClk_period;
    end process;

    -- System initialization
    system_init: process
    begin
        wait for 1 us;
        SysReset <= '0';
        wait for 1 us;
				
        SynchedTick60 <= '1';
        SynchedTick <= '1';
        wait for SysClk_period/2;
        SynchedTick60 <= '0';
        wait for SysClk_period/2;
        SynchedTick <= '0';
				
        wait for 125 us;

        SynchedTick60 <= '1';
        SynchedTick <= '1';
        wait for SysClk_period/2;
        SynchedTick60 <= '0';
        wait for SysClk_period/2;
        SynchedTick <= '0';
				
				AnlgPositionRead0 <= '1';
				for i in 0 to 7 loop
						wait until falling_edge(ExpA_CLK);
						wait for 2 ns;
						ExpA_DATA(i) <= '1';
				end loop;
				AnlgPositionRead0 <= '0';
				
				AnlgPositionRead1 <= '1';
				for i in 0 to 7 loop
						wait until falling_edge(ExpA_CLK);
						wait for 2 ns;
						ExpA_DATA(i) <= '1';
				end loop;
				AnlgPositionRead1 <= '0';
				
				wait for 5 us;
				
        ExpA1ReadCh0 <= '1';
        wait for 5 us;
        ExpA1ReadCh0 <= '0';

        ExpA1ReadCh1 <= '1';
        wait for 5 us;
        ExpA1ReadCh1 <= '0';

        wait for 1000 us;

    end process system_init;
end tb;






