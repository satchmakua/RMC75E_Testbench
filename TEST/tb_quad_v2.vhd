library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;

entity tb_quad_v2 is
end tb_quad_v2;
	
architecture tb of tb_quad_v2 is

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

    -- Component declaration for QuadXface
    component QuadXface is
        -- Component ports declaration
        ...
    end component;

    -- Clock period definitions
    constant H1_CLK_period : time := 16.6667 ns;
    constant SysClk_period : time := 33.3333 ns;
		
		-- Quad Signals 
    signal H1_CLKWR              : std_logic := '0';
    signal SysClk                : std_logic := '0';
    signal SynchedTick           : std_logic := '0';
    signal intDATA               : std_logic_vector(31 downto 0) := (others => '0');
    signal Exp0QuadDataOut       : std_logic_vector(31 downto 0);
    signal Exp1QuadDataOut       : std_logic_vector(31 downto 0);
    signal Exp2QuadDataOut       : std_logic_vector(31 downto 0);
    signal Exp3QuadDataOut       : std_logic_vector(31 downto 0);
    signal QuadA0DataOut         : std_logic_vector(31 downto 0);
    signal QuadA1DataOut         : std_logic_vector(31 downto 0);
    signal Exp0QuadCountRead     : std_logic := '0';
    signal Exp0QuadLEDStatusRead : std_logic := '0';
    signal Exp0QuadLEDStatusWrite: std_logic := '0';
    signal Exp0QuadInputRead     : std_logic := '0';
    signal Exp0QuadHomeRead      : std_logic := '0';
    signal Exp0QuadLatch0Read    : std_logic := '0';
    signal Exp0QuadLatch1Read    : std_logic := '0';
    signal Exp1QuadCountRead     : std_logic := '0';
    signal Exp1QuadLEDStatusRead : std_logic := '0';
    signal Exp1QuadLEDStatusWrite: std_logic := '0';
    signal Exp1QuadInputRead     : std_logic := '0';
    signal Exp1QuadHomeRead      : std_logic := '0';
    signal Exp1QuadLatch0Read    : std_logic := '0';
    signal Exp1QuadLatch1Read    : std_logic := '0';
    signal Exp2QuadCountRead     : std_logic := '0';
    signal Exp2QuadLEDStatusRead : std_logic := '0';
    signal Exp2QuadLEDStatusWrite: std_logic := '0';
    signal Exp2QuadInputRead     : std_logic := '0';
    signal Exp2QuadHomeRead      : std_logic := '0';
    signal Exp2QuadLatch0Read    : std_logic := '0';
    signal Exp2QuadLatch1Read    : std_logic := '0';
    signal Exp3QuadCountRead     : std_logic := '0';
    signal Exp3QuadLEDStatusRead : std_logic := '0';
    signal Exp3QuadLEDStatusWrite: std_logic := '0';
    signal Exp3QuadInputRead     : std_logic := '0';
    signal Exp3QuadHomeRead      : std_logic := '0';
    signal Exp3QuadLatch0Read    : std_logic := '0';
    signal Exp3QuadLatch1Read    : std_logic := '0';
    signal Exp0Quad_A            : std_logic := '0';
    signal Exp0Quad_B            : std_logic := '0';
    signal Exp0Quad_Reg          : std_logic := '0';
    signal Exp0Quad_FaultA       : std_logic := '0';
    signal Exp0Quad_FaultB       : std_logic := '0';
    signal Exp1Quad_A            : std_logic := '0';
    signal Exp1Quad_B            : std_logic := '0';
    signal Exp1Quad_Reg          : std_logic := '0';
    signal Exp1Quad_FaultA       : std_logic := '0';
    signal Exp1Quad_FaultB       : std_logic := '0';
    signal Exp2Quad_A            : std_logic := '0';
    signal Exp2Quad_B            : std_logic := '0';
    signal Exp2Quad_Reg          : std_logic := '0';
    signal Exp2Quad_FaultA       : std_logic := '0';
    signal Exp2Quad_FaultB       : std_logic := '0';
    signal Exp3Quad_A            : std_logic := '0';
    signal Exp3Quad_B            : std_logic := '0';
    signal Exp3Quad_Reg          : std_logic := '0';
    signal Exp3Quad_FaultA       : std_logic := '0';
    signal Exp3Quad_FaultB       : std_logic := '0';
    signal QA0CountRead          : std_logic := '0';
    signal QA0LEDStatusRead      : std_logic := '0';
    signal QA0LEDStatusWrite     : std_logic := '0';
    signal QA0InputRead          : std_logic := '0';
    signal QA0HomeRead           : std_logic := '0';
    signal QA0Latch0Read         : std_logic := '0';
    signal QA0Latch1Read         : std_logic := '0';
    signal QA1CountRead          : std_logic := '0';
    signal QA1LEDStatusRead      : std_logic := '0';
    signal QA1LEDStatusWrite     : std_logic := '0';
    signal QA1InputRead          : std_logic := '0';
    signal QA1HomeRead           : std_logic := '0';
    signal QA1Latch0Read         : std_logic := '0';
    signal QA1Latch1Read         : std_logic := '0';
    signal QA0_SigA              : std_logic := '0';
    signal QA0_SigB              : std_logic := '0';
    signal QA0_SigZ              : std_logic := '0';
    signal QA0_Home              : std_logic := '0';
    signal QA0_RegX_PosLmt       : std_logic := '0';
    signal QA0_RegY_NegLmt       : std_logic := '0';
    signal QA1_SigA              : std_logic := '0';
    signal QA1_SigB              : std_logic := '0';
    signal QA1_SigZ              : std_logic := '0';
    signal QA1_Home              : std_logic := '0';
    signal QA1_RegX_PosLmt       : std_logic := '0';
    signal QA1_RegY_NegLmt       : std_logic := '0';
    signal QA0AxisFault          : std_logic_vector(2 downto 0) := (others => '0');
    signal QA1AxisFault          : std_logic_vector(2 downto 0) := (others => '0');
		
		 -- QuadXface signals
    signal QuadDataOut         : std_logic_vector(31 downto 0):= (others => '0');
    signal CountRead           : std_logic := '0';
    signal LEDStatusRead       : std_logic := '0';
    signal LEDStatusWrite      : std_logic := '0';
    signal InputRead           : std_logic := '0';
    signal HomeRead            : std_logic := '0';
    signal Latch0Read          : std_logic := '0';
    signal Latch1Read          : std_logic := '0';
    signal Home                : std_logic := '0';
    signal RegistrationX       : std_logic := '0';
    signal RegistrationY       : std_logic := '0';
    signal LineFault           : std_logic_vector(2 downto 0):= (others => '0');
    signal A                   : std_logic := '0';
    signal B                   : std_logic := '0';
    signal Index               : std_logic:= '0';

begin

    -- Clock processes definitions

    H1_CLKWR_process : process
    begin
        H1_CLKWR <= '0';
        wait for H1_CLK_period/2;
        H1_CLKWR <= '1';
        wait for H1_CLK_period/2;
    end process;

    SysClk_process : process
    begin
        SysClk <= '0';
        wait for SysClk_period/2;
        SysClk <= '1';
        wait for SysClk_period/2;
    end process;

    A_proc: process
    begin
        A <= '0';
        wait for 30*SysClk_period;
        A <= '1';
        wait for 30*SysClk_period;
    end process A_proc;

    B_proc: process
    begin
        B <= '0';
        wait for 45*SysClk_period;
        while true loop
            wait for 30*SysClk_period;
            B <= not B;
        end loop;
    end process B_proc;

    -- Instantiate QuadXface
    uut_xf: QuadXface
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

    -- Generate statements for multiple Quad instantiations

    constant NUM_QUADS : natural := 4;  -- Number of quad instantiations

    generate
		-- Generate Quad instances
		gen_quad : for i in 0 to NUM_QUADS - 1 generate
				-- Signals for each Quad instance
				signal ExpQuadDataOut : std_logic_vector(31 downto 0);
				signal QuadADataOut : std_logic_vector(31 downto 0);
				signal ExpQuadCountRead : std_logic := '0';
				signal ExpQuadLEDStatusRead : std_logic := '0';
				signal ExpQuadLEDStatusWrite : std_logic := '0';
				signal ExpQuadInputRead : std_logic := '0';
				signal ExpQuadHomeRead : std_logic := '0';
				signal ExpQuadLatch0Read : std_logic := '0';
				signal ExpQuadLatch1Read : std_logic := '0';
				signal ExpQuad_A : std_logic := '0';
				signal ExpQuad_B : std_logic := '0';
				signal ExpQuad_Reg : std_logic := '0';
				signal ExpQuad_FaultA : std_logic := '0';
				signal ExpQuad_FaultB : std_logic := '0';
				signal QuadCountRead : std_logic := '0';
				signal QuadLEDStatusRead : std_logic := '0';
				signal QuadLEDStatusWrite : std_logic := '0';
				signal QuadInputRead : std_logic := '0';
				signal QuadHomeRead : std_logic := '0';
				signal QuadLatch0Read : std_logic := '0';
				signal QuadLatch1Read : std_logic := '0';
				signal Quad_A : std_logic := '0';
				signal Quad_B : std_logic := '0';
				signal Quad_Reg : std_logic := '0';
				signal Quad_FaultA : std_logic := '0';
				signal Quad_FaultB : std_logic := '0';

				begin
				-- Instantiate Quad
				uut_quad : Quad
						port map (
								H1_CLKWR                => H1_CLKWR,
								SysClk                  => SysClk,
								SynchedTick             => SynchedTick,
								intDATA                 => intDATA,
								ExpQuadDataOut          => ExpQuadDataOut,
								QuadADataOut            => QuadADataOut,
								ExpQuadCountRead        => ExpQuadCountRead,
								ExpQuadLEDStatusRead    => ExpQuadLEDStatusRead,
								ExpQuadLEDStatusWrite   => ExpQuadLEDStatusWrite,
								ExpQuadInputRead        => ExpQuadInputRead,
								ExpQuadHomeRead         => ExpQuadHomeRead,
								ExpQuadLatch0Read       => ExpQuadLatch0Read,
								ExpQuadLatch1Read       => ExpQuadLatch1Read,
								ExpQuad_A               => ExpQuad_A,
								ExpQuad_B               => ExpQuad_B,
								ExpQuad_Reg             => ExpQuad_Reg,
								ExpQuad_FaultA          => ExpQuad_FaultA,
								ExpQuad_FaultB          => ExpQuad
