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
	//���������ģ�飬����ǰ��һ��IF��ˮ�ε����롣

	pipeif if_stage   (pcsource,pc,bpc,da,jpc,npc,pc4,ins,mem_clock);
	//IFȡָ��ģ�飬ע�����а�����ָ��ͬ��ROM�洢����ͬ���źţ�
	//���������ģ���mem_clock�źţ�ģ���ڶ���Ϊrom_clk��// ע�� mem_clock��
	//ʵ���пɲ���ϵͳclock�ķ����ź���Ϊmem_clock���༴rom_clock��,
	//�������źŰ�����ĵĴ���ʱ�䡣
	
	pipeir inst_reg   (pc4,ins,wpcir,clock,resetn,dpc4,inst,if_flush);
	//IF/ID��ˮ�߼Ĵ���ģ�飬��н�IF�׶κ�ID�׶ε���ˮ����
	//��clock������ʱ����IF�׶��贫�ݸ�ID�׶ε���Ϣ��������IF/ID��ˮ�߼Ĵ���
	//�У���������ID�׶Ρ�

	pipeid id_stage   (mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,
				   wrn,wdi,ealu,malu,mmo,wwreg,clock,resetn,
				   bpc,jpc,pcsource,wpcir,dwreg,dm2reg,dwmem,daluc,
				   daluimm,da,db,dimm,drn,dshift,djal,fwda,fwdb,if_flush);        
	//IDָ������ģ�顣ע�����а���������CU���Ĵ����ѡ��������·���ȡ�
	//���еļĴ����ѣ�����ϵͳclock�����ؽ��мĴ���д�룬Ҳ���Ǹ��źŴ�WB�׶�
	//����������а��clock���ӳ�ʱ�䣬�༴ȷ���ź��ȶ���
	//�ý׶�CU�����ġ�Ҫ��������ˮ�ߺ󼶵��źŽ϶ࡣ
				   
	pipedereg de_reg  (dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,drn,
				   dshift,djal,dpc4,clock,resetn,ewreg,em2reg,ewmem,
				   ealuc,ealuimm,ea,eb,eimm,ern0,eshift,ejal,epc4,wpcir,if_flush); 
	//ID/EXE��ˮ�߼Ĵ���ģ�飬��н�ID�׶κ�EXE�׶ε���ˮ����
	//��clock������ʱ����ID�׶��贫�ݸ�EXE�׶ε���Ϣ��������ID/EXE��ˮ��
	//�Ĵ����У���������EXE�׶Ρ�
				   
	pipeexe exe_stage ( ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu,alu_in_a,alu_in_b,alu_out); 
	//EXE����ģ�顣���а���ALU�������·���ȡ�
				   
	pipeemreg em_reg  (ewreg,em2reg,ewmem,ealu,eb,ern,clock,resetn,mwreg,mm2reg,mwmem,malu,mb,mrn);
	//EXE/MEM��ˮ�߼Ĵ���ģ�飬��н�EXE�׶κ�MEM�׶ε���ˮ����
	//��clock������ʱ����EXE�׶��贫�ݸ�MEM�׶ε���Ϣ��������EXE/MEM
	//��ˮ�߼Ĵ����У���������MEM�׶Ρ�
				   
	pipemem mem_stage (mwmem,malu,mb,mem_clock,mmo,resetn,in_port0,in_port1,
					hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7,mem_dataout,io_read_data);
	//MEM���ݴ�ȡģ�顣���а���������ͬ��RAM�Ķ�д���ʡ�// ע�� mem_clock��
	//�������ͬ��RAM��mem_clock�źţ�ģ���ڶ���Ϊram_clk��
	//ʵ���пɲ���ϵͳclock�ķ����ź���Ϊmem_clock�źţ��༴ram_clk��,
	//�������źŰ�����ĵĴ���ʱ�䣬Ȼ����mem_clock����ʱ�����������д���롣

	pipemwreg mw_reg  (mwreg,mm2reg,mmo,malu,mrn,clock,resetn,wwreg,wm2reg,wmo,walu,wrn);
	//MEM/WB��ˮ�߼Ĵ���ģ�飬��н�MEM�׶κ�WB�׶ε���ˮ����
	//��clock������ʱ����MEM�׶��贫�ݸ�WB�׶ε���Ϣ��������MEM/WB
	//��ˮ�߼Ĵ����У���������WB�׶Ρ�                 
				   
				   
	mux2x32 wb_stage  (walu,wmo,wm2reg,wdi);
	output [31:0] wdi,mb;
	output wwreg,wm2reg;

	//WBд�ؽ׶�ģ�顣��ʵ�ϣ������ԭ��ͼ�Ͽ��Կ������ý׶ε��߼����ܲ���ֻ
	//����һ����·�������Կ��Խ���һ����·����ʵ������ʵ�ָò��֡�
	//��Ȼ�����ר��дһ��������ģ��Ҳ�Ǻܺõġ�

endmodule

 