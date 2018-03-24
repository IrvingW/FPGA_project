module vga_driver
#(
	// VGA_600_480_60Fps_25MHz
	// Horizontal Parameter	( Pixel )
	parameter	H_DISP 	=	11'd640, 
	parameter	H_FRONT	=	11'd16,	 
	parameter	H_SYNC 	=	11'd96,  
	parameter	H_BACK 	=	11'd48,   
	parameter	H_TOTAL	=	11'd800, 
	// Virtical Parameter	( Line ) 
	parameter	V_DISP 	=	10'd480,  					
	parameter	V_FRONT	=	10'd10,   
	parameter	V_SYNC 	=	10'd2,    
	parameter	V_BACK 	=	10'd33,   
	parameter	V_TOTAL	=	10'd525  
)
(  	
	input			clk_vga,	// VGA����ʱ��
	input			rst_n,     	// �첽��λ�ź�
	
	input	[23:0]	vga_data,
	output	[23:0]	vga_rgb,	// ����Ҫ��ʾ��ɫ��
	output	reg		vga_hs,		// VGA�ܽ� ��ͬ��
	output	reg		vga_vs,		// VGA�ܽ� ��ͬ��
	
	output	[9:0]	vga_xpos,	// ���غ�����λ�� 
	output	[9:0]	vga_ypos	// ����������λ�� 
);	

//------------------------------------------
// scan a row
reg [10:0] hcnt; 
always @ (posedge clk_vga or negedge rst_n)
begin
	if (!rst_n)
		hcnt <= 0;
	else
		begin
        if (hcnt < H_TOTAL-1'b1)			
            hcnt <= hcnt + 1'b1;
        else
            hcnt <= 0;
		end
end 
// scan a coloumn
always@(posedge clk_vga or negedge rst_n)
begin
	if(!rst_n)
		vga_hs <= 1;
	else
		begin
        if( (hcnt >= H_DISP+H_FRONT-1'b1) && (hcnt < H_DISP+H_FRONT+H_SYNC-1'b1) )
            vga_hs <= 0;       
        else
            vga_hs <= 1;
		end
end

//------------------------------------------
reg [9:0] vcnt;
always @ (posedge clk_vga or negedge rst_n)
begin
	if (!rst_n)
		vcnt <= 0;
	else
		begin
		if(hcnt == H_DISP-1)
			begin
			if (vcnt < V_TOTAL-1'b1)			
				vcnt <= vcnt+1'b1;
			else
				vcnt <= 0;   
			end 
		else
			vcnt <= vcnt;
		end
end

always @ (posedge clk_vga or negedge rst_n) 
begin
	if(!rst_n)
		vga_vs <= 1;
	else
		begin
		if( (vcnt >= V_DISP+V_FRONT-1'b1) && (vcnt < V_DISP+V_FRONT+V_SYNC-1'b1) )
            vga_vs <= 0;        
        else
            vga_vs <= 1;		
		end
end

//--------------------choose to display what ------------------
assign	vga_xpos = (hcnt < H_DISP) ? hcnt[9:0]+1'b1 : 10'd0;
assign	vga_ypos = (vcnt < V_DISP) ? vcnt[9:0]+1'b1 : 10'd0;
assign	vga_rgb 	= 	((hcnt < H_DISP) && (vcnt < V_DISP)) ? vga_data : 24'd0;

endmodule
