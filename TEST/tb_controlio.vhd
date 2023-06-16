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
  constant H1_CLK_PERIOD: time := 16.67 ns; -- 60MHz clock period
  constant SYS_CLK_PERIOD: time := 33.33 ns; -- 30MHz clock period

  signal RESET: std_logic := '1';
  signal H1_CLKWR: std_logic := '0';
  signal SysClk: std_logic := '0';
  signal Enable: std_logic := '0';
  signal SynchedTick: std_logic := '0';
  signal intDATA: std_logic_vector (31 downto 0) := (others => '0');
  signal Axis0LEDStatusRead: std_logic := '0';
  signal Axis0LEDConfigWrite: std_logic := '0';
  signal Axis0IORead: std_logic := '0';
  signal Axis0IOWrite: std_logic := '0';
  signal Axis1LEDStatusRead: std_logic := '0';
  signal Axis1LEDConfigWrite: std_logic := '0';
  signal Axis1IORead: std_logic := '0';
  signal Axis1IOWrite: std_logic := '0';
  signal M_IO_OE: std_logic;
  signal M_IO_LOAD: std_logic;
  signal M_IO_LATCH: std_logic;
  signal M_IO_CLK: std_logic;
  signal M_IO_DATAOut: std_logic;
  signal M_IO_DATAIn: std_logic;
  signal M_ENABLE: std_logic_vector (1 downto 0);
  signal M_FAULT: std_logic_vector (1 downto 0);
  signal PowerUp: std_logic := '0'; -- Set PowerUp to a specific value
  signal QUADPresent: std_logic;
  signal QA0AxisFault: std_logic_vector (2 downto 0);
  signal QA1AxisFault: std_logic_vector (2 downto 0);
  signal controlIoDataOut: std_logic_vector (31 downto 0); -- Define controlIoDataOut signal

  -- Clock signals based on H1_CLKWR
  signal H1_CLK: std_logic := '0';
  signal H1_CLK_30: std_logic := '0';

begin
  -- Instantiate the ControlIO module
  DUT: entity work.ControlIO
    port map (
      RESET => RESET,
      H1_CLKWR => H1_CLKWR,
      SysClk => SysClk,
      Enable => Enable,
      SynchedTick => SynchedTick,
      intDATA => intDATA,
      controlIoDataOut => controlIoDataOut, -- Connect controlIoDataOut signal
      Axis0LEDStatusRead => Axis0LEDStatusRead,
      Axis0LEDConfigWrite => Axis0LEDConfigWrite,
      Axis0IORead => Axis0IORead,
      Axis0IOWrite => Axis0IOWrite,
      Axis1LEDStatusRead => Axis1LEDStatusRead,
      Axis1LEDConfigWrite => Axis1LEDConfigWrite,
      Axis1IORead => Axis1IORead,
      Axis1IOWrite => Axis1IOWrite,
      M_IO_OE => M_IO_OE,
      M_IO_LOAD => M_IO_LOAD,
      M_IO_LATCH => M_IO_LATCH,
      M_IO_CLK => M_IO_CLK,
      M_IO_DATAOut => M_IO_DATAOut,
      M_IO_DATAIn => M_IO_DATAIn,
      M_ENABLE => M_ENABLE,
      M_FAULT => M_FAULT,
      PowerUp => PowerUp,
      QUADPresent => QUADPresent,
      QA0AxisFault => QA0AxisFault,
      QA1AxisFault => QA1AxisFault
    );

  -- Clock generation process for H1_CLKWR
  H1_CLKWR_proc: process
  begin
    while true loop
      H1_CLKWR <= not H1_CLKWR;
      wait for H1_CLK_PERIOD;
    end loop;
  end process H1_CLKWR_proc;

  -- Clock generation process for SysClk
  SysClk_proc: process
  begin
    while true loop
      SysClk <= not SysClk;
      wait for SYS_CLK_PERIOD;
    end loop;
  end process SysClk_proc;

  -- Clock generation process for H1_CLK
  H1_CLK_proc: process
  begin
    while true loop
      H1_CLK <= not H1_CLK;
      wait for H1_CLK_PERIOD;
    end loop;
  end process H1_CLK_proc;

  -- Clock generation process for H1_CLK_30
  H1_CLK_30_proc: process
  begin
    while true loop
      H1_CLK_30 <= not H1_CLK_30;
      wait for H1_CLK_PERIOD * 2;
    end loop;
  end process H1_CLK_30_proc;

  -- Stimulus process
  stimulus_proc: process
  begin
    -- Reset signal sequence
    RESET <= '1';
    wait for H1_CLK_PERIOD;
    RESET <= '0';

    -- Wait for one 30MHz clock cycle
    wait for H1_CLK_PERIOD * 2;

    -- Generate SynchedTick pulses
    while true loop
      SynchedTick <= '1';
      wait for H1_CLK_PERIOD;
      SynchedTick <= '0';
      wait for H1_CLK_PERIOD;
    end loop;

    -- Continue simulation
    wait;
  end process stimulus_proc;

  -- Assertion process
  assert_proc: process
  begin
    -- Add your assertions here

    wait;
  end process assert_proc;

end tb;




