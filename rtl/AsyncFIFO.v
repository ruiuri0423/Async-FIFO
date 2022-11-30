`timescale 1ns/10ps

module AsyncFIFO
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
	,dina
	
	,clkb
	,rstb
	,enb
	,doutb
	
	,almost_full
	,full
	,almost_empty
	,empty
);

/********************************/
/*								*/
/*								*/
/*								*/
/********************************/

input				clka;
input				rsta;
input				ena;
input				wra;
input	[WIDTH-1:0]	dina;

input				clkb;
input				rstb;
input				enb;
output	[WIDTH-1:0]	doutb;

output				almost_full;
output				full;
output				almost_empty;
output				empty;

/********************************/
/*								*/
/*								*/
/*								*/
/********************************/

wire				rf_fifo_ena;
wire				rf_fifo_wra;
wire				rf_fifo_enb;

wire				addra_en;
wire	[ADDR-1:0]	addra_cnt_bin;
wire	[ADDR-1:0]	addra_cnt_gray;

wire	[ADDR-1:0]	addra_cnt_gray_2_clkb;

wire				addrb_en;
wire	[ADDR-1:0]	addrb_cnt_bin;
wire	[ADDR-1:0]	addrb_cnt_gray;

wire	[ADDR-1:0]	addrb_cnt_gray_2_clka;

/********************************/
/*								*/
/*								*/
/*								*/
/********************************/

assign	addra_en	= ena & wra;

CNT_full
#(
	.WIDTH	(ADDR)
)
CNT_addra(	 
	.clk			(clka),
	.rst			(rsta),
	.clr			(1'd0),
	.en				(addra_en & ~full),
	.cnt_bin		(addra_cnt_bin),
	.cnt_gray		(addra_cnt_gray),
	.cnt_gray_sync	(addrb_cnt_gray_2_clka),
	.almost_full    (almost_full),
	.full           (full)
);

Synchronizer
#(
	.WIDTH	(ADDR)
)
Sync_2_clka(
	.clk	(clka),
	.rst	(rsta),
	.d		(addrb_cnt_gray),
	.q		(addrb_cnt_gray_2_clka)
);

/********************************/
/*								*/
/*								*/
/*								*/
/********************************/

assign	addrb_en	= enb;

CNT_empty
#(
	.WIDTH	(ADDR)
)
CNT_addrb(	 
	.clk			(clkb),
	.rst			(rstb),
	.clr			(1'd0),
	.en				(addrb_en & ~empty),
	.cnt_bin		(addrb_cnt_bin),
	.cnt_gray		(addrb_cnt_gray),
	.cnt_gray_sync	(addra_cnt_gray_2_clkb),
	.almost_empty	(almost_empty),
	.empty          (empty)
);

Synchronizer
#(
	.WIDTH	(ADDR)
)
Sync_2_clkb(
	.clk	(clkb),
	.rst	(rsta),
	.d		(addra_cnt_gray),
	.q		(addra_cnt_gray_2_clkb)
);

/********************************/
/*								*/
/*								*/
/*								*/
/********************************/

assign	rf_fifo_ena = ena;
assign	rf_fifo_wra = wra;
assign	rf_fifo_enb = enb;

RegFile
#(
	.WIDTH	(WIDTH),
	.DEPTH	(DEPTH),
	.ADDR 	(ADDR)
)
RF_fifo(
	.clka	(clka),
	.rsta	(rsta),
	.ena	(rf_fifo_ena),
	.wra	(rf_fifo_wra),
	.addra	(addra_cnt_bin),
	.dina	(dina),
	
	.clkb	(clkb),
	.rstb	(rstb),
	.enb	(rf_fifo_enb),
	.addrb	(addrb_cnt_bin),
	.doutb	(doutb)
);
endmodule