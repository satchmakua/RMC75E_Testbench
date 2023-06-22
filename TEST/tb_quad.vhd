--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_quad
--	File			tb_quad.vhd
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

entity tb_quad is
end tb_quad;

architecture tb of tb_quad is

    -- Component declaration
    component Quad is
        Port (
            H1_CLKWR                : in std_logic;
            SysClk                  : in std_logic;
            SynchedTick             : in std_logic;
            intDATA                 : in std_logic_vector(31 downto 0);
            Exp0QuadDataOut         : out std_logic_vector(31 downto 0);
            Exp1QuadDataOut         : out std_logic_vector(31 downto 0);
            Exp2QuadDataOut         : out std_logic_vector(31 downto 0);
            Exp3QuadDataOut         : out std_logic_vector(31 downto 0);
            QuadA0DataOut           : out std_logic_vector(31 downto 0);
            QuadA1DataOut           : out std_logic_vector(31 downto 0);
            Exp0QuadCountRead       : in std_logic;
            Exp0QuadLEDStatusRead   : in std_logic;
            Exp0QuadLEDStatusWrite  : in std_logic;
            Exp0QuadInputRead       : in std_logic;
            Exp0QuadHomeRead        : in std_logic;
            Exp0QuadLatch0Read      : in std_logic;
            Exp0QuadLatch1Read      : in std_logic;
            Exp1QuadCountRead       : in std_logic;
            Exp1QuadLEDStatusRead   : in std_logic;
            Exp1QuadLEDStatusWrite  : in std_logic;
            Exp1QuadInputRead       : in std_logic;
            Exp1QuadHomeRead        : in std_logic;
            Exp1QuadLatch0Read      : in std_logic;
            Exp1QuadLatch1Read      : in std_logic;
            Exp2QuadCountRead       : in std_logic;
            Exp2QuadLEDStatusRead   : in std_logic;
            Exp2QuadLEDStatusWrite  : in std_logic;
            Exp2QuadInputRead       : in std_logic;
            Exp2QuadHomeRead        : in std_logic;
            Exp2QuadLatch0Read      : in std_logic;
            Exp2QuadLatch1Read      : in std_logic;
            Exp3QuadCountRead       : in std_logic;
            Exp3QuadLEDStatusRead   : in std_logic;
            Exp3QuadLEDStatusWrite  : in std_logic;
            Exp3QuadInputRead       : in std_logic;
            Exp3QuadHomeRead        : in std_logic;
            Exp3QuadLatch0Read      : in std_logic;
            Exp3QuadLatch1Read      : in std_logic;
            Exp0Quad_A              : in std_logic;
            Exp0Quad_B              : in std_logic;
            Exp0Quad_Reg            : in std_logic;
            Exp0Quad_FaultA         : in std_logic;
            Exp0Quad_FaultB         : in std_logic;
            Exp1Quad_A              : in std_logic;
            Exp1Quad_B              : in std_logic;
            Exp1Quad_Reg            : in std_logic;
            Exp1Quad_FaultA         : in std_logic;
            Exp1Quad_FaultB         : in std_logic;
            Exp2Quad_A              : in std_logic;
            Exp2Quad_B              : in std_logic;
            Exp2Quad_Reg            : in std_logic;
            Exp2Quad_FaultA         : in std_logic;
            Exp2Quad_FaultB         : in std_logic;
            Exp3Quad_A              : in std_logic;
            Exp3Quad_B              : in std_logic;
            Exp3Quad_Reg            : in std_logic;
            Exp3Quad_FaultA         : in std_logic;
            Exp3Quad_FaultB         : in std_logic;
            QuadA0                  : in std_logic;
            QuadB0                  : in std_logic;
            QuadReg0                : in std_logic;
            QuadA1                  : in std_logic;
            QuadB1                  : in std_logic;
            QuadReg1                : in std_logic;
            Enable_Rst              : in std_logic;
            QA0CountRead            : in std_logic;
            QA0LEDStatusRead        : in std_logic;
            QA0LEDStatusWrite       : in std_logic;
            QA0InputRead            : in std_logic;
            QA0HomeRead             : in std_logic;
            QA0Latch0Read           : in std_logic;
            QA0Latch1Read           : in std_logic;
            QA1CountRead            : in std_logic;
            QA1LEDStatusRead        : in std_logic;
            QA1LEDStatusWrite       : in std_logic;
            QA1InputRead            : in std_logic;
            QA1HomeRead             : in std_logic;
            QA1Latch0Read           : in std_logic;
            QA1Latch1Read           : in std_logic;
            QA0_SigA                : in std_logic;
            QA0_SigB                : in std_logic;
            QA0_SigZ                : in std_logic;
            QA0_Home                : in std_logic;
            QA0_RegX_PosLmt         : in std_logic;
            QA0_RegY_NegLmt         : in std_logic;
            QA1_SigA                : in std_logic;
            QA1_SigB                : in std_logic;
            QA1_SigZ                : in std_logic;
            QA1_Home                : in std_logic;
            QA1_RegX_PosLmt         : in std_logic;
            QA1_RegY_NegLmt         : in std_logic;
            QA0AxisFault            : in std_logic_vector(2 downto 0);
            QA1AxisFault            : in std_logic_vector(2 downto 0)
        );
    end component;

    -- Constants
    constant H1_CLK_PERIOD     : time := 16.6667 ns; -- 60 MHz
    constant num_cycles        : integer := 100; -- This gives a simulation time of around 1000us

    -- Signals
    signal H1_CLKWR            : std_logic := '0';
    signal SysClk              : std_logic := '0';
    signal SynchedTick         : std_logic := '0';
    signal intDATA             : std_logic_vector(31 downto 0) := (others => '0');
    signal Exp0QuadDataOut     : std_logic_vector(31 downto 0);
    signal Exp1QuadDataOut     : std_logic_vector(31 downto 0);
    signal Exp2QuadDataOut     : std_logic_vector(31 downto 0);
    signal Exp3QuadDataOut     : std_logic_vector(31 downto 0);
    signal QuadA0DataOut       : std_logic_vector(31 downto 0);
    signal QuadA1DataOut       : std_logic_vector(31 downto 0);
    signal Exp0QuadCountRead   : std_logic := '0';
    signal Exp0QuadLEDStatusRead : std_logic := '0';
    signal Exp0QuadLEDStatusWrite : std_logic := '0';
    signal Exp0QuadInputRead   : std_logic := '0';
    signal Exp0QuadHomeRead    : std_logic := '0';
    signal Exp0QuadLatch0Read  : std_logic := '0';
    signal Exp0QuadLatch1Read  : std_logic := '0';
    signal Exp1QuadCountRead   : std_logic := '0';
    signal Exp1QuadLEDStatusRead : std_logic := '0';
    signal Exp1QuadLEDStatusWrite : std_logic := '0';
    signal Exp1QuadInputRead   : std_logic := '0';
    signal Exp1QuadHomeRead    : std_logic := '0';
    signal Exp1QuadLatch0Read  : std_logic := '0';
    signal Exp1QuadLatch1Read  : std_logic := '0';
    signal Exp2QuadCountRead   : std_logic := '0';
    signal Exp2QuadLEDStatusRead : std_logic := '0';
    signal Exp2QuadLEDStatusWrite : std_logic := '0';
    signal Exp2QuadInputRead   : std_logic := '0';
    signal Exp2QuadHomeRead    : std_logic := '0';
    signal Exp2QuadLatch0Read  : std_logic := '0';
    signal Exp2QuadLatch1Read  : std_logic := '0';
    signal Exp3QuadCountRead   : std_logic := '0';
    signal Exp3QuadLEDStatusRead : std_logic := '0';
    signal Exp3QuadLEDStatusWrite : std_logic := '0';
    signal Exp3QuadInputRead   : std_logic := '0';
    signal Exp3QuadHomeRead    : std_logic := '0';
    signal Exp3QuadLatch0Read  : std_logic := '0';
    signal Exp3QuadLatch1Read  : std_logic := '0';
    signal Exp0Quad_A          : std_logic := '0';
    signal Exp0Quad_B          : std_logic := '0';
    signal Exp0Quad_Reg        : std_logic := '0';
    signal Exp0Quad_FaultA     : std_logic := '0';
    signal Exp0Quad_FaultB     : std_logic := '0';
    signal Exp1Quad_A          : std_logic := '0';
    signal Exp1Quad_B          : std_logic := '0';
    signal Exp1Quad_Reg        : std_logic := '0';
    signal Exp1Quad_FaultA     : std_logic := '0';
    signal Exp1Quad_FaultB     : std_logic := '0';
    signal Exp2Quad_A          : std_logic := '0';
    signal Exp2Quad_B          : std_logic := '0';
    signal Exp2Quad_Reg        : std_logic := '0';
    signal Exp2Quad_FaultA     : std_logic := '0';
    signal Exp2Quad_FaultB     : std_logic := '0';
    signal Exp3Quad_A          : std_logic := '0';
    signal Exp3Quad_B          : std_logic := '0';
    signal Exp3Quad_Reg        : std_logic := '0';
    signal Exp3Quad_FaultA     : std_logic := '0';
    signal Exp3Quad_FaultB     : std_logic := '0';
    signal QuadA0              : std_logic := '0';
    signal QuadB0              : std_logic := '0';
    signal QuadReg0            : std_logic := '0';
    signal QuadA1              : std_logic := '0';
    signal QuadB1              : std_logic := '0';
    signal QuadReg1            : std_logic := '0';
    signal QA0CountRead        : std_logic := '0';
    signal QA0LEDStatusRead    : std_logic := '0';
    signal QA0LEDStatusWrite   : std_logic := '0';
    signal QA0InputRead        : std_logic := '0';
    signal QA0HomeRead         : std_logic := '0';
    signal QA0Latch0Read       : std_logic := '0';
    signal QA0Latch1Read       : std_logic := '0';
    signal QA1CountRead        : std_logic := '0';
    signal QA1LEDStatusRead    : std_logic := '0';
    signal QA1LEDStatusWrite   : std_logic := '0';
    signal QA1InputRead        : std_logic := '0';
    signal QA1HomeRead         : std_logic := '0';
    signal QA1Latch0Read       : std_logic := '0';
    signal QA1Latch1Read       : std_logic := '0';
    signal QA0_SigA            : std_logic := '0';
    signal QA0_SigB            : std_logic := '0';
    signal QA0_SigZ            : std_logic := '0';
    signal QA0_Home            : std_logic := '0';
    signal QA0_RegX_PosLmt     : std_logic := '0';
    signal QA0_RegY_NegLmt     : std_logic := '0';
    signal QA1_SigA            : std_logic := '0';
    signal QA1_SigB            : std_logic := '0';
    signal QA1_SigZ            : std_logic := '0';
    signal QA1_Home            : std_logic := '0';
    signal QA1_RegX_PosLmt     : std_logic := '0';
    signal QA1_RegY_NegLmt     : std_logic := '0';
    signal QA0AxisFault        : std_logic_vector(2 downto 0);
    signal QA1AxisFault        : std_logic_vector(2 downto 0);
		
		begin
    -- Clock process
    sysclk_gen: process
    begin
        wait for H1_CLK_PERIOD;
        while true loop
            SysClk <= '0';
            wait for H1_CLK_PERIOD;
            SysClk <= '1';
            wait for H1_CLK_PERIOD;
        end loop;
    end process sysclk_gen;
		
		-- Clock process
    h1_clkwr_gen: process
    begin
        wait for 2 * H1_CLK_PERIOD;
        while true loop
            H1_CLKWR <= '0';
            wait for 2 * H1_CLK_PERIOD;
            H1_CLKWR <= '1';
            wait for 2 * H1_CLK_PERIOD;
        end loop;
    end process h1_clkwr_gen;

    -- Stimulus process
    stimulus_process: process
    begin
			-- Wait for initial reset period
			wait for 2 * H1_CLK_PERIOD;
			
			-- Set SynchedTick to send pulses at 1 us and 8 us
			SynchedTick <= '0';
			wait for 1 us;
			SynchedTick <= '1';
			wait for 2 * H1_CLK_PERIOD;
			SynchedTick <= '0';
			wait for 2 * H1_CLK_PERIOD;
			wait for 7 us;
			SynchedTick <= '1';
			wait for 2 * H1_CLK_PERIOD;
			SynchedTick <= '0';
			wait for 2 * H1_CLK_PERIOD;

			-- Apply stimulus
			for i in 1 to num_cycles loop
				-- Set input values
				Exp0Quad_A <= '1';
				Exp0Quad_B <= '0';
				Exp0Quad_Reg <= '1';
				Exp0Quad_FaultA <= '0';
				Exp0Quad_FaultB <= '1';
				Exp1Quad_A <= '0';
				Exp1Quad_B <= '1';
				Exp1Quad_Reg <= '1';
				Exp1Quad_FaultA <= '1';
				Exp1Quad_FaultB <= '0';
				Exp2Quad_A <= '1';
				Exp2Quad_B <= '1';
				Exp2Quad_Reg <= '0';
				Exp2Quad_FaultA <= '1';
				Exp2Quad_FaultB <= '1';
				Exp3Quad_A <= '0';
				Exp3Quad_B <= '0';
				Exp3Quad_Reg <= '0';
				Exp3Quad_FaultA <= '0';
				Exp3Quad_FaultB <= '0';
				QuadA0 <= '1';
				QuadB0 <= '0';
				QuadReg0 <= '1';
				QuadA1 <= '0';
				QuadB1 <= '1';
				QuadReg1 <= '0';

				-- Set output read signals
				Exp0QuadCountRead <= '1';
				Exp0QuadLEDStatusRead <= '1';
				Exp0QuadLEDStatusWrite <= '0';
				Exp0QuadInputRead <= '1';
				Exp0QuadHomeRead <= '0';
				Exp0QuadLatch0Read <= '1';
				Exp0QuadLatch1Read <= '0';
				Exp1QuadCountRead <= '1';
				Exp1QuadLEDStatusRead <= '0';
				Exp1QuadLEDStatusWrite <= '1';
				Exp1QuadInputRead <= '0';
				Exp1QuadHomeRead <= '1';
				Exp1QuadLatch0Read <= '0';
				Exp1QuadLatch1Read <= '1';
				Exp2QuadCountRead <= '1';
				Exp2QuadLEDStatusRead <= '1';
				Exp2QuadLEDStatusWrite <= '0';
				Exp2QuadInputRead <= '1';
				Exp2QuadHomeRead <= '0';
				Exp2QuadLatch0Read <= '1';
				Exp2QuadLatch1Read <= '0';
				Exp3QuadCountRead <= '0';
				Exp3QuadLEDStatusRead <= '1';
				Exp3QuadLEDStatusWrite <= '1';
				Exp3QuadInputRead <= '0';
				Exp3QuadHomeRead <= '1';
				Exp3QuadLatch0Read <= '0';
				Exp3QuadLatch1Read <= '1';
				QA0CountRead <= '1';
				QA0LEDStatusRead <= '0';
				QA0LEDStatusWrite <= '1';
				QA0InputRead <= '0';
				QA0HomeRead <= '1';
				QA0Latch0Read <= '1';
				QA0Latch1Read <= '0';
				QA1CountRead <= '0';
				QA1LEDStatusRead <= '1';
				QA1LEDStatusWrite <= '1';
				QA1InputRead <= '1';
				QA1HomeRead <= '0';
				QA1Latch0Read <= '1';
				QA1Latch1Read <= '0';

				-- Wait for clock cycle
				wait for H1_CLK_PERIOD;
			end loop;
			-- End simulation
			wait;
		end process stimulus_process;
end tb;

