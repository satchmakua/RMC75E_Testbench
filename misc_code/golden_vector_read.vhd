library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_test is
end tb_test;

architecture arch of tb_test is
    file input_file : text;
    variable line_var : line;
    variable in_var : string(1 to 20);
    variable out_var : string(1 to 20);
begin
    process
    begin
        file_open(input_file, "golden_vector.txt", read_mode);
        while not endfile(input_file) loop
            readline(input_file, line_var);
            read(line_var, in_var);
            read(line_var, out_var);
            -- Here, you would compare out_var to the actual output
            -- If they're not equal, you could write an error to another file or the console
        end loop;
        file_close(input_file);
        wait;
    end process;
end arch;
