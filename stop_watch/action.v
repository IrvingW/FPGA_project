module action(
	reset, start_pause, display_stop_continue,
	clk_work, display,
	running
);

	input reset, start_pause, display_stop_continue;
	output clk_work, display;
	output running;
	
	// store current state
	reg watch_running;
	reg display_running;
	
	// initialize control wire
	assign clk_work = watch_running;
	assign display = display_running;
	assign running = watch_running;
	
	initial
		begin
			// initialize state
			watch_running = 1;
			display_running = 1;
		end

	// transfer button action to signal to controller
	always @ (negedge reset or negedge start_pause or negedge display_stop_continue)
		begin
			if(reset == 0)
				begin
					watch_running = 0;
					display_running = 1;
				end
				
			else if(start_pause == 0)
				begin
					if(watch_running == 1)
						watch_running = 0;
					else
						watch_running = 1;
				end
			else if(display_stop_continue == 0)
				begin
					if(display_running == 1)
						display_running = 0;
					else
						display_running = 1;
				end
		end
endmodule
