module pipeif (pcsource,pc,bpc,da,jpc,npc,pc4,ins,rom_clk);   // if state

	input  [31:0] pc,bpc,jpc,da;
	input   [1:0] pcsource;
	input         rom_clk;
	
	output [31:0] npc,pc4,ins; 
	

	wire   [31:0] pc,bpc,jpc,da,npc,pc4,ins;
	wire    [1:0] pcsource;
	wire          rom_clk;

	assign  pc4 = pc + 4'b0100;
	
	// 00->pc+4, 01->branch, 10->jr, 11->jal & j
	mux4x32 mux_next_pc (pc4,bpc,da,jpc,pcsource,npc);
	lpm_rom_inst inst_rom (pc[7:2],rom_clk,ins);

endmodule
	