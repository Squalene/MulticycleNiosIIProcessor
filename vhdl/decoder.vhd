library ieee;
use ieee.std_logic_1164.all;

entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic;
        cs_buttons : out std_logic
        
    );
end decoder;

architecture synth of decoder is
	
	constant c_ROMLowerBound:std_logic_vector(15 downto 0):=X"0000";
	constant c_ROMUpperBound:std_logic_vector(15 downto 0):=X"0FFC";
	constant c_LEDLowerBound:std_logic_vector(15 downto 0):=X"2000";
	constant c_LEDUpperBound:std_logic_vector(15 downto 0):=X"200C";
	constant c_RAMLowerBound:std_logic_vector(15 downto 0):=X"1000";
	constant c_RAMUpperBound:std_logic_vector(15 downto 0):=X"1FFC";
	constant c_ButtonLowerBound:std_logic_vector(15 downto 0):=X"2030";
	constant c_ButtonUpperBound:std_logic_vector(15 downto 0):=X"2034";
	
begin
	
	decode:process(address)
	begin 
		
		cs_LEDS<='0';
		cs_RAM<='0';
		cs_ROM<='0';
		cs_buttons <='0';
		
		if ((address >= c_ButtonLowerBound and address <= c_ButtonUpperBound)) then 
			
			cs_buttons <='1';	
		
			
		elsif (address >= c_ROMLowerBound and address <= c_ROMUpperBound) then
			
			cs_ROM<='1';
			
		elsif (address >= c_RAMLowerBound and address <= c_RAMUpperBound) then 
			
			cs_RAM<='1';
			
		elsif (address >= c_LEDLowerBound and address <= c_LEDUpperBound) then 
			
			cs_LEDS<='1';
		
		else 
		
		end if;
			
	end process decode;
	
end synth;
