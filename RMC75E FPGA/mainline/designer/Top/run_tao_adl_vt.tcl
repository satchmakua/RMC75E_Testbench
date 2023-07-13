set_device -family {IGLOO2} -die {M2GL005} -speed {STD}
read_adl {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top.adl}
read_afl {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top.afl}
map_netlist
read_sdc {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\constraint\Top_derived_constraints.sdc}
read_sdc {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\constraint\user.sdc}
check_constraints {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\constraint\timing_sdc_errors.log}
write_sdc -mode smarttime {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\timing_analysis.sdc}
