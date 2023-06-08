# Written by Synplify Pro version map202109actsp1, Build 056R. Synopsys Run ID: sid1677630435 
# Top Level Design Parameters 

# Clocks 
create_clock -period 10.000 -waveform {0.000 5.000} -name {Clock_Gen_Clock_Gen_0_FCCC|GL2_net_inferred_clock} [get_pins {ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/GL2}] 
create_clock -period 10.000 -waveform {0.000 5.000} -name {Top|H1_CLKWR} [get_ports {H1_CLKWR}] 
create_clock -period 10.000 -waveform {0.000 5.000} -name {Clock_Gen_Clock_Gen_0_FCCC|GL0_net_inferred_clock} [get_pins {ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/GL0}] 
create_clock -period 10.000 -waveform {0.000 5.000} -name {Clock_Gen_Clock_Gen_0_FCCC|GL1_net_inferred_clock} [get_pins {ClkCtrl_1/clk_1/Clock_Gen_0/CCC_INST/GL1}] 

# Virtual Clocks 

# Generated Clocks 

# Paths Between Clocks 

# Multicycle Constraints 

# Point-to-point Delay Constraints 

# False Path Constraints 

# Output Load Constraints 

# Driving Cell Constraints 

# Input Delay Constraints 

# Output Delay Constraints 

# Wire Loads 

# Other Constraints 

# syn_hier Attributes 

# set_case Attributes 

# Clock Delay Constraints 
set Inferred_clkgroup_0 [list Clock_Gen_Clock_Gen_0_FCCC|GL2_net_inferred_clock]
set Inferred_clkgroup_1 [list Top|H1_CLKWR]
set Inferred_clkgroup_2 [list Clock_Gen_Clock_Gen_0_FCCC|GL0_net_inferred_clock]
set Inferred_clkgroup_3 [list Clock_Gen_Clock_Gen_0_FCCC|GL1_net_inferred_clock]
set_clock_groups -asynchronous -group $Inferred_clkgroup_0
set_clock_groups -asynchronous -group $Inferred_clkgroup_1
set_clock_groups -asynchronous -group $Inferred_clkgroup_2
set_clock_groups -asynchronous -group $Inferred_clkgroup_3

set_clock_groups -asynchronous -group [get_clocks {Clock_Gen_Clock_Gen_0_FCCC|GL2_net_inferred_clock}]
set_clock_groups -asynchronous -group [get_clocks {Top|H1_CLKWR}]
set_clock_groups -asynchronous -group [get_clocks {Clock_Gen_Clock_Gen_0_FCCC|GL0_net_inferred_clock}]
set_clock_groups -asynchronous -group [get_clocks {Clock_Gen_Clock_Gen_0_FCCC|GL1_net_inferred_clock}]

# syn_mode Attributes 

# Cells 

# Port DRC Rules 

# Input Transition Constraints 

# Unused constraints (intentionally commented out) 


# Non-forward-annotatable constraints (intentionally commented out) 

# Block Path constraints 

