library ieee;
use ieee.std_logic_1164.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is
	
	signal s_triStateCurrent:std_logic:='0';
	signal s_triStateNext:std_logic;
	signal s_addressCurrent:std_logic_vector(9 downto 0):= (others=>'0');
	signal s_addressNext:std_logic_vector(9 downto 0);
	signal s_readMemBlock:std_logic_vector (31 downto 0);
	
	
	component ROM_Block is
	port
	(
		address	: in STD_LOGIC_VECTOR (9 downto 0);
		clock: in STD_LOGIC;
		q: out STD_LOGIC_VECTOR (31 downto 0)
	);
	end component ROM_Block;

	
begin
	
	addressDff:process (clk) is
	begin
		if (rising_edge(clk)) then s_addressCurrent<=s_addressNext; 
		end if;
		
	end process addressDff;
	
	triStateDff:process (clk) is
	begin
		if (rising_edge(clk)) then s_triStateCurrent<=s_triStateNext; 
		end if;
		
	end process triStateDff;
	
	rddata <= s_readMemBlock when s_triStateCurrent='1' else (others => 'Z');
	
	s_triStateNext<= read and cs;
	s_addressNext<=address;
	
	
	
	ROMBlock : ROM_Block
	port map (address => s_addressCurrent,
			 clock => clk,
			 q => s_readMemBlock);
	
end synth;
