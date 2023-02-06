`timescale 1ns/10ps

module CNT_full 
#(
	 parameter WIDTH	= 8
)
(	 
	 clk
	,rst
	,clr
	,en
	,cnt_bin
	,cnt_gray
	,cnt_gray_sync
	,full
);

input					clk;
input					rst;
input					en;
input					clr;
output	[WIDTH-1:0]		cnt_bin;
output	[WIDTH-1:0]		cnt_gray;
input	[WIDTH-1:0]		cnt_gray_sync;
output					full;

wire	[WIDTH-1:0]		cnt_bin_add;
wire	[WIDTH-1:0]		cnt_gray_add;
wire					next_full;

assign	cnt_bin_add	 = cnt_bin + (1'd1 & ~full);
assign	cnt_gray_add = (cnt_bin_add>>1) ^ cnt_bin_add;
assign	next_full  = cnt_gray_add=={~cnt_gray_sync[WIDTH-1:WIDTH-2] ,cnt_gray_sync[WIDTH-3:0]};

DFF_ 		  full_reg(clk, rst, clr, 1'd1, next_full, full);
DFF_ #(WIDTH) cnt_bin_reg(clk, rst, clr, en, cnt_bin_add, cnt_bin);
DFF_ #(WIDTH) cnt_gray_reg(clk, rst, clr, en, cnt_gray_add, cnt_gray);

endmodule