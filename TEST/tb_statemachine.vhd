library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_StateMachine is
end tb_StateMachine;

architecture tb of tb_StateMachine is
	-- Component declaration
	component StateMachine is
		port (
				-- Input signals
				SysReset            : in std_logic;
				SysClk              : in std_logic;
				SlowEnable          : in std_logic;
				SynchedTick         : in std_logic;
				LoopTime            : in std_logic_vector(2 downto 0);
				
				-- Output signals
				ExpA_CS_L           : out std_logic;
				ExpA_CLK            : out std_logic;
				Serial2ParallelEN   : out std_logic;
				Serial2ParallelCLR  : out std_logic;
				WriteConversion     : out std_logic
		);
	end component;
	
	constant SysClk_period : time := 33.3333 ns;
	
	-- Signal declarations
	signal SysReset        		: std_logic := '1';
	signal SysClk          		: std_logic := '0';
	signal SlowEnable     		: std_logic := '0';
	signal SynchedTick      	: std_logic;
	signal LoopTime        		: std_logic_vector(2 downto 0) := "000";
	signal ExpA_CS_L        	: std_logic;
	signal ExpA_CLK        		: std_logic;
	signal Serial2ParallelEN	: std_logic;
	signal Serial2ParallelCLR	: std_logic;
	signal WriteConversion		: std_logic;

	begin
	-- Instantiate the DUT
	dut: StateMachine
	port map (
			SysReset            => SysReset,
			SysClk              => SysClk,
			SlowEnable          => SlowEnable,
			SynchedTick         => SynchedTick,
			LoopTime            => LoopTime,
			ExpA_CS_L           => ExpA_CS_L,
			ExpA_CLK            => ExpA_CLK,
			Serial2ParallelEN   => Serial2ParallelEN,
			Serial2ParallelCLR  => Serial2ParallelCLR,
			WriteConversion     => WriteConversion
	);
	
	SysClk_process : process
	begin
			SysClk <= '0';
			wait for SysClk_period/2;
			SysClk <= '1';
			wait for SysClk_period/2;
	end process;

	SlowEnable_process : process
	begin
			SlowEnable <= '0';
			wait for 8 * SysClk_period;
			SlowEnable <= '1';
			wait for 8 * SysClk_period;
	end process;
		
	-- Stimulus process
	stim_proc: process
	begin
			wait for 1 us;
			SysReset <= '0';
			LoopTime <= "000";
			
			wait for 1 us;
			SynchedTick <= '1';
			wait for SysClk_period;
			SynchedTick <= '0';
			
			wait for 125 us;
			SynchedTick <= '1';
			wait for SysClk_period;
			SynchedTick <= '0';
			
			wait for 125 us;
			
	end process stim_proc;
end architecture tb;
