library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FaultFilter is
    Port ( 
	 		SysClk : in std_logic;
         FaultFilterLength : in std_logic_vector(15 downto 0);
         M_FAULT : in std_logic;
         FaultFiltered : out std_logic;
         Enable : in std_logic;
		 	SlowEnable : in std_logic
		);
end FaultFilter;

architecture FaultFilter_arch of FaultFilter is

-- Component Declarations
-- (No component declarations for this module)

-- Signal Declarations
signal AssignFault, Fault: std_logic_vector (1 downto 0) := "00";
signal FaultCount: std_logic_vector (15 downto 0) := X"0000";
signal FaultTerminalCount: std_logic := '0';
signal AssignFaultEnable, ClearFaultCount: std_logic := '0';

begin

process (SysClk)
begin
	if rising_edge(SysClk) then
		Fault(0) <= M_FAULT;
		Fault(1) <= Fault(0);
	end if;
end process;

-- Edge detection and a counter reset using 
-- an exor function are required.
ClearFaultCount <= '1' when Fault(1) /= Fault(0) else '0';

-- the filtering will take the form of a counter which counts up to max count
-- and then stops. When the counter reaches max count then the output will 
-- take on the new value. If the input changes during this time period, then
-- the counter resets and starts over. 
process (SysClk, ClearFaultCount)
begin
	if ClearFaultCount = '1' then
		FaultCount <= X"0000";
	elsif rising_edge(SysClk) then
		if (FaultTerminalCount = '0' and SlowEnable = '1') then
			FaultCount <= FaultCount + 1;
		end if;
	end if;
end process;

FaultTerminalCount <= '1' when (FaultCount = FaultFilterLength) else '0';

process (SysClk)
begin
	if rising_edge(SysClk) then
		if SlowEnable = '1' then
			AssignFault(0) <= FaultTerminalCount;
			AssignFault(1) <= AssignFault(0);
		end if;
	end if;
end process;

AssignFaultEnable <= '1' when ((AssignFault(0) = '1' and AssignFault(1) = '0' and Enable = '1' ) or  
										(ClearFaultCount = '1' and FaultFilterLength = X"0000")) else '0';

process (SysClk)
begin
	if rising_edge(SysClk) then
		if AssignFaultEnable = '1' then
			FaultFiltered <= M_FAULT;
		end if;
	end if;
end process;

end FaultFilter_arch;
