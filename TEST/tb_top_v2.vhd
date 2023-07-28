--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_top_v2
--	File			tb_top_v2.vhd
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

entity tb_top_v2 is
end tb_top_v2;

architecture tb of tb_top_v2 is
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
		
    -- Clock period definitions
    constant H1_CLK_period : time := 16.6667 ns;
    constant SysClk_period : time := 33.3333 ns;
		
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
				
		-- Clock process definitions
    H1_CLKWR_process : process
    begin
        H1_CLKWR <= '0';
        wait for H1_CLK_period/2;
        H1_CLKWR <= '1';
        wait for H1_CLK_period/2;
    end process;

    -- Stimulus process
    process
    begin
    wait;
    end process; 
end tb;
