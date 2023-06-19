--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		ControlOutput
--	File			controloutput.vhd
--
--------------------------------------------------------------------------------
--
--	Description:

--		DUT:
--		Analog Control Output Interface
--		a 16-bit word of control output data is loaded into a parallel load/serial out 
--		shift register for the axis.  
--
--		Drive data is initially written to the DATA_BUF registers.  This information is
--		then transferred to the SHIFT_REG to be serially clocked out to the DAC
--		The DAC information is clocked out MSB first.
--		
-- 		Test bench is designed to stimulate the ControlOutput module with a variety
--		of inputs, and check the correct operation by monitoring the outputs.

--	Revision: 1.0
--
--	File history:
--		Rev 1.0
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity tb_CountrolOutput is
end tb_CountrolOutput;

architecture tb of tb_CountrolOutput is
  constant clk_period : time := 16.6667 ns;
  constant num_cycles : integer := 15_000; -- 250 us divided by clk_period of 16.666 ns 

  signal H1_CLKWR           : std_logic := '0';
  signal SysClk             : std_logic := '0';
  signal RESET              : std_logic := '0';
  signal SynchedTick        : std_logic := '0';
  signal intDATA            : std_logic_vector (15 downto 0) := (others => '0');
  signal ControlOutputWrite : std_logic := '0';
  signal M_OUT_CLK          : std_logic := '0';
  signal M_OUT_DATA         : std_logic := '0';
  signal M_OUT_CONTROL      : std_logic := '0';
  signal PowerUp            : std_logic := '0';
  signal Enable             : std_logic := '0';

  component ControlOutput is
    port (
      H1_CLKWR           : in std_logic;
      SysClk             : in std_logic;
      RESET              : in std_logic;
      SynchedTick        : in std_logic;
      intDATA            : in std_logic_vector (15 downto 0);
      ControlOutputWrite : in std_logic;
      M_OUT_CLK          : out std_logic;
      M_OUT_DATA         : out std_logic;
      M_OUT_CONTROL      : out std_logic;
      PowerUp            : in std_logic;
      Enable             : in std_logic
    );
  end component;

begin
  DUT: ControlOutput
    port map (
      H1_CLKWR           => H1_CLKWR,
      SysClk             => SysClk,
      RESET              => RESET,
      SynchedTick        => SynchedTick,
      intDATA            => intDATA,
      ControlOutputWrite => ControlOutputWrite,
      M_OUT_CLK          => M_OUT_CLK,
      M_OUT_DATA         => M_OUT_DATA,
      M_OUT_CONTROL      => M_OUT_CONTROL,
      PowerUp            => PowerUp,
      Enable             => Enable
    );

  clk_proc : process
  begin
    SysClk <= '0';
    wait for clk_period/2;
    SysClk <= '1';
    wait for clk_period/2;
  end process;

  stim_proc : process
  begin
    RESET <= '1';
    wait for clk_period;
    RESET <= '0';
    Enable <= '1';
    wait for clk_period;
    for i in 1 to num_cycles loop
      intDATA <= "1010101010101010";
      ControlOutputWrite <= '1';
      wait for clk_period;
      intDATA <= "0101010101010101";
      ControlOutputWrite <= '0';
      wait for clk_period;
      SynchedTick <= '1';
      wait for clk_period;
      SynchedTick <= '0';
      intDATA <= "1111000011110000";
      ControlOutputWrite <= '1';
      wait for clk_period;
      ControlOutputWrite <= '0';
      wait for clk_period;
    end loop;

    assert(M_OUT_DATA /= 'U')
      report "Unexpected value on M_OUT_DATA"
      severity error;
    assert(M_OUT_CONTROL /= 'U')
      report "Unexpected value on M_OUT_CONTROL"
      severity error;
    assert(M_OUT_CLK /= 'U')
      report "Unexpected value on M_OUT_CLK"
      severity error;
    wait;
  end process;
end tb;


