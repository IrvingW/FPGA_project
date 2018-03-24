module io_output_reg (addr,datain,write_io_enable,io_clk,clrn,hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7);
	input [31:0] addr,datain;
	input write_io_enable,io_clk;
	input clrn;

	output [6:0] hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7;
	
	reg [31:0] out_port0_high, out_port0_low;
	reg [31:0] out_port1_high, out_port1_low;
	reg [31:0] res_3, res_2, res_1, res_0;
	
	always @(posedge io_clk or negedge clrn)
	begin
		if (clrn == 0)
		begin // reset
			out_port0_high <= 0; 
			out_port0_low <= 0;
			out_port1_high <= 0; 
			out_port1_low <= 0; // reset all the output port to 0.
		end
		else
		begin
			if (write_io_enable == 1)
				case (addr[7:2])
				6'b100000: // 80h
				begin
					out_port0_high <= datain[7:0]/10;
					out_port0_low <= datain[7:0]%10;
				end
				6'b100001: // 84h
				begin
					out_port1_high <= datain[7:0]/10;
					out_port1_low <= datain[7:0]%10;
				end
				6'b100010: // 88h
				begin
					res_3 <= datain[15:0]/1000;
					res_2 <= (datain[15:0]/100)%10;
					res_1 <= (datain[15:0]/10)%10;
					res_0 <= datain[15:0]%10;
				end
				// more ports，可根据需要设计更多的输出端口。
				endcase
		end
	end
	
	sevenseg LED8_out_port1_high (out_port0_high, hex7);
	sevenseg LED8_out_port1_low (out_port0_low, hex6);
	sevenseg LED8_out_port0_high (out_port1_high, hex5);
	sevenseg LED8_out_port0_low (out_port1_low, hex4);
	
	sevenseg LED8_res_3 (res_3, hex3);
	sevenseg LED8_res_2 (res_2, hex2);
	sevenseg LED8_res_1 (res_1, hex1);
	sevenseg LED8_res_0 (res_0, hex0);
	
endmodule