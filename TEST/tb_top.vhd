--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_top
--	File			tb_top.vhd
--
--------------------------------------------------------------------------------
--
--	Description:
 
--		Test bench for the top architecture component of the RMC75E device.
--		This design provides the interface to all the axis modules and expansion
--		modules on the RMC75E as well as control of the LEDs on the CPU module.
--		The main components are
--			* bus interface to the MPC5200 processor
--			* sensor interface logic
--			* sensor I/O signal multiplexing

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity tb_top is
end tb_top;

architecture tb of tb_top is
    -- Component declaration
    component Top is
        port (
            DATA                       : inout std_logic_vector (31 downto 0);
            ExtADDR                    : in std_logic_vector (11 downto 2);
            RD_L                       : in std_logic;
            WR_L                       : in std_logic;
            CS_L                       : in std_logic;
            LOOPTICK                   : in std_logic;
            H1_CLK_IN                  : in std_logic;
            H1_CLKWR                   : in std_logic;
            WD_TICKLE                  : in std_logic;
            RESET                      : in std_logic;
            M_DRV_EN_L                 : out std_logic;
            HALT_DRIVE_L               : in std_logic;
            M_OUT0_CLK                 : out std_logic;
            M_OUT0_DATA                : out std_logic;
            M_OUT0_CONTROL             : out std_logic;
            M_OUT1_CLK                 : out std_logic;
            M_OUT1_DATA                : out std_logic;
            M_OUT1_CONTROL             : out std_logic;
            M_AX0_0                    : out std_logic;
            M_AX0_RET_DATA             : in std_logic;
            M_AX1_INT_CLK              : out std_logic;
            M_AX1_RET_DATA             : in std_logic;
            M_MUXED_ADC_CS_QA0_SIGA    : inout std_logic;
            M_MUXED_ADC_DATA0_QA0_SIGB : in std_logic;
            M_MUXED_ADC_DATA1_QA1_SIGA : in std_logic;
            M_ENABLE                   : out std_logic_vector (1 downto 0);
            M_FAULT                    : in std_logic_vector (1 downto 0);
            M_Card_ID_LOAD             : out std_logic;
            M_Card_ID_LATCH            : out std_logic;
            M_Card_ID_CLK              : out std_logic;
            M_Card_ID_DATA             : in std_logic;
            Exp_Mxd_ID_LOAD            : out std_logic;
            Exp_Mxd_ID_LATCH           : out std_logic;
            Exp_Mxd_ID_CLK             : out std_logic;
            Exp_ID_DATA                : in std_logic;
            M_IO_OE                    : out std_logic;
            M_IO_LOAD                  : out std_logic;
            M_IO_LATCH                 : out std_logic;
            M_IO_CLK                   : out std_logic;
            M_IO_DATAOut               : out std_logic;
            M_IO_DATAIn                : in std_logic;
            M_SPROM_CLK                : out std_logic;
            M_SPROM_DATA               : inout std_logic;
            CPUStatLEDDrive            : out std_logic_vector (1 downto 0);
            Exp0Data                   : inout std_logic_vector (5 downto 0);
            Exp1Data                   : inout std_logic_vector (5 downto 0);
            Exp2Data                   : inout std_logic_vector (5 downto 0);
            Exp3Data                   : inout std_logic_vector (5 downto 0);
            QA0_SigZ                   : in std_logic;
            QA0_Home                   : in std_logic;
            QA0_RegX_PosLmt            : in std_logic;
            QA0_RegY_NegLmt            : in std_logic;
            QA1_SigB                   : in std_logic;
            QA1_SigZ                   : in std_logic;
            QA1_Home                   : in std_logic;
            QA1_RegX_PosLmt            : in std_logic;
            QA1_RegY_NegLmt            : in std_logic;
            X_Reserved0                : out std_logic;
            X_Reserved1                : out std_logic;
            Debug0                     : out std_logic;
            Debug1                     : out std_logic;
            Debug2                     : out std_logic;
            FPGA_Test                  : out std_logic;
            TestClock                  : out std_logic
        );
    end component;

    -- Signal declarations
    signal DATA                       : std_logic_vector (31 downto 0);
    signal ExtADDR                    : std_logic_vector (11 downto 2);
    signal RD_L                       : std_logic := '0';
    signal WR_L                       : std_logic := '0';
    signal CS_L                       : std_logic := '0';
    signal LOOPTICK                   : std_logic := '0';
    signal H1_CLK_IN                  : std_logic := '0';
    signal H1_CLKWR                   : std_logic;
    signal WD_TICKLE                  : std_logic;
    signal RESET                      : std_logic := '1';
    signal M_DRV_EN_L                 : std_logic;
    signal HALT_DRIVE_L               : std_logic;
    signal M_OUT0_CLK                 : std_logic;
    signal M_OUT0_DATA                : std_logic;
    signal M_OUT0_CONTROL             : std_logic;
    signal M_OUT1_CLK                 : std_logic;
    signal M_OUT1_DATA                : std_logic;
    signal M_OUT1_CONTROL             : std_logic;
    signal M_AX0_0                    : std_logic;
    signal M_AX0_RET_DATA             : std_logic;
    signal M_AX1_INT_CLK              : std_logic;
    signal M_AX1_RET_DATA             : std_logic;
    signal M_MUXED_ADC_CS_QA0_SIGA    : std_logic;
    signal M_MUXED_ADC_DATA0_QA0_SIGB : std_logic;
    signal M_MUXED_ADC_DATA1_QA1_SIGA : std_logic;
    signal M_ENABLE                   : std_logic_vector (1 downto 0);
    signal M_FAULT                    : std_logic_vector (1 downto 0);
    signal M_Card_ID_LOAD             : std_logic;
    signal M_Card_ID_LATCH            : std_logic;
    signal M_Card_ID_CLK              : std_logic;
    signal M_Card_ID_DATA             : std_logic;
    signal Exp_Mxd_ID_LOAD            : std_logic;
    signal Exp_Mxd_ID_LATCH           : std_logic;
    signal Exp_Mxd_ID_CLK             : std_logic;
    signal Exp_ID_DATA                : std_logic;
    signal M_IO_OE                    : std_logic;
    signal M_IO_LOAD                  : std_logic;
    signal M_IO_LATCH                 : std_logic;
    signal M_IO_CLK                   : std_logic;
    signal M_IO_DATAOut               : std_logic;
    signal M_IO_DATAIn                : std_logic;
    signal M_SPROM_CLK                : std_logic;
    signal M_SPROM_DATA               : std_logic;
    signal CPUStatLEDDrive            : std_logic_vector (1 downto 0);
    signal Exp0Data                   : std_logic_vector (5 downto 0);
    signal Exp1Data                   : std_logic_vector (5 downto 0);
    signal Exp2Data                   : std_logic_vector (5 downto 0);
    signal Exp3Data                   : std_logic_vector (5 downto 0);
    signal QA0_SigZ                   : std_logic;
    signal QA0_Home                   : std_logic;
    signal QA0_RegX_PosLmt            : std_logic;
    signal QA0_RegY_NegLmt            : std_logic;
    signal QA1_SigB                   : std_logic;
    signal QA1_SigZ                   : std_logic;
    signal QA1_Home                   : std_logic;
    signal QA1_RegX_PosLmt            : std_logic;
    signal QA1_RegY_NegLmt            : std_logic;
    signal X_Reserved0                : std_logic;
    signal X_Reserved1                : std_logic;
    signal Debug0                     : std_logic;
    signal Debug1                     : std_logic;
    signal Debug2                     : std_logic;
    signal FPGA_Test                  : std_logic;
    signal TestClock                  : std_logic;
  
begin  
    -- Clock generation process
    process
    begin
        while now < 1000 ns loop  -- Adjust the simulation time as needed
            TestClock <= '0';
            wait for 5 ns;
            TestClock <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Reset process
    process
    begin
        RESET <= '1';
        wait for 10 ns;
        RESET <= '0';
        wait;
    end process;

    -- Stimulus process
    process
    begin
        -- Apply various test scenarios here
        -- Test 1: Reset scenario
        wait for 20 ns;
        RESET <= '1';
        wait for 10 ns;
        RESET <= '0';
        
        -- Test 2: Read operation scenario
        wait for 50 ns;
        RD_L <= '1';
        wait for 10 ns;
        -- Perform read operation
        
        -- Test 3: Write operation scenario
        wait for 10 ns;
        WR_L <= '1';
        wait for 10 ns;
        -- Perform write operation
        
        -- Test 4: CS_L scenario
        wait for 20 ns;
        CS_L <= '0';
        wait for 10 ns;
        -- Perform operation with CS_L active
        
        -- Test 5: LOOPTICK scenario
        wait for 10 ns;
        LOOPTICK <= '1';
        wait for 10 ns;
        -- Perform operation with LOOPTICK active
        
        -- Test 6: H1_CLK_IN scenario
        wait for 10 ns;
        H1_CLK_IN <= '1';
        wait for 10 ns;
        -- Perform operation with H1_CLK_IN active
        
        -- Test 7: H1_CLKWR scenario
        wait for 10 ns;
        H1_CLKWR <= '1';
        wait for 10 ns;
        -- Perform operation with H1_CLKWR active
        
        -- Test 8: WD_TICKLE scenario
        wait for 10 ns;
        WD_TICKLE <= '1';
        wait for 10 ns;
        -- Perform operation with WD_TICKLE active
        
        -- Test 9: M_DRV_EN_L scenario
        wait for 10 ns;
        M_DRV_EN_L <= '1';
        wait for 10 ns;
        -- Perform operation with M_DRV_EN_L active
        
        -- Test 10: HALT_DRIVE_L scenario
        wait for 10 ns;
        HALT_DRIVE_L <= '1';
        wait for 10 ns;
        -- Perform operation with HALT_DRIVE_L active
        
        -- Test 11: M_OUT0_CLK scenario
        wait for 10 ns;
        M_OUT0_CLK <= '1';
        wait for 10 ns;
        -- Perform operation with M_OUT0_CLK active
        
        -- Test 12: M_OUT0_DATA scenario
        wait for 10 ns;
        M_OUT0_DATA <= '1';
        wait for 10 ns;
        -- Perform operation with M_OUT0_DATA active
        
        -- Test 13: M_OUT0_CONTROL scenario
        wait for 10 ns;
        M_OUT0_CONTROL <= '1';
        wait for 10 ns;
        -- Perform operation with M_OUT0_CONTROL active
        
        -- Test 14: M_OUT1_CLK scenario
        wait for 10 ns;
        M_OUT1_CLK <= '1';
        wait for 10 ns;
        -- Perform operation with M_OUT1_CLK active
        
        -- Test 15: M_OUT1_DATA scenario
        wait for 10 ns;
        M_OUT1_DATA <= '1';
        wait for 10 ns;
        -- Perform operation with M_OUT1_DATA active
        
        -- Test 16: M_OUT1_CONTROL scenario
        wait for 10 ns;
        M_OUT1_CONTROL <= '1';
        wait for 10 ns;
        -- Perform operation with M_OUT1_CONTROL active
        
        -- Test 17: M_AX0_0 scenario
        wait for 10 ns;
        M_AX0_0 <= '1';
        wait for 10 ns;
        -- Perform operation with M_AX0_0 active
        
        -- Test 18: M_AX0_RET_DATA scenario
        wait for 10 ns;
        M_AX0_RET_DATA <= '1';
        wait for 10 ns;
        -- Perform operation with M_AX0_RET_DATA active
        
        -- Test 19: M_AX1_INT_CLK scenario
        wait for 10 ns;
        M_AX1_INT_CLK <= '1';
        wait for 10 ns;
        -- Perform operation with M_AX1_INT_CLK active
        
        -- Test 20: M_AX1_RET_DATA scenario
        wait for 10 ns;
        M_AX1_RET_DATA <= '1';
        wait for 10 ns;
        -- Perform operation with M_AX1_RET_DATA active
        
        -- Test 21: M_MUXED_ADC_CS_QA0_SIGA scenario
        wait for 10 ns;
        M_MUXED_ADC_CS_QA0_SIGA <= '1';
        wait for 10 ns;
        -- Perform operation with M_MUXED_ADC_CS_QA0_SIGA active
        
        -- Test 22: M_MUXED_ADC_DATA0_QA0_SIGB scenario
        wait for 10 ns;
        M_MUXED_ADC_DATA0_QA0_SIGB <= '1';
        wait for 10 ns;
        -- Perform operation with M_MUXED_ADC_DATA0_QA0_SIGB active
        
        -- Test 23: M_MUXED_ADC_DATA1_QA1_SIGA scenario
        wait for 10 ns;
        M_MUXED_ADC_DATA1_QA1_SIGA <= '1';
        wait for 10 ns;
        -- Perform operation with M_MUXED_ADC_DATA1_QA1_SIGA active
        
        -- Test 24: M_ENABLE scenario
        wait for 10 ns;
        M_ENABLE <= "10";
        wait for 10 ns;
        -- Perform operation with M_ENABLE active
        
        -- Test 25: M_FAULT scenario
        wait for 10 ns;
        M_FAULT <= "10";
        wait for 10 ns;
        -- Perform operation with M_FAULT active
        
        -- Test 26: M_Card_ID_LOAD scenario
        wait for 10 ns;
        M_Card_ID_LOAD <= '1';
        wait for 10 ns;
        -- Perform operation with M_Card_ID_LOAD active
        
        -- Test 27: M_Card_ID_LATCH scenario
        wait for 10 ns;
        M_Card_ID_LATCH <= '1';
        wait for 10 ns;
        -- Perform operation with M_Card_ID_LATCH active
        
        -- Test 28: M_Card_ID_CLK scenario
        wait for 10 ns;
        M_Card_ID_CLK <= '1';
        wait for 10 ns;
        -- Perform operation with M_Card_ID_CLK active
        
        -- Test 29: M_Card_ID_DATA scenario
        wait for 10 ns;
        M_Card_ID_DATA <= '1';
        wait for 10 ns;
        -- Perform operation with M_Card_ID_DATA active
        
        -- Test 30: Exp_Mxd_ID_LOAD scenario
        wait for 10 ns;
        Exp_Mxd_ID_LOAD <= '1';
        wait for 10 ns;
        -- Perform operation with Exp_Mxd_ID_LOAD active
        
        -- Test 31: Exp_Mxd_ID_LATCH scenario
        wait for 10 ns;
        Exp_Mxd_ID_LATCH <= '1';
        wait for 10 ns;
        -- Perform operation with Exp_Mxd_ID_LATCH active
        
        -- Test 32: Exp_Mxd_ID_CLK scenario
        wait for 10 ns;
        Exp_Mxd_ID_CLK <= '1';
        wait for 10 ns;
        -- Perform operation with Exp_Mxd_ID_CLK active
        
        -- Test 33: Exp_ID_DATA scenario
        wait for 10 ns;
        Exp_ID_DATA <= '1';
        wait for 10 ns;
        -- Perform operation with Exp_ID_DATA active
        
        -- Test 34: M_IO_OE scenario
        wait for 10 ns;
        M_IO_OE <= '1';
        wait for 10 ns;
        -- Perform operation with M_IO_OE active
        
        -- Test 35: M_IO_LOAD scenario
        wait for 10 ns;
        M_IO_LOAD <= '1';
        wait for 10 ns;
        -- Perform operation with M_IO_LOAD active
        
        -- Test 36: M_IO_LATCH scenario
        wait for 10 ns;
        M_IO_LATCH <= '1';
        wait for 10 ns;
        -- Perform operation with M_IO_LATCH active
        
        -- Test 37: M_IO_CLK scenario
        wait for 10 ns;
        M_IO_CLK <= '1';
        wait for 10 ns;
        -- Perform operation with M_IO_CLK active
        
        -- Test 38: M_IO_DATAOut scenario
        wait for 10 ns;
        M_IO_DATAOut <= '1';
        wait for 10 ns;
        -- Perform operation with M_IO_DATAOut active
        
        -- Test 39: M_IO_DATAIn scenario
        wait for 10 ns;
        M_IO_DATAIn <= '1';
        wait for 10 ns;
        -- Perform operation with M_IO_DATAIn active
        
        -- Test 40: M_SPROM_CLK scenario
        wait for 10 ns;
        M_SPROM_CLK <= '1';
        wait for 10 ns;
        -- Perform operation with M_SPROM_CLK active
        
        -- Test 41: M_SPROM_DATA scenario
        wait for 10 ns;
        M_SPROM_DATA <= '1';
        wait for 10 ns;
        -- Perform operation with M_SPROM_DATA active
        
        -- Test 42: CPUStatLEDDrive scenario
        wait for 10 ns;
        CPUStatLEDDrive <= "10";
        wait for 10 ns;
        -- Perform operation with CPUStatLEDDrive active
        
        -- Test 43: Exp0Data scenario
        wait for 10 ns;
        Exp0Data <= "101010";
        wait for 10 ns;
        -- Perform operation with Exp0Data active
        
        -- Test 44: Exp1Data scenario
        wait for 10 ns;
        Exp1Data <= "010101";
        wait for 10 ns;
        -- Perform operation with Exp1Data active
        
        -- Test 45: Exp2Data scenario
        wait for 10 ns;
        Exp2Data <= "001100";
        wait for 10 ns;
        -- Perform operation with Exp2Data active
        
        -- Test 46: Exp3Data scenario
        wait for 10 ns;
        Exp3Data <= "110011";
        wait for 10 ns;
        -- Perform operation with Exp3Data active
        
        -- Test 47: QA0_SigZ scenario
        wait for 10 ns;
        QA0_SigZ <= '1';
        wait for 10 ns;
        -- Perform operation with QA0_SigZ active
        
        -- Test 48: QA0_Home scenario
        wait for 10 ns;
        QA0_Home <= '1';
        wait for 10 ns;
        -- Perform operation with QA0_Home active
        
        -- Test 49: QA0_RegX_PosLmt scenario
        wait for 10 ns;
        QA0_RegX_PosLmt <= '1';
        wait for 10 ns;
        -- Perform operation with QA0_RegX_PosLmt active
        
        -- Test 50: QA0_RegY_NegLmt scenario
        wait for 10 ns;
        QA0_RegY_NegLmt <= '1';
        wait for 10 ns;
        -- Perform operation with QA0_RegY_NegLmt active
        
        -- Test 51: QA1_SigB scenario
        wait for 10 ns;
        QA1_SigB <= '1';
        wait for 10 ns;
        -- Perform operation with QA1_SigB active
        
        -- Test 52: QA1_SigZ scenario
        wait for 10 ns;
        QA1_SigZ <= '1';
        wait for 10 ns;
        -- Perform operation with QA1_SigZ active
        
        -- Test 53: QA1_Home scenario
        wait for 10 ns;
        QA1_Home <= '1';
        wait for 10 ns;
        -- Perform operation with QA1_Home active
        
        -- Test 54: QA1_RegX_PosLmt scenario
        wait for 10 ns;
        QA1_RegX_PosLmt <= '1';
        wait for 10 ns;
        -- Perform operation with QA1_RegX_PosLmt active
        
        -- Test 55: QA1_RegY_NegLmt scenario
        wait for 10 ns;
        QA1_RegY_NegLmt <= '1';
        wait for 10 ns;
        -- Perform operation with QA1_RegY_NegLmt active
        
        -- Test 56: X_Reserved0 scenario
        wait for 10 ns;
        X_Reserved0 <= '1';
        wait for 10 ns;
        -- Perform operation with X_Reserved0 active
        
        -- Test 57: X_Reserved1 scenario
        wait for 10 ns;
        X_Reserved1 <= '1';
        wait for 10 ns;
        -- Perform operation with X_Reserved1 active
        
        -- Test 58: Debug0 scenario
        wait for 10 ns;
        Debug0 <= '1';
        wait for 10 ns;
        -- Perform operation with Debug0 active
        
        -- Test 59: Debug1 scenario
        wait for 10 ns;
        Debug1 <= '1';
        wait for 10 ns;
        -- Perform operation with Debug1 active
        
        -- Test 60: Debug2 scenario
        wait for 10 ns;
        Debug2 <= '1';
        wait for 10 ns;
        -- Perform operation with Debug2 active
        
        -- Test 61: FPGA_Test scenario
        wait for 10 ns;
        FPGA_Test <= '1';
        wait for 10 ns;
        -- Perform operation with FPGA_Test active
        
        wait;
    end process;

    -- Clock and reset assignment
    H1_CLK_IN <= TestClock;
    RESET <= RESET;

    -- DUT instantiation
    DUT : Top
        port map (
            DATA                       => DATA,
            ExtADDR                    => ExtADDR,
            RD_L                       => RD_L,
            WR_L                       => WR_L,
            CS_L                       => CS_L,
            LOOPTICK                   => LOOPTICK,
            H1_CLK_IN                  => H1_CLK_IN,
            H1_CLKWR                   => H1_CLKWR,
            WD_TICKLE                  => WD_TICKLE,
            RESET                      => RESET,
            M_DRV_EN_L                 => M_DRV_EN_L,
            HALT_DRIVE_L               => HALT_DRIVE_L,
            M_OUT0_CLK                 => M_OUT0_CLK,
            M_OUT0_DATA                => M_OUT0_DATA,
            M_OUT0_CONTROL             => M_OUT0_CONTROL,
            M_OUT1_CLK                 => M_OUT1_CLK,
            M_OUT1_DATA                => M_OUT1_DATA,
            M_OUT1_CONTROL             => M_OUT1_CONTROL,
            M_AX0_0                    => M_AX0_0,
            M_AX0_RET_DATA             => M_AX0_RET_DATA,
            M_AX1_INT_CLK              => M_AX1_INT_CLK,
            M_AX1_RET_DATA             => M_AX1_RET_DATA,
            M_MUXED_ADC_CS_QA0_SIGA    => M_MUXED_ADC_CS_QA0_SIGA,
            M_MUXED_ADC_DATA0_QA0_SIGB => M_MUXED_ADC_DATA0_QA0_SIGB,
            M_MUXED_ADC_DATA1_QA1_SIGA => M_MUXED_ADC_DATA1_QA1_SIGA,
            M_ENABLE                   => M_ENABLE,
            M_FAULT                    => M_FAULT,
            M_Card_ID_LOAD             => M_Card_ID_LOAD,
            M_Card_ID_LATCH            => M_Card_ID_LATCH,
            M_Card_ID_CLK              => M_Card_ID_CLK,
            M_Card_ID_DATA             => M_Card_ID_DATA,
            Exp_Mxd_ID_LOAD            => Exp_Mxd_ID_LOAD,
            Exp_Mxd_ID_LATCH           => Exp_Mxd_ID_LATCH,
            Exp_Mxd_ID_CLK             => Exp_Mxd_ID_CLK,
            Exp_ID_DATA                => Exp_ID_DATA,
            M_IO_OE                    => M_IO_OE,
            M_IO_LOAD                  => M_IO_LOAD,
            M_IO_LATCH                 => M_IO_LATCH,
            M_IO_CLK                   => M_IO_CLK,
            M_IO_DATAOut               => M_IO_DATAOut,
            M_IO_DATAIn                => M_IO_DATAIn,
            M_SPROM_CLK                => M_SPROM_CLK,
            M_SPROM_DATA               => M_SPROM_DATA,
            CPUStatLEDDrive            => CPUStatLEDDrive,
            Exp0Data                   => Exp0Data,
            Exp1Data                   => Exp1Data,
            Exp2Data                   => Exp2Data,
            Exp3Data                   => Exp3Data,
            QA0_SigZ                   => QA0_SigZ,
            QA0_Home                   => QA0_Home,
            QA0_RegX_PosLmt            => QA0_RegX_PosLmt,
            QA0_RegY_NegLmt            => QA0_RegY_NegLmt,
            QA1_SigB                   => QA1_SigB,
            QA1_SigZ                   => QA1_SigZ,
            QA1_Home                   => QA1_Home,
            QA1_RegX_PosLmt            => QA1_RegX_PosLmt,
            QA1_RegY_NegLmt            => QA1_RegY_NegLmt,
            X_Reserved0                => X_Reserved0,
            X_Reserved1                => X_Reserved1,
            Debug0                     => Debug0,
            Debug1                     => Debug1,
            Debug2                     => Debug2,
            FPGA_Test                  => FPGA_Test,
            TestClock                  => TestClock
        );
        
end tb;
