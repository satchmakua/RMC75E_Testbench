library ieee;
use ieee.std_logic_1164.all;

entity tb_DiscoverModules is
end tb_DiscoverModules;

architecture tb of tb_DiscoverModules is
  -- Constants for clock and slow enable
  constant SysClk_period : time := 33.3333 ns; -- 30 MHz clock
  constant Slow_period : time := 200 ns;       -- 5 MHz slow enable

  -- Signals for the modules
  signal RESET : std_logic := '0';
  signal SysClk : std_logic := '0';
  signal SlowEnable : std_logic := '0';
  signal ControlID : std_logic_vector(16 downto 0) := (others => '0');
  signal M_Card_ID_CLK : std_logic;
  signal M_Card_ID_DATA : std_logic := '0';
  signal M_Card_ID_LATCH : std_logic;
  signal M_Card_ID_LOAD : std_logic;
  signal ExpansionID0 : std_logic_vector(16 downto 0) := (others => '0');
  signal ExpansionID1 : std_logic_vector(16 downto 0) := (others => '0');
  signal ExpansionID2 : std_logic_vector(16 downto 0) := (others => '0');
  signal ExpansionID3 : std_logic_vector(16 downto 0) := (others => '0');
  signal Exp_ID_CLK : std_logic;
  signal Exp_ID_DATA : std_logic := '0';
  signal Exp_ID_LATCH : std_logic;
  signal Exp_ID_LOAD : std_logic;
  signal discoverIdDataOut : std_logic_vector(31 downto 0) := (others => '0');
  signal FPGAIDRead, ControlCardIDRead, Expansion1IDRead, Expansion2IDRead, Expansion3IDRead, Expansion4IDRead : std_logic := '0';
  signal MDTPresent, ANLGPresent, QUADPresent, DiscoveryComplete, ExpOldAP2, ENET_Build : std_logic; 
	signal Exp0Mux        : std_logic_vector(1 downto 0);
  signal Exp1Mux        : std_logic_vector(1 downto 0);
  signal Exp2Mux        : std_logic_vector(1 downto 0);
  signal Exp3Mux        : std_logic_vector(1 downto 0);
	
begin
  -- Instantiate the units under test (DUTs)
  DUT_DiscoverControlID: entity work.DiscoverControlID
    port map (
      RESET => RESET,
      SysClk => SysClk,
      SlowEnable => SlowEnable,
      ControlID => ControlID,
      M_Card_ID_CLK => M_Card_ID_CLK,
      M_Card_ID_DATA => M_Card_ID_DATA,
      M_Card_ID_LATCH => M_Card_ID_LATCH,
      M_Card_ID_LOAD => M_Card_ID_LOAD
    );

  DUT_DiscoverExpansionID: entity work.DiscoverExpansionID
    port map (
      RESET => RESET,
      SysClk => SysClk,
      SlowEnable => SlowEnable,
      ExpansionID0 => ExpansionID0,
      ExpansionID1 => ExpansionID1,
      ExpansionID2 => ExpansionID2,
      ExpansionID3 => ExpansionID3,
      Exp_ID_CLK => Exp_ID_CLK,
      Exp_ID_DATA => Exp_ID_DATA,
      Exp_ID_LATCH => Exp_ID_LATCH,
      Exp_ID_LOAD => Exp_ID_LOAD
    );

  DUT_DiscoverID: entity work.DiscoverID
    port map (
      RESET => RESET,
      SysClk => SysClk,
      SlowEnable => SlowEnable,
      discoverIdDataOut => discoverIdDataOut,
      FPGAIDRead => FPGAIDRead,
      ControlCardIDRead => ControlCardIDRead,
      Expansion1IDRead => Expansion1IDRead,
      Expansion2IDRead => Expansion2IDRead,
      Expansion3IDRead => Expansion3IDRead,
      Expansion4IDRead => Expansion4IDRead,
      M_Card_ID_CLK => M_Card_ID_CLK,
      M_Card_ID_DATA => M_Card_ID_DATA,
      M_Card_ID_LATCH => M_Card_ID_LATCH,
      M_Card_ID_LOAD => M_Card_ID_LOAD,
      Exp_ID_CLK => Exp_ID_CLK,
      Exp_ID_DATA => Exp_ID_DATA,
      Exp_ID_LATCH => Exp_ID_LATCH,
      Exp_ID_LOAD => Exp_ID_LOAD,
      MDTPresent => MDTPresent,
      ANLGPresent => ANLGPresent,
      QUADPresent => QUADPresent,
      DiscoveryComplete => DiscoveryComplete,
      ENET_Build => ENET_Build
    );

  -- Clock generation process
  clk_process : process
  begin
    SysClk <= '0';
    wait for SysClk_period / 2;
    SysClk <= '1';
    wait for SysClk_period / 2;
  end process clk_process;

  -- Slow enable generation process
  SlowEnable_process : process
  begin
    SlowEnable <= '0';
    wait for 7 * SysClk_period; -- Delay to allow DUTs to stabilize
    SlowEnable <= '1';
    wait for SysClk_period;
  end process SlowEnable_process;

  -- Testbench process
  tb_process : process
  begin
    -- Reset sequence
    RESET <= '1';
    wait for 50 ns;
    RESET <= '0';
    wait for 50 ns;

    FPGAIDRead <= '1';
    wait for 100 ns;
    FPGAIDRead <= '0';

    ControlCardIDRead <= '1';
    wait for 100 ns;
    ControlCardIDRead <= '0';

    Expansion1IDRead <= '1';
    wait for 100 ns;
    Expansion1IDRead <= '0';

    Expansion2IDRead <= '1';
    wait for 100 ns;
    Expansion2IDRead <= '0';

    Expansion3IDRead <= '1';
    wait for 100 ns;
    Expansion3IDRead <= '0';

    Expansion4IDRead <= '1';
    wait for 100 ns;
    Expansion4IDRead <= '0';
		
		Exp0Mux <= (others => '0');
    Exp1Mux <= (others => '0');
    Exp2Mux <= (others => '0');
    Exp3Mux <= (others => '0');
		ExpOldAP2 <= '0';
		
    -- Wait for completion of the discovery process
    wait until DiscoveryComplete = '1';
		
    -- End of testbench
    assert false report "End of testbench" severity note;
    wait;
  end process tb_process;
end tb;


