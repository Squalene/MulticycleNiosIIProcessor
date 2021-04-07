library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is
	
	TYPE StateType IS (FETCH1, FETCH2, DECODE, R_OP,R_OP_5BIT_IMM, STORE, BREAK, LOAD1, I_OP, LOAD2, BRANCH, CALL, JMP, I_OP_UNSIGNED);
	signal s_currentState, s_nextState: StateType;
	signal s_opAlu3MSB, s_opAlu3LSB:std_logic_vector(2 downto 0);
	
	constant c_3MSB_add: std_logic_vector(2 downto 0) := "000";
	constant c_3MSB_sub: std_logic_vector(2 downto 0) := "001";
	constant c_3MSB_comparison: std_logic_vector(2 downto 0) := "011";
	constant c_3MSB_logical: std_logic_vector(2 downto 0) := "100";
	constant c_3MSB_shiftRotate: std_logic_vector(2 downto 0) := "110";     
	
	constant c_ldw_op: std_logic_vector(5 downto 0) := "010111"; 	--X"17"
	constant c_stw_op: std_logic_vector(5 downto 0) := "010101"; 	--X"15"
	constant c_R_Type_op: std_logic_vector(5 downto 0) := "111010"; --X"3A"
	constant c_br_op: std_logic_vector(5 downto 0) := "000110"; 	--X"06"
	constant c_ble_op: std_logic_vector(5 downto 0) := "001110"; 	--X"0E"
	constant c_bgt_op: std_logic_vector(5 downto 0) := "010110"; 	--X"16"
	constant c_bne_op: std_logic_vector(5 downto 0) := "011110"; 	--X"1E"
	constant c_beq_op: std_logic_vector(5 downto 0) := "100110"; 	--X"26"
	constant c_bleu_op: std_logic_vector(5 downto 0) := "101110"; 	--X"2E"
	constant c_bgtu_op: std_logic_vector(5 downto 0) := "110110"; 	--X"36"
	constant c_jmpi_op: std_logic_vector(5 downto 0) := "000001"; 	--X"01"
	constant c_call_op: std_logic_vector(5 downto 0) := "000000"; 	--X"00"
	constant c_andi_op: std_logic_vector(5 downto 0) := "001100"; 	--X"0C"
	constant c_ori_op: std_logic_vector(5 downto 0) := "010100"; 	--X"14"
	constant c_xnori_op: std_logic_vector(5 downto 0) := "011100"; 	--X"1C"
	constant c_cmplei_op: std_logic_vector(5 downto 0) := "001000"; --X"08"
	constant c_cmpgti_op: std_logic_vector(5 downto 0) := "010000"; --X"10"
	constant c_cmpnei_op: std_logic_vector(5 downto 0) := "011000"; --X"18"
	constant c_cmpeqi_op: std_logic_vector(5 downto 0) := "100000"; --X"20"
	constant c_cmpleui_op: std_logic_vector(5 downto 0) := "101000";--X"28"
	constant c_cmpgtui_op: std_logic_vector(5 downto 0) := "110000";--X"30"
	constant c_addi_op: std_logic_vector(5 downto 0) := "000100"; 	--X"04"
	
	constant c_break_opx: std_logic_vector(5 downto 0) := "110100"; --X"34"
	constant c_callr_opx: std_logic_vector(5 downto 0) := "011101"; --X"1D"
	constant c_jmp_opx: std_logic_vector(5 downto 0) := "001101"; 	--X"0D"
	constant c_ret_opx: std_logic_vector(5 downto 0) := "000101"; 	--X"05"
	constant c_srl_opx: std_logic_vector(5 downto 0) := "011011"; 	--X"1B"
	constant c_add_opx: std_logic_vector(5 downto 0) := "110001"; 	--X"31"
	constant c_sub_opx: std_logic_vector(5 downto 0) := "111001"; 	--X"39"
	constant c_cmple_opx: std_logic_vector(5 downto 0) := "001000"; --X"08"
	constant c_cmpgt_opx: std_logic_vector(5 downto 0) := "010000"; --X"10"
	constant c_nor_opx: std_logic_vector(5 downto 0) := "000110"; 	--X"06"
	constant c_and_opx: std_logic_vector(5 downto 0) := "001110"; 	--X"0E"
	constant c_or_opx: std_logic_vector(5 downto 0) := "010110"; 	--X"16"
	constant c_xnor_opx: std_logic_vector(5 downto 0) := "011110"; 	--X"1E"
	constant c_sll_opx: std_logic_vector(5 downto 0) := "010011"; 	--X"13"
	constant c_sra_opx: std_logic_vector(5 downto 0) := "111011"; 	--X"3B"
	constant c_slli_opx: std_logic_vector(5 downto 0) := "010010"; 	--X"12"
	constant c_srli_opx: std_logic_vector(5 downto 0) := "011010"; 	--X"1A"
	constant c_srai_opx: std_logic_vector(5 downto 0) := "111010"; 	--X"3A"
	constant c_cmpne_opx: std_logic_vector(5 downto 0) := "011000"; --X"18"
	constant c_cmpeq_opx: std_logic_vector(5 downto 0) := "100000"; --X"20"
	constant c_cmpleu_opx: std_logic_vector(5 downto 0) := "101000";--X"28"
	constant c_cmpgtu_opx: std_logic_vector(5 downto 0) := "110000";--X"30"
	constant c_rol_opx: std_logic_vector(5 downto 0) := "000011"; 	--X"03"
	constant c_ror_opx: std_logic_vector(5 downto 0) := "001011"; 	--X"0B"
	constant c_roli_opx: std_logic_vector(5 downto 0) := "000010"; 	--X"02"


begin
	
	transition : process (s_currentState, op, opx) IS
	begin
		
		--Initialize every output value to '0':
		branch_op  <= '0';
		imm_signed <= '0';
		ir_en 	   <= '0';
		pc_add_imm <= '0';
        pc_en      <= '0';
        pc_sel_a   <= '0';
        pc_sel_imm <= '0';
		rf_wren    <= '0';
		sel_addr   <= '0';
        sel_b      <= '0';
        sel_mem    <= '0';
        sel_pc     <= '0';
        sel_ra     <= '0';
        sel_rC     <= '0';
        read	   <= '0';
        write	   <= '0';
		
		case (s_currentState) IS 
			when FETCH1 => 
				s_nextState <= FETCH2;
				read <= '1';
				
			when FETCH2 => 
				s_nextState <= DECODE;
				pc_en <= '1';
        		ir_en <= '1';	
				
			when DECODE => 
				case(op) IS
					when c_ldw_op => s_nextState <= LOAD1;
					when c_stw_op => s_nextState <= STORE;
					when c_R_Type_op =>
						case (opx) IS
							when c_break_opx => s_nextState <= BREAK;
							when c_callr_opx => s_nextState <= CALL;
							when c_jmp_opx | c_ret_opx => s_nextState <= JMP;
							when c_and_opx | c_srl_opx|c_add_opx|c_sub_opx|c_cmple_opx
								 |c_nor_opx|c_or_opx|c_xnor_opx|c_sll_opx|c_sra_opx 
								 |c_cmpne_opx|c_cmpeq_opx|c_cmpleu_opx|c_cmpgtu_opx
								 |c_cmpgt_opx |c_rol_opx|c_ror_opx=> s_nextState <= R_OP;
							when c_slli_opx|c_srli_opx|c_srai_opx|c_roli_opx => s_nextState<=R_OP_5BIT_IMM;
							when others => --nothing
						end case;
					when c_br_op | c_ble_op | c_bgt_op | c_bne_op | c_beq_op | c_bleu_op | c_bgtu_op => s_nextState <= BRANCH;
					when c_jmpi_op => s_nextState <= JMP;
					when c_call_op => s_nextState <= CALL;
					when c_addi_op|c_cmplei_op|c_cmpgti_op|c_cmpnei_op|c_cmpeqi_op
						=> s_nextState <= I_OP;
					when c_andi_op|c_ori_op|c_xnori_op|c_cmpleui_op|c_cmpgtui_op=> s_nextState<= I_OP_UNSIGNED;
					when others => --nothing
				end case;
			
			when R_OP =>
				s_nextState <= FETCH1;
				sel_b <= '1';
        		sel_rC <= '1';
        		rf_wren <= '1';	
        		
			when R_OP_5BIT_IMM => 
				s_nextState <= FETCH1;
        		sel_rC <= '1';
        		rf_wren <= '1';	
        		
			when STORE  => 
				s_nextState <= FETCH1;
				sel_addr <= '1';
        		write <= '1';
        		imm_signed <= '1';
			
			when BREAK => -- @suppress "Dead state "BREAK": state does not have outgoing transitions"
				s_nextState <= BREAK; 
				
			when LOAD1 => 
				s_nextState <= LOAD2;	
				sel_addr <= '1';
        		read <= '1';
        		imm_signed <= '1';	
        		
        	when LOAD2 => 
        		s_nextState <= FETCH1;
        		sel_mem <= '1';
        		rf_wren <= '1';
        		
        	when I_OP =>
        		s_nextState <= FETCH1;
        		rf_wren <= '1';
        		imm_signed <= '1';
        	
			when I_OP_UNSIGNED =>
				s_nextState <= FETCH1;
        		rf_wren <= '1';
        		
        	--Incremente de 4 dans FETCH 2 et ici on decide si il reincremente ou pas de imm?		
			when BRANCH => 
				s_nextState <= FETCH1;
			
				
				branch_op<='1';
				sel_b<='1';
				pc_add_imm<='1';
				--reste est fait par l'alu
				
				
			when CALL =>
				s_nextState <= FETCH1;
				
				rf_wren<='1';
				pc_en<='1';
				sel_pc<='1';
				sel_ra<='1';
				
				if(op=c_call_op) then pc_sel_imm<='1';
				end if;
				
				if(opx=c_callr_opx) then pc_sel_a<='1';
				end if;

			when JMP => 
				s_nextState <= FETCH1;
				--ret is just jmp RA with Ra=ra(register 31) done with the instruction format
				pc_en  <= '1';
				if(opx=c_jmp_opx or opx=c_ret_opx) then
					pc_sel_a  <= '1';
				end if;
				
				if(op=c_jmpi_op) then 
					pc_sel_imm  <= '1';
				end if;
		
		end case ;
	end process transition;
	
	
	dff : process (clk, reset_n) is
	begin
		if(reset_n = '0') then 
			s_currentState <= FETCH1;
		elsif (rising_edge(clk)) then
			s_currentState <= s_nextState;
		end if;
	end process dff;
	
	opAlu : process (op, opx) is
	begin
		if (op=c_R_Type_op) then -- R-type instruction
			
			s_opAlu3LSB<=opx(5 downto 3);
			
			case (opx) is
				when c_add_opx => --add
					s_opAlu3MSB<=c_3MSB_add;
				when c_sub_opx => --sub
					s_opAlu3MSB<=c_3MSB_sub;
				when c_cmple_opx|c_cmpgt_opx|c_cmpne_opx|c_cmpeq_opx
					 |c_cmpleu_opx|c_cmpgtu_opx => --comparison
					s_opAlu3MSB<=c_3MSB_comparison;
				when c_and_opx|c_nor_opx|c_or_opx|c_xnor_opx => --logical
					s_opAlu3MSB<=c_3MSB_logical;
				when c_sll_opx|c_srl_opx|c_sra_opx|c_slli_opx|c_srli_opx
					 |c_srai_opx|c_rol_opx|c_ror_opx|c_roli_opx=> --shift/rotate
					s_opAlu3MSB<=c_3MSB_shiftRotate;
					
				when others => --Nothing
					
			end case;
				
		else -- I-type instruction
	
			s_opAlu3LSB<=op(5 downto 3);
			
			case (op) is
				when  c_addi_op|c_ldw_op|c_stw_op => --add
					s_opAlu3MSB<=c_3MSB_add;
--				when  => --sub
--					s_opAlu3MSB<=c_3MSB_sub;
				when c_ble_op|c_bgt_op|c_bne_op|c_beq_op|c_bleu_op|c_bgtu_op
					|c_cmplei_op|c_cmpgti_op|c_cmpnei_op|c_cmpeqi_op|c_cmpleui_op
					|c_cmpgtui_op => --comparison
					s_opAlu3MSB<=c_3MSB_comparison;
				when  c_andi_op|c_ori_op|c_xnori_op|c_br_op=> --logical
					s_opAlu3MSB<=c_3MSB_logical;
--				when  => --shift/rotate
--					s_opAlu3MSB<=c_3MSB_shiftRotate;
					
				when others => --Nothing
				
			end case;
		end if;
			
	end process opAlu;
	
	op_alu<=s_opAlu3MSB & s_opAlu3LSB;
	
end synth;
