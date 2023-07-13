read_sdc -scenario "timing_analysis" -netlist "optimized" -pin_separator "/" -ignore_errors {C:/RMC70/Programmable/CPU/RMC75E/FPGA/mainline/designer/Top/timing_analysis.sdc}
set_options -analysis_scenario "timing_analysis" 
save
