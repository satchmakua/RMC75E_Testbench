--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_RAM128x16
--	File			tb_RAM128x16.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--  This test bench writes to each memory location with its address as data, then reads
--	back and checks if the data read matches the address, ensuring each memory
--	location can be written and read correctly. 

--	This test bench first resets the memory by writing zeros to all addresses,
--	then tests the write and read operations. All signals should be initialized and tested properly.

--	Note that the data and addresses are generated in a loop for thorough testing.

--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_RAM128x16 is
end tb_RAM128x16;

architecture tb of tb_RAM128x16 is
    signal clk   : std_logic := '0';
    signal we    : std_logic := '0';
    signal a     : std_logic_vector(6 downto 0) := (others => '0');
    signal d     : std_logic_vector(15 downto 0) := (others => '0');
    signal o     : std_logic_vector(15 downto 0);

begin
    DUT: entity work.RAM128x16
    port map (
        clk => clk,
        we  => we,
        a   => a,
        d   => d,
        o   => o
    );

    -- Test sequence
    process
    begin
        -- Generate clock
        clk <= not clk after 10 ns;
        
        -- Reset process (writing zeros to all addresses)
        we <= '1';
        d <= (others => '0');
        for i in 0 to 127 loop
            a <= std_logic_vector(to_unsigned(i, 7));
            wait for 20 ns;
        end loop;
        we <= '0';
        
        -- Write to memory locations
        for i in 0 to 127 loop
            a <= std_logic_vector(to_unsigned(i, 7));
            d <= std_logic_vector(to_unsigned(i, 16));
            we <= '1';
            wait for 20 ns;
            we <= '0';
            wait for 20 ns;
        end loop;

        -- Read from memory locations
        for i in 0 to 127 loop
            a <= std_logic_vector(to_unsigned(i, 7));
            wait for 20 ns;
            assert o = std_logic_vector(to_unsigned(i, 16)) report "Read Error at Address: " & integer'image(i) severity error;
        end loop;

        -- End test sequence
        wait;
    end process;
end tb;
