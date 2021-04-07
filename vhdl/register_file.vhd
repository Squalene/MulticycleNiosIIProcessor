library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity register_file is
    port(
        clk    : in  std_logic;
        aa     : in  std_logic_vector(4 downto 0);--adress of word a to read
        ab     : in  std_logic_vector(4 downto 0);--adress of word b to read  
        aw     : in  std_logic_vector(4 downto 0);--adress where to write
        wren   : in  std_logic;-- authorization to write
        wrdata : in  std_logic_vector(31 downto 0);-- data to write
        a      : out std_logic_vector(31 downto 0);-- reading output a
        b      : out std_logic_vector(31 downto 0)-- reading output b
    );
end register_file;

architecture synth of register_file is
	type reg_type is array(0 to 31) of std_logic_vector(31 downto 0); 
	signal s_regCurrent: reg_type:=(others=> (others=>'0'));
	
begin

	-- modifies state register like a dff
	reg: process (clk, wren) is
	begin
		if (rising_edge(clk) and wren='1' )then 
		
			s_regCurrent(to_integer(unsigned(aw))) <= wrdata;			
			s_regCurrent(0) <= (others=>'0');
			
		end if;
	end process reg;
		 
	--read data asynchronous
	a<=s_regCurrent(to_integer(unsigned(aa)));
	b<=s_regCurrent(to_integer(unsigned(ab)));
	
end synth;
