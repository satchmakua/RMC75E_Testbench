--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_DIO8_v2
--	File					tb_DIO8_v2.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

	-- The DUT (Device Under Test) here is the DIO8 module which is a
	-- Discrete Input/Output (DIO) device with 8-bit interfaces.
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

entity tb_DIO8_v2 is
end tb_DIO8_v2;

architecture tb of tb_DIO8_v2 is 

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
		
		-- Input values
		constant shift_register_input : std_logic_vector(31 downto 0) := "11100011100010101110001110001010";
		constant shift_register_input_2 : std_logic_vector(31 downto 0) := X"FF00FF00";
		
    -- Clock period definitions
    constant H1_CLK_period : time := 16.6667 ns;
    constant SysClk_period : time := 33.3333 ns;
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
		
		stim_proc: process
		begin
				RESET <= '1';
				wait for 100 ns;
				RESET <= '0';

				wait for 1 us;
				SynchedTick <= '1';
				wait for SysClk_period;
				SynchedTick <= '0';
				
				intData <= X"AA55AA55";
				
				ExpDIO8ConfigWrite <= "0001";
				wait for H1_CLK_period;
				ExpDIO8ConfigWrite <= "0010";
				wait for H1_CLK_period;
				ExpDIO8ConfigWrite <= "0100";
				wait for H1_CLK_period;
				ExpDIO8ConfigWrite <= "1000";
				wait for H1_CLK_period;
				ExpDIO8ConfigWrite <= "0000";
				
				wait for 125 us;
				SynchedTick <= '1';
				wait for SysClk_period;
				SynchedTick <= '0';
				
				for i in 0 to 31 loop
						wait until falling_edge(Exp0D8_Clk);
						Exp0D8_DataIn <= shift_register_input(i);
				end loop;
				
				for i in 0 to 31 loop
						wait until falling_edge(Exp1D8_Clk);
						Exp1D8_DataIn <= shift_register_input(i);
				end loop;
				
				for i in 0 to 31 loop
						wait until falling_edge(Exp2D8_Clk);
						Exp2D8_DataIn <= shift_register_input(i);
				end loop;
				
				for i in 0 to 31 loop
						wait until falling_edge(Exp3D8_Clk);
						Exp3D8_DataIn <= shift_register_input(i);
				end loop;
				
				wait for 5 us;
				
				ExpDIO8ConfigRead <= "0001";
				ExpDIO8DinRead <= "0001";
				wait for 5 us;
				ExpDIO8ConfigRead <= "0010";
				ExpDIO8DinRead <= "0010";
				wait for 5 us;
				ExpDIO8ConfigRead <= "0100";
				ExpDIO8DinRead <= "0100";
				wait for 5 us;
				ExpDIO8ConfigRead <= "1000";
				ExpDIO8DinRead <= "1000";
				wait for 5 us;
				ExpDIO8ConfigRead <= "0000";
				ExpDIO8DinRead <= "0000";
				wait for 5 us;

				wait for 100 us;
				
				intData <= X"39D7CEBF";
				
				ExpDIO8ConfigWrite <= "0001";
				wait for H1_CLK_period;
				ExpDIO8ConfigWrite <= "0010";
				wait for H1_CLK_period;
				ExpDIO8ConfigWrite <= "0100";
				wait for H1_CLK_period;
				ExpDIO8ConfigWrite <= "1000";
				wait for H1_CLK_period;
				ExpDIO8ConfigWrite <= "0000";
				
				wait for 125 us;
				SynchedTick <= '1';
				wait for SysClk_period;
				SynchedTick <= '0';
				
				for i in 0 to 31 loop
						wait until falling_edge(Exp0D8_Clk);
						Exp0D8_DataIn <= shift_register_input_2(i);
				end loop;
				
				for i in 0 to 31 loop
						wait until falling_edge(Exp1D8_Clk);
						Exp1D8_DataIn <= shift_register_input_2(i);
				end loop;
				
				for i in 0 to 31 loop
						wait until falling_edge(Exp2D8_Clk);
						Exp2D8_DataIn <= shift_register_input_2(i);
				end loop;
				
				for i in 0 to 31 loop
						wait until falling_edge(Exp3D8_Clk);
						Exp3D8_DataIn <= shift_register_input_2(i);
				end loop;
				
				wait for 5 us;
				
				ExpDIO8ConfigRead <= "0001";
				ExpDIO8DinRead <= "0001";
				wait for 5 us;
				ExpDIO8ConfigRead <= "0010";
				ExpDIO8DinRead <= "0010";
				wait for 5 us;
				ExpDIO8ConfigRead <= "0100";
				ExpDIO8DinRead <= "0100";
				wait for 5 us;
				ExpDIO8ConfigRead <= "1000";
				ExpDIO8DinRead <= "1000";
				wait for 5 us;
				ExpDIO8ConfigRead <= "0000";
				ExpDIO8DinRead <= "0000";
				wait for 5 us;

				wait for 100 us;
		end process stim_proc;		
		
end tb;
