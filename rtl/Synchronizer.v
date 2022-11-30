`timescale 1ns/10ps

module Synchronizer
#(
	 parameter	WIDTH	= 8
)
(
	 clk
	,rst
	,d
	,q
);

input				clk;
input				rst;
input	[WIDTH-1:0]	d;
output	[WIDTH-1:0]	q;

wire	[WIDTH-1:0]	d_2_q;

DFF_ #(WIDTH) Sync_DFF_0(clk, rst, 1'd0, 1'd1, d, d_2_q);
DFF_ #(WIDTH) Sync_DFF_1(clk, rst, 1'd0, 1'd1, d_2_q, q);

endmodule