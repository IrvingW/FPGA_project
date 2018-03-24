// Control Unit
module pipe_cu  (op,func,rs,rt,rsrtequ,
                 dwreg,dm2reg,dwmem,daluc,daluimm,dshift,djal,regrt,sext,fwda,fwdb,
                 mrn,mm2reg,mwreg,ern,em2reg,ewreg,
                 pcsource,wpcir,clock,if_flush,i_jal);

	input  [5:0]  op,func;
	input  [4:0]  rs,rt,mrn,ern;     
	input		  mm2reg,mwreg,em2reg,ewreg,rsrtequ,clock;     

	output        dwreg,regrt,djal,dm2reg,dshift,daluimm,sext,dwmem,wpcir,if_flush,i_jal;
	output [3:0]  daluc;
	output [1:0]  pcsource,fwda,fwdb;	  

	// forwarding
	reg    [1:0]  fwda,fwdb;
	
	wire r_type = ~|op;
	// rd <- rs ? rt
	wire i_add  = r_type &  func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & ~func[0];          //100000
	wire i_sub  = r_type &  func[5] & ~func[4] & ~func[3] & ~func[2] &  func[1] & ~func[0];          //100010
	wire i_and  = r_type &  func[5] & ~func[4] & ~func[3] &  func[2] & ~func[1] & ~func[0];          //100100
	wire i_or   = r_type &  func[5] & ~func[4] & ~func[3] &  func[2] & ~func[1] &  func[0];          //100101
	wire i_xor  = r_type &  func[5] & ~func[4] & ~func[3] &  func[2] &  func[1] & ~func[0];          //100110
	//  rd <- rt ? sa
	wire i_sll  = r_type & ~func[5] & ~func[4] & ~func[3] & ~func[2] & ~func[1] & ~func[0];          //000000
	wire i_srl  = r_type & ~func[5] & ~func[4] & ~func[3] & ~func[2] &  func[1] & ~func[0];          //000010
	wire i_sra  = r_type & ~func[5] & ~func[4] & ~func[3] & ~func[2] &  func[1] &  func[0];          //000011
	// pc <- rs
	wire i_jr   = r_type & ~func[5] & ~func[4] &  func[3] & ~func[2] & ~func[1] & ~func[0];          //001000				
	// rt <- rs ? (sign)imm
	wire i_addi = ~op[5] & ~op[4] &  op[3] & ~op[2] & ~op[1] & ~op[0]; //001000
	wire i_andi = ~op[5] & ~op[4] &  op[3] &  op[2] & ~op[1] & ~op[0]; //001100
	wire i_ori  = ~op[5] & ~op[4] &  op[3] &  op[2] & ~op[1] &  op[0]; //001101
	wire i_xori = ~op[5] & ~op[4] &  op[3] &  op[2] &  op[1] & ~op[0]; //001110
	// rt ? mem[rs + (sign)imm]
	wire i_lw   =  op[5] & ~op[4] & ~op[3] & ~op[2] &  op[1] &  op[0]; //100011
	wire i_sw   =  op[5] & ~op[4] &  op[3] & ~op[2] &  op[1] &  op[0]; //101011
	// rs, rt, imm
	wire i_beq  = ~op[5] & ~op[4] & ~op[3] &  op[2] & ~op[1] & ~op[0]; //000100
	wire i_bne  = ~op[5] & ~op[4] & ~op[3] &  op[2] & ~op[1] &  op[0]; //000101
	// rt, imm
	wire i_lui  = ~op[5] & ~op[4] &  op[3] &  op[2] &  op[1] &  op[0]; //001111
	// imm
	wire i_j    = ~op[5] & ~op[4] & ~op[3] & ~op[2] &  op[1] & ~op[0]; //000010
	wire i_jal  = ~op[5] & ~op[4] & ~op[3] & ~op[2] &  op[1] &  op[0]; //000011
	
	// intructions that contain rs and rt
	wire i_rs   = i_add | i_sub | i_and | i_or | i_xor | i_jr | i_addi | i_andi | i_ori | i_xori | i_lw | i_sw | i_beq | i_bne;
	wire i_rt   = i_add | i_sub | i_and | i_or | i_xor | i_sll | i_srl | i_sra | i_lui | i_lw | i_sw | i_beq | i_bne;
	
	// 00:pc+4, 01:branch, 10: jr, 11: j & jal 
	assign pcsource[1] = i_jr | i_j | i_jal;
	assign pcsource[0] = (i_beq & rsrtequ ) | (i_bne & ~rsrtequ) | i_j | i_jal ;
	
	// alu code   
	assign daluc[3] = i_sra ;
	assign daluc[2] = i_sub | i_or  | i_srl | i_sra | i_ori ;
	assign daluc[1] = i_xor | i_sll | i_srl | i_sra | i_xori;
	assign daluc[0] = i_and | i_or  | i_sll | i_srl | i_sra | i_andi | i_ori ;
	   
	// control signal
	assign dshift   = i_sll | i_srl | i_sra ;  
	assign daluimm  = i_addi | i_andi | i_ori | i_xori | i_lw | i_sw | i_lui ;    
	assign sext     = i_addi | i_lw | i_sw | i_beq | i_bne ;
	assign dm2reg   = i_lw ;
	assign regrt    = i_addi |i_andi | i_ori | i_xori | i_lw | i_lui ;
	assign djal     = i_jal;
	
	// block signal
	// when stall condition is satisfied, wpcir = 0
	assign wpcir  =  ~(ewreg & em2reg & (ern != 0) & ((i_rs & (ern == rs)) | (i_rt & (ern == rt))));
	// control branch and jump
	assign if_flush = (i_beq & rsrtequ ) | (i_bne & ~rsrtequ) | i_j | i_jr | i_jal;
	assign dwreg  = (i_add | i_sub | i_and | i_or | i_xor | i_sll | i_srl | i_sra | i_addi | i_andi | i_ori | i_xori | i_lw | i_lui | i_jal) & wpcir; 
	assign dwmem  = i_sw & wpcir;

	// !!! 1st half->write; 2nd half->read. 
	//We give pipeline half a cycle to let all the signal transfered totally.
	always @ ( negedge clock )   
		begin 
			//forwar A
			fwda = 2'b00; // default forward a: no hazards
			if (ewreg & (ern != 0) & (ern == rs) & ~em2reg) 
				fwda = 2'b01; // exe_alu
			else if (mwreg & (mrn != 0) & (mrn == rs) & ~mm2reg)
				fwda = 2'b10; // mem_alu
			else if (mwreg & (mrn != 0) & (mrn == rs) & mm2reg)
				fwda = 2'b11; // mem_lw
			//forwar B
			fwdb = 2'b00; // default forward b: no hazards
			if (ewreg & (ern != 0) & (ern == rt) & ~em2reg)
				fwdb = 2'b01; // exe_alu
			else if (mwreg & (mrn != 0) & (mrn == rt) & ~mm2reg)
				fwdb = 2'b10; // mem_alu
			else if (mwreg & (mrn != 0) & (mrn == rt) & mm2reg)
				fwdb = 2'b11; // mem_lw
		end

endmodule

   