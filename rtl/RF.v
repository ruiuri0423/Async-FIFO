`timescale 1ns/10ps

module RegFile
#(
	 parameter WIDTH	= 8
	,parameter DEPTH	= 64
	,parameter ADDR		= 6	
)
(
	 clka
	,rsta
	,ena
	,wra
	,addra
	,dina
	
	,clkb
	,rstb
	,enb
	,addrb
	,doutb
);

/*
 *	Interface
 */
//
input					clka;
input					rsta;
input					ena;
input					wra;
input		 [ADDR-1:0]	addra;
input		[WIDTH-1:0]	dina;

input					clkb;
input					rstb;
input					enb;
input		 [ADDR-1:0]	addrb;
output		[WIDTH-1:0]	doutb;
//
/*
 *	Interconnect
 */
//
reg		[WIDTH-1:0]	dff_qin [DEPTH-1:0];
wire	[WIDTH-1:0]	dff_dout;

assign	doutb = dff_dout;
//
/*
 *	din dff
 */
//
always@(posedge clka or posedge rsta)
begin:din_dff_block

	integer i;
	
	if(rsta) // Reset all RegFile value 
	begin
		for(i=0; i<DEPTH; i=i+1)
			dff_qin[i] <= {(WIDTH){1'd0}};
	end
	
	else if(wra & ena)  // Write value to RegFile addra correspodingly 
	begin
		dff_qin[addra] <= dina;
	end
	
end
//
/*
 *	dout dff
 */
//
DFF_ 
#(
	.WIDTH(WIDTH)
)
dff_out(
	.clk(clkb), 
	.rst(rstb), 
	.clr(1'd0), 
	.en (enb), 
	.d	(dff_qin[addrb]), 
	.q	(dff_dout)
);
endmodule