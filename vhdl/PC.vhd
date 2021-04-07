library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
	
	signal s_addressCur: std_logic_vector(15 downto 0);
	
begin
	
	addressDff:process (clk,reset_n) is
	begin
		if (reset_n='0') then 
			s_addressCur<=(others=>'0');
		elsif (rising_edge(clk)) then 
			if(en='1') then
				if(add_imm='1') then s_addressCur<=std_logic_vector(unsigned(s_addressCur) + unsigned(imm));
				elsif(sel_imm='1') then s_addressCur<= imm(13 downto 0) & "00";
				elsif (sel_a='1') then s_addressCur<= a;
				else  s_addressCur<=std_logic_vector(unsigned(s_addressCur) + 4);
				end if;
			end if;
		end if;
	end process addressDff;
	
	addr<=X"0000" & s_addressCur(15 downto 2) & "00";
end synth;
