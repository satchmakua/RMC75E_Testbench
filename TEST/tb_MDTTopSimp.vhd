library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_MDTTopSimp is
end tb_MDTTopSimp;

architecture testbench of tb_MDTTopSimp is
  component MDTTopSimp is
    Port (
      SysReset       : in std_logic;
      H1_CLK         : in std_logic;
      H1_CLKWR       : in std_logic;
      H1_CLK90       : in std_logic;
      SynchedTick60  : in std_logic;
      intDATA        : in std_logic_vector(31 downto 0);
      mdtSimpDataOut : out std_logic_vector(31 downto 0);
      PositionRead   : in std_logic;
      StatusRead     : in std_logic;
      ParamWrite     : in std_logic;
      M_INT_CLK      : out std_logic;
      M_RET_DATA     : in std_logic;
      SSI_DATA       : out std_logic;
      SSISelect      : in std_logic
    );
  end component;

  signal SysReset_tb     : std_logic := '1';
  signal H1_CLK_tb       : std_logic := '0';
  signal H1_CLKWR_tb     : std_logic := '0';
  signal H1_CLK90_tb     : std_logic := '0';
  signal SynchedTick60_tb: std_logic := '0';
  signal intDATA_tb      : std_logic_vector(31 downto 0) := (others => '0');
  signal mdtSimpDataOut_tb: std_logic_vector(31 downto 0);
  signal PositionRead_tb : std_logic := '0';
  signal StatusRead_tb   : std_logic := '0';
  signal ParamWrite_tb   : std_logic := '0';
  signal M_INT_CLK_tb    : std_logic;
  signal M_RET_DATA_tb   : std_logic := '0';
  signal SSI_DATA_tb     : std_logic;
  signal SSISelect_tb    : std_logic := '0';
  
  constant H1_CLK_PERIOD : time := 16.6667 ns; -- 60 MHz
  constant num_cycles : integer := 100; -- This gives a simulation time of around 1000us.

begin
  dut: MDTTopSimp
    Port map (
      SysReset       => SysReset_tb,
      H1_CLK         => H1_CLK_tb,
      H1_CLKWR       => H1_CLKWR_tb,
      H1_CLK90       => H1_CLK90_tb,
      SynchedTick60  => SynchedTick60_tb,
      intDATA        => intDATA_tb,
      mdtSimpDataOut => mdtSimpDataOut_tb,
      PositionRead   => PositionRead_tb,
      StatusRead     => StatusRead_tb,
      ParamWrite     => ParamWrite_tb,
      M_INT_CLK      => M_INT_CLK_tb,
      M_RET_DATA     => M_RET_DATA_tb,
      SSI_DATA       => SSI_DATA_tb,
      SSISelect      => SSISelect_tb
    );

  -- Generate H1_CLK_tb
  clk_gen: process
  begin
    wait for H1_CLK_PERIOD / 2;
    H1_CLK_tb <= not H1_CLK_tb;
  end process clk_gen;

	-- Generate H1_CLKWR_tb
	clkwr_gen: process
	begin
		wait for H1_CLK_PERIOD;
		H1_CLKWR_tb <= not H1_CLKWR_tb;
	end process clkwr_gen;

	-- Generate H1_CLK90_tb with 90-degree phase shift
	clk90_gen: process
	begin
		wait for H1_CLK_PERIOD / 4; -- initial delay for 90-degree phase shift
		while true loop
			wait for H1_CLK_PERIOD / 2;
			H1_CLK90_tb <= not H1_CLK90_tb;
		end loop;
	end process clk90_gen;


  -- System initialization
  reset_gen: process
	begin
		wait for H1_CLK_PERIOD * 2; -- wait for one 30 MHz clock cycle
		SysReset_tb <= '0'; -- end of system reset
		wait for H1_CLK_PERIOD * 2;
		ParamWrite_tb <= '1'; -- start of system configuration
		intDATA_tb <= "00000000000000000000000000001011"; -- selecting the 11th transducer
		wait for H1_CLK_PERIOD * 2;
		ParamWrite_tb <= '0'; -- end of system configuration
    wait for H1_CLK_PERIOD;
    SynchedTick60_tb <= '1'; -- first tick
    wait for H1_CLK_PERIOD;
    SynchedTick60_tb <= '0'; -- end of first tick
    wait for 1 us - 4 * H1_CLK_PERIOD;
    M_RET_DATA_tb <= '1'; -- start of 8us pulse on M_RET_DATA_tb
    wait for 8 us;
    M_RET_DATA_tb <= '0'; -- end of 8us pulse on M_RET_DATA_tb
    wait for 30 us - 1 us - 8 us;
    SynchedTick60_tb <= '1'; -- second tick
    wait for H1_CLK_PERIOD;
    SynchedTick60_tb <= '0'; -- end of second tick
    wait;
  end process reset_gen;
end testbench;
