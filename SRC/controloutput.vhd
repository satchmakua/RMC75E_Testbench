--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer (Satchel Hamilton)
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
--		Analog Control Output Interface
--		a 16-bit word of control output data is loaded into a parallel load/serial out 
--		shift register for the axis.  
--
--		Drive data is initially written to the DATA_BUF registers.  This information is
--		then transferred to the SHIFT_REG to be serially clocked out to the DAC
--		The DAC information is clocked out MSB first.
--
--	Revision: 1.3
--
--	File history:
--		Rev 1.2 : 05/26/2023 :	Added catch-all statement to handle unresolved cases
--		Rev 1.1 : 06/10/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ControlOutput is
  port (
    H1_CLKWR           : in std_logic;
    SysClk             : in std_logic;
    RESET              : in std.STANDARD.BOOLEAN; -- Modify the type here
    SynchedTick        : in std_logic;
    intDATA            : in std_logic_vector (15 downto 0);
    ControlOutputWrite : in std_logic;
    M_OUT_CLK          : out std_logic;
    M_OUT_DATA         : out std_logic;
    M_OUT_CONTROL      : out std_logic;
    PowerUp            : in std_logic;
    Enable             : in std_logic
  );
end ControlOutput;


architecture ControlOutput_arch of ControlOutput is

  signal ShiftRegister            : std_logic_vector (15 downto 0);    -- := X"0000";
  signal DataBuffer,
         DataBufferOut            : std_logic_vector (15 downto 0);    -- := X"0000";
  signal Count                    : std_logic_vector (4 downto 0);    -- := "00000";
  signal ControlOutputWriteLatched0,
         ControlOutputWriteLatched1,
         ControlOutputWriteLatched2  : std_logic;    -- := '0';
  signal ControlOutputOneShot      : std_logic;    -- := '0';
  signal OutputClock,
         ShiftEnable,
         ShiftComplete            : std_logic;    -- := '0';
  signal ShiftDataOutput            : std_logic;    -- := '0';

  ---- State Encoding
  constant s0: std_logic := '0';
  constant s1: std_logic := '1';

  signal State : std_logic; -- state can be assigned the constants s0-s1

  constant TerminalCountValue : bit_vector := B"10000";
  constant TerminalCount : std_logic_vector (4 downto 0) := To_StdLogicVector(TerminalCountValue);

begin -- Beginning of architechure description

  -- A 16 bit word buffer catches the data coming in from the processor
  -- After this write occurs, the state machine will start to shift
  -- data out to the DAC
  process (H1_CLKWR, RESET)
  begin
    if RESET then
      DataBuffer <= (others => '1');
    elsif rising_edge(H1_CLKWR) then
      if ControlOutputWrite = '1' then
        DataBuffer(15 downto 0) <= intDATA(15 downto 0);
      end if;

      -- edge detector to sense the falling edge of the ControlOutputWrite
      -- This signal is used to start the shift process
      ControlOutputWriteLatched0 <= ControlOutputWrite or (ControlOutputWriteLatched0 and not ControlOutputWriteLatched1);
    end if;  
  end process;

  -- this converts from two's complement to MAX5541 format (refer to DAC datasheet for details)
  DataBufferOut <= DataBuffer(15) & not DataBuffer(14 downto 0);

  process (SysClk)
  begin
    if rising_edge(SysClk) then
      if Enable = '1' then
        -- edge detector to sense the falling edge of the ControlOutputWrite
        -- This signal is used to start the shift process
        ControlOutputWriteLatched1 <= ControlOutputWriteLatched0 or (ControlOutputWriteLatched1 and not ControlOutputWriteLatched2);
        ControlOutputWriteLatched2 <= ControlOutputWriteLatched1 and not ControlOutputWriteLatched2;
      end if;
    end if;
  end process;

  -- ControlOutputOneShot is Active for a single SysClk cycle after a data write
  ControlOutputOneShot <= '1' when (ControlOutputWriteLatched1 = '1' and ControlOutputWriteLatched2 = '1') or PowerUp = '1' else '0';

  -- State Machine to control the write sequence to the DAC outputs
  StateMachine : process(SysClk, SynchedTick, ControlOutputOneShot, ShiftDataOutput)
  begin
    if rising_edge(SysClk) then
      if SynchedTick = '1' then
        State <= s0; -- reset state, this will reset the state machine every ms
      elsif Enable = '1' then
        case State is
          when  s0 =>
            if ControlOutputOneShot = '1' then
              State <= s1;
            else
              ShiftEnable <= '0';           -- disable the data shifting
              M_OUT_CONTROL <= '1';         -- converter chip select inactive
              M_OUT_DATA <= '0';            -- converter data locked to 0
            end if;
          when  s1 =>
            if ShiftComplete = '1' then
              ShiftEnable <= '0';
              State <= s0;
            else
              M_OUT_CONTROL <= '0';         -- converter chip select is active
              M_OUT_DATA <= ShiftDataOutput;
              ShiftEnable <= '1';           -- enable the data shifting
            end if;
          when others => -- Added this line to handle all other cases
            State <= s0;      -- default, reset state
        end case;
      end if;
    end if;
  end process;

  process (SysClk)
  begin
    if rising_edge(SysClk) then
      -- Data is clocked into the DAC on the RISING edge of the OutputClock
      if SynchedTick = '1' or ShiftComplete = '1' then -- set the output clock on the control loop tick
        OutputClock <= '0'; 
      elsif ShiftEnable = '1' and Enable = '1' then
        OutputClock <= not OutputClock;
      end if;

      -- 5-bit synchronous counter with count enable and asynchronous reset
      if SynchedTick = '1' or ShiftComplete = '1' then
        Count (4 downto 0) <= "00000";
      elsif ShiftEnable = '1' and OutputClock = '0' and Enable = '1' then
        Count <= Count + 1;
      end if;

      if Enable='1' then
        if Count(4 downto 0) = TerminalCount(4 downto 0) and OutputClock = '1' then -- Terminal count at 16
          ShiftComplete <= '1';
        else
          ShiftComplete <= '0';
        end if;
        -- Load and shift 16-bit shift register
        if ControlOutputOneShot then
          ShiftRegister <= DataBufferOut;
        elsif (ShiftEnable and not OutputClock) then
          ShiftRegister(15 downto 0) <= ShiftRegister(14 downto 0) & '0';
        end if;
      end if;

    end if;
  end process;

  M_OUT_CLK <= OutputClock;

  ShiftDataOutput <= ShiftRegister(15);

end ControlOutput_arch;

