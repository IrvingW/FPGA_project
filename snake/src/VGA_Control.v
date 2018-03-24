module VGA_Control
(
	input CLK_50M,
	input RSTn,
	
	input [1:0]snake,
	input [5:0]apple_x,
	input [4:0]apple_y,
	
	//vga interface
	output			vga_adv_clk, 
	output			vga_blank_n, 
	output			vga_sync_n,
	
	output			vga_hs,    
	output			vga_vs,    
	output	[23:0]	vga_rgb,

	output  [9:0]   x_pos,
	output  [9:0]   y_pos
);

	// define each parameter of 640x480
	`define	VGA_640_480_60FPS_25MHz

	`ifdef	VGA_640_480_60FPS_25MHz
	parameter	DUTY_CYCLE		=	50;
	parameter	DIVIDE_DATA		=	2;
	parameter	MULTIPLY_DATA	=	1;
	parameter	H_DISP	=	11'd640;
	parameter	H_FRONT	=	11'd16; 
	parameter	H_SYNC 	=	11'd96;  
	parameter	H_BACK 	=	11'd48;   
	parameter	H_TOTAL	=	11'd800; 	
	parameter	V_DISP 	=	10'd480;  					
	parameter	V_FRONT	=	10'd10;  
	parameter	V_SYNC 	=	10'd2;   
	parameter	V_BACK 	=	10'd33;   
	parameter	V_TOTAL	=	10'd525;
	`endif

	//-----------------------------
	//system control instantiation
	wire	clk_vga;
	wire	sys_rst_n;

	assign	vga_adv_clk	=	~clk_vga;
	assign	vga_blank_n = 	1'b1;		
	assign	vga_sync_n 	= 	1'b0;	

	system_ctrl
	#(
		.DUTY_CYCLE		(DUTY_CYCLE),
		.DIVIDE_DATA	(DIVIDE_DATA),
		.MULTIPLY_DATA	(MULTIPLY_DATA)
	)
	system_ctrl_inst
	(
		.clk		(CLK_50M),
		.rst_n		(RSTn),
		.clk_c0		(clk_vga),
		.sys_rst_n	(sys_rst_n)
	);

	//-----------------------------
	//vga display instantiation
	wire	[9:0]	vga_xpos;
	wire	[9:0]	vga_ypos;
	wire	[23:0]	vga_data;
	assign x_pos = vga_xpos;
	assign y_pos = vga_ypos;

	vga_display 
	#(
		.H_DISP 	(H_DISP),
		.V_DISP 	(V_DISP) 
	)
	vga_display_inst
	(
		.clk		(clk_vga), 
		.rst_n		(sys_rst_n), 

		.vga_xpos	(vga_xpos), 
		.vga_ypos	(vga_ypos),
		.cube_kind 	(snake),
		.apple_x 	(apple_x),
		.apple_y	(apple_y),
		.vga_data	(vga_data)
	);

	//----------------------------
	//vga driver instantiation
	vga_driver
	#
	(
		.H_DISP 	(H_DISP), 	
		.H_FRONT	(H_FRONT),	
		.H_SYNC 	(H_SYNC), 	
		.H_BACK 	(H_BACK), 	
		.H_TOTAL	(H_TOTAL),	
		.V_DISP 	(V_DISP), 					
		.V_FRONT	(V_FRONT),	 
		.V_SYNC 	(V_SYNC), 	
		.V_BACK 	(V_BACK), 	
		.V_TOTAL	(V_TOTAL)
	)
	vga_driver_inst
	(  	
		.clk_vga	(clk_vga),	
		.rst_n		(sys_rst_n),     
		
		.vga_data	(vga_data),
		.vga_rgb	(vga_rgb),	
		.vga_hs		(vga_hs),	
		.vga_vs		(vga_vs),	
		
		.vga_xpos	(vga_xpos),	
		.vga_ypos	(vga_ypos)	
	);
		

endmodule

