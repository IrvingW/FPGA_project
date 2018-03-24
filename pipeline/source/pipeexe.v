module pipeexe ( ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,
                 ern,ealu,
                 alu_in_a,alu_in_b,alu_out);   //EXE stage 
       
	input  [3:0]   ealuc; // alu code
	input  [4:0]   ern0;
	input  [31:0]  ea,eb,eimm,epc4;
	input 		   ealuimm,eshift,ejal; // control signal
	
	// debug
	output [31:0] alu_in_a,alu_in_b,alu_out;
	
	output [4:0]   ern;
	output [31:0]  ealu; // alu_out
	   
	// inner signal   
	wire   [31:0]  epc8,alu_in_a,alu_in_b,alu_out;
	wire   [31:0]  sa;

	assign  epc8 = epc4 + 8'h4;
	assign  sa[31:0] = {27'b0, eimm[10:6]}; // Here we get the right sa in spite of the wrong extension in ID stage
	assign  ern[4:0] = ern0 | {5{ejal}};    // if jal, ern = 5'b11111

	mux2x32 mux_shift  (ea,sa,eshift,alu_in_a);
	mux2x32 mux_aluimm (eb,eimm,ealuimm,alu_in_b);
	alu     alu_unit   (alu_in_a,alu_in_b,ealuc,alu_out);
	mux2x32 mux_jal    (alu_out,epc8,ejal,ealu);		// if jal, alu_out is epc8
    
endmodule
