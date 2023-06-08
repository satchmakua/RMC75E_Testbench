set_device \
    -family  IGLOO2 \
    -die     PA4MGL500 \
    -package vf256 \
    -speed   STD \
    -tempr   {COM} \
    -voltr   {COM}
set_def {VOLTAGE} {1.2}
set_def {VCCI_1.2_VOLTR} {COM}
set_def {VCCI_1.5_VOLTR} {COM}
set_def {VCCI_1.8_VOLTR} {COM}
set_def {VCCI_2.5_VOLTR} {COM}
set_def {VCCI_3.3_VOLTR} {COM}
set_def {PLL_SUPPLY} {PLL_SUPPLY_33}
set_def USE_CONSTRAINTS_FLOW 1
set_netlist -afl {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top.afl} -adl {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top.adl}
set_constraints   {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top.tcml}
set_placement   {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top.loc}
set_routing     {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top.seg}
