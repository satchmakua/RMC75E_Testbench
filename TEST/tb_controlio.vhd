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
--	File					tb_ControlIO.vhd
--
--------------------------------------------------------------------------------
--
--	Description: This is a test bench for the ControlIO module which governs the Control Board IO and LED Interface. 
--	This test bench exercises the ControlIO module with a sequence of input stimuli. 

--	The test bench simulates a 60MHz H1 clock signal, a 30MHz system clock signal, and an enable signal that 
--	becomes active every 4th tick of the system clock. It also includes a reset sequence and a stimuli process
--	that applies various signals to the ControlIO module to emulate different states and conditions. 

--	The test bench includes fault, enable, and IO signals for two axes (Axis0 and Axis1). The IO signals include 
--	write and read commands for both the LEDs and the IOs. The simulation includes sequences for writing to and 
--	reading from the LED configurations and IOs for both axes.

--	The test bench generates both clock signals (H1_CLKWR and SysClk) and simulates the toggling of data signals,
--	enabling the testing of ControlIO's functionality under various data conditions.

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
  constant H1_CLK_PERIOD: time := 16.6667 ns; -- 60MHz clock period
  constant SYS_CLK_PERIOD: time := 33.3333 ns; -- 30MHz clock period

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
  signal M_IO_DATAIn: std_logic:= '0';
  signal M_ENABLE: std_logic_vector (1 downto 0);
  signal M_FAULT: std_logic_vector (1 downto 0) := (others => '0');
  signal PowerUp: std_logic := '0'; -- Set PowerUp to a specific value
  signal QUADPresent: std_logic:= '0';
  signal QA0AxisFault: std_logic_vector (2 downto 0):= (others => '0');
  signal QA1AxisFault: std_logic_vector (2 downto 0):= (others => '0');
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
      controlIoDataOut => controlIoDataOut,
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
      wait for SYS_CLK_PERIOD;
    end loop;
  end process H1_CLK_30_proc;
	
	-- Enable process active on every 4th tick of system clock
	Enable_process : process
    begin
        Enable <= '0';
        wait for 3 * SYS_CLK_PERIOD;
        Enable <= '1';
        wait for SYS_CLK_PERIOD;
	end process;
	
  -- Stimulus process
  stimulus_proc: process
  begin
    -- Reset signal sequence
		wait for 1 us;
		
		PowerUp <= '1';
    
		RESET <= '1';
    wait for SYS_CLK_PERIOD;
		RESET <= '0';
		
		wait for 1 us;
		SynchedTick <= '1';
		wait for SYS_CLK_PERIOD;
		SynchedTick <= '0';

		wait for 10 us;
		SynchedTick <= '1';
		wait for SYS_CLK_PERIOD;
		SynchedTick <= '0';
		
		QUADPresent <= '1';
		M_IO_DATAIn <= '1';
		intDATA	 <= X"FFFFFFFF";
		
		wait for 5 us;
		Axis0LEDConfigWrite <= '1';
		wait for SYS_CLK_PERIOD;
		Axis0LEDConfigWrite <= '0';
		
		Axis0IOWrite <= '1';
		wait for SYS_CLK_PERIOD;
		Axis0IOWrite <= '0';
		
		Axis0LEDStatusRead <= '1';
		wait for 5 us;
		Axis0LEDStatusRead <= '0';
		
		Axis0IORead <= '1';
		wait for 5 us;
		Axis0IORead <= '0';
		
		
		Axis1LEDConfigWrite <= '1';
		wait for SYS_CLK_PERIOD;
		Axis1LEDConfigWrite <= '0';
		
		Axis1IOWrite <= '1';
		wait for SYS_CLK_PERIOD;
		Axis1IOWrite <= '0';
		
		Axis1LEDStatusRead <= '1';
		wait for 5 us;
		Axis1LEDStatusRead <= '0';
		
		Axis1IORead <= '1';
		wait for 5 us;
		Axis1IORead <= '0';
		wait for 5 us;
		
		wait for 100 us;
  end process stimulus_proc;

end tb;




