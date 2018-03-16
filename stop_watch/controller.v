// controller of my stop watch, listen to different key action 
// and do something

// hex for a number

// led0: reset/stop
// led1: counting
//	led2: pause
// led3: display_stop

module controller(clk,
						reset,
						display,	// display
						hex0, hex1, hex2, hex3, hex4, hex5,
);
	
	input clk;	// clock (10ms)
	input reset, display;	// action signal
	
	output [6:0] 	hex0, hex1, hex2, hex3, hex4, hex5;  	// each number has 7 led light

	
	// for display
	reg [3:0] minute_display_high;
	reg [3:0] minute_display_low;
	reg [3:0] second_display_high;
	reg [3:0] second_display_low;
	reg [3:0] msecond_display_high;
	reg [3:0] msecond_display_low;

	// for count
	reg [3:0] minute_count_high;
	reg [3:0] minute_count_low;
	reg [3:0] second_count_high;
	reg [3:0] second_count_low;
	reg [3:0] msecond_count_high;
	reg [3:0] msecond_count_low;
	
	// contro 6 led number
	// minute part
	sevenseg LED_minute_display_high (minute_display_high, hex5);
	sevenseg LED_minute_display_low (minute_display_low, hex4);
	
	// second part
	sevenseg LED_second_display_high (second_display_high, hex3);
	sevenseg LED_second_display_low (second_display_low, hex2);
	
	// msecond part
	sevenseg LED_msecond_display_high (msecond_display_high, hex1);
	sevenseg LED_msecond_display_low (msecond_display_low, hex0);

	
	initial
		begin
			// clear display
			msecond_display_low <= 4'd0;
			msecond_display_high <= 4'd0;
			second_display_low <= 4'd0;
			second_display_high <= 4'd0;
			minute_display_low <= 4'd0;
			minute_display_high <= 4'd0;
						
			// clear count
			msecond_count_low <= 4'd0;
			msecond_count_high <= 4'd0;
			second_count_low <= 4'd0;
			second_count_high <= 4'd0;
			minute_count_low <= 4'd0;
			minute_count_high <= 4'd0;
		end
	
	
	
	always @ (posedge clk)
		begin
		
			if(reset == 0) 	// clear
				begin
					// clear display
					msecond_display_low <= 4'd0;
					msecond_display_high <= 4'd0;
					second_display_low <= 4'd0;
					second_display_high <= 4'd0;
					minute_display_low <= 4'd0;
					minute_display_high <= 4'd0;
								
					// clear count
					msecond_count_low <= 4'd0;
					msecond_count_high <= 4'd0;
					second_count_low <= 4'd0;
					second_count_high <= 4'd0;
					minute_count_low <= 4'd0;
					minute_count_high <= 4'd0;
				end
				
			else
		
			begin
					// update count register
					if(msecond_count_low == 4'd9)
					begin
						msecond_count_low <= 4'd0;
						if(msecond_count_high == 4'd9)
						begin
							msecond_count_high <= 4'd0;
								if(second_count_low == 4'd9)
								begin
									second_count_low <= 4'd0;
									if(second_count_high == 4'd5)
									begin
										second_count_high <= 4'd0;
											if(minute_count_low == 4'd9)
											begin
												minute_count_low <= 4'd0;
													if(minute_count_high == 4'd5)
													begin
														minute_count_high <= 4'd0;
													end
													else
														minute_count_high <= minute_count_high + 4'd1;
											end
											else
												minute_count_low <= minute_count_low + 4'd1;
									end
									else
										second_count_high <= second_count_high + 4'd1;
								end
								else
									second_count_low <= second_count_low + 4'd1;
						end
						else
							msecond_count_high <= msecond_count_high + 4'd1;
					end
					else
						msecond_count_low <= msecond_count_low + 4'd1;
						
						// update display
						if(display)
							begin
								msecond_display_low = msecond_count_low;
								msecond_display_high = msecond_count_high;
								second_display_low = second_count_low;
								second_display_high = second_count_high;
								minute_display_low = minute_count_low;
								minute_display_high = minute_display_high;
							end
				end
		
		end
		
endmodule
