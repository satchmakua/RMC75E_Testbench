--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_QuadXface
--	File			tb_QuadXface.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_QuadXface is
end tb_QuadXface;

architecture tb of tb_QuadXface is
    -- Define the component based on the entity
    component QuadXface is
        Port (
            H1_CLKWR            : in std_logic;
            SysClk              : in std_logic;
            SynchedTick         : in std_logic;
            intDATA             : in std_logic_vector(31 downto 0);
            QuadDataOut         : out std_logic_vector(31 downto 0);
            CountRead           : in std_logic;
            LEDStatusRead       : in std_logic;
            LEDStatusWrite      : in std_logic;
            InputRead           : in std_logic;
            HomeRead            : in std_logic;
            Latch0Read          : in std_logic;
            Latch1Read          : in std_logic;
            Home                : in std_logic;
            RegistrationX       : in std_logic;
            RegistrationY       : in std_logic;
            LineFault           : in std_logic_vector(2 downto 0);
            A                   : in std_logic;
            B                   : in std_logic;
            Index               : in std_logic
        );
    end component QuadXface;
    
    -- Define the signals that are connected to the ports of the component
    signal H1_CLKWR            : std_logic;
    signal SysClk              : std_logic;
    signal SynchedTick         : std_logic;
    signal intDATA             : std_logic_vector(31 downto 0);
    signal QuadDataOut         : std_logic_vector(31 downto 0);
    signal CountRead           : std_logic;
    signal LEDStatusRead       : std_logic;
    signal LEDStatusWrite      : std_logic;
    signal InputRead           : std_logic;
    signal HomeRead            : std_logic;
    signal Latch0Read          : std_logic;
    signal Latch1Read          : std_logic;
    signal Home                : std_logic;
    signal RegistrationX       : std_logic;
    signal RegistrationY       : std_logic;
    signal LineFault           : std_logic_vector(2 downto 0);
    signal A                   : std_logic;
    signal B                   : std_logic;
    signal Index               : std_logic;

begin
    -- Instantiate the QuadXface component
    DUT: QuadXface
        port map (
            H1_CLKWR        => H1_CLKWR,
            SysClk          => SysClk,
            SynchedTick     => SynchedTick,
            intDATA         => intDATA,
            QuadDataOut     => QuadDataOut,
            CountRead       => CountRead,
            LEDStatusRead   => LEDStatusRead,
            LEDStatusWrite  => LEDStatusWrite,
            InputRead       => InputRead,
            HomeRead        => HomeRead,
            Latch0Read      => Latch0Read,
            Latch1Read      => Latch1Read,
            Home            => Home,
            RegistrationX   => RegistrationX,
            RegistrationY   => RegistrationY,
            LineFault       => LineFault,
            A               => A,
            B               => B,
            Index           => Index
        );
        
	process
	begin
		-- Initialization
		H1_CLKWR <= '0';
		SysClk <= '0';
		SynchedTick <= '0';
		intDATA <= (others => '0');
		CountRead <= '0';
		LEDStatusRead <= '0';
		LEDStatusWrite <= '0';
		InputRead <= '0';
		HomeRead <= '0';
		Latch0Read <= '0';
		Latch1Read <= '0';
		Home <= '0';
		RegistrationX <= '0';
		RegistrationY <= '0';
		LineFault <= (others => '0');
		A <= '0';
		B <= '0';
		Index <= '0';
		wait for 10 ns;

		-- Apply clock signal
		for i in 1 to 200 loop
			SysClk <= not SysClk;
			wait for 10 ns; -- assuming a 100MHz clock
		end loop;

		-- Scenario 1: Enable LEDStatusWrite while keeping other signals in default state
		LEDStatusWrite <= '1';
		wait for 20 ns;
		LEDStatusWrite <= '0';
		wait for 20 ns;

		-- Scenario 2: Write some data to intDATA
		intDATA <= X"ABCD1234";
		wait for 20 ns;
		intDATA <= (others => '0');
		wait for 20 ns;

		-- Scenario 3: Set Index and B signals, to simulate some event
		B <= '1';
		Index <= '1';
		wait for 20 ns;
		B <= '0';
		Index <= '0';
		wait for 20 ns;

		-- Scenario 4: Enable CountRead, HomeRead, Latch0Read, Latch1Read and observe QuadDataOut
		CountRead <= '1';
		HomeRead <= '1';
		Latch0Read <= '1';
		Latch1Read <= '1';
		wait for 20 ns;
		CountRead <= '0';
		HomeRead <= '0';
		Latch0Read <= '0';
		Latch1Read <= '0';
		wait for 20 ns;

		assert false report "End of Test" severity failure;
	end process;

end tb;

