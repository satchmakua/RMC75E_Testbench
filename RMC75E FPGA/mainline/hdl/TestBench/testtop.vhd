
library IEEE;
use IEEE.std_logic_1164.all;

entity TestTop is
    port (
      H1_CLK: in std_logic;
      H1B_CLK: inout std_logic
    );
end TestTop;

architecture Top_arch of TestTop is

-- component definitions
component bufg is
	port (I: in std_logic; O: out std_logic);
end component;


-- signal definitions
signal H1_CLK_INT: std_logic;

begin

-- component instantiations
U1:bufg port map (H1_CLK, H1_CLK_INT);


process(H1_CLK_INT)
begin
	if H1_CLK_INT'event and H1_CLK_INT = '1' then
		H1B_CLK <= not H1B_CLK;
	end if;
end process;

end Top_arch;
