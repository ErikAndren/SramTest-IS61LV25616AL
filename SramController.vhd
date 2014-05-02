library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Types.all;

entity SramController is
  generic (
    AddrW : positive := 18;
    DataW : positive := 16
    );
  port (
    Clk     : in    bit1;
    RstN    : in    bit1;
    AddrIn  : in    word(AddrW-1 downto 0);
    WrData  : in    word(DataW-1 downto 0);
    RdData  : out   word(DataW-1 downto 0);
    We      : in    bit1;
    Re      : in    bit1;
    --
    D       : inout word(DataW-1 downto 0);
    AddrOut : out   word(AddrW-1 downto 0);
    CeN     : out   bit1;
    OeN     : out   bit1;
    WeN     : out   bit1;
    UbN     : out   bit1;
    LbN     : out   bit1
    );
end entity;

architecture rtl of SramController is
  -- The Is61LV25616-10 is asynchronous
  -- tWC = Write Cycle Time = 10 ns min
  -- tSA = Address Setup Time = 8 ns min
  -- tSCE = CeN to Write End = 8 ns min
  -- tHA = Address Hold from Write End = 0 ns min
  -- tAW = Address Setup Time to Write End = 8 ns min
  -- tPWE = WeN Pulse Width = 8 ns min 
  -- tPWB = LbN, UbN valid to end of write = 8 ns
  -- tHZWE = WeN low to High-Z output = 5 ns max
  -- tLZWE = WeN high to low-Z output = 3 ns min
  -- tSD =  Data Setup to Write End = 5 ns min
  -- tHD = Data Hold from Write End = 0 ns min
  -- tRC = Read Cycle Time = 10 ns min
  type SramFSM is (IDLE, WR0, WR1, RE0);

  signal SramFSM_N, SramFSM_D : SramFSM;
  signal Addr_N, Addr_D       : word(AddrW-1 downto 0);
  signal Data_N, Data_D       : word(DataW-1 downto 0);

begin
  FSMSyncRst : process (Clk, RstN)
  begin
    if RstN = '0' then
      SramFSM_D <= IDLE;
    elsif rising_edge(Clk) then
      SramFSM_D <= SramFSM_N;
    end if;
  end process;

  FSMSyncNoRst : process (Clk)
  begin
    if rising_edge(Clk) then
      Addr_D <= Addr_N;
      Data_D <= Data_N;
    end if;
  end process;

  FSMASync : process (SramFSM_D, We, Re, Addr_D, Data_D, AddrIn, WrData, D)
  begin
    SramFSM_N <= SramFSM_D;
    Addr_N    <= Addr_D;
    AddrOut   <= Addr_D;
    Data_N    <= Data_D;
    --
    D         <= (others => 'Z');
    WeN       <= '1';

    -- FIXME: Tie these to 0
    UbN <= '1';
    LbN <= '1';

    CeN <= '1';
    OeN <= '1';

    case SramFsm_D is
      when WR0 =>
        SramFSM_N <= IDLE;
        --
        D         <= Data_D;
        CeN       <= '0';
        WeN       <= '0';
        UbN       <= '0';
        LbN       <= '0';
        
      when RE0 =>
        SramFSM_N <= IDLE;
        --
        Data_N    <= D;
        
      when others =>
        if (We = '1') then
          SramFSM_N <= WR0;
          --
          Data_N    <= WrData;
          Addr_N    <= AddrIn;
          AddrOut   <= AddrIn;
          
        elsif Re = '1' then
          SramFSM_N <= RE0;
          --
          CeN       <= '0';
          OeN       <= '0';
          UbN       <= '0';
          LbN       <= '0';
          --
          Addr_N    <= AddrIn;
          AddrOut   <= AddrIn;
          -- FIXME: Potentially change this to sample the line instead
          Data_N    <= (others => '1');
        end if;
    end case;
  end process;
  RdData <= Data_D;
end architecture;


