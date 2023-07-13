--
-- Synopsys
-- Vhdl wrapper for top level design, written on Tue Feb 28 16:27:09 2023
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity wrapper_for_Top is
   port (
      DATA : in std_logic_vector(31 downto 0);
      ExtADDR : in std_logic_vector(11 downto 2);
      RD_L : in std_logic;
      WR_L : in std_logic;
      CS_L : in std_logic;
      LOOPTICK : in std_logic;
      H1_CLK_IN : in std_logic;
      H1_CLKWR : in std_logic;
      WD_RST_L : out std_logic;
      WD_TICKLE : in std_logic;
      RESET : in std_logic;
      M_DRV_EN_L : out std_logic;
      HALT_DRIVE_L : in std_logic;
      M_OUT0_CLK : out std_logic;
      M_OUT0_DATA : out std_logic;
      M_OUT0_CONTROL : out std_logic;
      M_OUT1_CLK : out std_logic;
      M_OUT1_DATA : out std_logic;
      M_OUT1_CONTROL : out std_logic;
      M_AX0_0 : out std_logic;
      M_AX0_RET_DATA : in std_logic;
      M_AX1_INT_CLK : out std_logic;
      M_AX1_RET_DATA : in std_logic;
      M_MUXED_ADC_CS_QA0_SIGA : in std_logic;
      M_MUXED_ADC_DATA0_QA0_SIGB : in std_logic;
      M_MUXED_ADC_DATA1_QA1_SIGA : in std_logic;
      M_ENABLE : out std_logic_vector(1 downto 0);
      M_FAULT : in std_logic_vector(1 downto 0);
      M_Card_ID_LOAD : out std_logic;
      M_Card_ID_LATCH : out std_logic;
      M_Card_ID_CLK : out std_logic;
      M_Card_ID_DATA : in std_logic;
      Exp_Mxd_ID_LOAD : out std_logic;
      Exp_Mxd_ID_LATCH : out std_logic;
      Exp_Mxd_ID_CLK : out std_logic;
      Exp_ID_DATA : in std_logic;
      M_IO_OE : out std_logic;
      M_IO_LOAD : out std_logic;
      M_IO_LATCH : out std_logic;
      M_IO_CLK : out std_logic;
      M_IO_DATAOut : out std_logic;
      M_IO_DATAIn : in std_logic;
      M_SPROM_CLK : out std_logic;
      M_SPROM_DATA : in std_logic;
      CPUStatLEDDrive : out std_logic_vector(1 downto 0);
      Exp0Data : in std_logic_vector(5 downto 0);
      Exp1Data : in std_logic_vector(5 downto 0);
      Exp2Data : in std_logic_vector(5 downto 0);
      Exp3Data : in std_logic_vector(5 downto 0);
      QA0_SigZ : in std_logic;
      QA0_Home : in std_logic;
      QA0_RegX_PosLmt : in std_logic;
      QA0_RegY_NegLmt : in std_logic;
      QA1_SigB : in std_logic;
      QA1_SigZ : in std_logic;
      QA1_Home : in std_logic;
      QA1_RegX_PosLmt : in std_logic;
      QA1_RegY_NegLmt : in std_logic;
      X_Reserved0 : out std_logic;
      X_Reserved1 : out std_logic;
      Debug0 : out std_logic;
      Debug1 : out std_logic;
      Debug2 : out std_logic;
      FPGA_Test : out std_logic;
      TestClock : out std_logic
   );
end wrapper_for_Top;

architecture top_arch of wrapper_for_Top is

component Top
 port (
   DATA : inout std_logic_vector (31 downto 0);
   ExtADDR : in std_logic_vector (11 downto 2);
   RD_L : in std_logic;
   WR_L : in std_logic;
   CS_L : in std_logic;
   LOOPTICK : in std_logic;
   H1_CLK_IN : in std_logic;
   H1_CLKWR : in std_logic;
   WD_RST_L : out std_logic;
   WD_TICKLE : in std_logic;
   RESET : in std_logic;
   M_DRV_EN_L : out std_logic;
   HALT_DRIVE_L : in std_logic;
   M_OUT0_CLK : out std_logic;
   M_OUT0_DATA : out std_logic;
   M_OUT0_CONTROL : out std_logic;
   M_OUT1_CLK : out std_logic;
   M_OUT1_DATA : out std_logic;
   M_OUT1_CONTROL : out std_logic;
   M_AX0_0 : out std_logic;
   M_AX0_RET_DATA : in std_logic;
   M_AX1_INT_CLK : out std_logic;
   M_AX1_RET_DATA : in std_logic;
   M_MUXED_ADC_CS_QA0_SIGA : inout std_logic;
   M_MUXED_ADC_DATA0_QA0_SIGB : in std_logic;
   M_MUXED_ADC_DATA1_QA1_SIGA : in std_logic;
   M_ENABLE : out std_logic_vector (1 downto 0);
   M_FAULT : in std_logic_vector (1 downto 0);
   M_Card_ID_LOAD : out std_logic;
   M_Card_ID_LATCH : out std_logic;
   M_Card_ID_CLK : out std_logic;
   M_Card_ID_DATA : in std_logic;
   Exp_Mxd_ID_LOAD : out std_logic;
   Exp_Mxd_ID_LATCH : out std_logic;
   Exp_Mxd_ID_CLK : out std_logic;
   Exp_ID_DATA : in std_logic;
   M_IO_OE : out std_logic;
   M_IO_LOAD : out std_logic;
   M_IO_LATCH : out std_logic;
   M_IO_CLK : out std_logic;
   M_IO_DATAOut : out std_logic;
   M_IO_DATAIn : in std_logic;
   M_SPROM_CLK : out std_logic;
   M_SPROM_DATA : inout std_logic;
   CPUStatLEDDrive : out std_logic_vector (1 downto 0);
   Exp0Data : inout std_logic_vector (5 downto 0);
   Exp1Data : inout std_logic_vector (5 downto 0);
   Exp2Data : inout std_logic_vector (5 downto 0);
   Exp3Data : inout std_logic_vector (5 downto 0);
   QA0_SigZ : in std_logic;
   QA0_Home : in std_logic;
   QA0_RegX_PosLmt : in std_logic;
   QA0_RegY_NegLmt : in std_logic;
   QA1_SigB : in std_logic;
   QA1_SigZ : in std_logic;
   QA1_Home : in std_logic;
   QA1_RegX_PosLmt : in std_logic;
   QA1_RegY_NegLmt : in std_logic;
   X_Reserved0 : out std_logic;
   X_Reserved1 : out std_logic;
   Debug0 : out std_logic;
   Debug1 : out std_logic;
   Debug2 : out std_logic;
   FPGA_Test : out std_logic;
   TestClock : out std_logic
 );
end component;

signal tmp_DATA : std_logic_vector (31 downto 0);
signal tmp_ExtADDR : std_logic_vector (11 downto 2);
signal tmp_RD_L : std_logic;
signal tmp_WR_L : std_logic;
signal tmp_CS_L : std_logic;
signal tmp_LOOPTICK : std_logic;
signal tmp_H1_CLK_IN : std_logic;
signal tmp_H1_CLKWR : std_logic;
signal tmp_WD_RST_L : std_logic;
signal tmp_WD_TICKLE : std_logic;
signal tmp_RESET : std_logic;
signal tmp_M_DRV_EN_L : std_logic;
signal tmp_HALT_DRIVE_L : std_logic;
signal tmp_M_OUT0_CLK : std_logic;
signal tmp_M_OUT0_DATA : std_logic;
signal tmp_M_OUT0_CONTROL : std_logic;
signal tmp_M_OUT1_CLK : std_logic;
signal tmp_M_OUT1_DATA : std_logic;
signal tmp_M_OUT1_CONTROL : std_logic;
signal tmp_M_AX0_0 : std_logic;
signal tmp_M_AX0_RET_DATA : std_logic;
signal tmp_M_AX1_INT_CLK : std_logic;
signal tmp_M_AX1_RET_DATA : std_logic;
signal tmp_M_MUXED_ADC_CS_QA0_SIGA : std_logic;
signal tmp_M_MUXED_ADC_DATA0_QA0_SIGB : std_logic;
signal tmp_M_MUXED_ADC_DATA1_QA1_SIGA : std_logic;
signal tmp_M_ENABLE : std_logic_vector (1 downto 0);
signal tmp_M_FAULT : std_logic_vector (1 downto 0);
signal tmp_M_Card_ID_LOAD : std_logic;
signal tmp_M_Card_ID_LATCH : std_logic;
signal tmp_M_Card_ID_CLK : std_logic;
signal tmp_M_Card_ID_DATA : std_logic;
signal tmp_Exp_Mxd_ID_LOAD : std_logic;
signal tmp_Exp_Mxd_ID_LATCH : std_logic;
signal tmp_Exp_Mxd_ID_CLK : std_logic;
signal tmp_Exp_ID_DATA : std_logic;
signal tmp_M_IO_OE : std_logic;
signal tmp_M_IO_LOAD : std_logic;
signal tmp_M_IO_LATCH : std_logic;
signal tmp_M_IO_CLK : std_logic;
signal tmp_M_IO_DATAOut : std_logic;
signal tmp_M_IO_DATAIn : std_logic;
signal tmp_M_SPROM_CLK : std_logic;
signal tmp_M_SPROM_DATA : std_logic;
signal tmp_CPUStatLEDDrive : std_logic_vector (1 downto 0);
signal tmp_Exp0Data : std_logic_vector (5 downto 0);
signal tmp_Exp1Data : std_logic_vector (5 downto 0);
signal tmp_Exp2Data : std_logic_vector (5 downto 0);
signal tmp_Exp3Data : std_logic_vector (5 downto 0);
signal tmp_QA0_SigZ : std_logic;
signal tmp_QA0_Home : std_logic;
signal tmp_QA0_RegX_PosLmt : std_logic;
signal tmp_QA0_RegY_NegLmt : std_logic;
signal tmp_QA1_SigB : std_logic;
signal tmp_QA1_SigZ : std_logic;
signal tmp_QA1_Home : std_logic;
signal tmp_QA1_RegX_PosLmt : std_logic;
signal tmp_QA1_RegY_NegLmt : std_logic;
signal tmp_X_Reserved0 : std_logic;
signal tmp_X_Reserved1 : std_logic;
signal tmp_Debug0 : std_logic;
signal tmp_Debug1 : std_logic;
signal tmp_Debug2 : std_logic;
signal tmp_FPGA_Test : std_logic;
signal tmp_TestClock : std_logic;

begin

tmp_DATA <= DATA;

tmp_ExtADDR <= ExtADDR;

tmp_RD_L <= RD_L;

tmp_WR_L <= WR_L;

tmp_CS_L <= CS_L;

tmp_LOOPTICK <= LOOPTICK;

tmp_H1_CLK_IN <= H1_CLK_IN;

tmp_H1_CLKWR <= H1_CLKWR;

WD_RST_L <= tmp_WD_RST_L;

tmp_WD_TICKLE <= WD_TICKLE;

tmp_RESET <= RESET;

M_DRV_EN_L <= tmp_M_DRV_EN_L;

tmp_HALT_DRIVE_L <= HALT_DRIVE_L;

M_OUT0_CLK <= tmp_M_OUT0_CLK;

M_OUT0_DATA <= tmp_M_OUT0_DATA;

M_OUT0_CONTROL <= tmp_M_OUT0_CONTROL;

M_OUT1_CLK <= tmp_M_OUT1_CLK;

M_OUT1_DATA <= tmp_M_OUT1_DATA;

M_OUT1_CONTROL <= tmp_M_OUT1_CONTROL;

M_AX0_0 <= tmp_M_AX0_0;

tmp_M_AX0_RET_DATA <= M_AX0_RET_DATA;

M_AX1_INT_CLK <= tmp_M_AX1_INT_CLK;

tmp_M_AX1_RET_DATA <= M_AX1_RET_DATA;

tmp_M_MUXED_ADC_CS_QA0_SIGA <= M_MUXED_ADC_CS_QA0_SIGA;

tmp_M_MUXED_ADC_DATA0_QA0_SIGB <= M_MUXED_ADC_DATA0_QA0_SIGB;

tmp_M_MUXED_ADC_DATA1_QA1_SIGA <= M_MUXED_ADC_DATA1_QA1_SIGA;

M_ENABLE <= tmp_M_ENABLE;

tmp_M_FAULT <= M_FAULT;

M_Card_ID_LOAD <= tmp_M_Card_ID_LOAD;

M_Card_ID_LATCH <= tmp_M_Card_ID_LATCH;

M_Card_ID_CLK <= tmp_M_Card_ID_CLK;

tmp_M_Card_ID_DATA <= M_Card_ID_DATA;

Exp_Mxd_ID_LOAD <= tmp_Exp_Mxd_ID_LOAD;

Exp_Mxd_ID_LATCH <= tmp_Exp_Mxd_ID_LATCH;

Exp_Mxd_ID_CLK <= tmp_Exp_Mxd_ID_CLK;

tmp_Exp_ID_DATA <= Exp_ID_DATA;

M_IO_OE <= tmp_M_IO_OE;

M_IO_LOAD <= tmp_M_IO_LOAD;

M_IO_LATCH <= tmp_M_IO_LATCH;

M_IO_CLK <= tmp_M_IO_CLK;

M_IO_DATAOut <= tmp_M_IO_DATAOut;

tmp_M_IO_DATAIn <= M_IO_DATAIn;

M_SPROM_CLK <= tmp_M_SPROM_CLK;

tmp_M_SPROM_DATA <= M_SPROM_DATA;

CPUStatLEDDrive <= tmp_CPUStatLEDDrive;

tmp_Exp0Data <= Exp0Data;

tmp_Exp1Data <= Exp1Data;

tmp_Exp2Data <= Exp2Data;

tmp_Exp3Data <= Exp3Data;

tmp_QA0_SigZ <= QA0_SigZ;

tmp_QA0_Home <= QA0_Home;

tmp_QA0_RegX_PosLmt <= QA0_RegX_PosLmt;

tmp_QA0_RegY_NegLmt <= QA0_RegY_NegLmt;

tmp_QA1_SigB <= QA1_SigB;

tmp_QA1_SigZ <= QA1_SigZ;

tmp_QA1_Home <= QA1_Home;

tmp_QA1_RegX_PosLmt <= QA1_RegX_PosLmt;

tmp_QA1_RegY_NegLmt <= QA1_RegY_NegLmt;

X_Reserved0 <= tmp_X_Reserved0;

X_Reserved1 <= tmp_X_Reserved1;

Debug0 <= tmp_Debug0;

Debug1 <= tmp_Debug1;

Debug2 <= tmp_Debug2;

FPGA_Test <= tmp_FPGA_Test;

TestClock <= tmp_TestClock;



u1:   Top port map (
		DATA => tmp_DATA,
		ExtADDR => tmp_ExtADDR,
		RD_L => tmp_RD_L,
		WR_L => tmp_WR_L,
		CS_L => tmp_CS_L,
		LOOPTICK => tmp_LOOPTICK,
		H1_CLK_IN => tmp_H1_CLK_IN,
		H1_CLKWR => tmp_H1_CLKWR,
		WD_RST_L => tmp_WD_RST_L,
		WD_TICKLE => tmp_WD_TICKLE,
		RESET => tmp_RESET,
		M_DRV_EN_L => tmp_M_DRV_EN_L,
		HALT_DRIVE_L => tmp_HALT_DRIVE_L,
		M_OUT0_CLK => tmp_M_OUT0_CLK,
		M_OUT0_DATA => tmp_M_OUT0_DATA,
		M_OUT0_CONTROL => tmp_M_OUT0_CONTROL,
		M_OUT1_CLK => tmp_M_OUT1_CLK,
		M_OUT1_DATA => tmp_M_OUT1_DATA,
		M_OUT1_CONTROL => tmp_M_OUT1_CONTROL,
		M_AX0_0 => tmp_M_AX0_0,
		M_AX0_RET_DATA => tmp_M_AX0_RET_DATA,
		M_AX1_INT_CLK => tmp_M_AX1_INT_CLK,
		M_AX1_RET_DATA => tmp_M_AX1_RET_DATA,
		M_MUXED_ADC_CS_QA0_SIGA => tmp_M_MUXED_ADC_CS_QA0_SIGA,
		M_MUXED_ADC_DATA0_QA0_SIGB => tmp_M_MUXED_ADC_DATA0_QA0_SIGB,
		M_MUXED_ADC_DATA1_QA1_SIGA => tmp_M_MUXED_ADC_DATA1_QA1_SIGA,
		M_ENABLE => tmp_M_ENABLE,
		M_FAULT => tmp_M_FAULT,
		M_Card_ID_LOAD => tmp_M_Card_ID_LOAD,
		M_Card_ID_LATCH => tmp_M_Card_ID_LATCH,
		M_Card_ID_CLK => tmp_M_Card_ID_CLK,
		M_Card_ID_DATA => tmp_M_Card_ID_DATA,
		Exp_Mxd_ID_LOAD => tmp_Exp_Mxd_ID_LOAD,
		Exp_Mxd_ID_LATCH => tmp_Exp_Mxd_ID_LATCH,
		Exp_Mxd_ID_CLK => tmp_Exp_Mxd_ID_CLK,
		Exp_ID_DATA => tmp_Exp_ID_DATA,
		M_IO_OE => tmp_M_IO_OE,
		M_IO_LOAD => tmp_M_IO_LOAD,
		M_IO_LATCH => tmp_M_IO_LATCH,
		M_IO_CLK => tmp_M_IO_CLK,
		M_IO_DATAOut => tmp_M_IO_DATAOut,
		M_IO_DATAIn => tmp_M_IO_DATAIn,
		M_SPROM_CLK => tmp_M_SPROM_CLK,
		M_SPROM_DATA => tmp_M_SPROM_DATA,
		CPUStatLEDDrive => tmp_CPUStatLEDDrive,
		Exp0Data => tmp_Exp0Data,
		Exp1Data => tmp_Exp1Data,
		Exp2Data => tmp_Exp2Data,
		Exp3Data => tmp_Exp3Data,
		QA0_SigZ => tmp_QA0_SigZ,
		QA0_Home => tmp_QA0_Home,
		QA0_RegX_PosLmt => tmp_QA0_RegX_PosLmt,
		QA0_RegY_NegLmt => tmp_QA0_RegY_NegLmt,
		QA1_SigB => tmp_QA1_SigB,
		QA1_SigZ => tmp_QA1_SigZ,
		QA1_Home => tmp_QA1_Home,
		QA1_RegX_PosLmt => tmp_QA1_RegX_PosLmt,
		QA1_RegY_NegLmt => tmp_QA1_RegY_NegLmt,
		X_Reserved0 => tmp_X_Reserved0,
		X_Reserved1 => tmp_X_Reserved1,
		Debug0 => tmp_Debug0,
		Debug1 => tmp_Debug1,
		Debug2 => tmp_Debug2,
		FPGA_Test => tmp_FPGA_Test,
		TestClock => tmp_TestClock
       );
end top_arch;
