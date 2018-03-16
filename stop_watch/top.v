// 3 keys: key_reset/reset, key_start_pause, key_display_stop_continue
// This module transfer the button action to signal sent to controller
module stop_watch(CLOCK_50,  	// clock, 50M 
						key_reset, key_start_pause, key_display_stop_continue,	// 4 buttons
						hex0, hex1, hex2, hex3, hex4, hex5,		// 6 led number
						led0, led1, led2, led3		// indicate current state
);
						
	input		CLOCK_50;
	input 	key_reset, key_start_pause, key_display_stop_continue;
	
	output [6:0]	hex0, hex1, hex2, hex3, hex4, hex5;
	output 	led0, led1, led2, led3;
	
	
	// signal
	wire 	clk_work;
	wire 	display;
	
	wire watch_running;

	// new clock
	wire 	CLOCK_10MS;
	
	// solve shake
	wire unshake_reset;
	wire unshake_display;
	wire unshake_start_pause;
	
	assign led0 = ~key_start_pause;
	assign led1 = ~key_display_stop_continue;
	assign led2 = ~key_reset;
	assign led3 = watch_running;
	
		

	
	//	clock transfer
	clock_50_to_10ms clock_div(
		.clk_50(CLOCK_50),
		.clk_10ms(CLOCK_10MS),
		.reset(key_reset),
		.work(clk_work)
	);
	// filter key signal, solve shake
	solve_shake(
		.clk(CLOCK_50), 
		.in(key_reset), 
		.out(unshake_reset)
	);
	solve_shake(
		.clk(CLOCK_50), 
		.in(key_start_pause), 
		.out(unshake_start_pause)
	);
	solve_shake(
		.clk(CLOCK_50), 
		.in(key_display_stop_continue), 
		.out(unshake_display)
	);
	// judge action
	action action_div(
		.reset(unshake_reset), 
		.start_pause(unshake_start_pause), 
		.display_stop_continue(unshake_display),
		.clk_work(clk_work), 
		.display(display),
		.running(watch_running)
	);
	// control count and display
	controller crontroller(
		.clk(CLOCK_10MS),
		.reset(key_reset),
		.display(display),
		.hex0(hex0), .hex1(hex1), .hex2(hex2), .hex3(hex3), .hex4(hex4), .hex5(hex5),
	);
	

endmodule


		