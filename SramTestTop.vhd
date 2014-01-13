library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;
use work.BcdPack.all;

entity SramTestTop is
	generic (
	Displays : positive := 8
	);
	port (
	Clk      : in bit1;
	--
	Segments : out word(BcdSegs-1 downto 0);
	Display  : out word(Displays-1 downto 0)
	--
	);
end entity;

architecture rtl of SramTestTop is
	constant Freq : positive := 50000000;
	--
	signal Data : word(bits(10**Displays)-1 downto 0);
begin
	Data <= conv_word(12345678, Data'length);

	BCDDisplay : entity work.BcdDisp
	generic map (
		Freq => Freq,
		Displays => Displays
	)
	port map (
		Clk	=> Clk,
		--
		Data => Data,
		--
		Segments => Segments,
		Display  => Display
	);
	
	
	
end architecture rtl;