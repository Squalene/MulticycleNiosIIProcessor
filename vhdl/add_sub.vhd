library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

--use the sub_mode signal for two's complement

architecture synth of add_sub is
	constant c_32BitsZero: std_logic_vector(31 downto 0) := X"00000000";
	
	signal s_BXorSub :std_logic_vector(31 downto 0);
	signal s_subModeVector:std_logic_vector(31 downto 0);
	signal s_tempSum:std_logic_vector(32 downto 0);
	signal s_rTemp: std_logic_vector(31 downto 0);
	
begin
	s_subModeVector<= (others=>sub_mode);
	
	s_BXorSub<=b xor s_subModeVector;
	
	
	s_tempSum<= std_logic_vector(unsigned('0' & a) +  unsigned('0' & s_BXorSub) + unsigned(c_32BitsZero & sub_mode));
	
	--pour recuperer le carry
	s_rTemp<=s_tempSum(31 downto 0);
	
	
	zero<='1' when s_rTemp = X"00000000" else '0';
		  
	r <= s_rTemp;
	
	carry <=s_tempSum(32);
	
	
end synth;
