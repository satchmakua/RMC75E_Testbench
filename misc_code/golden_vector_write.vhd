library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_golden_vector is
end tb_golden_vector;

architecture arch of tb_golden_vector is
    file output_file : text;
    variable line_var : line;
begin
    process
    begin
        file_open(output_file, "golden_vector.txt", write_mode);
        -- Write your golden vector here. For instance:
        write(line_var, string'("input1 output1"));
        writeline(output_file, line_var);
        write(line_var, string'("input2 output2"));
        writeline(output_file, line_var);
        -- Continue writing for all input-output pairs
        file_close(output_file);
        wait;
    end process;
end arch;