--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2023 Delta Computer Systems, Inc.
--	Author: Satchel Hamilton
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		tb_decode
--	File			tb_decode.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
	-- DUT:
	-- The module "Decode" is responsible for generating WRITE control lines
	-- and READ control lines based on the input address and control signals.
	-- It is a decoder module for interfacing with various peripheral devices.
	
	-- Test bench is used to verify the functionality of the Decode module.
	-- It provides stimulus signals to the module and monitors the output signals to ensure correct behavior.
	-- Stimulus signals are initialized and applied to the Decode module inputs, and the corresponding
	-- outputs are observed. The testbench includes response verification blocks that compare
	-- the output signals against expected values and report errors if they do not match.


--	Revision: 1.0
--
--	File history:
--	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity tb_decode is
end tb_decode;

architecture tb of tb_decode is
    -- Component declaration
    component Decode is
        port(
            ADDR: in std_logic_vector(11 downto 0);
            RD_L, WR_L, CS_L, MDTPresent, ANLGPresent, QUADPresent: in std_logic;
            Exp0Mux, Exp1Mux, Exp2Mux, Exp3Mux: in std_logic_vector(1 downto 0);
             ExpA0ReadCh0, ExpA0ReadCh1, ExpA0LED0Read, ExpA0LED0Write, ExpA0LED1Read, ExpA0LED1Write: out std_logic;
            ExpA1ReadCh0, ExpA1ReadCh1, ExpA1LED0Read, ExpA1LED0Write, ExpA1LED1Read, ExpA1LED1Write: out std_logic;
            ExpA2ReadCh0, ExpA2ReadCh1, ExpA2LED0Read, ExpA2LED0Write, ExpA2LED1Read, ExpA2LED1Write: out std_logic;
            ExpA3ReadCh0, ExpA3ReadCh1, ExpA3LED0Read, ExpA3LED0Write, ExpA3LED1Read, ExpA3LED1Write: out std_logic;
            Exp0QuadCountRead, Exp0QuadLEDStatusRead, Exp0QuadLEDStatusWrite, Exp0QuadInputRead, Exp0QuadHomeRead, Exp0QuadLatch0Read, Exp0QuadLatch1Read: out std_logic;
            Exp1QuadCountRead, Exp1QuadLEDStatusRead, Exp1QuadLEDStatusWrite, Exp1QuadInputRead, Exp1QuadHomeRead, Exp1QuadLatch0Read, Exp1QuadLatch1Read: out std_logic;
            Exp2QuadCountRead, Exp2QuadLEDStatusRead, Exp2QuadLEDStatusWrite, Exp2QuadInputRead, Exp2QuadHomeRead, Exp2QuadLatch0Read, Exp2QuadLatch1Read: out std_logic;
            Exp3QuadCountRead, Exp3QuadLEDStatusRead, Exp3QuadLEDStatusWrite, Exp3QuadInputRead, Exp3QuadHomeRead, Exp3QuadLatch0Read, Exp3QuadLatch1Read: out std_logic;
            FPGAAccess, ANLGAccess, FPGAIDRead, CPUConfigRead, CPUConfigWrite: out std_logic;
            CPUsuccessfulBoot, WatchdogTriggeredReset, ANLGRead, ANLGWrite, MDTPresenceRead: out std_logic
        );
    end component;

	-- Clock signal period
	constant CLK_PERIOD: time := 16.6667 ns;
	
    -- Test inputs
    signal ADDR: std_logic_vector(11 downto 0);
    signal RD_L, WR_L, CS_L, MDTPresent, ANLGPresent, QUADPresent: std_logic;
    signal Exp0Mux, Exp1Mux, Exp2Mux, Exp3Mux: std_logic_vector(1 downto 0);

    -- Test outputs
    signal FPGAAccess, ANLGAccess, FPGAIDRead, CPUConfigRead, CPUConfigWrite: std_logic;
    signal CPUsuccessfulBoot, WatchdogTriggeredReset, ANLGRead, ANLGWrite, MDTPresenceRead: std_logic;
		
    -- Adding test signals for expanded outputs
    signal ExpA0ReadCh0, ExpA0ReadCh1, ExpA0LED0Read, ExpA0LED0Write, ExpA0LED1Read, ExpA0LED1Write: std_logic;
    signal ExpA1ReadCh0, ExpA1ReadCh1, ExpA1LED0Read, ExpA1LED0Write, ExpA1LED1Read, ExpA1LED1Write: std_logic;
    signal ExpA2ReadCh0, ExpA2ReadCh1, ExpA2LED0Read, ExpA2LED0Write, ExpA2LED1Read, ExpA2LED1Write: std_logic;
    signal ExpA3ReadCh0, ExpA3ReadCh1, ExpA3LED0Read, ExpA3LED0Write, ExpA3LED1Read, ExpA3LED1Write: std_logic;
    signal Exp0QuadCountRead, Exp0QuadLEDStatusRead, Exp0QuadLEDStatusWrite, Exp0QuadInputRead, Exp0QuadHomeRead, Exp0QuadLatch0Read, Exp0QuadLatch1Read: std_logic;
    signal Exp1QuadCountRead, Exp1QuadLEDStatusRead, Exp1QuadLEDStatusWrite, Exp1QuadInputRead, Exp1QuadHomeRead, Exp1QuadLatch0Read, Exp1QuadLatch1Read: std_logic;
    signal Exp2QuadCountRead, Exp2QuadLEDStatusRead, Exp2QuadLEDStatusWrite, Exp2QuadInputRead, Exp2QuadHomeRead, Exp2QuadLatch0Read, Exp2QuadLatch1Read: std_logic;
    signal Exp3QuadCountRead, Exp3QuadLEDStatusRead, Exp3QuadLEDStatusWrite, Exp3QuadInputRead, Exp3QuadHomeRead, Exp3QuadLatch0Read, Exp3QuadLatch1Read: std_logic;
	
		begin
    
		-- Test Stimuli
		stimuli : process
		begin
			-- Initialize inputs
			ADDR <= (others => '0');
			RD_L <= '0';
			WR_L <= '0';
			CS_L <= '0';
			MDTPresent <= '0';
			ANLGPresent <= '0';
			QUADPresent <= '0';
			Exp0Mux <= (others => '0');
			Exp1Mux <= (others => '0');
			Exp2Mux <= (others => '0');
			Exp3Mux <= (others => '0');

			-- Initialize outputs
			FPGAAccess <= '0';
			ANLGAccess <= '0';
			FPGAIDRead <= '0';
			CPUConfigRead <= '0';
			CPUConfigWrite <= '0';
			CPUsuccessfulBoot <= '0';
			WatchdogTriggeredReset <= '0';
			ANLGRead <= '0';
			ANLGWrite <= '0';
			MDTPresenceRead <= '0';
		
			ExpA0ReadCh0 <= '0';
			ExpA0ReadCh1 <= '0';
			ExpA0LED0Read <= '0';
			ExpA0LED0Write <= '0';
			ExpA0LED1Read <= '0';
			ExpA0LED1Write <= '0';
			ExpA1ReadCh0 <= '0';
			ExpA1ReadCh1 <= '0';
			ExpA1LED0Read <= '0';
			ExpA1LED0Write <= '0';
			ExpA1LED1Read <= '0';
			ExpA1LED1Write <= '0';
			ExpA2ReadCh0 <= '0';
			ExpA2ReadCh1 <= '0';
			ExpA2LED0Read <= '0';
			ExpA2LED0Write <= '0';
			ExpA2LED1Read <= '0';
			ExpA2LED1Write <= '0';
			ExpA3ReadCh0 <= '0';
			ExpA3ReadCh1 <= '0';
			ExpA3LED0Read <= '0';
			ExpA3LED0Write <= '0';
			ExpA3LED1Read <= '0';
			ExpA3LED1Write <= '0';
			Exp0QuadCountRead <= '0';
			Exp0QuadLEDStatusRead <= '0';
			Exp0QuadLEDStatusWrite <= '0';
			Exp0QuadInputRead <= '0';
			Exp0QuadHomeRead <= '0';
			Exp0QuadLatch0Read <= '0';
			Exp0QuadLatch1Read <= '0';
			Exp1QuadCountRead <= '0';
			Exp1QuadLEDStatusRead <= '0';
			Exp1QuadLEDStatusWrite <= '0';
			Exp1QuadInputRead <= '0';
			Exp1QuadHomeRead <= '0';
			Exp1QuadLatch0Read <= '0';
			Exp1QuadLatch1Read <= '0';
			Exp2QuadCountRead <= '0';
			Exp2QuadLEDStatusRead <= '0';
			Exp2QuadLEDStatusWrite <= '0';
			Exp2QuadInputRead <= '0';
			Exp2QuadHomeRead <= '0';
			Exp2QuadLatch0Read <= '0';
			Exp2QuadLatch1Read <= '0';
			Exp3QuadCountRead <= '0';
			Exp3QuadLEDStatusRead <= '0';
			Exp3QuadLEDStatusWrite <= '0';
			Exp3QuadInputRead <= '0';
			Exp3QuadHomeRead <= '0';
			Exp3QuadLatch0Read <= '0';
			Exp3QuadLatch1Read <= '0';
		
			-- Reset Signals
			RD_L <= '0'; WR_L <= '0'; CS_L <= '0';
			MDTPresent <= '0'; ANLGPresent <= '0'; QUADPresent <= '0';
			Exp0Mux <= "00"; Exp1Mux <= "00"; Exp2Mux <= "00"; Exp3Mux <= "00";
			wait for 6 * CLK_PERIOD;

			-- Stimuli 0
			ADDR <= "000000000001";
			RD_L <= '1'; WR_L <= '1'; CS_L <= '1';
			MDTPresent <= '1'; ANLGPresent <= '1'; QUADPresent <= '1';
			Exp0Mux <= "01"; Exp1Mux <= "01"; Exp2Mux <= "01"; Exp3Mux <= "01";
			wait for 6 * CLK_PERIOD;

		-- Stimuli 1
			ADDR <= "000000000011";
			RD_L <= '1'; WR_L <= '0'; CS_L <= '1';
			MDTPresent <= '1'; ANLGPresent <= '0'; QUADPresent <= '1';
			Exp0Mux <= "10"; Exp1Mux <= "00"; Exp2Mux <= "11"; Exp3Mux <= "01";
			wait for 6 * CLK_PERIOD;

			-- Stimuli 2
			ADDR <= "000000000100";
			RD_L <= '1'; WR_L <= '1'; CS_L <= '0';
			MDTPresent <= '0'; ANLGPresent <= '1'; QUADPresent <= '0';
			Exp0Mux <= "01"; Exp1Mux <= "10"; Exp2Mux <= "00"; Exp3Mux <= "11";
			wait for 6 * CLK_PERIOD;

			-- Stimuli 3
			ADDR <= "000000000101";
			RD_L <= '0'; WR_L <= '0'; CS_L <= '0';
			MDTPresent <= '1'; ANLGPresent <= '1'; QUADPresent <= '1';
			Exp0Mux <= "00"; Exp1Mux <= "00"; Exp2Mux <= "00"; Exp3Mux <= "00";
			wait for 6 * CLK_PERIOD;

			-- Stimuli 4
			ADDR <= "000000000110";
			RD_L <= '1'; WR_L <= '1'; CS_L <= '1';
			MDTPresent <= '0'; ANLGPresent <= '0'; QUADPresent <= '0';
			Exp0Mux <= "11"; Exp1Mux <= "11"; Exp2Mux <= "11"; Exp3Mux <= "11";
			wait for 6 * CLK_PERIOD;

			-- Stimuli 5
			ADDR <= "000000000111";
			RD_L <= '0'; WR_L <= '0'; CS_L <= '0';
			MDTPresent <= '1'; ANLGPresent <= '1'; QUADPresent <= '1';
			Exp0Mux <= "01"; Exp1Mux <= "10"; Exp2Mux <= "00"; Exp3Mux <= "11";
			wait for 6 * CLK_PERIOD;

			-- Stimuli 6
			ADDR <= "000000001000";
			RD_L <= '1'; WR_L <= '1'; CS_L <= '1';
			MDTPresent <= '0'; ANLGPresent <= '0'; QUADPresent <= '0';
			Exp0Mux <= "00"; Exp1Mux <= "00"; Exp2Mux <= "00"; Exp3Mux <= "00";
			wait for 6 * CLK_PERIOD;

			-- Stimuli 7
			ADDR <= "000000001001";
			RD_L <= '0'; WR_L <= '1'; CS_L <= '0';
			MDTPresent <= '1'; ANLGPresent <= '0'; QUADPresent <= '1';
			Exp0Mux <= "11"; Exp1Mux <= "01"; Exp2Mux <= "10"; Exp3Mux <= "00";
			wait for 6 * CLK_PERIOD;

			wait;
		end process;

		-- Response Verification
		-- Processes to monitor output signals and compare them against expected values.
		-- If the output does not match the expected value, print an error message.

		-- Response Verification 1
		check : process
		begin
			wait on ExpA0ReadCh0;
			if ExpA0ReadCh0 /= '0' then
					report "ExpA0ReadCh0 has unexpected value" severity error;
			end if;
			wait on ExpA1ReadCh0;
			if ExpA1ReadCh0 /= '1' then
					report "ExpA1ReadCh0 has unexpected value" severity error;
			end if;
			wait on ExpA2ReadCh1;
			if ExpA2ReadCh1 /= '0' then
					report "ExpA2ReadCh1 has unexpected value" severity error;
			end if;
		end process;

		-- Response Verification 2
		check2 : process
		begin
			wait on Exp0QuadCountRead;
			if Exp0QuadCountRead /= '1' then
					report "Exp0QuadCountRead has unexpected value" severity error;
			end if;
			wait on Exp1QuadLEDStatusWrite;
			if Exp1QuadLEDStatusWrite /= '0' then
					report "Exp1QuadLEDStatusWrite has unexpected value" severity error;
			end if;
			wait on Exp2QuadHomeRead;
			if Exp2QuadHomeRead /= '1' then
					report "Exp2QuadHomeRead has unexpected value" severity error;
			end if;
		end process;

		-- Response Verification 3
		check3 : process
		begin
			wait on FPGAAccess;
			if FPGAAccess /= '0' then
					report "FPGAAccess has unexpected value" severity error;
			end if;
			wait on CPUConfigRead;
			if CPUConfigRead /= '1' then
					report "CPUConfigRead has unexpected value" severity error;
			end if;
			wait on ANLGWrite;
			if ANLGWrite /= '0' then
					report "ANLGWrite has unexpected value" severity error;
			end if;
		end process;

end tb;

	
