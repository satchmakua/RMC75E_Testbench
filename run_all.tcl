# Load the libraries (change "work" to your specific library name if necessary)
vlib work

# List of test bench files
set testbenches {
		tb_analog.vhd
    tb_CPUconfig.vhd
    tb_DIO8.vhd
    tb_DataBuffer.vhd
    tb_DiscoverExpansionID.vhd
    tb_ExpModuleLED.vhd
    tb_ExpSigRoute.vhd
    tb_MDTTopSimp.vhd
    tb_RtdExpIDLED.vhd
    tb_SSITop.vhd
    tb_Serial2Parallel.vhd
    tb_Serial2Parallel_v2.vhd
    tb_analog.vhd
    tb_controlio.vhd
    tb_controloutput.vhd
    tb_cpuled.vhd
    tb_decode.vhd
    tb_disccontID.vhd
    tb_discovercontrol.vhd
    tb_latencyCounter.vhd
    tb_list.txt
    tb_mdtssiroute.vhd
    tb_quad.vhd
    tb_ram128x16bits.vhd
    tb_serial_mem.vhd
    tb_statemachine.vhd
    tb_ticksync.vhd
    tb_top.vhd
    tb_watchdogtimer.vhd
}

# Load and run each test bench
foreach tb $testbenches {
    vsim work.[file rootname $tb]
		set StdArithNoWarnings 1
		set NumericStdNoWarnings 1
    run 100 us
    add wave -r /*
    quit -sim
}
