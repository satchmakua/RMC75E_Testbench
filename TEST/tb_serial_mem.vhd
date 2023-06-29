library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.numeric_std_unsigned.all;

entity tb_SerialMemoryInterface is
end tb_SerialMemoryInterface;

architecture tb_arch of tb_SerialMemoryInterface is
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

    -- Signals
    signal SysReset, H1_CLK, SysClk, SlowEnable, SerialMemXfaceWrite, SerialMemoryDataIn : std_logic;
    signal SerialMemoryDataOut, SerialMemoryDataControl, SerialMemoryClk : std_logic;
    signal intDATA, serialMemDataOut : std_logic_vector(31 downto 0);
    signal Exp0SerialSelect, Exp1SerialSelect, Exp2SerialSelect, Exp3SerialSelect : std_logic;
    signal EEPROMAccessFlag, M_SPROM_CLK, M_SPROM_DATA : std_logic;
    
    constant H1_CLK_PERIOD : time := 1 ns / 60; -- 60 MHz
    constant SYS_CLK_PERIOD : time := 1 ns / 30; -- 30 MHz

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

		-- Clock generators
		process
		begin
				H1_CLK <= '0';
				SysClk <= '0';
				wait for H1_CLK_PERIOD / 2;
				H1_CLK <= '1';
				wait for H1_CLK_PERIOD / 2;
				H1_CLK <= '0';
				wait for H1_CLK_PERIOD / 2;
				H1_CLK <= '1';
				wait for H1_CLK_PERIOD / 2;
				
				wait for SYS_CLK_PERIOD / 2;
				SysClk <= '1';
				wait for SYS_CLK_PERIOD / 2;
				SysClk <= '0';
				wait for SYS_CLK_PERIOD / 2;
				SysClk <= '1';
				wait for SYS_CLK_PERIOD / 2;
				
				-- Repeat the pattern
				while now < 10 ms loop
						wait for H1_CLK_PERIOD;
						H1_CLK <= not H1_CLK;
						wait for SYS_CLK_PERIOD;
						SysClk <= not SysClk;
				end loop;
				H1_CLK <= 'X';
				SysClk <= 'X';
				wait;
		end process;

    -- Stimulus process
    process
    begin
        -- Initialize inputs
        SysReset <= '1';
        SlowEnable <= '0';
        intDATA <= (others => '0');
        SerialMemXfaceWrite <= '0';
        SerialMemoryDataIn <= '0';

        -- Wait for reset to complete
        wait for 10 ns;

        -- Release reset
        SysReset <= '0';
        wait for 10 ns;

        -- Test scenario 1: Write operation
        -- Write data 32'hABCD1234 to the EEPROM
        SerialMemXfaceWrite <= '1';
        intDATA <= "10101011110011010001001000110100";
        wait for 10 ns;
        SerialMemXfaceWrite <= '0';
        wait for 20 ns;

        -- Test scenario 2: Read operation
        -- Read data from the EEPROM
        SerialMemXfaceWrite <= '0';
        wait for 10 ns;
        wait for 20 ns;

        -- Test scenario 3: Write and Read operations
        -- Write data 32'h87654321 to the EEPROM
        SerialMemXfaceWrite <= '1';
        intDATA <= "10000111011001010000110000100001";
        wait for 10 ns;
        SerialMemXfaceWrite <= '0';
        wait for 20 ns;
        -- Read data from the EEPROM
        SerialMemXfaceWrite <= '0';
        wait for 10 ns;
        wait for 20 ns;

        -- Test scenario 4: Write and Read with different data
        -- Write data 32'h55AAFF00 to the EEPROM
        SerialMemXfaceWrite <= '1';
        intDATA <= "01010101101010101111111100000000";
        wait for 10 ns;
        SerialMemXfaceWrite <= '0';
        wait for 20 ns;
        -- Read data from the EEPROM
        SerialMemXfaceWrite <= '0';
        wait for 10 ns;
        wait for 20 ns;

        -- Test scenario 5: Continuous Write and Read operations
        -- Perform multiple write and read operations
        for i in 0 to 9 loop
            -- Write data i to the EEPROM
            SerialMemXfaceWrite <= '1';
            intDATA <= std_logic_vector(unsigned(to_unsigned(i, intDATA'length)));
            wait for 10 ns;
            SerialMemXfaceWrite <= '0';
            wait for 20 ns;
            -- Read data from the EEPROM
            SerialMemXfaceWrite <= '0';
            wait for 10 ns;
            wait for 20 ns;
        end loop;

        -- Additional test scenarios here...

        -- End simulation
        wait;
    end process;

end tb_arch;
