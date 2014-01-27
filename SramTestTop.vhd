library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;
use work.BcdPack.all;

entity SramTestTop is
	generic (
		Displays : positive := 8;
		AddrW : positive := 18;
		DataW : positive := 16
	);
	port (
	Clk      : in bit1;
	RstN     : in bit1;
	--
	Button0  : in bit1;
	Button1  : in bit1;
	--
	Segments : out word(BcdSegs-1 downto 0);
	Display  : out word(Displays-1 downto 0);
	--
	D       : inout word(DataW-1 downto 0);
	AddrOut : out word(AddrW-1 downto 0);
	CeN     : out bit1;
	OeN     : out bit1;
	WeN     : out bit1;
	UbN     : out bit1;
	LbN     : out bit1;
	--
	flash_oe : out bit1;
	flash_wr : out bit1;
	flash_rd : out bit1
	);
end entity;

architecture rtl of SramTestTop is
	constant Freq : positive := 50000000;
	--	
	signal SramAddr : word(AddrW-1 downto 0);
	signal SramWrData : word(DataW-1 downto 0);
	signal SramRdData : word(DataW-1 downto 0);
	signal SramWe : bit1;
	signal SramRe : bit1;

	signal Data : word(bits(10**Displays)-1 downto 0);
begin
	flash_oe <= '1';
	flash_wr <= '1';
	flash_rd <= '1';

	BCDDisplay : entity work.BcdDisp
	generic map (
		Freq => Freq,
		Displays => Displays
	)
	port map (
		Clk	=> Clk,
		RstN  => RstN,
		--
		Data => Data,
		--
		Segments => Segments,
		Display  => Display
	);
	Data <= xt0(SramRdData, Data'length);
	--Data <= xt0(SramAddr, Data'length);
	
	SramCont : entity work.SramController
	port map (
		Clk  => Clk,
		RstN => RstN,
		--
		AddrIn => SramAddr,
		WrData => SramWrData,
		RdData => SramRdData,
		We     => SramWe,
		Re     => SramRe,
		--
		D       => D,
		AddrOut => AddrOut,
		CeN     => CeN,
		OeN     => OeN,
		WeN     => WeN,
		UbN     => UbN,
		LbN     => LbN
	);
	
	SramTest : entity work.SramControllerTestGen
	port map (
		Clk  => Clk,
		RstN => RstN,
		--
		Button0 => Button0,
		Button1 => Button1,
		--
		Addr => SramAddr,
		Data => SramWrData,
		We   => SramWe, 
		Re   => SramRe
	);
	
end architecture rtl;