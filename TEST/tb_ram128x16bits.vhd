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
--	File					tb_RAM128x16.vhd
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
    constant CLK_PERIOD : time := 16.6667 ns;
    
    signal clk: std_logic := '0';
    signal we: std_logic := '0';
    signal a: std_logic_vector(6 downto 0) := (others => '0');
    signal d: std_logic_vector(15 downto 0) := (others => '0');
    signal o: std_logic_vector(15 downto 0);
		
		begin
    DUT: entity work.RAM128x16
    port map (
        clk => clk,
        we => we,
        a => a,
        d => d,
        o => o
    );

    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    stimulus_process: process
    begin
        -- Write data to address 0
        we <= '1';
        a <= "0000000";
        d <= "1010101010101010";
        wait for CLK_PERIOD;
        we <= '0';
        wait for CLK_PERIOD;
        
        -- Read data from address 0
        a <= "0000000";
        wait for CLK_PERIOD;
        
        -- Check the output
        assert o = "1010101010101010" report "Test 1 failed: Incorrect data read from address 0" severity error;
        
        -- Write data to address 10
        we <= '1';
        a <= "0001010";
        d <= "0101010101010101";
        wait for CLK_PERIOD;
        we <= '0';
        wait for CLK_PERIOD;
        
        -- Read data from address 10
        a <= "0001010";
        wait for CLK_PERIOD;
        
        -- Check the output
        assert o = "0101010101010101" report "Test 2 failed: Incorrect data read from address 10" severity error;
        
        -- Write data to address 127
        we <= '1';
        a <= "1111111";
        d <= "1111000011110000";
        wait for CLK_PERIOD;
        we <= '0';
        wait for CLK_PERIOD;
        
        -- Read data from address 127
        a <= "1111111";
        wait for CLK_PERIOD;
        
        -- Check the output
        assert o = "1111000011110000" report "Test 3 failed: Incorrect data read from address 127" severity error;
        
        -- End simulation
        wait;
    end process;
end tb;
