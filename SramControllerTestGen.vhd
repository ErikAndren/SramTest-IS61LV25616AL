library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;

entity SramControllerTestGen is
	generic (
		AddrW : positive := 18;
		DataW : positive := 16
	);
	port (
	Clk : in bit1;
	RstN : in bit1;
	--
	Button0 : in bit1;
	Button1 : in bit1;
	--
	Addr : out word(AddrW-1 downto 0);
	Data : out word(DataW-1 downto 0);
	We   : out bit1;
	Re   : out bit1
	);
end entity;

architecture rtl of SramControllerTestGen is
	signal WriteCnt_N, WriteCnt_D : word(4-1 downto 0);
	signal Btn0State_N, Btn0State_D : bit1;
	signal Btn1State_N, Btn1State_D : bit1;
	signal Addr_N, Addr_D : word(AddrW-1 downto 0);
begin
	SyncProcRst : process (Clk, RstN)
	begin
		if RstN = '0' then
			WriteCnt_D <= (others => '0');
			Btn0State_D <= '1';
			Btn1State_D <= '1';
			Addr_D <= (others => '0');
		elsif rising_edge(Clk) then
			WriteCnt_D <= WriteCnt_N;
			Btn0State_D <= Btn0State_N;
			Btn1State_D <= Btn1State_N;
			Addr_D <= Addr_N;
		end if;
	end process;
	
	AsyncProc : process (WriteCnt_D, Btn0State_D, Btn1State_D, Addr_D, Button0, Button1)
	begin
		WriteCnt_N <= WriteCnt_D;
		We <= '0';
		Re <= '0';
		Data <= (others => '0');
		Btn0State_N <= Btn0State_D;
		Btn1State_N <= Btn1State_D;
		Addr_N <= Addr_D;
	
		-- Initial writes 
		if WriteCnt_D < 15 and WriteCnt_D(1) = '1' then
			WriteCnt_N <= WriteCnt_D + 1;
			Addr_N <= xt0(WriteCnt_D + 1, Addr_N'length);
			We <= '1';
			Data <= xt0(WriteCnt_D, Data'length);
		elsif Button0 = '0' and Btn0State_D = '1' then
			Addr_N <= Addr_D - 1;
			Re <= '1';
		elsif Button1 = '0' and Btn1State_D = '1' then
			Addr_N <= Addr_D + 1;
			Re <= '1';
		end if;
	end process;
	Addr <= Addr_D;

end architecture;