//(alu_ina,alu_inb,ealuc,aluout)
module alu (a,b,aluc,res);
	input  [31:0] a,b;
	input  [3:0]  aluc;
	
	output [31:0] res;
	
	reg    [31:0] res;
	
	always @ (a or b or aluc) 
		begin                                   
			casex (aluc)
				4'bx000: res = a + b;              //x000 ADD
				4'bx100: res = a - b;              //x100 SUB
				4'bx001: res = a & b;              //x001 AND
				4'bx101: res = a | b;              //x101 OR
				4'bx010: res = a ^ b;              //x010 XOR
				4'bx110: res = b << 16;        //LUI: imm << 16bit             
				4'b0011: res = b << a;             //SLL: rd <- (rt << sa)
				4'b0111: res = b >> a;             //SRL: rd <- (rt >> sa) (logical)
				4'b1111: res = $signed(b) >>> a;   //SRA: rd <- (rt >> sa) (arithmetic)
				default: res = 0;
			endcase        
		end      
endmodule 