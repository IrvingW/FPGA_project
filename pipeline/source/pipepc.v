module pipepc (npc,wpcir,clock,resetn,pc);

	input  [31:0] npc;
	input         clock,resetn,wpcir;      
	output [31:0] pc;
	
	reg    [31:0] pc;

	always @ (negedge resetn or posedge clock)
	if (resetn == 0) 
		pc[31:0] <= 32'b0;
	else if (wpcir == 1) 
		pc[31:0] <= npc[31:0];

	  
endmodule 	
	