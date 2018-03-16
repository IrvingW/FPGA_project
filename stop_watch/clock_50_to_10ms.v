// transfer the CLOCK_50
module clock_50_to_10ms(clk_50, clk_10ms,
								reset, work);
	input clk_50;
	output clk_10ms;
	input reset;
	input work;

	reg [31:0] cnt;

	initial
		cnt = 32'd0;
	
	assign clk_10ms = (cnt < 32'd500000);  // 5 ms(0.5 T)
	always @(posedge clk_50)
		begin
			if (reset == 0)
				cnt = 32'd0;
				
			else if(work == 1)
				begin
					if (cnt >= 32'd1000000) // 10ms (1T)
						cnt = 0;
					else
						cnt = cnt + 32'd1;
				end
		end
		
endmodule
