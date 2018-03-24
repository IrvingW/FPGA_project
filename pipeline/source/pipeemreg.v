//EXE/MEM register
module pipeemreg(ewreg,em2reg,ewmem,ealu,eb,ern,clock,resetn,mwreg,mm2reg,mwmem,malu,mb,mrn);  
	
	input 		 ewreg,em2reg,ewmem,clock,resetn;
	input [31:0] ealu,eb;
	input [4:0]  ern;

	output [31:0] malu,mb;
	output [4:0]  mrn;
	output        mwreg,mm2reg,mwmem;

	reg [31:0] malu,mb;
	reg [4:0]  mrn;
	reg 	   mwreg,mm2reg,mwmem;

	always @ (negedge resetn or posedge clock)
		if(resetn == 0) 
			begin
				mwreg    <=  1'b0;
				mm2reg   <=  1'b0;
				mwmem    <=  1'b0;
				malu     <=  32'b0;
				mb       <=  32'b0;
				mrn      <=  5'b0;
			end
		else
			begin 
				mwreg    <=  ewreg;
				mm2reg   <=  em2reg;
				mwmem    <=  ewmem;
				malu     <=  ealu;
				mb       <=  eb;
				mrn      <=  ern;
			end

endmodule
