new_project \
         -name {Top} \
         -location {C:\RMC70\Programmable\CPU\RMC75E\FPGA\mainline\designer\Top\Top_fp} \
         -mode {chain} \
         -connect_programmers {FALSE}
add_actel_device \
         -device {M2GL005} \
         -name {M2GL005}
enable_device \
         -name {M2GL005} \
         -enable {TRUE}
save_project
close_project
