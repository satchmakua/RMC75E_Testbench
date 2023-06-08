-- Registers.vhd
-- Registers contains the user configurable registers and the LED's

library IEEE;
use IEEE.std_logic_1164.all;

entity ConfigReg is
	port (
		Clk: in std_logic;
		WR_Clk: in std_logic;
		DATA: in std_logic_vector (1 downto 0);
		TickOut: in std_logic;
		LED0EN: in std_logic;
		LED1EN: in std_logic;
		RED0: out std_logic;
		RED1: out std_logic;
		GRN0: out std_logic;
		GRN1: out std_logic;
		LoopTimeEN: in std_logic;
		LoopTimeFlag: out std_logic
		);
end ConfigReg;

architecture ConfigReg_arch of ConfigReg is

-- component declarations

-- signal declarations
signal IntRed0: std_logic;
signal IntRed1: std_logic;
signal IntGrn0: std_logic;
signal IntGrn1: std_logic;
signal ExtRed0: std_logic;
signal ExtRed1: std_logic;
signal ExtGrn0: std_logic;
signal ExtGrn1: std_logic;

begin -- start of architecture definition

-- signal assignments
-- led's are double buffered for added drive capability

-- axis 0 LED's
RED0 <= ExtRed0;
GRN0 <= ExtGrn0;

-- axis 1 LED's
RED1 <= ExtRed1;
GRN1 <= ExtGrn1;

-- LED latch(flip-flop) descriptions
process (WR_Clk, LED0EN)
begin
if WR_Clk'event and WR_Clk = '1' then
	if LED0EN = '1' then
		IntRed0 <= DATA(0);
		IntGrn0 <= DATA(1);
	end if;
end if;
end process;

process (WR_Clk, LED1EN)
begin
if WR_Clk'event and WR_Clk = '1' then
	if LED1EN = '1' then
		IntRed1 <= DATA(0);
		IntGrn1 <= DATA(1);
	end if;
end if;
end process;

-- The LED's are only updated on the one millisecond transition to ensure no
-- noise is coupled onto the analog inputs.
process (Clk, TickOut)
begin
if Clk'event and Clk='1' then
	if TickOut = '1' then
		ExtRed0 <= IntRed0;
		ExtGrn0 <= IntGrn0;
		ExtRed1 <= IntRed1;
		ExtGrn1 <= IntGrn1;
	end if;
end if;
end process;

-- set up up a register to hold the one or two millisecond delay flag
-- a '1' in the LoopTimeFlag register means 2ms looptime else 1ms looptime
process (Wr_Clk, LoopTimeEN, DATA)
begin
	if Wr_Clk'event and Wr_Clk='1' then
		if LoopTimeEN='1' then
			LoopTimeFlag <= DATA(0);
		end if;
	end if;
end process;

end ConfigReg_arch;
