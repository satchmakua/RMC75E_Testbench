--
-- VHDL Test Bench Created from source file top.vhd -- 19:20:18 07/11/2002
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_MDT0Xducer IS
	port(
		M_AX0_RET_DATA: out std_logic;
		M_AX0_INT_CLK: in std_logic
	);
END tb_MDT0Xducer;

ARCHITECTURE behavior OF tb_MDT0Xducer IS 

	constant ClockPeriod : TIME := 3 ns;

BEGIN

-- set up the MDT return pulses 
	mdt0 : Process
	begin
	-- first return pulse
		M_AX0_RET_DATA <= '0';
		wait until M_AX0_INT_CLK = '1';
		wait for (ClockPeriod * 25) + (ClockPeriod/2);
		M_AX0_RET_DATA <= '1';
--		wait for (ClockPeriod * 10) + (ClockPeriod/4);
--		M_AX0_RET_DATA <= '0';
		wait for (ClockPeriod * 1000);

	-- second return pulse
--		M_AX0_RET_DATA <= '1';
--		wait for (ClockPeriod * 10) + (ClockPeriod/4);
		M_AX0_RET_DATA <= '0';

		wait for (ClockPeriod * 10);

		wait until M_AX0_INT_CLK = '1';		-- This is my NoXducer cycle

	-- first return pulse
--		M_AX0_RET_DATA <= '0';
		wait until M_AX0_INT_CLK = '1';
		wait for (ClockPeriod * 25) + (ClockPeriod/2);
		M_AX0_RET_DATA <= '1';
--		wait for (ClockPeriod * 10) + (ClockPeriod/4);
--		M_AX0_RET_DATA <= '0';
		wait for (ClockPeriod * 6000);

	-- second return pulse
--		M_AX0_RET_DATA <= '1';
--		wait for (ClockPeriod * 10) + (ClockPeriod/4);
--		M_AX0_RET_DATA <= '0';

	end process;

END;