--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_ControlIO
--	File			tb_ControlIO.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

--	Test bench for the module that governs Control Board IO and LED Interface.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity tb_ControlIO is
end tb_ControlIO;

architecture tb of tb_ControlIO is
    -- Declare component of the ControlIO
    component ControlIO
    port (
        RESET                   : in std_logic;
        H1_CLKWR                : in std_logic;
        SysClk                  : in std_logic;
        Enable                  : in std_logic;
        SynchedTick             : in std_logic;
        intDATA                 : in std_logic_vector (31 downto 0);
        controlIoDataOut        : out std_logic_vector (31 downto 0);
        Axis0LEDStatusRead      : in std_logic;
        Axis0LEDConfigWrite     : in std_logic;
        Axis0IORead             : in std_logic;
        Axis0IOWrite            : in std_logic;
        Axis1LEDStatusRead      : in std_logic;
        Axis1LEDConfigWrite     : in std_logic;
        Axis1IORead             : in std_logic;
        Axis1IOWrite            : in std_logic;
        M_IO_OE                 : out std_logic;
        M_IO_LOAD               : out std_logic;
        M_IO_LATCH              : out std_logic;
        M_IO_CLK                : out std_logic;
        M_IO_DATAOut            : out std_logic;
        M_IO_DATAIn             : in std_logic;
        M_ENABLE                : out std_logic_vector (1 downto 0);
        M_FAULT                 : in std_logic_vector (1 downto 0);
        PowerUp                 : in std_logic;
        QUADPresent             : in std_logic;
        QA0AxisFault            : out std_logic_vector (2 downto 0);
        QA1AxisFault            : out std_logic_vector (2 downto 0)
    );
    end component;

    -- Declare test signals
    signal RESET                  : std_logic := '0';
    signal H1_CLKWR               : std_logic := '0';
    signal SysClk                 : std_logic := '0';
    signal Enable                 : std_logic := '0';
    signal SynchedTick            : std_logic := '0';
    signal intDATA                : std_logic_vector (31 downto 0);
    signal controlIoDataOut       : std_logic_vector (31 downto 0);
    signal Axis0LEDStatusRead     : std_logic := '0';
    signal Axis0LEDConfigWrite    : std_logic := '0';
    signal Axis0IORead            : std_logic := '0';
    signal Axis0IOWrite           : std_logic := '0';
    signal Axis1LEDStatusRead     : std_logic := '0';
    signal Axis1LEDConfigWrite    : std_logic := '0';
    signal Axis1IORead            : std_logic := '0';
    signal Axis1IOWrite           : std_logic := '0';
    signal M_IO_OE                : std_logic := '0';
    signal M_IO_LOAD              : std_logic := '0';
    signal M_IO_LATCH             : std_logic := '0';
    signal M_IO_CLK               : std_logic := '0';
    signal M_IO_DATAOut           : std_logic := '0';
    signal M_IO_DATAIn            : std_logic := '0';
    signal M_ENABLE               : std_logic_vector (1 downto 0);
    signal M_FAULT                : std_logic_vector (1 downto 0);
    signal PowerUp                : std_logic := '0';
    signal QUADPresent            : std_logic := '0';
    signal QA0AxisFault           : std_logic_vector (2 downto 0);
	signal QA1AxisFault           : std_logic_vector (2 downto 0);
begin
    -- Instantiate ControlIO with test signals
    UUT: ControlIO
    port map (
        RESET                => RESET,
        H1_CLKWR             => H1_CLKWR,
        SysClk               => SysClk,
        Enable               => Enable,
        SynchedTick          => SynchedTick,
        intDATA              => intDATA,
        controlIoDataOut     => controlIoDataOut,
        Axis0LEDStatusRead   => Axis0LEDStatusRead,
        Axis0LEDConfigWrite  => Axis0LEDConfigWrite,
        Axis0IORead          => Axis0IORead,
        Axis0IOWrite         => Axis0IOWrite,
        Axis1LEDStatusRead   => Axis1LEDStatusRead,
        Axis1LEDConfigWrite  => Axis1LEDConfigWrite,
        Axis1IORead          => Axis1IORead,
        Axis1IOWrite         => Axis1IOWrite,
        M_IO_OE              => M_IO_OE,
        M_IO_LOAD            => M_IO_LOAD,
        M_IO_LATCH           => M_IO_LATCH,
        M_IO_CLK             => M_IO_CLK,
        M_IO_DATAOut         => M_IO_DATAOut,
        M_IO_DATAIn          => M_IO_DATAIn,
        M_ENABLE             => M_ENABLE,
        M_FAULT              => M_FAULT,
        PowerUp              => PowerUp,
        QUADPresent          => QUADPresent,
        QA0AxisFault         => QA0AxisFault,
        QA1AxisFault         => QA1AxisFault
    );

	-- Test process
    test: process
    begin
        -- Reset the system
        RESET <= '1';
        wait for 10 ns;
        RESET <= '0';
        wait;

        -- Test Case 1: Check behavior when system clock is off
        SysClk <= '0';
        wait for 10 ns;
        assert (controlIoDataOut = "00000000000000000000000000000000")
            report "Failure in Test Case 1: Incorrect data out when system clock is off"
            severity error;
        SysClk <= '1';
        wait;

        -- Test Case 2: Check behavior when Enable is off
        Enable <= '0';
        wait for 10 ns;
        assert (M_IO_OE = '0')
            report "Failure in Test Case 2: M_IO_OE is not low when Enable is off"
            severity error;
        Enable <= '1';
        wait;

        -- Test Case 3: Check behavior when power is off
        PowerUp <= '0';
        wait for 10 ns;
        assert (M_ENABLE = "00")
            report "Failure in Test Case 3: M_ENABLE is not low when PowerUp is off"
            severity error;
        PowerUp <= '1';
        wait;

        -- Test Case 4: Simulate fault condition and check the response
        M_FAULT <= "01";
        wait for 10 ns;
        assert (QA0AxisFault /= "000")
            report "Failure in Test Case 4: QA0AxisFault is not reporting error when M_FAULT is set"
            severity error;
        M_FAULT <= "00";
        wait;

        -- Test Case 5: Check behavior with different intDATA inputs
        intDATA <= "00000000000000000000000000000001";
        wait for 10 ns;
        -- Here we need to specify the expected output based on the design's functionality

        intDATA <= "11111111111111111111111111111111";
        wait for 10 ns;
        -- Here we need to specify the expected output based on the design's functionality

        -- Test termination
        assert false
            report "End of Test"
            severity failure;

    end process test;
end tb;
 
