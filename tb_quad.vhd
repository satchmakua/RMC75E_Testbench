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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity tb_quad is
end tb_quad;

architecture tb of tb_quad is
    -- Component declaration
    component Quad is
        Port (
            H1_CLKWR: in std_logic;
            SysClk: in std_logic;
            SynchedTick: in std_logic;
            intDATA: in std_logic_vector(31 downto 0);
            Exp0QuadDataOut: out std_logic_vector(31 downto 0);
            Exp1QuadDataOut: out std_logic_vector(31 downto 0);
            Exp2QuadDataOut: out std_logic_vector(31 downto 0);
            Exp3QuadDataOut: out std_logic_vector(31 downto 0);
            QuadA0DataOut: out std_logic_vector(31 downto 0);
            QuadA1DataOut: out std_logic_vector(31 downto 0);
            Exp0QuadCountRead: in std_logic;
            Exp0QuadLEDStatusRead: in std_logic;
            Exp0QuadLEDStatusWrite: in std_logic;
            Exp0QuadInputRead: in std_logic;
            Exp0QuadHomeRead: in std_logic;
            Exp0QuadLatch0Read: in std_logic;
            Exp0QuadLatch1Read: in std_logic;
            Exp1QuadCountRead: in std_logic;
            Exp1QuadLEDStatusRead: in std_logic;
            Exp1QuadLEDStatusWrite: in std_logic;
            Exp1QuadInputRead: in std_logic;
            Exp1QuadHomeRead: in std_logic;
            Exp1QuadLatch0Read: in std_logic;
            Exp1QuadLatch1Read: in std_logic;
            Exp2QuadCountRead: in std_logic;
            Exp2QuadLEDStatusRead: in std_logic;
            Exp2QuadLEDStatusWrite: in std_logic;
            Exp2QuadInputRead: in std_logic;
            Exp2QuadHomeRead: in std_logic;
            Exp2QuadLatch0Read: in std_logic;
            Exp2QuadLatch1Read: in std_logic;
            Exp3QuadCountRead: in std_logic;
            Exp3QuadLEDStatusRead: in std_logic;
            Exp3QuadLEDStatusWrite: in std_logic;
            Exp3QuadInputRead: in std_logic;
            Exp3QuadHomeRead: in std_logic;
            Exp3QuadLatch0Read: in std_logic;
            Exp3QuadLatch1Read: in std_logic;
            Exp0Quad_A: in std_logic;
            Exp0Quad_B: in std_logic;
            Exp0Quad_Reg: in std_logic;
            Exp0Quad_FaultA: in std_logic;
            Exp0Quad_FaultB: in std_logic;
            Exp1Quad_A: in std_logic;
            Exp1Quad_B: in std_logic;
            Exp1Quad_Reg: in std_logic;
            Exp1Quad_FaultA: in std_logic;
            Exp1Quad_FaultB: in std_logic;
            Exp2Quad_A: in std_logic;
            Exp2Quad_B: in std_logic;
            Exp2Quad_Reg: in std_logic;
            Exp2Quad_FaultA: in std_logic;
            Exp2Quad_FaultB: in std_logic;
            Exp3Quad_A: in std_logic;
            Exp3Quad_B: in std_logic;
            Exp3Quad_Reg: in std_logic;
            Exp3Quad_FaultA: in std_logic;
            Exp3Quad_FaultB: in std_logic;
            QA0CountRead: in std_logic;
            QA0LEDStatusRead: in std_logic;
            QA0LEDStatusWrite: in std_logic;
            QA0InputRead: in std_logic;
            QA0HomeRead: in std_logic;
            QA0Latch0Read: in std_logic;
            QA0Latch1Read: in std_logic;
            QA1CountRead: in std_logic;
            QA1LEDStatusRead: in std_logic;
            QA1LEDStatusWrite: in std_logic;
            QA1InputRead: in std_logic;
            QA1HomeRead: in std_logic;
            QA1Latch0Read: in std_logic;
            QA1Latch1Read: in std_logic;
            QA0_SigA: in std_logic;
            QA0_SigB: in std_logic;
            QA0_SigZ: in std_logic;
            QA0_Home: in std_logic;
            QA0_RegX_PosLmt: in std_logic;
            QA0_RegY_NegLmt: in std_logic;
            QA1_SigA: in std_logic;
            QA1_SigB: in std_logic;
            QA1_SigZ: in std_logic;
            QA1_Home: in std_logic;
            QA1_RegX_PosLmt: in std_logic;
            QA1_RegY_NegLmt: in std_logic;
            QA0AxisFault: in std_logic_vector(2 downto 0);
            QA1AxisFault: in std_logic_vector(2 downto 0)
        );
    end component;

    -- Test inputs
    signal H1_CLKWR: std_logic;
    signal SysClk: std_logic;
    signal SynchedTick: std_logic;
    signal intDATA: std_logic_vector(31 downto 0);
    signal Exp0QuadCountRead: std_logic;
    signal Exp0QuadLEDStatusRead: std_logic;
    signal Exp0QuadLEDStatusWrite: std_logic;
    signal Exp0QuadInputRead: std_logic;
    signal Exp0QuadHomeRead: std_logic;
    signal Exp0QuadLatch0Read: std_logic;
    signal Exp0QuadLatch1Read: std_logic;
    signal Exp1QuadCountRead: std_logic;
    signal Exp1QuadLEDStatusRead: std_logic;
    signal Exp1QuadLEDStatusWrite: std_logic;
    signal Exp1QuadInputRead: std_logic;
    signal Exp1QuadHomeRead: std_logic;
    signal Exp1QuadLatch0Read: std_logic;
    signal Exp1QuadLatch1Read: std_logic;
    signal Exp2QuadCountRead: std_logic;
    signal Exp2QuadLEDStatusRead: std_logic;
    signal Exp2QuadLEDStatusWrite: std_logic;
    signal Exp2QuadInputRead: std_logic;
    signal Exp2QuadHomeRead: std_logic;
    signal Exp2QuadLatch0Read: std_logic;
    signal Exp2QuadLatch1Read: std_logic;
    signal Exp3QuadCountRead: std_logic;
    signal Exp3QuadLEDStatusRead: std_logic;
    signal Exp3QuadLEDStatusWrite: std_logic;
    signal Exp3QuadInputRead: std_logic;
    signal Exp3QuadHomeRead: std_logic;
    signal Exp3QuadLatch0Read: std_logic;
    signal Exp3QuadLatch1Read: std_logic;
    signal Exp0Quad_A: std_logic;
    signal Exp0Quad_B: std_logic;
    signal Exp0Quad_Reg: std_logic;
    signal Exp0Quad_FaultA: std_logic;
    signal Exp0Quad_FaultB: std_logic;
    signal Exp1Quad_A: std_logic;
    signal Exp1Quad_B: std_logic;
    signal Exp1Quad_Reg: std_logic;
    signal Exp1Quad_FaultA: std_logic;
    signal Exp1Quad_FaultB: std_logic;
    signal Exp2Quad_A: std_logic;
    signal Exp2Quad_B: std_logic;
    signal Exp2Quad_Reg: std_logic;
    signal Exp2Quad_FaultA: std_logic;
    signal Exp2Quad_FaultB: std_logic;
    signal Exp3Quad_A: std_logic;
    signal Exp3Quad_B: std_logic;
    signal Exp3Quad_Reg: std_logic;
    signal Exp3Quad_FaultA: std_logic;
    signal Exp3Quad_FaultB: std_logic;
    signal QA0CountRead: std_logic;
    signal QA0LEDStatusRead: std_logic;
    signal QA0LEDStatusWrite: std_logic;
    signal QA0InputRead: std_logic;
    signal QA0HomeRead: std_logic;
    signal QA0Latch0Read: std_logic;
    signal QA0Latch1Read: std_logic;
    signal QA1CountRead: std_logic;
    signal QA1LEDStatusRead: std_logic;
    signal QA1LEDStatusWrite: std_logic;
    signal QA1InputRead: std_logic;
    signal QA1HomeRead: std_logic;
    signal QA1Latch0Read: std_logic;
    signal QA1Latch1Read: std_logic;
    signal QA0_SigA: std_logic;
    signal QA0_SigB: std_logic;
    signal QA0_SigZ: std_logic;
    signal QA0_Home: std_logic;
    signal QA0_RegX_PosLmt: std_logic;
    signal QA0_RegY_NegLmt: std_logic;
    signal QA1_SigA: std_logic;
    signal QA1_SigB: std_logic;
    signal QA1_SigZ: std_logic;
    signal QA1_Home: std_logic;
    signal QA1_RegX_PosLmt: std_logic;
    signal QA1_RegY_NegLmt: std_logic;
    signal QA0AxisFault: std_logic_vector(2 downto 0);
    signal QA1AxisFault: std_logic_vector(2 downto 0);

    -- Test outputs
    signal Exp0QuadDataOut: std_logic_vector(31 downto 0);
    signal Exp1QuadDataOut: std_logic_vector(31 downto 0);
    signal Exp2QuadDataOut: std_logic_vector(31 downto 0);
    signal Exp3QuadDataOut: std_logic_vector(31 downto 0);
    signal QuadA0DataOut: std_logic_vector(31 downto 0);
    signal QuadA1DataOut: std_logic_vector(31 downto 0);

begin
    -- DUT instantiation
    DUT: Quad
        port map (
            H1_CLKWR => H1_CLKWR,
            SysClk => SysClk,
            SynchedTick => SynchedTick,
            intDATA => intDATA,
            Exp0QuadDataOut => Exp0QuadDataOut,
            Exp1QuadDataOut => Exp1QuadDataOut,
            Exp2QuadDataOut => Exp2QuadDataOut,
            Exp3QuadDataOut => Exp3QuadDataOut,
            QuadA0DataOut => QuadA0DataOut,
            QuadA1DataOut => QuadA1DataOut,
            Exp0QuadCountRead => Exp0QuadCountRead,
            Exp0QuadLEDStatusRead => Exp0QuadLEDStatusRead,
            Exp0QuadLEDStatusWrite => Exp0QuadLEDStatusWrite,
            Exp0QuadInputRead => Exp0QuadInputRead,
            Exp0QuadHomeRead => Exp0QuadHomeRead,
            Exp0QuadLatch0Read => Exp0QuadLatch0Read,
            Exp0QuadLatch1Read => Exp0QuadLatch1Read,
            Exp1QuadCountRead => Exp1QuadCountRead,
            Exp1QuadLEDStatusRead => Exp1QuadLEDStatusRead,
            Exp1QuadLEDStatusWrite => Exp1QuadLEDStatusWrite,
            Exp1QuadInputRead => Exp1QuadInputRead,
            Exp1QuadHomeRead => Exp1QuadHomeRead,
            Exp1QuadLatch0Read => Exp1QuadLatch0Read,
            Exp1QuadLatch1Read => Exp1QuadLatch1Read,
            Exp2QuadCountRead => Exp2QuadCountRead,
            Exp2QuadLEDStatusRead => Exp2QuadLEDStatusRead,
            Exp2QuadLEDStatusWrite => Exp2QuadLEDStatusWrite,
            Exp2QuadInputRead => Exp2QuadInputRead,
            Exp2QuadHomeRead => Exp2QuadHomeRead,
            Exp2QuadLatch0Read => Exp2QuadLatch0Read,
            Exp2QuadLatch1Read => Exp2QuadLatch1Read,
            Exp3QuadCountRead => Exp3QuadCountRead,
            Exp3QuadLEDStatusRead => Exp3QuadLEDStatusRead,
            Exp3QuadLEDStatusWrite => Exp3QuadLEDStatusWrite,
            Exp3QuadInputRead => Exp3QuadInputRead,
            Exp3QuadHomeRead => Exp3QuadHomeRead,
            Exp3QuadLatch0Read => Exp3QuadLatch0Read,
            Exp3QuadLatch1Read => Exp3QuadLatch1Read,
            Exp0Quad_A => Exp0Quad_A,
            Exp0Quad_B => Exp0Quad_B,
            Exp0Quad_Reg => Exp0Quad_Reg,
            Exp0Quad_FaultA => Exp0Quad_FaultA,
            Exp0Quad_FaultB => Exp0Quad_FaultB,
            Exp1Quad_A => Exp1Quad_A,
            Exp1Quad_B => Exp1Quad_B,
            Exp1Quad_Reg => Exp1Quad_Reg,
            Exp1Quad_FaultA => Exp1Quad_FaultA,
            Exp1Quad_FaultB => Exp1Quad_FaultB,
            Exp2Quad_A => Exp2Quad_A,
            Exp2Quad_B => Exp2Quad_B,
            Exp2Quad_Reg => Exp2Quad_Reg,
            Exp2Quad_FaultA => Exp2Quad_FaultA,
            Exp2Quad_FaultB => Exp2Quad_FaultB,
            Exp3Quad_A => Exp3Quad_A,
            Exp3Quad_B => Exp3Quad_B,
            Exp3Quad_Reg => Exp3Quad_Reg,
            Exp3Quad_FaultA => Exp3Quad_FaultA,
            Exp3Quad_FaultB => Exp3Quad_FaultB,
            QA0CountRead => QA0CountRead,
            QA0LEDStatusRead => QA0LEDStatusRead,
            QA0LEDStatusWrite => QA0LEDStatusWrite,
            QA0InputRead => QA0InputRead,
            QA0HomeRead => QA0HomeRead,
            QA0Latch0Read => QA0Latch0Read,
            QA0Latch1Read => QA0Latch1Read,
            QA1CountRead => QA1CountRead,
            QA1LEDStatusRead => QA1LEDStatusRead,
            QA1LEDStatusWrite => QA1LEDStatusWrite,
            QA1InputRead => QA1InputRead,
            QA1HomeRead => QA1HomeRead,
            QA1Latch0Read => QA1Latch0Read,
            QA1Latch1Read => QA1Latch1Read,
            QA0_SigA => QA0_SigA,
            QA0_SigB => QA0_SigB,
            QA0_SigZ => QA0_SigZ,
            QA0_Home => QA0_Home,
            QA0_RegX_PosLmt => QA0_RegX_PosLmt,
            QA0_RegY_NegLmt => QA0_RegY_NegLmt,
            QA1_SigA => QA1_SigA,
            QA1_SigB => QA1_SigB,
            QA1_SigZ => QA1_SigZ,
            QA1_Home => QA1_Home,
            QA1_RegX_PosLmt => QA1_RegX_PosLmt,
            QA1_RegY_NegLmt => QA1_RegY_NegLmt,
            QA0AxisFault => QA0AxisFault,
            QA1AxisFault => QA1AxisFault
        );

	-- Clock process
    process
    begin
        H1_CLKWR <= '0';
        wait for 10 ns;
        
        loop
            wait for 5 ns;
            H1_CLKWR <= '1';
            wait for 5 ns;
            H1_CLKWR <= '0';
        end loop;
    end process;

    -- Stimulus process
    process
    begin
        -- Add stimulus here
        
        -- Example stimulus for Exp0QuadInputRead
        Exp0QuadInputRead <= '1';
        wait for 10 ns;
        Exp0QuadInputRead <= '0';
        wait for 20 ns;
        
        -- Add more stimulus here
        
        wait;
    end process;

end tb;
