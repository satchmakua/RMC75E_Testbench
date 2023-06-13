
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_MDTTopSimp_v4 is
end tb_MDTTopSimp_v4;

architecture testbench of tb_MDTTopSimp_v4 is
  -- Component declaration for the DUT (MDTTopSimp)
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

  -- Signals
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
  signal M_RET_DATA_tb   : std_logic;
  signal SSI_DATA_tb     : std_logic;
  signal SSISelect_tb    : std_logic := '0';

  constant H1_CLK_PERIOD : time := 16.6667 ns; -- 60 MHz

begin
  -- Instantiate the DUT (MDTTopSimp)
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

   -- Clock generator process
  process
    constant num_cycles: integer := 50;
    variable phase_shift: boolean := false;
  begin
    -- Wait for SysReset_tb transition
    wait until falling_edge(SysReset_tb);
    wait for H1_CLK_PERIOD;

    for i in 1 to num_cycles loop
      -- Toggle H1_CLK_tb
      H1_CLK_tb <= not H1_CLK_tb;
      wait for H1_CLK_PERIOD/4;
      
      -- Toggle H1_CLK90_tb
      if phase_shift then
        H1_CLK90_tb <= not H1_CLK90_tb;
        phase_shift := false;
      else
        phase_shift := true;
      end if;
      wait for H1_CLK_PERIOD/4;
      
      -- Toggle H1_CLKWR_tb (only once per loop)
      if i = 1 then
        H1_CLKWR_tb <= not H1_CLKWR_tb;
      end if;
      wait for H1_CLK_PERIOD/4;
      
      -- Toggle H1_CLK_tb again
      H1_CLK_tb <= not H1_CLK_tb;
      wait for H1_CLK_PERIOD/4;
      
      -- Toggle H1_CLK90_tb again
      if phase_shift then
        H1_CLK90_tb <= not H1_CLK90_tb;
        phase_shift := false;
      else
        phase_shift := true;
      end if;
    end loop;

    wait;
  end process;

  -- Stimulus process
  process
    constant reset_duration: time := (5/6) * H1_CLK_PERIOD;
  begin
    -- Reset the system
    SysReset_tb <= '0';
    wait for reset_duration;
    SysReset_tb <= '1';
    wait for reset_duration;
    SysReset_tb <= '0';

    -- Wait for a few clock cycles to observe the system "turn on"
    wait for 100 ns;

    -- Configure transducer type to PWM
    wait until falling_edge(SysReset_tb);
    wait for H1_CLK_PERIOD;
    ParamWrite_tb <= '1';
    intDATA_tb(1 downto 0) <= "11"; -- PWMXducer
    wait for H1_CLK_PERIOD;
    ParamWrite_tb <= '0';

    -- Generate a long pulse on M_RET_DATA_tb
    wait until falling_edge(SysReset_tb);
    wait for H1_CLK_PERIOD;
    M_RET_DATA_tb <= '1';
    wait for 1 us;
    M_RET_DATA_tb <= '0';
    wait for 8 us;

    -- Stop the simulation
    wait;
  end process;

end testbench;

