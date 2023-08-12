library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.numeric_std_unsigned.all;

entity tb_SerialMemoryInterface_v2 is
end tb_SerialMemoryInterface_v2;

architecture tb_arch of tb_SerialMemoryInterface_v2 is

    component SerialMemoryInterface
    port (
        SysReset                : in std_logic;
        H1_CLK                  : in std_logic;
        SysClk                  : in std_logic;
        SlowEnable              : in std_logic;
        intDATA                 : in std_logic_vector(31 downto 0);
        serialMemDataOut        : out std_logic_vector(31 downto 0);
        SerialMemXfaceWrite     : in std_logic;
        SerialMemoryDataIn      : in std_logic;
        SerialMemoryDataOut     : out std_logic;
        SerialMemoryDataControl : out std_logic;
        SerialMemoryClk         : out std_logic;
        Exp0SerialSelect        : out std_logic;
        Exp1SerialSelect        : out std_logic;
        Exp2SerialSelect        : out std_logic;
        Exp3SerialSelect        : out std_logic;
        EEPROMAccessFlag        : out std_logic;
        M_SPROM_CLK             : out std_logic;
        M_SPROM_DATA            : inout std_logic
    );
    end component;

    -- Signals
    signal SysReset, H1_CLK, SysClk, SlowEnable, SerialMemXfaceWrite, SerialMemoryDataIn : std_logic;
    signal SerialMemoryDataOut, SerialMemoryDataControl, SerialMemoryClk : std_logic;
    signal intDATA, serialMemDataOut : std_logic_vector(31 downto 0);
    signal Exp0SerialSelect, Exp1SerialSelect, Exp2SerialSelect, Exp3SerialSelect : std_logic;
    signal EEPROMAccessFlag, M_SPROM_CLK : std_logic;
    signal M_SPROM_DATA, M_SPROM_DATA_tb, M_SPROM_DATA_DUT : std_logic := 'Z';

    constant H1_CLK_period : time := 16.6667 ns;
    constant SysClk_period : time := 33.3333 ns;

begin

    M_SPROM_DATA <= M_SPROM_DATA_tb when (M_SPROM_DATA_tb /= 'Z') else M_SPROM_DATA_DUT;

    DUT : SerialMemoryInterface
    port map (
        SysReset => SysReset,
        H1_CLK => H1_CLK,
        SysClk => SysClk,
        SlowEnable => SlowEnable,
        intDATA => intDATA,
        serialMemDataOut => serialMemDataOut,
        SerialMemXfaceWrite => SerialMemXfaceWrite,
        SerialMemoryDataIn => SerialMemoryDataIn,
        SerialMemoryDataOut => SerialMemoryDataOut,
        SerialMemoryDataControl => SerialMemoryDataControl,
        SerialMemoryClk => SerialMemoryClk,
        Exp0SerialSelect => Exp0SerialSelect,
        Exp1SerialSelect => Exp1SerialSelect,
        Exp2SerialSelect => Exp2SerialSelect,
        Exp3SerialSelect => Exp3SerialSelect,
        EEPROMAccessFlag => EEPROMAccessFlag,
        M_SPROM_CLK => M_SPROM_CLK,
        M_SPROM_DATA => M_SPROM_DATA_DUT
    );

    H1_CLK_process : process
    begin
        H1_CLK <= '0';
        wait for H1_CLK_period / 2;
        H1_CLK <= '1';
        wait for H1_CLK_period / 2;
    end process;

    SysClk_process : process
    begin
        SysClk <= '0';
        wait for SysClk_period / 2;
        SysClk <= '1';
        wait for SysClk_period / 2;
    end process;

    SlowEnable_process : process
    begin
        SlowEnable <= '0';
        wait for 7 * SysClk_period;
        SlowEnable <= '1';
        wait for SysClk_period;
    end process;

    process
        variable pulseCounter : natural := 0;
    begin
        wait until falling_edge(M_SPROM_CLK);
        pulseCounter := pulseCounter + 1;

        case pulseCounter is
            when 9 | 18 =>
                M_SPROM_DATA_tb <= '0';
                wait until falling_edge(M_SPROM_CLK);
            when 27 =>  
                M_SPROM_DATA_tb <= '0';
                pulseCounter := 0;
            when others =>
                M_SPROM_DATA_tb <= 'Z';
        end case;
    end process;

    process
    begin
        SysReset <= '1';
        wait for 1 us;
        SysReset <= '0';

        SerialMemoryDataIn <= '0';
        wait for 2 us;

        intDATA(31 downto 25) <= "1010000";
        intDATA(24 downto 22) <= "100";
        intDATA(21 downto 16) <= "000001";
        intDATA(15)            <= '1';
        intDATA(14)            <= '0';
        intDATA(13 downto 8)   <= "000000";
        intDATA(7 downto 0)    <= "11100101";
        SerialMemXfaceWrite <= '1';
        wait for SysClk_period;
				SerialMemXfaceWrite <= '0';
        wait for 300 us;
				
				intDATA(24 downto 22) <= "000";
				SerialMemXfaceWrite <= '1';
        wait for SysClk_period;
				SerialMemXfaceWrite <= '0';
        
        wait;
    end process;

end tb_arch;
