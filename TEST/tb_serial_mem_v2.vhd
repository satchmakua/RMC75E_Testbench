

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.numeric_std_unsigned.all;

entity tb_SerialMemoryInterface_v2 is
end tb_SerialMemoryInterface_v2;

architecture tb_arch of tb_SerialMemoryInterface_v2 is
    -- Component declaration
    component SerialMemoryInterface
    port (
        SysReset                : in std_logic;          -- System Reset or PLL not locked
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
		
		-- Input data
		-- constant shift_register_input_0		: std_logic_vector(31 downto 0) := X"FF00FF00";
		
    -- Signals
    signal SysReset, H1_CLK, SysClk, SlowEnable, SerialMemXfaceWrite, SerialMemoryDataIn : std_logic;
    signal SerialMemoryDataOut, SerialMemoryDataControl, SerialMemoryClk : std_logic;
    signal intDATA, serialMemDataOut : std_logic_vector(31 downto 0);
    signal Exp0SerialSelect, Exp1SerialSelect, Exp2SerialSelect, Exp3SerialSelect : std_logic;
    signal EEPROMAccessFlag, M_SPROM_CLK, M_SPROM_DATA : std_logic;
    
    -- Clock period definitions
    constant H1_CLK_period : time := 16.6667 ns;
    constant SysClk_period : time := 33.3333 ns;

begin

    -- Instantiate the SerialMemoryInterface component
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
        M_SPROM_DATA => M_SPROM_DATA
    );

    -- Clock process definitions
    H1_CLK_process : process
    begin
        H1_CLK <= '0';
        wait for H1_CLK_period/2;
        H1_CLK <= '1';
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

    -- Stimulus process
    process
    begin
        -- Initialize inputs
				SysReset <= '1';
				wait for 1 us;
        SysReset <= '0';
				
				wait for 2 us;
				
				intDATA(31 downto 25) <= "1010000"; -- device address
				intDATA(24 downto 22) <= "100"; -- module address
				intDATA(21 downto 16) <= "000001"; -- memory address
				intDATA(15) 					<= '1'; -- write operation
				intDATA(14) 					<= '0'; -- read operation
				intDATA(13 downto 8) 	<= "000000"; -- unused
				intDATA(7 downto 0) 	<= "11100101"; -- data buffer
				
				SerialMemoryDataIn <= '1';
				
				SerialMemXfaceWrite <= '1';
				wait for SysClk_period;
				SerialMemXfaceWrite <= '0';
				
				wait for 325 us;
				
				intDATA(24 downto 22) <= "000";

				SerialMemoryDataIn <= '0';
				
				SerialMemXfaceWrite <= '1';
				wait for SysClk_period;
				SerialMemXfaceWrite <= '0';
				
				wait for 1000 us;
    end process;

end tb_arch;
