----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:21:57 02/02/2006 
-- Design Name: 
-- Module Name:    QuadMux - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity QuadMux is
	Port (
		InSelect : in std_logic_vector (2 downto 0);
		Output : out std_logic;
		In0 : in std_logic;
		In1 : in std_logic;
		In2 : in std_logic;
		In3 : in std_logic
	);
end QuadMux;

architecture Arch of QuadMux is

begin

process (InSelect(2 downto 0), In0, In1, In2, In3)
begin
   case InSelect(2 downto 0) is
      when "000" => Output <= In0;
      when "001" => Output <= In1;
      when "010" => Output <= In2;
      when "011" => Output <= In3;
      when others => Output <= '0';
   end case;
end process;

end Arch;