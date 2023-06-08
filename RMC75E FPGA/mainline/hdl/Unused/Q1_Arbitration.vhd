----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:23:34 02/02/2006 
-- Design Name: 
-- Module Name:    Q1_Arbitration - Behavioral 
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

entity Q1Arbitration is
	Port (
		Exp0Mux : in std_logic_vector (1 downto 0);
		Exp1Mux : in std_logic_vector (1 downto 0);
		Exp2Mux : in std_logic_vector (1 downto 0);
		Exp3Mux : in std_logic_vector (1 downto 0);
		Exp0QuadCountRead: in std_logic;
		Exp0QuadLEDStatusRead: in std_logic;
		Exp0QuadLEDStatusWrite: in std_logic;
		Exp0QuadInputRead: in std_logic;
		Exp0QuadHomeRead: in std_logic;
		Exp0QuadLatch0Read: in std_logic;
		Exp0QuadLatch1Read: in std_logic;
		Exp1QuadCountRead: in std_logic;
		Exp1QuadLEDStatusRead: in std_logic;
		Exp1QuadLEDStatusWrite: in std_logic;
		Exp1QuadInputRead: in std_logic;
		Exp1QuadHomeRead: in std_logic;
		Exp1QuadLatch0Read: in std_logic;
		Exp1QuadLatch1Read: in std_logic;
		Exp2QuadCountRead: in std_logic;
		Exp2QuadLEDStatusRead: in std_logic;
		Exp2QuadLEDStatusWrite: in std_logic;
		Exp2QuadInputRead: in std_logic;
		Exp2QuadHomeRead: in std_logic;
		Exp2QuadLatch0Read: in std_logic;
		Exp2QuadLatch1Read: in std_logic;
		Exp3QuadCountRead: in std_logic;
		Exp3QuadLEDStatusRead: in std_logic;
		Exp3QuadLEDStatusWrite: in std_logic;
		Exp3QuadInputRead: in std_logic;
		Exp3QuadHomeRead: in std_logic;
		Exp3QuadLatch0Read: in std_logic;
		Exp3QuadLatch1Read: in std_logic;
		Exp0Quad_A : in std_logic;
		Exp0Quad_B : in std_logic;
		Exp0Quad_Reg : in std_logic;
		Exp0Quad_FaultA : in std_logic;
		Exp0Quad_FaultB : in std_logic;
		Exp1Quad_A : in std_logic;
		Exp1Quad_B : in std_logic;
		Exp1Quad_Reg : in std_logic;
		Exp1Quad_FaultA : in std_logic;
		Exp1Quad_FaultB : in std_logic;
 		Exp2Quad_A : in std_logic;
		Exp2Quad_B : in std_logic;
		Exp2Quad_Reg : in std_logic;
		Exp2Quad_FaultA : in std_logic;
		Exp2Quad_FaultB : in std_logic;
		Exp3Quad_A : in std_logic;
		Exp3Quad_B : in std_logic;
		Exp3Quad_Reg : in std_logic;
		Exp3Quad_FaultA : in std_logic;
		Exp3Quad_FaultB : in std_logic;
		Q1_0_QuadCountRead: out std_logic;
		Q1_0_QuadLEDStatusRead: out std_logic;
		Q1_0_QuadLEDStatusWrite: out std_logic;
		Q1_0_QuadInputRead: out std_logic;
		Q1_0_QuadHomeRead: out std_logic;
		Q1_0_QuadLatch0Read: out std_logic;
		Q1_0_QuadLatch1Read: out std_logic;
		Q1_1_QuadCountRead: out std_logic;
		Q1_1_QuadLEDStatusRead: out std_logic;
		Q1_1_QuadLEDStatusWrite: out std_logic;
		Q1_1_QuadInputRead: out std_logic;
		Q1_1_QuadHomeRead: out std_logic;
		Q1_1_QuadLatch0Read: out std_logic;
		Q1_1_QuadLatch1Read: out std_logic;
		Q1_0_A : out std_logic;
		Q1_0_B : out std_logic;
		Q1_0_Reg : out std_logic;
		Q1_0_FaultA : out std_logic;
		Q1_0_FaultB : out std_logic;
		Q1_1_A : out std_logic;
		Q1_1_B : out std_logic;
		Q1_1_Reg : out std_logic;
		Q1_1_FaultA : out std_logic;
		Q1_1_FaultB : out std_logic
		);
end Q1Arbitration;

architecture Arch of Q1Arbitration is
-- Component Declarations

component QuadMux is
   Port (	
		InSelect : in std_logic_vector (2 downto 0);
		Output : out std_logic;
		In0 : in std_logic;
		In1 : in std_logic;
		In2 : in std_logic;
		In3 : in std_logic
		);
end component;

-- Signal Declarations
signal Q1Present : std_logic_vector (3 downto 0) := X"0";
signal Q1_0_Map, Q1_1_Map : std_logic_vector (2 downto 0) := "000";

begin

-- Simplify the logic for 
Q1Present(3) <= '1' when Exp0Mux(1 downto 0) = "11" else '0';
Q1Present(2) <= '1' when Exp1Mux(1 downto 0) = "11" else '0';
Q1Present(1) <= '1' when Exp2Mux(1 downto 0) = "11" else '0';
Q1Present(0) <= '1' when Exp3Mux(1 downto 0) = "11" else '0';

-- the binary count corresponds to Expansion Slots
-- mapping is generated based upon the presence of -Q1 modules
process( Q1Present(3 downto 0))

begin
	case (Q1Present(3 downto 0)) is 
      when "0000" =>	-- 0000 -> No Q1's
			Q1_0_Map(2 downto 0) <= "100";
			Q1_1_Map(2 downto 0) <= "100";
      when "0001" =>	-- 0001 -> Pos 3 mapped to Slot0
			Q1_0_Map(2 downto 0) <= "011";
			Q1_1_Map(2 downto 0) <= "100";
      when "0010" =>	-- 0010 -> Pos 2 mapped to Slot0
			Q1_0_Map(2 downto 0) <= "010";
			Q1_1_Map(2 downto 0) <= "100";
      when "0011" =>	-- 0011 -> Pos 2 mapped to Slot0, Pos 3 mapped to Slot1
			Q1_0_Map(2 downto 0) <= "010";
			Q1_1_Map(2 downto 0) <= "011";
      when "0100" =>	-- 0100 -> Pos 1 mapped to Slot0
			Q1_0_Map(2 downto 0) <= "001";
			Q1_1_Map(2 downto 0) <= "100";
      when "0101" =>	-- 0101 -> Pos 1 mapped to Slot0, Pos 3 mapped to Slot1
			Q1_0_Map(2 downto 0) <= "001";
			Q1_1_Map(2 downto 0) <= "011";
      when "0110" =>	-- 0110 -> Pos 1 mapped to Slot0, Pos 2 mapped to Slot1
			Q1_0_Map(2 downto 0) <= "001";
			Q1_1_Map(2 downto 0) <= "010";
      when "0111" =>	-- 0111 -> Pos 1 mapped to Slot0, Pos 2 mapped to Slot1, Pos 3 unmapped
			Q1_0_Map(2 downto 0) <= "001";
			Q1_1_Map(2 downto 0) <= "010";
      when "1000" =>	-- 1000 -> Pos 0 mapped to Slot0
			Q1_0_Map(2 downto 0) <= "000";
			Q1_1_Map(2 downto 0) <= "100";
      when "1001" =>	-- 1001 -> Pos 0 mapped to Slot0, Pos 3 mapped to Slot1
			Q1_0_Map(2 downto 0) <= "000";
			Q1_1_Map(2 downto 0) <= "011";
      when "1010" =>	-- 1010 -> Pos 0 mapped to Slot0, Pos 2 mapped to Slot1
			Q1_0_Map(2 downto 0) <= "000";
			Q1_1_Map(2 downto 0) <= "010";
      when "1011" =>	-- 1011 -> Pos 0 mapped to Slot0, Pos 2 mapped to Slot1, Pos 3 unmapped
			Q1_0_Map(2 downto 0) <= "000";
			Q1_1_Map(2 downto 0) <= "010";
      when "1100" =>	-- 1100 -> Pos 0 mapped to Slot0, Pos 1 mapped to Slot1
			Q1_0_Map(2 downto 0) <= "000";
			Q1_1_Map(2 downto 0) <= "001";
      when "1101" =>	-- 1101 -> Pos 0 mapped to Slot0, Pos 1 mapped to Slot1, Pos 3 unmapped
			Q1_0_Map(2 downto 0) <= "000";
			Q1_1_Map(2 downto 0) <= "001";
      when "1110" => -- 1110 -> Pos 0 mapped to Slot0, Pos 1 mapped to Slot1, Pos 2 unmapped
			Q1_0_Map(2 downto 0) <= "000";
			Q1_1_Map(2 downto 0) <= "001";
      when "1111" => -- 1111 -> Pos 0 mapped to Slot0, Pos 1 mapped to Slot1, Pos 2 & 3 unmapped
			Q1_0_Map(2 downto 0) <= "000";
			Q1_1_Map(2 downto 0) <= "001";
      when others => 
			Q1_0_Map(2 downto 0) <= "100";
			Q1_1_Map(2 downto 0) <= "100";
   end case;
end process;



-- Slot 0 decode
U1: QuadMux Port Map (Q1_0_Map(2 downto 0), Q1_0_QuadCountRead, 
							 Exp0QuadCountRead, Exp1QuadCountRead, Exp2QuadCountRead, Exp3QuadCountRead);
U2: QuadMux Port Map (Q1_0_Map(2 downto 0), Q1_0_QuadLEDStatusRead, 
							 Exp0QuadLEDStatusRead, Exp1QuadLEDStatusRead, Exp2QuadLEDStatusRead, Exp3QuadLEDStatusRead);
U3: QuadMux Port Map (Q1_0_Map(2 downto 0), Q1_0_QuadLEDStatusWrite,
							 Exp0QuadLEDStatusWrite, Exp1QuadLEDStatusWrite, Exp2QuadLEDStatusWrite, Exp3QuadLEDStatusWrite);
U4: QuadMux Port Map (Q1_0_Map(2 downto 0), Q1_0_QuadInputRead,
							 Exp0QuadInputRead, Exp1QuadInputRead, Exp2QuadInputRead, Exp3QuadInputRead);
U5: QuadMux Port Map (Q1_0_Map(2 downto 0), Q1_0_QuadHomeRead,
							 Exp0QuadHomeRead, Exp1QuadHomeRead, Exp2QuadHomeRead, Exp3QuadHomeRead);
U6: QuadMux Port Map (Q1_0_Map(2 downto 0), Q1_0_QuadLatch0Read,
							 Exp0QuadLatch0Read, Exp1QuadLatch0Read, Exp2QuadLatch0Read, Exp3QuadLatch0Read);
U7: QuadMux Port Map (Q1_0_Map(2 downto 0), Q1_0_QuadLatch1Read,
							 Exp0QuadLatch1Read, Exp1QuadLatch1Read, Exp2QuadLatch1Read, Exp3QuadLatch1Read);

U8: QuadMux Port Map (Q1_0_Map(2 downto 0), Q1_0_A, Exp0Quad_A, Exp1Quad_A, Exp2Quad_A, Exp3Quad_A);
U9: QuadMux Port Map (Q1_0_Map(2 downto 0), Q1_0_B, Exp0Quad_B, Exp1Quad_B, Exp2Quad_B, Exp3Quad_B);
U10: QuadMux Port Map (Q1_0_Map(2 downto 0), Q1_0_Reg, Exp0Quad_Reg, Exp1Quad_Reg, Exp2Quad_Reg, Exp3Quad_Reg);
U11: QuadMux Port Map (Q1_0_Map(2 downto 0), Q1_0_FaultA, Exp0Quad_FaultA, Exp1Quad_FaultA, Exp2Quad_FaultA, Exp3Quad_FaultA);
U12: QuadMux Port Map (Q1_0_Map(2 downto 0), Q1_0_FaultB, Exp0Quad_FaultB, Exp1Quad_FaultB, Exp2Quad_FaultB, Exp3Quad_FaultB);



-- Slot 1 decode
U13: QuadMux Port Map (Q1_1_Map(2 downto 0), Q1_1_QuadCountRead, 
							 Exp0QuadCountRead, Exp1QuadCountRead, Exp2QuadCountRead, Exp3QuadCountRead);
U14: QuadMux Port Map (Q1_1_Map(2 downto 0), Q1_1_QuadLEDStatusRead, 
							 Exp0QuadLEDStatusRead, Exp1QuadLEDStatusRead, Exp2QuadLEDStatusRead, Exp3QuadLEDStatusRead);
U15: QuadMux Port Map (Q1_1_Map(2 downto 0), Q1_1_QuadLEDStatusWrite,
							 Exp0QuadLEDStatusWrite, Exp1QuadLEDStatusWrite, Exp2QuadLEDStatusWrite, Exp3QuadLEDStatusWrite);
U16: QuadMux Port Map (Q1_1_Map(2 downto 0), Q1_1_QuadInputRead,
							 Exp0QuadInputRead, Exp1QuadInputRead, Exp2QuadInputRead, Exp3QuadInputRead);
U17: QuadMux Port Map (Q1_1_Map(2 downto 0), Q1_1_QuadHomeRead,
							 Exp0QuadHomeRead, Exp1QuadHomeRead, Exp2QuadHomeRead, Exp3QuadHomeRead);
U18: QuadMux Port Map (Q1_1_Map(2 downto 0), Q1_1_QuadLatch0Read,
							 Exp0QuadLatch0Read, Exp1QuadLatch0Read, Exp2QuadLatch0Read, Exp3QuadLatch0Read);
U19: QuadMux Port Map (Q1_1_Map(2 downto 0), Q1_1_QuadLatch1Read,
							 Exp0QuadLatch1Read, Exp1QuadLatch1Read, Exp2QuadLatch1Read, Exp3QuadLatch1Read);

U20: QuadMux Port Map (Q1_1_Map(2 downto 0), Q1_1_A, Exp0Quad_A, Exp1Quad_A, Exp2Quad_A, Exp3Quad_A);
U21: QuadMux Port Map (Q1_1_Map(2 downto 0), Q1_1_B, Exp0Quad_B, Exp1Quad_B, Exp2Quad_B, Exp3Quad_B);
U22: QuadMux Port Map (Q1_1_Map(2 downto 0), Q1_1_Reg, Exp0Quad_Reg, Exp1Quad_Reg, Exp2Quad_Reg, Exp3Quad_Reg);
U23: QuadMux Port Map (Q1_1_Map(2 downto 0), Q1_1_FaultA, Exp0Quad_FaultA, Exp1Quad_FaultA, Exp2Quad_FaultA, Exp3Quad_FaultA);
U24: QuadMux Port Map (Q1_1_Map(2 downto 0), Q1_1_FaultB, Exp0Quad_FaultB, Exp1Quad_FaultB, Exp2Quad_FaultB, Exp3Quad_FaultB);



end Arch;