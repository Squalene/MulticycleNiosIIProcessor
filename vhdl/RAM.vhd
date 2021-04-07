library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is
	
	--Type for a register (array) 1024 ou 1000 register???
	type ram_type is array(0 to 1023) of std_logic_vector(31 downto 0); 
	signal s_ram: ram_type:=(others=> (others=>'0'));
	
	signal s_triStateCurrent:std_logic:='0';
	signal s_triStateNext:std_logic;
	signal s_addressCurrent:std_logic_vector(9 downto 0):= (others=>'0');
	signal s_addressNext:std_logic_vector(9 downto 0);
	
begin
	
	--Writing process
	writing: process (clk, write, cs) is
	begin
		if (rising_edge(clk) and write='1' and cs='1') then
			s_ram(to_integer(unsigned(address))) <= wrdata;
		end if;
	end process;
	
	
	--Process that allows to have a delay of 1 cycle with the address and the tri-state buffer
	delayDff:process (clk) is
	begin
		if (rising_edge(clk)) then 
			s_addressCurrent<=s_addressNext; 
			s_triStateCurrent<=s_triStateNext;
		end if;		
	end process delayDff;
	
	
	rddata <= s_ram(to_integer(unsigned(s_addressCurrent)))when s_triStateCurrent='1' 
		else (others => 'Z');
	s_triStateNext<= read and cs;
	s_addressNext<=address;
	
end synth;
