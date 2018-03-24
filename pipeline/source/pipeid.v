// ID state
module pipeid ( mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,
                wrn,wdi,ealu,malu,mmo,wwreg,clock,resetn,
                bpc,jpc,pcsource,wpcir,dwreg,dm2reg,dwmem,daluc,
                daluimm,da,db,dimm,drn,dshift,djal,
                fwda,fwdb,if_flush);

	input         mwreg,ewreg,em2reg,mm2reg;
	input         wwreg,clock,resetn;
	input  [31:0] dpc4,inst,wdi,ealu,malu,mmo;
	input  [4:0]  wrn,mrn,ern;
	
	
	//debug
	output [1:0]  fwda,fwdb;
	
	output [31:0] bpc,jpc,da,db;
	output [1:0]  pcsource; // control signal
	output [3:0]  daluc;
	output [4:0]  drn;
	output        wpcir,dwreg,dm2reg,dwmem,daluimm,dshift,djal;
	output [31:0] dimm;   // including imm and sa
	output 		  if_flush;

	// inner signal
	wire   [1:0]  fwda,fwdb;
	wire          regrt,sext,rsrtequ; // regrt=1->rt, regrt=0->rd; to choose target register into which data is written
	wire   [31:0] regfile_q1,regfile_q2;        
	wire   [13:0] bpc_sign_ext = {14 {inst[15]}};  // sign extension
	wire          e = sext & inst[15];             // sign extension or zero extension
	wire   [15:0] imm_ext = {16{e}};               // sa and imm
	wire          jal;
	// !!! Although we use the same extension regar regardless of sa or imm, we can still get right sa in the exe stage.
	wire   [31:0] dimm = {imm_ext,inst[15:0]};
	
	assign bpc = {bpc_sign_ext,inst[15:0],2'b00} + dpc4; // branch address  
	assign jpc = {dpc4[31:28],inst[25:0],2'b00 }; // jump address
	assign rsrtequ = (da==db); // zero

	regfile rf (inst[25:21],inst[20:16],wdi,wrn,wwreg,clock,resetn,regfile_q1,regfile_q2,dp4,jal);

	// forwarding
	mux4x32 mux_sel_da (regfile_q1,ealu,malu,mmo,fwda,da);    
	mux4x32 mux_sel_db (regfile_q2,ealu,malu,mmo,fwdb,db);    
	// 						     0->rd        1->rt
	mux2x5  mux_sel_regrt_rn (inst[15:11],inst[20:16],regrt,drn);  

	//			op			func	  rs		  rt
	pipe_cu cu (inst[31:26],inst[5:0],inst[25:21],inst[20:16],rsrtequ,
		   dwreg,dm2reg,dwmem,daluc,daluimm,dshift,djal,regrt,sext,fwda,fwdb,
		   mrn,mm2reg,mwreg,ern,em2reg,ewreg,pcsource,wpcir,clock,if_flush,jal);


endmodule
