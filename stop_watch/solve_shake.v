module solve_shake(clk,
							in, out
);
		input clk;
		input in;
		output out;
		
		reg [31:0] cnt;
		reg last_state;
		reg out_reg = 1;
		
		assign out =  out_reg;
		
		always @ (posedge clk)
			begin
				cnt = cnt + 1'd1;
				if(in == 1)
					begin
						cnt = 32'd0;
						out_reg = 1;
					end
				if(cnt == 32'd500000)
					begin
						cnt = 32'd0;
						out_reg = 0;
					end
			end			
			
endmodule
