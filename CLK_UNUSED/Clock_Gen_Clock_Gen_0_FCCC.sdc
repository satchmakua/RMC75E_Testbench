set_component Clock_Gen_Clock_Gen_0_FCCC
# Microsemi Corp.
# Date: 2022-Sep-26 15:42:44
#

create_clock -period 16.6667 [ get_pins { CCC_INST/CLK1_PAD } ]
create_generated_clock -multiply_by 2 -divide_by 2 -source [ get_pins { CCC_INST/CLK1_PAD } ] -phase 0 [ get_pins { CCC_INST/GL0 } ]
create_generated_clock -multiply_by 2 -divide_by 2 -source [ get_pins { CCC_INST/CLK1_PAD } ] -phase 90 [ get_pins { CCC_INST/GL1 } ]
create_generated_clock -multiply_by 2 -divide_by 4 -source [ get_pins { CCC_INST/CLK1_PAD } ] -phase 0 [ get_pins { CCC_INST/GL2 } ]
