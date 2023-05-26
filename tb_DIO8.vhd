--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_DIO8
--	File			tb_DIO8.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- The DUT (Device Under Test) here is the DIO8 module which is a
	-- Digital Input/Output (DIO) device with 8-bit interfaces.
	-- It has a wide array of input and output signals for configuration and data interaction.
	-- It also includes signals for clock, reset, and enable operations.

	-- The testbench is used to verify the correct behavior of this DIO8 device.
	-- It initializes the DUT and provides various input stimuli to it.
	-- The output from the DUT is then checked against the expected
	-- behavior to ensure its functionality. 

	-- The stimulus process specifically is used to generate the
	-- test vectors that are applied to the DUT. It can apply one or
	-- many different sequences of inputs to test various functionalities and edge cases of the DUT.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_DIO8 is
end tb_DIO8;

architecture tb of tb_DIO8 is 

component DIO8 is
    Port (
        RESET				: in std_logic;
        H1_CLKWR			: in std_logic;
        SysClk				: in std_logic;
        SlowEnable			: in std_logic;
        SynchedTick			: in std_logic;
        intDATA				: in std_logic_vector(31 downto 0);
        d8DataOut			: out std_logic_vector(31 downto 0);
        ExpDIO8ConfigRead	: in std_logic_vector(3 downto 0);
        ExpDIO8ConfigWrite	: in std_logic_vector(3 downto 0);
        ExpDIO8DinRead		: in std_logic_vector(3 downto 0);
        Exp0D8_DataIn		: in std_logic;
        Exp0D8_Clk			: out std_logic;
        Exp0D8_DataOut		: out std_logic;
        Exp0D8_OE			: out std_logic;
        Exp0D8_Load			: out std_logic;
        Exp0D8_Latch		: out std_logic;
        Exp1D8_DataIn		: in std_logic;
        Exp1D8_Clk			: out std_logic;
        Exp1D8_DataOut		: out std_logic;
        Exp1D8_OE			: out std_logic;
        Exp1D8_Load			: out std_logic;
        Exp1D8_Latch		: out std_logic;
        Exp2D8_DataIn		: in std_logic;
        Exp2D8_Clk			: out std_logic;
        Exp2D8_DataOut		: out std_logic;
        Exp2D8_OE			: out std_logic;
        Exp2D8_Load			: out std_logic;
        Exp2D8_Latch		: out std_logic;
        Exp3D8_DataIn		: in std_logic;
        Exp3D8_Clk			: out std_logic;
        Exp3D8_DataOut		: out std_logic;
        Exp3D8_OE			: out std_logic;
        Exp3D8_Load			: out std_logic;
        Exp3D8_Latch		: out std_logic
    );
end component;

-- Declare inputs
signal RESET				: std_logic := '0';
signal H1_CLKWR				: std_logic := '0';
signal SysClk				: std_logic := '0';
signal SlowEnable			: std_logic := '0';
signal SynchedTick			: std_logic := '0';
signal intDATA				: std_logic_vector(31 downto 0) := (others => '0');
signal ExpDIO8ConfigRead	: std_logic_vector(3 downto 0) := (others => '0');
signal ExpDIO8ConfigWrite	: std_logic_vector(3 downto 0) := (others => '0');
signal ExpDIO8DinRead		: std_logic_vector(3 downto 0) := (others => '0');
signal Exp0D8_DataIn		: std_logic := '0';
signal Exp1D8_DataIn		: std_logic := '0';
signal Exp2D8_DataIn		: std_logic := '0';
signal Exp3D8_DataIn		: std_logic := '0';

-- Declare outputs
signal d8DataOut			: std_logic_vector(31 downto 0);
signal Exp0D8_Clk			: std_logic;
signal Exp0D8_DataOut		: std_logic;
signal Exp0D8_OE			: std_logic;
signal Exp0D8_Load			: std_logic;
signal Exp0D8_Latch			: std_logic;
signal Exp1D8_Clk			: std_logic;
signal Exp1D8_DataOut		: std_logic;
signal Exp1D8_OE			: std_logic;
signal Exp1D8_Load			: std_logic;
signal Exp1D8_Latch			: std_logic;
signal Exp2D8_Clk			: std_logic;
signal Exp2D8_DataOut		: std_logic;
signal Exp2D8_OE			: std_logic;
signal Exp2D8_Load			: std_logic;
signal Exp2D8_Latch			: std_logic;
signal Exp3D8_Clk			: std_logic;
signal Exp3D8_DataOut		: std_logic;
signal Exp3D8_OE			: std_logic;
signal Exp3D8_Load			: std_logic;
signal Exp3D8_Latch			: std_logic;

begin
    -- Instantiate the Device Under Test (DUT)
    DUT: DIO8 port map (
        RESET				=> RESET,
        H1_CLKWR			=> H1_CLKWR,
        SysClk				=> SysClk,
        SlowEnable			=> SlowEnable,
        SynchedTick			=> SynchedTick,
        intDATA				=> intDATA,
        d8DataOut			=> d8DataOut,
        ExpDIO8ConfigRead	=> ExpDIO8ConfigRead,
        ExpDIO8ConfigWrite	=> ExpDIO8ConfigWrite,
        ExpDIO8DinRead		=> ExpDIO8DinRead,
        Exp0D8_DataIn		=> Exp0D8_DataIn,
        Exp0D8_Clk			=> Exp0D8_Clk,
        Exp0D8_DataOut		=> Exp0D8_DataOut,
        Exp0D8_OE			=> Exp0D8_OE,
        Exp0D8_Load			=> Exp0D8_Load,
        Exp0D8_Latch		=> Exp0D8_Latch,
        Exp1D8_DataIn		=> Exp1D8_DataIn,
        Exp1D8_Clk			=> Exp1D8_Clk,
        Exp1D8_DataOut		=> Exp1D8_DataOut,
        Exp1D8_OE			=> Exp1D8_OE,
        Exp1D8_Load			=> Exp1D8_Load,
        Exp1D8_Latch		=> Exp1D8_Latch,
        Exp2D8_DataIn		=> Exp2D8_DataIn,
        Exp2D8_Clk			=> Exp2D8_Clk,
        Exp2D8_DataOut		=> Exp2D8_DataOut,
        Exp2D8_OE			=> Exp2D8_OE,
        Exp2D8_Load			=> Exp2D8_Load,
        Exp2D8_Latch		=> Exp2D8_Latch,
        Exp3D8_DataIn		=> Exp3D8_DataIn,
        Exp3D8_Clk			=> Exp3D8_Clk,
        Exp3D8_DataOut		=> Exp3D8_DataOut,
        Exp3D8_OE			=> Exp3D8_OE,
        Exp3D8_Load			=> Exp3D8_Load,
        Exp3D8_Latch		=> Exp3D8_Latch
    );

	stim_proc: process
	begin	
		-- hold reset state for 100 ns.
		RESET <= '1';
		wait for 100 ns;	

		RESET <= '0';

		-- insert your stimulus here 
		wait for 100 ns;

		-- Test case 1: Test ExpDIO8ConfigRead and ExpDIO8ConfigWrite signals
		-- Write data to ExpDIO8ConfigWrite
		ExpDIO8ConfigWrite <= "1010";
		wait for 100 ns;

		-- Enable ExpDIO8ConfigRead
		ExpDIO8ConfigRead <= "0001";
		wait for 100 ns;

		-- Verify if data is successfully read by observing d8DataOut
		assert d8DataOut = "10101010101010101010101010101010" report "Read fail for ExpDIO8ConfigWrite" severity error;

		-- Reset ExpDIO8ConfigRead and ExpDIO8ConfigWrite
		ExpDIO8ConfigRead <= "0000";
		ExpDIO8ConfigWrite <= (others => '0');
		wait for 100 ns;

		-- Additional test cases can be included here

		-- End of test cases
		wait;
	end process;

end tb;
