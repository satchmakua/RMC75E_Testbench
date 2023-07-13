
# Compile the VHDL files
vcom -93 -work work ./tb_all.vhd

# Compile the remaining VHDL files
# The vcom command takes a VHDL file and compiles it into a library (work by default)
# You will need to add vcom commands for each of your VHDL files. Replace filename with your actual file names

foreach tb {tb_analog.vhd} {
   vcom -93 -work work ./$tb
}

# Load the simulation
vsim -novopt work.tb_all

# Run the simulation
run -all
Replace tb_CPUconfig.vhd tb_DIO8.vhd ... with the filenames of your testbenches.

To run the script, use the following command in ModelSim: source script.tcl