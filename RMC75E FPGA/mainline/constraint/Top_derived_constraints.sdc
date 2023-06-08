# Microsemi Corp.
# Date: 2022-Oct-23 14:11:00
# This file was generated based on the following SDC source files:
#   C:/RMC70/Programmable/CPU/RMC75E/FPGA/mainline/component/work/Clock_Gen/Clock_Gen_0/Clock_Gen_Clock_Gen_0_FCCC.sdc
# *** Any modifications to this file will be lost if derived constraints is re-run. ***
#

create_clock -name {H1_CLK_IN} -period 16.6667 [ get_ports { H1_CLK_IN } ]
create_generated_clock -name {ClkCtrl_1/clk_1/Clock_Gen_0/GL0} -multiply_by 2 -divide_by 2 -source [ get_pins { ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/CLK1_PAD } ] -phase 0 [ get_pins { ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/GL0 } ]
create_generated_clock -name {ClkCtrl_1/clk_1/Clock_Gen_0/GL1} -multiply_by 2 -divide_by 2 -source [ get_pins { ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/CLK1_PAD } ] -phase 90 [ get_pins { ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/GL1 } ]
create_generated_clock -name {ClkCtrl_1/clk_1/Clock_Gen_0/GL2} -multiply_by 2 -divide_by 4 -source [ get_pins { ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/CLK1_PAD } ] -phase 0 [ get_pins { ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/GL2 } ]
