`timescale 1ns/10ps

module DFF_n 
#(
	 parameter WIDTH	= 1
)
(	 
	 clk
	,rst
	,clr
	,en
	,d
	,q
);

input						clk;
input						rst;
input						en;
input						clr;
input		[WIDTH-1:0]		d;
output	reg	[WIDTH-1:0]		q;

always@(posedge clk or posedge rst)
begin
	if(rst)
		q <= {(WIDTH){1'd1}};
	
	else if(clr)
		q <= {(WIDTH){1'd1}};
		
	else if(en)
		q <= d;
end
endmodule