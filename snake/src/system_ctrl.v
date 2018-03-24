module system_ctrl
#(
	parameter	DUTY_CYCLE		=	50,
	parameter	DIVIDE_DATA		=	2,
	parameter	MULTIPLY_DATA	=	1
)
(
	input 		clk,		//50MHz
	input 		rst_n,		//global reset

	output 		sys_rst_n,	//system reset
	output 		clk_c0		//50MHz
);

//----------------------------------------------
//rst_n synchronism, is controlled by the input clk
reg     rst_nr1,rst_nr2;
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		rst_nr1 <= 1'b0;
		rst_nr2 <= 1'b0;
		end
	else
		begin
		rst_nr1 <= 1'b1;
		rst_nr2 <= rst_nr1;
		end
end

//----------------------------------
//component instantiation for system_delay
wire	delay_ok;
system_delay	system_delay_inst
(
	.clk		(clk),
	.delay_ok	(delay_ok)
);
wire	pll_rst = ~rst_nr2 & ~delay_ok;	//active High

//----------------------------------------------
//Component instantiation
pll_vga	
#(
	.DUTY_CYCLE		(DUTY_CYCLE),	
	.DIVIDE_DATA	(DIVIDE_DATA),
	.MULTIPLY_DATA	(MULTIPLY_DATA)
)
pll_vga_inst
(
	.areset	(pll_rst),
	.inclk0	(clk),
			
	.c0		(clk_c0),
	.locked	(locked)
);

//----------------------------------------------
//sys_rst_n synchronism, is control by the highest output clk
wire 	locked;		  
wire	sysrst_nr0 = rst_nr2 & locked & delay_ok;  
reg 	sysrst_nr1, sysrst_nr2; 
always @(posedge clk_c0 or negedge sysrst_nr0)
begin
	if(!sysrst_nr0) 
        begin
        sysrst_nr1 <= 1'b0;
        sysrst_nr2 <= 1'b0;
        end        
	else 
        begin
        sysrst_nr1 <= 1'b1;
        sysrst_nr2 <= sysrst_nr1;
        end
end
assign sys_rst_n = sysrst_nr2;	//active Low


 
endmodule



module system_delay
(
	input	clk,		//50MHz	
	output	delay_ok
);

//------------------------------------------
// Delay 100ms for steady state
reg	[22:0] cnt;
always@(posedge clk)
begin
	if(cnt < 23'd50_00000) //100ms
		cnt <= cnt + 1'b1;
	else
		cnt <= cnt;
end

//------------------------------------------
//sys_rst_n synchronism
assign	delay_ok = (cnt == 23'd50_00000)? 1'b1 : 1'b0;

endmodule

