// MEM stage: malu->addr, mb->datain, mmo->dataout
module pipemem (mwmem,malu,mb,mem_clk,mmo,clrn,
				in_port0,in_port1,
				hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7,
				mem_dataout,io_read_data);

	input 		 mwmem,mem_clk,clrn;
	input [31:0] malu,mb;
	input [31:0] in_port0,in_port1;

	output [31:0] mmo;
	output [6:0]  hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7;
	output [31:0] mem_dataout;
	output [31:0] io_read_data;

	wire		  write_io_output_reg_enable;
	wire 		  write_datamem_enable;

	assign write_datamem_enable = mwmem & (~malu[7]);
	assign write_io_output_reg_enable = mwmem & malu[7];

	mux2x32 mem_io_dataout_mux(mem_dataout,io_read_data,malu[7],mmo);

	lpm_ram_dq0 dram(malu[6:2],mem_clk,mb,write_datamem_enable,mem_dataout);
	// when address[7]=1, means the access is to the I/O space.
	// that is, the address space of I/O is from 100000 to 111111 word(4 bytes)

	io_output_reg io_output_reg(malu,mb,write_io_output_reg_enable,mem_clk,clrn,hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7);
	// module io_output_reg (addr,datain,write_io_enable,io_clk,clrn,hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7);

	//assign io_read_data = 32'b1010;
	io_input_reg io_input_reg(malu,mem_clk,io_read_data,in_port0,in_port1);
	// module io_input_reg (addr,io_clk,io_read_data,in_port0,in_port1);

endmodule 
