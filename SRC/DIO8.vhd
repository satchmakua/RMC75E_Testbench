--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	© 2022 Delta Computer Systems, Inc.
--	Author: Dennis Ritola and David Shroyer
--
--  Design:         RMC75E Rev 3.n (Replace Xilinx with Microchip)
--  Board:          RMC75E Rev 3.0
--
--	Entity Name		DIO8
--	File					DIO8.vhd
--
--------------------------------------------------------------------------------
--
--	Description: 
--		
--
--	Revision: 1.2
--
--	File history:
--		Rev 1.2 : 08/26/2022 :	Reset state of outputs on power-up
--		Rev 1.1 : 05/30/2022 :	Updated formatting
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following lines to use the declarations that are
-- provided for instantiating Xilinx primitive components.

-- library UNISIM;
-- use UNISIM.VComponents.all;

entity DIO8 is
	Port (
		RESET				: in std_logic;
		H1_CLKWR			: in std_logic;
		SysClk				: in std_logic;
		SlowEnable			: in std_logic;
		SynchedTick			: in std_logic;
		intDATA				: in std_logic_vector(31 downto 0);
		d8DataOut			: out std_logic_vector(31 downto 0);
		ExpDIO8ConfigRead	: in std_logic_vector(3 downto 0);
		ExpDIO8ConfigWrite	: in std_logic_vector(3 downto 0);
		ExpDIO8DinRead		: in std_logic_vector(3 downto 0);
		Exp0D8_DataIn		: in std_logic;
		Exp0D8_Clk			: out std_logic;
		Exp0D8_DataOut		: out std_logic;
		Exp0D8_OE			: out std_logic;
		Exp0D8_Load			: out std_logic;
		Exp0D8_Latch		: out std_logic;
		Exp1D8_DataIn		: in std_logic;
		Exp1D8_Clk			: out std_logic;
		Exp1D8_DataOut		: out std_logic;
		Exp1D8_OE			: out std_logic;
		Exp1D8_Load			: out std_logic;
		Exp1D8_Latch		: out std_logic;
		Exp2D8_DataIn		: in std_logic;
		Exp2D8_Clk			: out std_logic;
		Exp2D8_DataOut		: out std_logic;
		Exp2D8_OE			: out std_logic;
		Exp2D8_Load			: out std_logic;
		Exp2D8_Latch		: out std_logic;
		Exp3D8_DataIn		: in std_logic;
		Exp3D8_Clk			: out std_logic;
		Exp3D8_DataOut		: out std_logic;
		Exp3D8_OE			: out std_logic;
		Exp3D8_Load			: out std_logic;
		Exp3D8_Latch		: out std_logic
	);
end DIO8;

architecture DIO8_arch of DIO8 is

	-- State Encoding
	type STATE_TYPE is (IdleState, LoadState1, LoadState2, LoadState3, s3_LoadShiftState, s4_ShiftIOState, 
						s5_SRAMWriteState, s6_SRAMReadState, s7_LoadShiftState, s8_ShiftOutState, s9_EndState);

	signal	State				: STATE_TYPE; -- state can be assigned the constants defined above in "State Encoding"
	signal	ExpSlot				: std_logic_vector (1 downto 0);	-- := "00";
	signal	InputShiftRegister,
			OutputShiftRegister	: std_logic_vector (15 downto 0);	-- := X"0000";
	signal	Counter				: std_logic_vector (4 downto 0);	-- := "00000";
	
	signal	SynchedTick_Delay	: std_logic;	-- := '0';
	signal	intExpD8_Clk,
			IntWrite			: std_logic;	-- := '0';  
	signal	ExpD8_DataIn,
			ExpD8_DataOut,
			ExpD8_Load,
			ExpD8_Latch			: std_logic;	-- := '0';
	signal	ExpD8_OE			: std_logic;	-- := '1';
	signal	IntDoutMap			: std_logic_vector(15 downto 0);	-- := X"0000";
	signal	IntDout				: std_logic_vector(31 downto 0);	-- := X"0000_0000";
	signal	D8OutputReg0,
			D8OutputReg1,
			D8OutputReg2,
			D8OutputReg3		: std_logic_vector(31 downto 0);	-- := X"0000_0000";
	signal	D8InputReg0,
			D8InputReg1,
			D8InputReg2,
			D8InputReg3			: std_logic_vector(7 downto 0);		-- := X"00";

begin

	-- As the state machine sequences through the reads/writes from/to the different DIO8 modules
	-- The internal state machine logic must be directed to the four different Expansion Slot locations
	-- the following multiplexer handles redirecting the logic lines

	ExpD8_DataIn <=	Exp0D8_DataIn when ExpSlot(1 downto 0)="00" else
					Exp1D8_DataIn when ExpSlot(1 downto 0)="01" else
					Exp2D8_DataIn when ExpSlot(1 downto 0)="10" else
					Exp3D8_DataIn when ExpSlot(1 downto 0)="11" else '0';

	Exp0D8_Clk		<= intExpD8_Clk   when ExpSlot(1 downto 0)="00" else '0';
	Exp0D8_DataOut	<= ExpD8_DataOut  when ExpSlot(1 downto 0)="00" else '0';
	Exp0D8_OE		<= ExpD8_OE;
	Exp0D8_Load		<= ExpD8_Load     when ExpSlot(1 downto 0)="00" else '0';
	Exp0D8_Latch	<= ExpD8_Latch    when ExpSlot(1 downto 0)="00" else '1';

	Exp1D8_Clk		<= intExpD8_Clk   when ExpSlot(1 downto 0)="01" else '0';
	Exp1D8_DataOut	<= ExpD8_DataOut  when ExpSlot(1 downto 0)="01" else '0';
	Exp1D8_OE		<= ExpD8_OE;
	Exp1D8_Load		<= ExpD8_Load     when ExpSlot(1 downto 0)="01" else '0';
	Exp1D8_Latch	<= ExpD8_Latch    when ExpSlot(1 downto 0)="01" else '1';

	Exp2D8_Clk		<= intExpD8_Clk   when ExpSlot(1 downto 0)="10" else '0';
	Exp2D8_DataOut	<= ExpD8_DataOut  when ExpSlot(1 downto 0)="10" else '0';
	Exp2D8_OE		<= ExpD8_OE;
	Exp2D8_Load		<= ExpD8_Load     when ExpSlot(1 downto 0)="10" else '0';
	Exp2D8_Latch	<= ExpD8_Latch    when ExpSlot(1 downto 0)="10" else '1';

	Exp3D8_Clk		<= intExpD8_Clk   when ExpSlot(1 downto 0)="11" else '0';
	Exp3D8_DataOut	<= ExpD8_DataOut  when ExpSlot(1 downto 0)="11" else '0';
	Exp3D8_OE		<= ExpD8_OE;
	Exp3D8_Load		<= ExpD8_Load     when ExpSlot(1 downto 0)="11" else '0';
	Exp3D8_Latch	<= ExpD8_Latch    when ExpSlot(1 downto 0)="11" else '1';

--	d8DataOut(31 downto 0) <= 	X"0101_01" & D8InputReg0(7 downto 0) when ExpDIO8DinRead(0)='1' else 
--							X"1111_11" & D8InputReg1(7 downto 0) when ExpDIO8DinRead(1)='1' else 
--							X"2222_22" & D8InputReg2(7 downto 0) when ExpDIO8DinRead(2)='1' else 
--							X"3333_33" & D8InputReg3(7 downto 0) when ExpDIO8DinRead(3)='1' else 
--							D8OutputReg0(31 downto 0) when ExpDIO8ConfigRead(0)='1' else
--							D8OutputReg1(31 downto 0) when ExpDIO8ConfigRead(1)='1' else
--							D8OutputReg2(31 downto 0) when ExpDIO8ConfigRead(2)='1' else
--							D8OutputReg3(31 downto 0) when ExpDIO8ConfigRead(3)='1' else

							-- debug only
							-- X"FFFF_4567" when ExpDIO8ConfigRead(3)='1' else
--							X"0000_0000";

	d8DataOut(31 downto 0) <= 	X"0000_00" & D8InputReg0(7 downto 0) when ExpDIO8DinRead(0)='1' else 
								X"0000_00" & D8InputReg1(7 downto 0) when ExpDIO8DinRead(1)='1' else 
								X"0000_00" & D8InputReg2(7 downto 0) when ExpDIO8DinRead(2)='1' else 
								X"0000_00" & D8InputReg3(7 downto 0) when ExpDIO8DinRead(3)='1' else 
								D8OutputReg0(31 downto 0) when ExpDIO8ConfigRead(0)='1' else
								D8OutputReg1(31 downto 0) when ExpDIO8ConfigRead(1)='1' else
								D8OutputReg2(31 downto 0) when ExpDIO8ConfigRead(2)='1' else
								D8OutputReg3(31 downto 0) when ExpDIO8ConfigRead(3)='1' else
								-- debug only
								-- X"FFFF_4567" when ExpDIO8ConfigRead(3)='1' else
								X"0000_0000";

	-- The individual register banks correspond to -D8 module positions in the Expansion slot stackup
	process(RESET, H1_CLKWR)
	begin
		if	RESET then
			D8OutputReg0 <= (others => '0');
			D8OutputReg1 <= (others => '0');
			D8OutputReg2 <= (others => '0');
			D8OutputReg3 <= (others => '0');
		elsif rising_edge(H1_CLKWR) then
			if ExpDIO8ConfigWrite(0)='1' then
				D8OutputReg0(31 downto 0) <= intDATA(31 downto 0);
			end if;
			if ExpDIO8ConfigWrite(1)='1' then
				D8OutputReg1(31 downto 0) <= intDATA(31 downto 0);
			end if;
			if ExpDIO8ConfigWrite(2)='1' then
				D8OutputReg2(31 downto 0) <= intDATA(31 downto 0);
			end if;
			if ExpDIO8ConfigWrite(3)='1' then
				D8OutputReg3(31 downto 0) <= intDATA(31 downto 0);
			end if;
		end if;  
	end process;

	-- The IntDout(31 downto 0) is used by the state machine
	-- The register outputs are mapped to IntDout according to the 
	-- ExpSlot select lines
	process(ExpSlot(1 downto 0), D8OutputReg0(31 downto 0), D8OutputReg1(31 downto 0), D8OutputReg2(31 downto 0), D8OutputReg3(31 downto 0))
	begin
		if ExpSlot(1 downto 0)="00" then
			IntDout(31 downto 0) <= D8OutputReg0(31 downto 0);
		elsif ExpSlot(1 downto 0)="01" then
			IntDout(31 downto 0) <= D8OutputReg1(31 downto 0);
		elsif ExpSlot(1 downto 0)="10" then
			IntDout(31 downto 0) <= D8OutputReg2(31 downto 0);
		elsif ExpSlot(1 downto 0)="11" then
			IntDout(31 downto 0) <= D8OutputReg3(31 downto 0);
		end if;
	end process;

	-- ExpSlot maps the input shift register to a DIO input register and 
	-- the register is written when IntWrite is active. The CPU reads these
	-- registers directly. Note that the uppper 8 bits of the shift register are
	-- used only
	process(SysClk)
	begin
		if rising_edge(SysClk) then
			if ExpSlot(1 downto 0)="00" and IntWrite='1' then
				D8InputReg0(7 downto 0) <= InputShiftRegister(15 downto 8);
			end if;
			if ExpSlot(1 downto 0)="01" and IntWrite='1' then
				D8InputReg1(7 downto 0) <= InputShiftRegister(15 downto 8);
			end if;
			if ExpSlot(1 downto 0)="10" and IntWrite='1' then
				D8InputReg2(7 downto 0) <= InputShiftRegister(15 downto 8);
			end if;
			if ExpSlot(1 downto 0)="11" and IntWrite='1' then
				D8InputReg3(7 downto 0) <= InputShiftRegister(15 downto 8);
			end if;
		end if;  
	end process;

	ExpD8_DataOut <= OutputShiftRegister(15);

	IntDoutMap(15 downto 0) <=	IntDout(19) & IntDout(27) & 
								IntDout(18) & IntDout(26) & 
								IntDout(17) & IntDout(25) & 
								IntDout(16) & IntDout(24) & 
								IntDout(23) & IntDout(31) & 
								IntDout(22) & IntDout(30) & 
								IntDout(21) & IntDout(29) & 
								IntDout(20) & IntDout(28);

	process(SysClk)
	begin
		if rising_edge(SysClk) then
			SynchedTick_Delay <= SynchedTick;
		end if;
	end process;

	-- Slow enable provides a 3.75MHz clock output for the serial comm
	-- State Machine to control the Read/Write sequences to the DIO8 modules
	StateMachine : process(RESET, SysClk)
	begin
		if RESET then
			ExpD8_Load <= '0';
			ExpD8_Latch <= '0';
			ExpD8_OE <= '1';
			State <= IdleState;
			ExpSlot <= "00";
		elsif rising_edge(SysClk) then 
			if SynchedTick then
				State <= IdleState;
			else
				case State is

					when IdleState =>
						if SynchedTick_Delay = '1' then
							State <= LoadState1;
						else
							IntWrite <= '0';
							intExpD8_Clk <= '0';
							ExpD8_Latch <= '1';
							ExpD8_Load <= '0';
							ExpSlot <= "00";
							State <= IdleState;
						end if;

					when LoadState1 => 
						ExpD8_Latch <= '0';
						ExpD8_Load <= '0';
						if SlowEnable = '1' then
							State <= LoadState2;
						else
							State <= LoadState1;
						end if;

					when LoadState2 => 
						ExpD8_Load <= '1';
						if SlowEnable = '1' then
							State <= LoadState3;
						else
							State <= LoadState2;
						end if;

					when LoadState3 => 
						if ExpDIO8ConfigWrite(3)='0' and ExpDIO8ConfigWrite(2)='0' and ExpDIO8ConfigWrite(1)='0' and ExpDIO8ConfigWrite(0)='0' then -- No access by CPU       
							OutputShiftRegister(15 downto 0) <= IntDout(7 downto 0) & IntDout(15 downto 8); -- The Data is latched into the shift register
							State <= S3_LoadShiftState;         -- Stay here if a write is happening from the CPU to the dual-port memory
						else
							State <= LoadState3;
						end if;

					when s3_LoadShiftState => 
						Counter(4 downto 0) <= "00000";     -- Reset the Shift Counter
						State <= s4_ShiftIOState;

					-- This state will shift the Output bits and the Enable bits out and the Input bits in
					when s4_ShiftIOState =>          
						if SlowEnable = '1' then
							if Counter(4 downto 0) = "10000" then
								State <= s5_SRAMWriteState;
							else
							if SlowEnable = '1' then
								intExpD8_Clk <= not intExpD8_Clk;
								if intExpD8_Clk = '0' then    -- Data is clocked in on the rising edge of the clock
									InputShiftRegister(15 downto 0) <= InputShiftRegister(14 downto 0) & ExpD8_DataIn;
								elsif intExpD8_Clk = '1' then    -- Data is clocked out on the falling edge of the clock
									OutputShiftRegister(15 downto 0) <= OutputShiftRegister(14 downto 0) & '0';
									Counter(4 downto 0) <= Counter(4 downto 0) + '1';
								end if;
							end if;
							State <= s4_ShiftIOState;
							end if;  
						end if;

					when s5_SRAMWriteState => 
						if ExpDIO8ConfigWrite(3)='0' and ExpDIO8ConfigWrite(2)='0' and ExpDIO8ConfigWrite(1)='0' and ExpDIO8ConfigWrite(0)='0' then -- Stay here if an access is happening by the CPU from the dual-port memory
							IntWrite <= '1';
							State <= s6_SRAMReadState;
						else
							State <= s5_SRAMWriteState;
						end if;

					when s6_SRAMReadState => 
						ExpD8_Load <= '0';
						IntWrite <= '0';                 -- End DP SRAM Write
						if ExpDIO8ConfigWrite(3)='0' and ExpDIO8ConfigWrite(2)='0' and ExpDIO8ConfigWrite(1)='0' and ExpDIO8ConfigWrite(0)='0' then            
							OutputShiftRegister(15 downto 0) <= IntDoutMap(15 downto 0); -- The SRAM Data is latched into the shift register
							State <= s7_LoadShiftState;
						else
							State <= s6_SRAMReadState;
						end if;

					when s7_LoadShiftState =>                    -- Stay here if a write is happening from the CPU to the dual-port memory
						Counter(4 downto 0) <= "00000";
						State <= s8_ShiftOutState;

					-- This state will shift out the LED information               
					when s8_ShiftOutState => 
						if SlowEnable = '1' then
							if Counter(4 downto 0) = "10000" then
								State <= s9_EndState;
							else
								intExpD8_Clk <= not intExpD8_Clk;
								if intExpD8_Clk = '1' then       -- Data is clocked out on the falling edge of the clock
									OutputShiftRegister(15 downto 0) <= OutputShiftRegister(14 downto 0) & '0';
									Counter(4 downto 0) <= Counter(4 downto 0) + '1';
								end if;
								State <= s8_ShiftOutState;
							end if;  
						end if;

					when s9_EndState => 
						if ExpSlot(1 downto 0) = "11" then
							ExpD8_OE <= '0';                 -- The OE will always be low after the first-pass outputs are written
							ExpD8_Latch <= '1';
							State <= IdleState;              -- default, reset state
						else
							ExpSlot(1 downto 0) <= ExpSlot(1 downto 0) + '1';
							State <= LoadState1;
						end if;

					when others =>
						State <= IdleState;                 -- default, reset state
				end case;
			end if;
		end if;
	end process;

end DIO8_arch;
