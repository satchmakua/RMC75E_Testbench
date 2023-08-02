--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_ExpSigRoute
--	File					tb_ExpSigRoute.vhd
--
--------------------------------------------------------------------------------
--
--	Description:

--		ExpSigRoute routes signals based on the value of the ExpMux signal.
--		Depending on ExpMux, different signals are mapped to the ExpData vector,
--		and others are set from ExpData. This includes controlling signals for analog input,
--		digital input/output, and Q1 modules.

--		The test bench initializes all inputs and then tests various scenarios.
--		It tests the module by applying different values to the input signals,
--		such as toggling the ExpMux values, and checking the expected output
--		on the ExpData lines and other output signals.

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
use IEEE.numeric_std.all;

entity tb_ExpSigRoute is
end tb_ExpSigRoute;

architecture tb of tb_ExpSigRoute is

  component ExpSigRoute is
    Port (
      ExpMux                 : in std_logic_vector (1 downto 0);
      ExpSerialSelect        : in std_logic;
      ExpLEDSelect           : in std_logic;
      ExpLEDData             : in std_logic;
      ExpData                : inout std_logic_vector (5 downto 0);
      ExpA_CS_L              : in std_logic;
      ExpA_CLK               : in std_logic;
      ExpA_DATA              : out std_logic_vector(1 downto 0);
      SerialMemoryDataIn     : out std_logic;
      SerialMemoryDataOut    : in std_logic;
      SerialMemoryDataControl: in std_logic;
      SerialMemoryClk        : in std_logic;
      ExpD8_DataIn           : out std_logic;
      ExpD8_Clk              : in std_logic;
      ExpD8_DataOut          : in std_logic;
      ExpD8_OE               : in std_logic;
      ExpD8_Load             : in std_logic;
      ExpD8_Latch            : in std_logic;
      ExpQ1_A                : out std_logic;
      ExpQ1_B                : out std_logic;
      ExpQ1_Reg              : out std_logic;
      ExpQ1_FaultA           : out std_logic;
      ExpQ1_FaultB           : out std_logic
    );
  end component;
  
  constant CLK_PERIOD : time := 33.3333 ns;
  
  signal ExpMux                : std_logic_vector (1 downto 0) := (others => '0');
  signal ExpSerialSelect       : std_logic := '0';
  signal ExpLEDSelect          : std_logic := '0';
  signal ExpLEDData            : std_logic := '0';
  signal ExpData               : std_logic_vector (5 downto 0) := (others => '0');
  signal ExpA_CS_L             : std_logic := '0';
  signal ExpA_CLK              : std_logic := '0';
  signal ExpA_DATA             : std_logic_vector(1 downto 0) := (others => '0');
  signal SerialMemoryDataIn    : std_logic := '0';
  signal SerialMemoryDataOut   : std_logic := '0';
  signal SerialMemoryDataControl: std_logic := '0';
  signal SerialMemoryClk       : std_logic := '0';
  signal ExpD8_DataIn          : std_logic := '0';
  signal ExpD8_Clk             : std_logic := '0';
  signal ExpD8_DataOut         : std_logic := '0';
  signal ExpD8_OE              : std_logic := '0';
  signal ExpD8_Load            : std_logic := '0';
  signal ExpD8_Latch           : std_logic := '0';
  signal ExpQ1_A               : std_logic := '0';
  signal ExpQ1_B               : std_logic := '0';
  signal ExpQ1_Reg             : std_logic := '0';
  signal ExpQ1_FaultA          : std_logic := '0';
  signal ExpQ1_FaultB          : std_logic := '0';

begin

  uut: ExpSigRoute port map (
    ExpMux                 => ExpMux,
    ExpSerialSelect        => ExpSerialSelect,
    ExpLEDSelect           => ExpLEDSelect,
    ExpLEDData             => ExpLEDData,
    ExpData                => ExpData,
    ExpA_CS_L              => ExpA_CS_L,
    ExpA_CLK               => ExpA_CLK,
    ExpA_DATA              => ExpA_DATA,
    SerialMemoryDataIn     => SerialMemoryDataIn,
    SerialMemoryDataOut    => SerialMemoryDataOut,
    SerialMemoryDataControl=> SerialMemoryDataControl,
    SerialMemoryClk        => SerialMemoryClk,
    ExpD8_DataIn           => ExpD8_DataIn,
    ExpD8_Clk              => ExpD8_Clk,
    ExpD8_DataOut          => ExpD8_DataOut,
    ExpD8_OE               => ExpD8_OE,
    ExpD8_Load             => ExpD8_Load,
    ExpD8_Latch            => ExpD8_Latch,
    ExpQ1_A                => ExpQ1_A,
    ExpQ1_B                => ExpQ1_B,
    ExpQ1_Reg              => ExpQ1_Reg,
    ExpQ1_FaultA           => ExpQ1_FaultA,
    ExpQ1_FaultB           => ExpQ1_FaultB
  );
  
  Clock_process : process
  begin
    SerialMemoryClk <= '0';
    ExpA_CLK <= '0';
    wait for CLK_PERIOD/2;
    SerialMemoryClk <= '1';
    ExpA_CLK <= '1';
    wait for CLK_PERIOD/2;
  end process Clock_process;

  Test_Process : process
  begin
	
    -- Initialize the signals
    ExpMux <= "00";
    ExpSerialSelect <= '0';
    ExpLEDSelect <= '0';
    ExpLEDData <= '0';
    ExpA_CS_L <= '0';
    SerialMemoryDataControl <= '0';
		SerialMemoryDataOut <= '0';
    ExpD8_OE <= '0';
    ExpD8_Load <= '0';
    ExpD8_Latch <= '0';
		
		-- Testing Ax module
		wait for 5 us;
		ExpMux <= "01";
		SerialMemoryDataControl <= '1';
		SerialMemoryDataOut <= '1';
		ExpSerialSelect <= '1';
		ExpA_CS_L <= '1';
		
		-- Testing D8 module
		wait for 5 us;
		ExpMux <= "10";
		ExpD8_DataOut <= '1';
		ExpD8_OE <= '1';
		ExpD8_Load <= '1';
		ExpD8_Latch <= '1';
		
		wait for 5 us;
		ExpMux <= "01";
		ExpD8_DataOut <= '0';
		ExpD8_OE <= '0';
		ExpD8_Load <= '0';
		ExpD8_Latch <= '0';
		
		-- Testing LED module
		wait for 5 us;
		SerialMemoryDataControl <= '0';
		SerialMemoryDataOut <= '0';
		ExpSerialSelect <= '0';
		ExpLEDSelect <= '1';
		
		-- Testing Q1 module
		wait for 5 us;
		ExpMux <= "10";
		ExpLEDSelect <= '0';
		
		wait for 500 us;
		
  end process Test_Process;
  
end tb;
   




