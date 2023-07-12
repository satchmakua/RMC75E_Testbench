library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;

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
				
    -- Instantiate the Quad module
		uut: Quad
        port map (
            H1_CLKWR                => H1_CLKWR,
            SysClk                  => SysClk,
            SynchedTick             => SynchedTick,
            intDATA                 => intDATA,
            Exp0QuadDataOut         => Exp0QuadDataOut,
            Exp1QuadDataOut         => Exp1QuadDataOut,
            Exp2QuadDataOut         => Exp2QuadDataOut,
            Exp3QuadDataOut         => Exp3QuadDataOut,
            QuadA0DataOut           => QuadA0DataOut,
            QuadA1DataOut           => QuadA1DataOut,
            Exp0QuadCountRead       => Exp0QuadCountRead,
            Exp0QuadLEDStatusRead   => Exp0QuadLEDStatusRead,
            Exp0QuadLEDStatusWrite  => Exp0QuadLEDStatusWrite,
            Exp0QuadInputRead       => Exp0QuadInputRead,
            Exp0QuadHomeRead        => Exp0QuadHomeRead,
            Exp0QuadLatch0Read      => Exp0QuadLatch0Read,
            Exp0QuadLatch1Read      => Exp0QuadLatch1Read,
            Exp1QuadCountRead       => Exp1QuadCountRead,
            Exp1QuadLEDStatusRead   => Exp1QuadLEDStatusRead,
            Exp1QuadLEDStatusWrite  => Exp1QuadLEDStatusWrite,
            Exp1QuadInputRead       => Exp1QuadInputRead,
            Exp1QuadHomeRead        => Exp1QuadHomeRead,
            Exp1QuadLatch0Read      => Exp1QuadLatch0Read,
            Exp1QuadLatch1Read      => Exp1QuadLatch1Read,
            Exp2QuadCountRead       => Exp2QuadCountRead,
            Exp2QuadLEDStatusRead   => Exp2QuadLEDStatusRead,
            Exp2QuadLEDStatusWrite  => Exp2QuadLEDStatusWrite,
            Exp2QuadInputRead       => Exp2QuadInputRead,
            Exp2QuadHomeRead        => Exp2QuadHomeRead,
            Exp2QuadLatch0Read      => Exp2QuadLatch0Read,
            Exp2QuadLatch1Read      => Exp2QuadLatch1Read,
            Exp3QuadCountRead       => Exp3QuadCountRead,
            Exp3QuadLEDStatusRead   => Exp3QuadLEDStatusRead,
            Exp3QuadLEDStatusWrite  => Exp3QuadLEDStatusWrite,
            Exp3QuadInputRead       => Exp3QuadInputRead,
            Exp3QuadHomeRead        => Exp3QuadHomeRead,
            Exp3QuadLatch0Read      => Exp3QuadLatch0Read,
            Exp3QuadLatch1Read      => Exp3QuadLatch1Read,
            Exp0Quad_A              => Exp0Quad_A,
            Exp0Quad_B              => Exp0Quad_B,
            Exp0Quad_Reg            => Exp0Quad_Reg,
            Exp0Quad_FaultA         => Exp0Quad_FaultA,
            Exp0Quad_FaultB         => Exp0Quad_FaultB,
            Exp1Quad_A              => Exp1Quad_A,
            Exp1Quad_B              => Exp1Quad_B,
            Exp1Quad_Reg            => Exp1Quad_Reg,
            Exp1Quad_FaultA         => Exp1Quad_FaultA,
            Exp1Quad_FaultB         => Exp1Quad_FaultB,
            Exp2Quad_A              => Exp2Quad_A,
            Exp2Quad_B              => Exp2Quad_B,
            Exp2Quad_Reg            => Exp2Quad_Reg,
            Exp2Quad_FaultA         => Exp2Quad_FaultA,
            Exp2Quad_FaultB         => Exp2Quad_FaultB,
            Exp3Quad_A              => Exp3Quad_A,
            Exp3Quad_B              => Exp3Quad_B,
            Exp3Quad_Reg            => Exp3Quad_Reg,
            Exp3Quad_FaultA         => Exp3Quad_FaultA,
            Exp3Quad_FaultB         => Exp3Quad_FaultB,
            QA0CountRead            => QA0CountRead,
            QA0LEDStatusRead        => QA0LEDStatusRead,
            QA0LEDStatusWrite       => QA0LEDStatusWrite,
            QA0InputRead            => QA0InputRead,
            QA0HomeRead             => QA0HomeRead,
            QA0Latch0Read           => QA0Latch0Read,
            QA0Latch1Read           => QA0Latch1Read,
            QA1CountRead            => QA1CountRead,
            QA1LEDStatusRead        => QA1LEDStatusRead,
            QA1LEDStatusWrite       => QA1LEDStatusWrite,
            QA1InputRead            => QA1InputRead,
            QA1HomeRead             => QA1HomeRead,
            QA1Latch0Read           => QA1Latch0Read,
            QA1Latch1Read           => QA1Latch1Read,
            QA0_SigA                => QA0_SigA,
            QA0_SigB                => QA0_SigB,
            QA0_SigZ                => QA0_SigZ,
            QA0_Home                => QA0_Home,
            QA0_RegX_PosLmt         => QA0_RegX_PosLmt,
            QA0_RegY_NegLmt         => QA0_RegY_NegLmt,
            QA1_SigA                => QA1_SigA,
            QA1_SigB                => QA1_SigB,
            QA1_SigZ                => QA1_SigZ,
            QA1_Home                => QA1_Home,
            QA1_RegX_PosLmt         => QA1_RegX_PosLmt,
            QA1_RegY_NegLmt         => QA1_RegY_NegLmt,
            QA0AxisFault            => QA0AxisFault,
            QA1AxisFault            => QA1AxisFault
        );
		
		-- Clock process definitions
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

		Exp0_A_proc: process
		begin
			Exp0Quad_A <= '0';
			wait for 30*SysClk_period;
			Exp0Quad_A <= '1';
			wait for 30*SysClk_period;
		end process Exp0_A_proc;

		Exp0_B_proc: process
		begin
			Exp0Quad_B <= '0';
			wait for 45*SysClk_period;
			Exp0Quad_B <= '1';
			wait for 30*SysClk_period;
		end process Exp0_B_proc;

		Exp1_A_proc: process
		begin
			Exp1Quad_A <= '0';
			wait for 30*SysClk_period;
			Exp1Quad_A <= '1';
			wait for 30*SysClk_period;
		end process Exp1_A_proc;

		Exp1_B_proc: process
		begin
			Exp1Quad_B <= '0';
			wait for 45*SysClk_period;
			Exp1Quad_B <= '1';
			wait for 30*SysClk_period;
		end process Exp1_B_proc;

		Exp2_A_proc: process
		begin
			Exp2Quad_A <= '0';
			wait for 30*SysClk_period;
			Exp2Quad_A <= '1';
			wait for 30*SysClk_period;
		end process Exp2_A_proc;

		Exp2_B_proc: process
		begin
			Exp2Quad_B <= '0';
			wait for 45*SysClk_period;
			Exp2Quad_B <= '1';
			wait for 30*SysClk_period;
		end process Exp2_B_proc;

		Exp3_A_proc: process
		begin
			Exp3Quad_A <= '0';
			wait for 30*SysClk_period;
			Exp3Quad_A <= '1';
			wait for 30*SysClk_period;
		end process Exp3_A_proc;

		Exp3_B_proc: process
		begin
			Exp3Quad_B <= '0';
			wait for 45*SysClk_period;
			Exp3Quad_B <= '1';
			wait for 30*SysClk_period;
		end process Exp3_B_proc;
		
		QA0_A_proc: process
		begin
			QA0_SigA <= '0';
			wait for 30*SysClk_period;
			QA0_SigA <= '1';
			wait for 30*SysClk_period;
		end process QA0_A_proc;

		QA0_B_proc: process
		begin
			QA0_SigB <= '0';
			wait for 45*SysClk_period;
			QA0_SigB <= '1';
			wait for 30*SysClk_period;
		end process QA0_B_proc;
		
				QA1_A_proc: process
		begin
			QA1_SigA <= '0';
			wait for 30*SysClk_period;
			QA1_SigA <= '1';
			wait for 30*SysClk_period;
		end process QA1_A_proc;

		QA1_B_proc: process
		begin
			QA1_SigB <= '0';
			wait for 45*SysClk_period;
			QA1_SigB <= '1';
			wait for 30*SysClk_period;
		end process QA1_B_proc;

----------------------------------------------------------------------------------------------------------------------------------

		-- Quadxface Stimulus process
		process
		begin

    -- Delay on startup (30MHz delay)
    wait for SysClk_period;

    -- Send first 30MHz sync tick pulse
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
    -- Wait for one clock cycle
    wait for 20 us;
    
    -- Send second sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
   
		wait for 5 us;
		Home <= '1';
		RegistrationX <= '1';
		intDATA(2) <= '1';
		intDATA(9 downto 7) <= "010";
		intDATA(13 downto 11) <= "010";
    LEDStatusWrite <= '1';
		
    wait for 5 us;
		Home <= '0';
		RegistrationX <= '0';
    LEDStatusWrite <= '0';
		
		wait for 20 us;
		
    -- Send third sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
		wait for 5 us;
		
    CountRead <= '1';
    wait for 5 us;
    CountRead <= '0';
		
    InputRead <= '1';
    wait for 5 us;
    InputRead <= '0';
		
    HomeRead <= '1';
    wait for 5 us;
    HomeRead <= '0';
		
    LEDStatusRead <= '1';
    wait for 5 us;
    LEDStatusRead <= '0';
		
    Latch0Read <= '1';
    wait for 5 us;
    Latch0Read <= '0';
		
		RegistrationY <= '1';
		wait for 5 us;
		RegistrationY <= '0';
		
		wait for 5 us;
    Latch1Read <= '1';
    wait for 5 us;
    Latch1Read <= '0';
		
    wait;
		end process;
		
----------------------------------------------------------------------------------------------------------------------------------

    -- Exp0 Stimulus process
		process
		begin

    -- Delay on startup (30MHz delay)
    wait for SysClk_period;

    -- Send first 30MHz sync tick pulse
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
    -- Wait for one clock cycle
    wait for 20 us;
    
    -- Send second sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
   
		wait for 5 us;
		Exp0Quad_Reg <= '1';
		intDATA(2) <= '1';
		intDATA(9 downto 7) <= "010";
		intDATA(13 downto 11) <= "010";
    Exp0QuadLEDStatusWrite <= '1';
		
    wait for 5 us;
		Exp0Quad_Reg <= '0';
    Exp0QuadLEDStatusWrite <= '0';
		
		wait for 20 us;
		
    -- Send third sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
    Exp0QuadCountRead <= '1';
    wait for 5 us;
    Exp0QuadCountRead <= '0';
		
		wait for 5 us;
    Exp0QuadInputRead <= '1';
    wait for 5 us;
    Exp0QuadInputRead <= '0';
		
    Exp0QuadHomeRead <= '1';
    wait for 5 us;
    Exp0QuadHomeRead <= '0';	
		
    Exp0QuadLEDStatusRead <= '1';
    wait for 5 us;
    Exp0QuadLEDStatusRead <= '0';
		
    Exp0QuadLatch0Read <= '1';
    wait for 5 us;
    Exp0QuadLatch0Read <= '0';
		wait for 5 us;
    Exp0QuadLatch1Read <= '1';
    wait for 5 us;
    Exp0QuadLatch1Read <= '0';
		
    wait;
		end process;
		
----------------------------------------------------------------------------------------------------------------------------------		
 
     -- Exp1 Stimulus process
		process
		begin

    -- Delay on startup (30MHz delay)
    wait for SysClk_period;

    -- Send first 30MHz sync tick pulse
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
    -- Wait for one clock cycle
    wait for 20 us;
    
    -- Send second sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
   
		wait for 5 us;
		Exp1Quad_Reg <= '1';
		intDATA(2) <= '1';
		intDATA(9 downto 7) <= "010";
		intDATA(13 downto 11) <= "010";
    Exp1QuadLEDStatusWrite <= '1';
		
    wait for 5 us;
		Exp1Quad_Reg <= '0';
    Exp1QuadLEDStatusWrite <= '0';
		
		wait for 20 us;
		
    -- Send third sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
    Exp1QuadCountRead <= '1';
    wait for 5 us;
    Exp1QuadCountRead <= '0';
		
		wait for 5 us;
    Exp1QuadInputRead <= '1';
    wait for 5 us;
    Exp1QuadInputRead <= '0';
		
    Exp1QuadHomeRead <= '1';
    wait for 5 us;
    Exp1QuadHomeRead <= '0';	
		
    Exp1QuadLEDStatusRead <= '1';
    wait for 5 us;
    Exp1QuadLEDStatusRead <= '0';
		
    Exp1QuadLatch0Read <= '1';
    wait for 5 us;
    Exp1QuadLatch0Read <= '0';
		wait for 5 us;
    Exp1QuadLatch1Read <= '1';
    wait for 5 us;
    Exp1QuadLatch1Read <= '0';
		
    wait;
		end process;

 ----------------------------------------------------------------------------------------------------------------------------------
 
     -- Exp2 Stimulus process
		process
		begin

    -- Delay on startup (30MHz delay)
    wait for SysClk_period;

    -- Send first 30MHz sync tick pulse
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
    -- Wait for one clock cycle
    wait for 20 us;
    
    -- Send second sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
   
		wait for 5 us;
		Exp2Quad_Reg <= '1';
		intDATA(2) <= '1';
		intDATA(9 downto 7) <= "010";
		intDATA(13 downto 11) <= "010";
    Exp2QuadLEDStatusWrite <= '1';
		
    wait for 5 us;
		Exp2Quad_Reg <= '0';
    Exp2QuadLEDStatusWrite <= '0';
		
		wait for 20 us;
		
    -- Send third sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
    Exp2QuadCountRead <= '1';
    wait for 5 us;
    Exp2QuadCountRead <= '0';
		
		wait for 5 us;
    Exp2QuadInputRead <= '1';
    wait for 5 us;
    Exp2QuadInputRead <= '0';
		
    Exp2QuadHomeRead <= '1';
    wait for 5 us;
    Exp2QuadHomeRead <= '0';	
		
    Exp2QuadLEDStatusRead <= '1';
    wait for 5 us;
    Exp2QuadLEDStatusRead <= '0';
		
    Exp2QuadLatch0Read <= '1';
    wait for 5 us;
    Exp2QuadLatch0Read <= '0';
		wait for 5 us;
    Exp2QuadLatch1Read <= '1';
    wait for 5 us;
    Exp2QuadLatch1Read <= '0';
		
    wait;
		end process;
		
----------------------------------------------------------------------------------------------------------------------------------

    -- Exp3 Stimulus process
		process
		begin

    -- Delay on startup (30MHz delay)
    wait for SysClk_period;

    -- Send first 30MHz sync tick pulse
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
    -- Wait for one clock cycle
    wait for 20 us;
    
    -- Send second sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
   
		wait for 5 us;
		Exp3Quad_Reg <= '1';
		intDATA(2) <= '1';
		intDATA(9 downto 7) <= "010";
		intDATA(13 downto 11) <= "010";
    Exp3QuadLEDStatusWrite <= '1';
		
    wait for 5 us;
		Exp3Quad_Reg <= '0';
    Exp3QuadLEDStatusWrite <= '0';
		
		wait for 20 us;
		
    -- Send third sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
    Exp3QuadCountRead <= '1';
    wait for 5 us;
    Exp3QuadCountRead <= '0';
		
		wait for 5 us;
    Exp3QuadInputRead <= '1';
    wait for 5 us;
    Exp3QuadInputRead <= '0';
		
    Exp3QuadHomeRead <= '1';
    wait for 5 us;
    Exp3QuadHomeRead <= '0';	
		
    Exp3QuadLEDStatusRead <= '1';
    wait for 5 us;
    Exp3QuadLEDStatusRead <= '0';
		
    Exp3QuadLatch0Read <= '1';
    wait for 5 us;
    Exp3QuadLatch0Read <= '0';
		wait for 5 us;
    Exp3QuadLatch1Read <= '1';
    wait for 5 us;
    Exp3QuadLatch1Read <= '0';
		
    wait;
		end process;
----------------------------------------------------------------------------------------------------------------------------------

		-- QA0 Stimulus process
		process
		begin

    -- Delay on startup (30MHz delay)
    wait for SysClk_period;

    -- Send first 30MHz sync tick pulse
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
    -- Wait for one clock cycle
    wait for 20 us;
    
    -- Send second sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
   
		wait for 5 us;
		QA0_Home <= '1';
		QA0_RegX_PosLmt <= '1';
		intDATA(2) <= '1';
		intDATA(9 downto 7) <= "010";
		intDATA(13 downto 11) <= "010";
		QA0LEDStatusWrite <= '1';
		
    wait for 5 us;
		QA0_Home <= '0';
		QA0_RegX_PosLmt <= '0';
    QA0LEDStatusWrite <= '0';
		
		wait for 20 us;
		
    -- Send third sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
		wait for 5 us;
		
    QA0CountRead <= '1';
    wait for 5 us;
    QA0CountRead <= '0';
		
    QA0InputRead <= '1';
    wait for 5 us;
    QA0InputRead <= '0';
		
    QA0HomeRead <= '1';
    wait for 5 us;
    QA0HomeRead <= '0';
		
    QA0LEDStatusRead <= '1';
    wait for 5 us;
    QA0LEDStatusRead <= '0';
		
    QA0Latch0Read <= '1';
    wait for 5 us;
    QA0Latch0Read <= '0';
		
		QA0_RegY_NegLmt <= '1';
		wait for 5 us;
		QA0_RegY_NegLmt <= '0';
		
		wait for 5 us;
    QA0Latch1Read <= '1';
    wait for 5 us;
    QA0Latch1Read <= '0';
		
    wait;
		end process;
		
----------------------------------------------------------------------------------------------------------------------------------

		-- QA1 Stimulus process
		process
		begin

    -- Delay on startup (30MHz delay)
    wait for SysClk_period;

    -- Send first 30MHz sync tick pulse
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
    -- Wait for one clock cycle
    wait for 20 us;
    
    -- Send second sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
   
		wait for 5 us;
		QA1_Home <= '1';
		QA1_RegX_PosLmt <= '1';
		intDATA(2) <= '1';
		intDATA(9 downto 7) <= "010";
		intDATA(13 downto 11) <= "010";
		QA1LEDStatusWrite <= '1';
		
    wait for 5 us;
		QA1_Home <= '0';
		QA1_RegX_PosLmt <= '0';
    QA1LEDStatusWrite <= '0';
		
		wait for 20 us;
		
    -- Send third sync tick (30MHz)
    SynchedTick <= '1';
    wait for SysClk_period;
    SynchedTick <= '0';
		
		wait for 5 us;
		
    QA1CountRead <= '1';
    wait for 5 us;
    QA1CountRead <= '0';
		
    QA1InputRead <= '1';
    wait for 5 us;
    QA1InputRead <= '0';
		
    QA1HomeRead <= '1';
    wait for 5 us;
    QA1HomeRead <= '0';
		
    QA1LEDStatusRead <= '1';
    wait for 5 us;
    QA1LEDStatusRead <= '0';
		
    QA1Latch0Read <= '1';
    wait for 5 us;
    QA1Latch0Read <= '0';
		
		QA1_RegY_NegLmt <= '1';
		wait for 5 us;
		QA1_RegY_NegLmt <= '0';
		
		wait for 5 us;
    QA1Latch1Read <= '1';
    wait for 5 us;
    QA1Latch1Read <= '0';
		
    wait;
		end process;

end tb;