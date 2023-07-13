open_project -project {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top_fp\Top.pro}\
         -connect_programmers {FALSE}
load_programming_data \
    -name {M2GL005} \
    -fpga {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top.map} \
    -header {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top.hdr} \
    -spm {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top.spm} \
    -dca {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top.dca}
export_single_dat \
    -name {M2GL005} \
    -file {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\export\RMC75E3v1_rev3v2.dat} \
    -secured

save_project
close_project
