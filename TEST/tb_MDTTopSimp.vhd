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
  signal DelayCountEnable: std_logic := '0';
  signal MDTSelect_tb    : std_logic_vector(0 to 1) := (others => '0');

  constant H1_CLK_PERIOD : time := 16.6667 ns; -- 60 MHz
  constant num_cycles : integer := 60000; -- This gives a simulation time of around 1000us.

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
    wait for H1_CLK_PERIOD / 4;
    while true loop
      wait for H1_CLK_PERIOD / 2;
      H1_CLKWR_tb <= not H1_CLKWR_tb;
    end loop;
  end process clkwr_gen;

  -- Generate H1_CLK90_tb
  clk90_gen: process
  begin
    wait for H1_CLK_PERIOD / 4;
    while true loop
      wait for H1_CLK_PERIOD / 2;
      H1_CLK90_tb <= not H1_CLK90_tb;
    end loop;
  end process clk90_gen;

  -- System initialization
  reset_gen: process
  begin
    wait for 20 * H1_CLK_PERIOD;
    SysReset_tb <= '0';
    wait for 10 * H1_CLK_PERIOD; -- Wait before starting SynchedTick60
    SynchedTick60_tb <= '1'; -- Start SynchedTick60 after the sysreset signal goes from high to low.
    wait for 8 us;
    SynchedTick60_tb <= '0'; -- Make SynchedTick60 one clock cycle long
    wait;
  end process reset_gen;

  signal_gen: process
  begin
    for i in 1 to num_cycles loop
      wait until rising_edge(H1_CLK_tb);

      if i = 2 then
        MDTSelect_tb <= "01"; -- set MDTSelect_tb to "01" to enable transducer selection
      end if;

      if i = 5 then
        ParamWrite_tb <= '1'; -- Set ParamWrite_tb high for one cycle of H1_CLKWR_tb
        intDATA_tb(1 downto 0) <= "11"; -- set intDATA_tb(1 downto 0) to "11" (PWMXducer)
      elsif i = 6 then
        ParamWrite_tb <= '0';
        intDATA_tb(1 downto 0) <= (others => '0');
      end if;

      -- Simulate counter overflow condition
      if i = 200 then
        M_RET_DATA_tb <= '1'; -- Simulate CounterOverFlowRetrigger condition
      elsif i = 210 then
        M_RET_DATA_tb <= '0';
      end if;

      -- Generate a long pulse on M_RET_DATA_tb, starting around 1 us and lasting about 8 us
      if i >= 60 and i <= 480 then
        M_RET_DATA_tb <= '1';
      else
        M_RET_DATA_tb <= '0';
      end if;

      -- Delay the MDTSelect signal by one clock cycle
      MDTSelect_tb <= '0' & MDTSelect_tb(0);
      
      -- Generate DelayCountEnable signal based on conditions in the DUT code
      if SynchedTick60_tb = '1' or (DelayCountEnable = '1' and MDTSelect_tb(1) = '0') then
        DelayCountEnable <= '1';
      else
        DelayCountEnable <= '0';
      end if;

      -- Assign DelayCountEnable to M_INT_CLK_tb
      M_INT_CLK_tb <= DelayCountEnable;

    end loop;
    wait;
  end process signal_gen;

  -- Add assert checks to ensure the signals are valid
  assert_chk: process
  begin
    for i in 1 to num_cycles loop
      wait until rising_edge(H1_CLK_tb);

      -- Checking for undefined states
      assert (SysReset_tb /= 'U' and H1_CLK_tb /= 'U' and H1_CLKWR_tb /= 'U' and H1_CLK90_tb /= 'U' and 
              SynchedTick60_tb /= 'U' and intDATA_tb /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU") 
      report "Uninitialized signal found" severity failure;

      if i = num_cycles then
        assert false report "Simulation finished successfully" severity note;
      end if;

    end loop;
    wait;
  end process assert_chk;

end testbench;
