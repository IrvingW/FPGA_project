module pipelined_computer (resetn,clock,mem_clock,
						   pc,ins,inst,ealu,malu,walu,
						   hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7,
						   io_input_0,io_input_1,
						   io_read_data,
						   fwda,fwdb,
						   wpcir,if_flush,mmo,wwreg,wdi,wm2reg,mb);
						   
	input       resetn,clock;
	input [5 :0] io_input_0,io_input_1;
	
	wire   [31:0] in_port0,in_port1;
	assign in_port0 = {24'b0, io_input_0};
	assign in_port1 = {24'b0, io_input_1};
	
	output        mem_clock;
	output [31:0] pc,ins,inst,ealu,malu,walu;
	output [31:0] mmo;
	output [31:0] io_read_data;
	output [6:0]  hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7;
	
	output [1:0]  fwda,fwdb;
	output wpcir,if_flush;

	assign mem_clock = ~clock;

	wire   [31:0] bpc,jpc,npc,pc4,ins,dpc4,inst,da,db,dimm,ea,eb,eimm; //if stage
	wire   [31:0] epc4,mb,mmo,wmo,wdi;
	wire   [4:0]  drn,ern0,ern,mrn,wrn;
	wire   [3:0]  daluc,ealuc;
	wire   [1:0]  pcsource;
	wire          wpcir; // CU output signal: control whether write pc and IF/ID_reg
	wire          dwreg,dm2reg,dwmem,daluimm,dshift,djal; // id stage
	wire          ewreg,em2reg,ewmem,ealuimm,eshift,ejal; // exe stage
	wire          mwreg,mm2reg,mwmem;                     // mem stage
	wire          wwreg,wm2reg;                           // wb stage

	pipepc prog_cnt   (npc,wpcir,clock,resetn,pc);
	//程序计数器模块，是最前面一级IF流水段的输入。

	pipeif if_stage   (pcsource,pc,bpc,da,jpc,npc,pc4,ins,mem_clock);
	//IF取指令模块，注意其中包含的指令同步ROM存储器的同步信号，
	//即输入给该模块的mem_clock信号，模块内定义为rom_clk。// 注意 mem_clock。
	//实验中可采用系统clock的反相信号作为mem_clock（亦即rom_clock）,
	//即留给信号半个节拍的传输时间。
	
	pipeir inst_reg   (pc4,ins,wpcir,clock,resetn,dpc4,inst,if_flush);
	//IF/ID流水线寄存器模块，起承接IF阶段和ID阶段的流水任务。
	//在clock上升沿时，将IF阶段需传递给ID阶段的信息，锁存在IF/ID流水线寄存器
	//中，并呈现在ID阶段。

	pipeid id_stage   (mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,
				   wrn,wdi,ealu,malu,mmo,wwreg,clock,resetn,
				   bpc,jpc,pcsource,wpcir,dwreg,dm2reg,dwmem,daluc,
				   daluimm,da,db,dimm,drn,dshift,djal,fwda,fwdb,if_flush);        
	//ID指令译码模块。注意其中包含控制器CU、寄存器堆、及多个多路器等。
	//其中的寄存器堆，会在系统clock的下沿进行寄存器写入，也就是给信号从WB阶段
	//传输过来留有半个clock的延迟时间，亦即确保信号稳定。
	//该阶段CU产生的、要传播到流水线后级的信号较多。
				   
	pipedereg de_reg  (dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,drn,
				   dshift,djal,dpc4,clock,resetn,ewreg,em2reg,ewmem,
				   ealuc,ealuimm,ea,eb,eimm,ern0,eshift,ejal,epc4,wpcir,if_flush); 
	//ID/EXE流水线寄存器模块，起承接ID阶段和EXE阶段的流水任务。
	//在clock上升沿时，将ID阶段需传递给EXE阶段的信息，锁存在ID/EXE流水线
	//寄存器中，并呈现在EXE阶段。
				   
	pipeexe exe_stage ( ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu,alu_in_a,alu_in_b,alu_out); 
	//EXE运算模块。其中包含ALU及多个多路器等。
				   
	pipeemreg em_reg  (ewreg,em2reg,ewmem,ealu,eb,ern,clock,resetn,mwreg,mm2reg,mwmem,malu,mb,mrn);
	//EXE/MEM流水线寄存器模块，起承接EXE阶段和MEM阶段的流水任务。
	//在clock上升沿时，将EXE阶段需传递给MEM阶段的信息，锁存在EXE/MEM
	//流水线寄存器中，并呈现在MEM阶段。
				   
	pipemem mem_stage (mwmem,malu,mb,mem_clock,mmo,resetn,in_port0,in_port1,
					hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7,mem_dataout,io_read_data);
	//MEM数据存取模块。其中包含对数据同步RAM的读写访问。// 注意 mem_clock。
	//输入给该同步RAM的mem_clock信号，模块内定义为ram_clk。
	//实验中可采用系统clock的反相信号作为mem_clock信号（亦即ram_clk）,
	//即留给信号半个节拍的传输时间，然后在mem_clock上沿时，读输出、或写输入。

	pipemwreg mw_reg  (mwreg,mm2reg,mmo,malu,mrn,clock,resetn,wwreg,wm2reg,wmo,walu,wrn);
	//MEM/WB流水线寄存器模块，起承接MEM阶段和WB阶段的流水任务。
	//在clock上升沿时，将MEM阶段需传递给WB阶段的信息，锁存在MEM/WB
	//流水线寄存器中，并呈现在WB阶段。                 
				   
				   
	mux2x32 wb_stage  (walu,wmo,wm2reg,wdi);
	output [31:0] wdi,mb;
	output wwreg,wm2reg;

	//WB写回阶段模块。事实上，从设计原理图上可以看出，该阶段的逻辑功能部件只
	//包含一个多路器，所以可以仅用一个多路器的实例即可实现该部分。
	//当然，如果专门写一个完整的模块也是很好的。

endmodule

 