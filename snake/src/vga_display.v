module vga_display
#(
	parameter	H_DISP 	=	10'd640,
	parameter	V_DISP 	=	10'd480 
)
(
	input				clk, 
	input   			rst_n, 

	input		[9:0]	vga_xpos, 
	input 		[9:0] 	vga_ypos,
	input 		[1:0]	cube_kind,
	input 		[5:0]	apple_x,
	input 		[5:0] 	apple_y,

	output 	reg	[23:0] 	vga_data
);
 
//define colors RGB--8|8|8
localparam RED     = 24'hFF0000;   /*11111111,00000000,00000000   */
localparam GREEN   = 24'h00FF00;   /*00000000,11111111,00000000   */
localparam BLUE    = 24'h0000FF;   /*00000000,00000000,11111111   */
localparam WHITE   = 24'hFFFFFF;   /*11111111,11111111,11111111   */
localparam BLACK   = 24'h000000;   /*00000000,00000000,00000000   */
localparam YELLOW  = 24'hFFFF00;   /*11111111,11111111,00000000   */
localparam CYAN    = 24'hFF00FF;   /*11111111,00000000,11111111   */
localparam ROYAL   = 24'h00FFFF;   /*00000000,11111111,11111111   */ 

// cube kind
localparam NONE=2'b00;
localparam HEAD=2'b01;
localparam BODY=2'b10;
localparam WALL=2'b11;

// define color scheme;
localparam HEAD_COLOR = YELLOW;
localparam BODY_COLOR = GREEN;
localparam WALL_COLOR = BLUE;
localparam APPLE_COLOR = RED;
localparam BG_COLOR = BLACK;

reg [3:0] lox, loy;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		vga_data <= 16'h0;
	else
		begin
			if	(vga_xpos >= 0 && vga_xpos < H_DISP && vga_ypos >= 0 && vga_ypos < V_DISP)	// in show area
				begin
					lox = vga_xpos[3:0];
					loy = vga_ypos[3:0];
					if(vga_xpos[9:4]==apple_x && vga_ypos[9:4]==apple_y)	// apple
						case({loy,lox})
							8'b0000_0000:
								vga_data <= BG_COLOR;	// skin
							default:
								vga_data <= APPLE_COLOR;
						endcase
					else if(cube_kind == NONE)
						vga_data <= BG_COLOR;
					else if(cube_kind == WALL)
						vga_data <= WALL_COLOR;
					else if(cube_kind == HEAD || cube_kind == BODY)
						case({lox,loy})
							8'b0000_0000:
								vga_data <= BG_COLOR;	// skin
							default:
								vga_data <= (cube_kind==HEAD)?HEAD_COLOR:BODY_COLOR;
						endcase
				end
		end
end

endmodule
