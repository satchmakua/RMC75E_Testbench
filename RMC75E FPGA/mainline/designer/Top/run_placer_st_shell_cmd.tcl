read_sdc -scenario "place_and_route" -netlist "optimized" -pin_separator "/" -ignore_errors {C:/RMC70/Programmable/CPU/RMC75E/FPGA/mainline/designer/Top/place_route.sdc}
set_options -tdpr_scenario "place_and_route" 
save
set_options -analysis_scenario "place_and_route"
report -type combinational_loops -format xml {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top_layout_combinational_loops.xml}
report -type slack {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\pinslacks.txt}
set coverage [report \
    -type     constraints_coverage \
    -format   xml \
    -slacks   no \
    {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top_place_and_route_constraint_coverage.xml}]
set reportfile {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\coverage_placeandroute}
set fp [open $reportfile w]
puts $fp $coverage
close $fp