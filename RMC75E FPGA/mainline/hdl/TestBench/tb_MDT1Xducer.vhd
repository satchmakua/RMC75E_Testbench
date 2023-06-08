--
-- VHDL Test Bench Created from source file top.vhd -- 19:20:18 07/11/2002
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_MDT1Xducer IS
	port(
		M_AX1_RET_DATA: out std_logic;
		M_AX1_INT_CLK: in std_logic
	);
END tb_MDT1Xducer;

ARCHITECTURE behavior OF tb_MDT1Xducer IS 

	constant ClockPeriod : TIME := 3 ns;

BEGIN

-- set up the MDT return pulses 
	mdt1 : Process
	begin
	-- first return pulse
		M_AX1_RET_DATA <= '0';
		wait until M_AX1_INT_CLK = '1';
		wait until M_AX1_INT_CLK = '0';
		wait for (ClockPeriod * 25) + (ClockPeriod/2);
		M_AX1_RET_DATA <= '1';
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_AX1_RET_DATA <= '0';
		wait for (ClockPeriod * 200);
		M_AX1_RET_DATA <= '1';
		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_AX1_RET_DATA <= '0';
	end process;

END;