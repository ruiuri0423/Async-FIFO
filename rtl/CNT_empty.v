`timescale 1ns/10ps

module CNT_empty 
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
	,almost_empty
	,empty
);

input					clk;
input					rst;
input					en;
input					clr;
output	[WIDTH-1:0]		cnt_bin;
output	[WIDTH-1:0]		cnt_gray;
input	[WIDTH-1:0]		cnt_gray_sync;
output					almost_empty;
output					empty;

wire	[WIDTH-1:0]		cnt_bin_add;
wire	[WIDTH-1:0]		cnt_gray_add;

assign	cnt_bin_add	 = cnt_bin + (1'd1 & ~empty);
assign	cnt_gray_add = (cnt_bin_add>>1) ^ cnt_bin_add;
assign	almost_empty = cnt_gray_add == cnt_gray_sync;

DFF_ 		  empty_reg(clk, rst, clr, 1'd1, almost_empty, empty);
DFF_ #(WIDTH) cnt_bin_reg(clk, rst, clr, en, cnt_bin_add, cnt_bin);
DFF_ #(WIDTH) cnt_gray_reg(clk, rst, clr, en, cnt_gray_add, cnt_gray);

endmodule