set_device -family {IGLOO2} -die {M2GL005} -speed {STD}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\ram128x16bits.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\databuffer.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\serial2parallel.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\statemachine.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\analog.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\CPUConfig.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\cpuled.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\component\work\Clock_Gen\Clock_Gen_0\Clock_Gen_Clock_Gen_0_FCCC.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\component\work\Clock_Gen\Clock_Gen.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\clockcontrol.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\controlio.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\controloutput.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\DIO8.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\decode.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\DiscoverControlID.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\DiscoverExpansionID.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\discovercontrol.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\ExpModuleLED.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\ExpansionSigRoute.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\LatencyCounter.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\mdssiroute.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\MDTTopSimp.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\QuadXface.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\Quad.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\rtdexpidled.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\SSITop.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\serial_mem.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\ticksync.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\WatchDogTimer.vhd}
read_vhdl -mode vhdl_2008 {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\hdl\top.vhd}
set_top_level {Top}
map_netlist
check_constraints {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\constraint\synthesis_sdc_errors.log}
write_fdc {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\synthesis.fdc}
