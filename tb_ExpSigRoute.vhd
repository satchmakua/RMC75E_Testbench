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
--	File			tb_ExpSigRoute.vhd
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

entity tb_ExpSigRoute is
end tb_ExpSigRoute;

architecture tb of tb_ExpSigRoute is 

	component ExpSigRoute is
		Port ( 
			ExpMux					: in std_logic_vector (1 downto 0);
			ExpSerialSelect			: in std_logic;
			ExpLEDSelect			: in std_logic;
			ExpLEDData				: in std_logic;
			ExpData					: inout std_logic_vector (5 downto 0);
			ExpA_CS_L				: in std_logic;
			ExpA_CLK				: in std_logic;
			ExpA_DATA				: out std_logic_vector(1 downto 0);
			SerialMemoryDataIn		: out std_logic;
			SerialMemoryDataOut		: in std_logic;
			SerialMemoryDataControl	: in std_logic;
			SerialMemoryClk			: in std_logic;
			ExpD8_DataIn			: out std_logic;
			ExpD8_Clk				: in std_logic;
			ExpD8_DataOut			: in std_logic;
			ExpD8_OE				: in std_logic;
			ExpD8_Load				: in std_logic;
			ExpD8_Latch				: in std_logic;
			ExpQ1_A					: out std_logic;
			ExpQ1_B					: out std_logic;
			ExpQ1_Reg				: out std_logic;
			ExpQ1_FaultA			: out std_logic;
			ExpQ1_FaultB			: out std_logic
		);
	end component;

	signal ExpMux					: std_logic_vector (1 downto 0) := (others => '0');
	signal ExpSerialSelect			: std_logic := '0';
	signal ExpLEDSelect				: std_logic := '0';
	signal ExpLEDData				: std_logic := '0';
	signal ExpData					: std_logic_vector (5 downto 0) := (others => '0');
	signal ExpA_CS_L				: std_logic := '0';
	signal ExpA_CLK					: std_logic := '0';
	signal ExpA_DATA				: std_logic_vector(1 downto 0) := (others => '0');
	signal SerialMemoryDataIn		: std_logic := '0';
	signal SerialMemoryDataOut		: std_logic := '0';
	signal SerialMemoryDataControl	: std_logic := '0';
	signal SerialMemoryClk			: std_logic := '0';
	signal ExpD8_DataIn				: std_logic := '0';
	signal ExpD8_Clk				: std_logic := '0';
	signal ExpD8_DataOut			: std_logic := '0';
	signal ExpD8_OE					: std_logic := '0';
	signal ExpD8_Load				: std_logic := '0';
	signal ExpD8_Latch				: std_logic := '0';
	signal ExpQ1_A					: std_logic := '0';
	signal ExpQ1_B					: std_logic := '0';
	signal ExpQ1_Reg				: std_logic := '0';
	signal ExpQ1_FaultA				: std_logic := '0';
	signal ExpQ1_FaultB				: std_logic := '0';

	constant CLK_PERIOD : time := 10 ns;

begin

	uut: ExpSigRoute port map (
		ExpMux => ExpMux,
		ExpSerialSelect => ExpSerialSelect,
		ExpLEDSelect => ExpLEDSelect,
		ExpLEDData => ExpLEDData,
		ExpData => ExpData,
		ExpA_CS_L => ExpA_CS_L,
		ExpA_CLK => ExpA_CLK,
		ExpA_DATA => ExpA_DATA,
		SerialMemoryDataIn => SerialMemoryDataIn,
		SerialMemoryDataOut => SerialMemoryDataOut,
		SerialMemoryDataControl => SerialMemoryDataControl,
		SerialMemoryClk => SerialMemoryClk,
		ExpD8_DataIn => ExpD8_DataIn,
		ExpD8_Clk => ExpD8_Clk,
		ExpD8_DataOut => ExpD8_DataOut,
		ExpD8_OE => ExpD8_OE,
		ExpD8_Load => ExpD8_Load,
		ExpD8_Latch => ExpD8_Latch,
		ExpQ1_A => ExpQ1_A,
		ExpQ1_B => ExpQ1_B,
		ExpQ1_Reg => ExpQ1_Reg,
		ExpQ1_FaultA => ExpQ1_FaultA,
		ExpQ1_FaultB => ExpQ1_FaultB
	);

	stim_proc: process
	begin	
		-- Test scenario 1: No valid module, expect tied to '1', '0', or 'Z'
		ExpMux <= "00"; ExpSerialSelect <= '0'; ExpLEDSelect <= '0'; ExpLEDData <= '0';
		wait for CLK_PERIOD;
		
		-- Test scenario 2: Analog input logic module with serial select
		ExpMux <= "01"; ExpSerialSelect <= '1'; ExpA_CS_L <= '0'; ExpA_CLK <= '1';
		wait for CLK_PERIOD;
		
		-- Test scenario 3: DIO input logic module
		ExpMux <= "10"; ExpLEDSelect <= '1'; ExpLEDData <= '1'; ExpD8_OE <= '1'; ExpD8_Load <= '1';
		wait for CLK_PERIOD;

		-- Test scenario 4: ExpData with both the AP2 and the DIO8 modules
		ExpMux <= "11"; ExpSerialSelect <= '0'; ExpLEDSelect <= '0'; ExpLEDData <= '1'; 
		wait for CLK_PERIOD;
		
		-- Test scenario 5: Random combination of inputs
		ExpMux <= "01"; ExpSerialSelect <= '1'; ExpLEDSelect <= '0'; ExpLEDData <= '0'; ExpA_CS_L <= '1'; ExpA_CLK <= '0';
		wait for CLK_PERIOD;

		-- Additional test cases
		-- Test scenario 6: Testing upper bound of ExpData
		ExpData <= "111111";
		wait for CLK_PERIOD;
		
		-- Test scenario 7: Testing lower bound of ExpData
		ExpData <= "000000";
		wait for CLK_PERIOD;

		-- Test scenario 8: Random combination of inputs with AP2 module
		ExpMux <= "01"; ExpSerialSelect <= '1'; ExpLEDSelect <= '0'; ExpLEDData <= '1'; ExpA_CS_L <= '0'; ExpA_CLK <= '0';
		wait for CLK_PERIOD;

		wait;
	end process;

	-- Assertion for Test scenario 1: No valid module
	assert (ExpQ1_A = '1' and ExpQ1_B = '0' and ExpQ1_Reg = 'Z' and ExpQ1_FaultA = '1' and ExpQ1_FaultB = '0')
		report "Test scenario 1 failed" severity error;

	-- Assertion for Test scenario 2: Analog input logic module with serial select
	assert (ExpQ1_A = '0' and ExpQ1_B = '0' and ExpQ1_Reg = '1' and ExpQ1_FaultA = '0' and ExpQ1_FaultB = '0')
		report "Test scenario 2 failed" severity error;

	-- Assertion for Test scenario 3: DIO input logic module
	assert (ExpQ1_A = 'Z' and ExpQ1_B = 'Z' and ExpQ1_Reg = 'Z' and ExpQ1_FaultA = '0' and ExpQ1_FaultB = '0')
		report "Test scenario 3 failed" severity error;

	-- Assertion for Test scenario 4: ExpData with both the AP2 and the DIO8 modules
	assert (ExpQ1_A = '0' and ExpQ1_B = '0' and ExpQ1_Reg = '0' and ExpQ1_FaultA = '0' and ExpQ1_FaultB = '0')
		report "Test scenario 4 failed" severity error;

	-- Assertion for Test scenario 5: Random combination of inputs
	assert (ExpQ1_A = 'Z' and ExpQ1_B = 'Z' and ExpQ1_Reg = '0' and ExpQ1_FaultA = '0' and ExpQ1_FaultB = '0')
		report "Test scenario 5 failed" severity error;

	-- Assertion for Test scenario 6: Testing upper bound of ExpData
	assert (ExpQ1_A = '1' and ExpQ1_B = '1' and ExpQ1_Reg = '1' and ExpQ1_FaultA = '0' and ExpQ1_FaultB = '0')
		report "Test scenario 6 failed" severity error;

	-- Assertion for Test scenario 7: Testing lower bound of ExpData
	assert (ExpQ1_A = '0' and ExpQ1_B = '0' and ExpQ1_Reg = '0' and ExpQ1_FaultA = '0' and ExpQ1_FaultB = '0')
		report "Test scenario 7 failed" severity error;

	-- Assertion for Test scenario 8: Random combination of inputs with AP2 module
	assert (ExpQ1_A = 'Z' and ExpQ1_B = 'Z' and ExpQ1_Reg = '0' and ExpQ1_FaultA = '0' and ExpQ1_FaultB = '0')
		report "Test scenario 8 failed" severity error;

end tb;

