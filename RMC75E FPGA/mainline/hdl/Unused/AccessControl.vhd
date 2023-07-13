library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AccessControl is
	port (	
		Axis0PositionRead: in std_logic;
		Axis1PositionRead: in std_logic;
		MDTPresent: in std_logic;
		ANLGPresent: in std_logic;
		MDT_SSIPositionRead0: out std_logic;
		MDT_SSIPositionRead1: out std_logic;
		AnlgPositionRead0: out std_logic;
		AnlgPositionRead1: out std_logic
	);
end AccessControl;

architecture AccessControl_arch of AccessControl is

begin

MDT_SSIPositionRead0 <= (Axis0PositionRead and MDTPresent);
MDT_SSIPositionRead1 <= (Axis1PositionRead and MDTPresent);

AnlgPositionRead0 <= (Axis0PositionRead and ANLGPresent); 
AnlgPositionRead1 <= (Axis1PositionRead and ANLGPresent); 

end AccessControl_arch;
