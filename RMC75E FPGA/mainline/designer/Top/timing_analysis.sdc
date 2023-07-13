# Microsemi Corp.
# Date: 2023-Feb-28 17:05:58
# This file was generated based on the following SDC source files:
#   C:/RMC70/Programmable/CPU/RMC75E/FPGA/mainline/constraint/Top_derived_constraints.sdc
#   C:/RMC70/Programmable/CPU/RMC75E/FPGA/mainline/constraint/user.sdc
#

create_clock -name {H1_CLK_IN} -period 16.6667 [ get_ports { H1_CLK_IN } ]
create_clock -name {WriteClk60MHz} -period 16.6667 -waveform {0 8.33333 } [ get_ports { H1_CLKWR } ]
create_clock -name {MainClockIn60MHz} -period 16.6667 -waveform {0 8.33333 } [ get_ports { H1_CLK_IN } ]
create_generated_clock -name {ClkCtrl_1/clk_1/Clock_Gen_0/GL0} -multiply_by 2 -divide_by 2 -source [ get_pins { ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/INST_CCC_IP/CLK1_PAD } ] -phase 0 [ get_pins { ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/INST_CCC_IP/GL0 } ]
create_generated_clock -name {ClkCtrl_1/clk_1/Clock_Gen_0/GL1} -multiply_by 2 -divide_by 2 -source [ get_pins { ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/INST_CCC_IP/CLK1_PAD } ] -phase 90 [ get_pins { ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/INST_CCC_IP/GL1 } ]
create_generated_clock -name {ClkCtrl_1/clk_1/Clock_Gen_0/GL2} -multiply_by 2 -divide_by 4 -source [ get_pins { ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/INST_CCC_IP/CLK1_PAD } ] -phase 0 [ get_pins { ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/INST_CCC_IP/GL2 } ]
create_generated_clock -name {Clk_30M} -divide_by 2 -source [ get_ports { H1_CLK_IN } ] [ get_nets { SysClk } ]
set_max_delay 30 -from [ get_ports { CS_L ExtADDR RD_L } ] -to [ get_ports { DATA } ]
set_max_delay 4 -from [ get_ports { M_AX0_RET_DATA } ] -to [ get_pins { MDTTop_1/FallingA[1]/D } ]
set_max_delay 4 -from [ get_ports { M_AX1_RET_DATA } ] -to [ get_pins { MDTTop_2/FallingA[1]/D } ]
