
create_clock -name {WriteClk60MHz} -period 16.6667 -waveform {0 8.33333 } [ get_ports { H1_CLKWR } ]

create_clock -name {MainClockIn60MHz} -period 16.6667 -waveform {0 8.33333 } [ get_ports { H1_CLK_IN } ]

# Main 60 MHz clock (GL0 out of CCC)
create_generated_clock -name {Clk_60M} -divide_by 1 -source [ get_ports { H1_CLK_IN } ] [ get_nets { H1_CLK } ]

# Main 30 MHz system clock (GL2 of CCC)
create_generated_clock -name {Clk_30M} -divide_by 2 -source [ get_ports { H1_CLK_IN } ] [ get_nets { SysClk } ]

# 60 MHz clock with 90 deg phase shift for MDT
create_generated_clock -name {Clk_60M_90deg} -divide_by 1 -source [ get_ports { H1_CLK_IN } ] -phase 90 [ get_nets { H1_CLK90 } ]

#set_input_delay 3 -min  -clock { Clk_60M_90deg } [ get_ports { M_AX0_RET_DATA M_AX1_RET_DATA } ]
#set_input_delay 14 -max  -clock { Clk_60M_90deg } [ get_ports { M_AX0_RET_DATA M_AX1_RET_DATA } ]
#set_input_delay 3 -min  -clock { Clk_60M } [ get_ports { M_AX0_RET_DATA M_AX1_RET_DATA } ]
#set_input_delay 14 -max  -clock { Clk_60M } [ get_ports { M_AX0_RET_DATA M_AX1_RET_DATA } ]

# Max Read delay
set_max_delay 30 -from [ get_ports { CS_L ExtADDR RD_L } ] -to [ get_ports { DATA } ]
