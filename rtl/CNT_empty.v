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
	,empty
);

input					clk;
input					rst;
input					en;
input					clr;
output	[WIDTH-1:0]		cnt_bin;
output	[WIDTH-1:0]		cnt_gray;
input	[WIDTH-1:0]		cnt_gray_sync;
output	reg				empty;

wire	[WIDTH-1:0]		cnt_bin_add;
wire	[WIDTH-1:0]		cnt_gray_add;
wire					next_empty;

assign	cnt_bin_add	 = cnt_bin + (1'd1 & ~empty);
assign	cnt_gray_add = (cnt_bin_add>>1) ^ cnt_bin_add;
assign	next_empty   = cnt_gray_add == cnt_gray_sync;

always@(posedge clk or posedge rst)
begin
	if(rst)
		empty <= 1'd1;
        
	else if(en)
		empty <= next_empty;
    
    // Empty state escaped.
	else if(cnt_gray != cnt_gray_sync)
		empty <= 1'd0;
end

DFF_ #(WIDTH) cnt_bin_reg(clk, rst, clr, en, cnt_bin_add, cnt_bin);
DFF_ #(WIDTH) cnt_gray_reg(clk, rst, clr, en, cnt_gray_add, cnt_gray);

endmodule