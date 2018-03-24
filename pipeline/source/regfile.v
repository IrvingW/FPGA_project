//		(inst[25:21],inst[20:16],wdi,wrn,wwreg,clock,resetn,regfile_q1,regfile_q2);
module regfile (rna,rnb,d,wn,we,clk,clrn,qa,qb,dp4,jal);
	input [4:0] rna,rnb,wn;
	input [31:0] d,dp4;
	input we,clk,clrn,jal;

	output [31:0] qa,qb;

	reg [31:0] register [1:31]; // r1 - r31

	assign qa = (rna == 0)? 0 : register[rna]; // read
	assign qb = (rnb == 0)? 0 : register[rnb]; // read

	always @(negedge clk or negedge clrn) 
	begin
	  if (clrn == 0) 
		  begin
			 integer i;
			 for (i=1; i<32; i=i+1) register[i] <= 0;
		  end
	  else if (jal == 1)
			register[31] <= dp4;
	  else if ((wn != 0) && (we == 1))
			register[wn] <= d;
	end
endmodule 