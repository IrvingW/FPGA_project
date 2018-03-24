module snake
(
	input CLK_50M,
	input RSTn,
	
	input left,
	input right,
	input up,
	input down,

	//vga interface
	output			vga_adv_clk, 
	output			vga_blank_n, 
	output			vga_sync_n,
	
	output			vga_hs,    
	output			vga_vs,    
	output	[23:0]	vga_rgb,

	// score
	output 	[6:0]	hex0,
	output 	[6:0]	hex1
	
);

	wire left_key_press,right_key_press,up_key_press,down_key_press;
	wire [1:0]snake;
	wire [9:0]x_pos;
	wire [9:0]y_pos;
	wire [5:0]apple_x;
	wire [4:0]apple_y;
	wire [5:0]head_x;
	wire [5:0]head_y;
	
	wire add_cube;
	wire[1:0]game_status;
	wire hit_wall;
	wire hit_body;
	wire die_flash;
	wire restart;
	wire [6:0]cube_num;


	Game_Ctrl_Unit U2
	(
		.CLK_50M(CLK_50M),
		.RSTn(RSTn),
		.key1_press(left_key_press),
		.key2_press(right_key_press),
		.key3_press(up_key_press),
		.key4_press(down_key_press),
		.game_status(game_status),
		.hit_wall(hit_wall),
		.hit_body(hit_body),
		.die_flash(die_flash),
		.restart(restart)
		
	);
		
	
	Snake_Eatting_Apple U3
	(
		.CLK_50M(CLK_50M),
		.RSTn(RSTn),
		.apple_x(apple_x),
		.apple_y(apple_y),
		.head_x(head_x),
		.head_y(head_y),
		.add_cube(add_cube)
	
	);


	Snake U4
	(
		.CLK_50M(CLK_50M),
		.RSTn(RSTn),
		.left_press(left_key_press),
		.right_press(right_key_press),
		.up_press(up_key_press),
		.down_press(down_key_press),
		.snake(snake),
		.x_pos(x_pos),
		.y_pos(y_pos),
		.head_x(head_x),
		.head_y(head_y),
		.add_cube(add_cube),
		.game_status(game_status),
		.cube_num(cube_num),
		.hit_body(hit_body),
		.hit_wall(hit_wall),
		.die_flash(die_flash)
	);
	
	
	VGA_Control U5
	(
		.CLK_50M(CLK_50M),
		.RSTn(RSTn),
		.snake(snake),
		.apple_x(apple_x),
		.apple_y(apple_y),

		.vga_adv_clk(vga_adv_clk),
		.vga_blank_n(vga_blank_n),
		.vga_sync_n(vga_sync_n),
		.vga_hs(vga_hs),
		.vga_vs(vga_vs),
		.vga_rgb(vga_rgb),

		.x_pos(x_pos),
		.y_pos(y_pos)
	);
	
	
	Key U6
	(
		.CLK_50M(CLK_50M),
		.RSTn(RSTn),
		.left(left),
		.right(right),
		.up(up),
		.down(down),
		.left_key_press(left_key_press),
		.right_key_press(right_key_press),
		.up_key_press(up_key_press),
		.down_key_press(down_key_press),			
	
	);
	
	Seg_Display U7
	(
		.CLK_50M(CLK_50M),
		.RSTn(RSTn),	
		.add_cube(add_cube),
		.hex0(hex0),
		.hex1(hex1)
	);

	endmodule
