// control 7 seg light to display score
module Seg_Display
(
	input CLK_50M,
	input RSTn,
	input add_cube,		// add point signal
	
	output [6:0]hex0,	// low bit
	output [6:0]hex1		// high bit
							// can show point less than 100
);
	reg[31:0]point;
	reg[31:0]point_low, point_high;
	
	initial
		begin
			point <= 0;
			point_high <= 0;
			point_low <= 0;
		end


	// calculate score
	reg addcube_state;
	
	always@(posedge CLK_50M or negedge RSTn)
		begin
			if(!RSTn)
				begin
					point<=0;
					addcube_state<=0;	
					point_low<=0;
					point_high<=0;
				end
			else 
				begin
					case(addcube_state)
					0:
						begin
							if(add_cube)
								begin
									point = point + 1;
									point_low <= point % 10;
									point_high <= point / 10;
								end
							addcube_state<=1;
						end
					1:
						begin
							if(!add_cube)
								addcube_state<=0;
						end
					endcase
				end
				
		end				

	// display current point on seven seg led light
	sevenseg out_low (point_low, hex0);
	sevenseg out_high (point_high, hex1);


endmodule
