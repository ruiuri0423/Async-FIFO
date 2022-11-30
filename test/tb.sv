`timescale 1ns/10ps

`define	CLKa 10.0
`define	CLKb 50.0

`define	testData "../data/din.dat"

module AsyncFIFOtb();

//-------------------------
//	Declare test parameter
//-------------------------
parameter WIDTH = 8;
parameter DEPTH = 64;
parameter ADDR 	= 7;
parameter DLEN	= 500; 

integer counter = 0;

//---------------------
//	Create data memory
//---------------------
reg	[WIDTH-1:0]	data_mem [DLEN-1:0];

//-----------------------
//	TB <-> DUT interface
//-----------------------
reg				clka = 1'd0;
reg				rsta;
reg				ena;
reg				wra;
reg	[WIDTH-1:0]	dina;

reg				clkb = 1'd0;
reg				rstb;
reg				enb;
wire[WIDTH-1:0]	doutb;

wire			almost_full;
wire			full;
wire			almost_empty;
wire			empty;

//----------------
//	Initial stage
//----------------
initial
begin
	// Loading data
	$readmemh(`testData, data_mem);
	
	// Reset DUT
	#20	rsta = 1'd1;
		rstb = 1'd1;
	
	#20	rsta = 1'd0;
		rstb = 1'd0;
end

//------
//	DUT
//------
AsyncFIFO
#(
	.WIDTH	(WIDTH),
	.DEPTH	(DEPTH),
	.ADDR	(ADDR)
)
async_fifo(

	.clka			(clka),
	.rsta			(rsta),
	.ena    		(ena),
	.wra    		(wra),
	.dina   		(dina),
			
	.clkb   		(clkb),
	.rstb   		(rstb),
	.enb    		(enb),
	.doutb  		(doutb),
	
	.almost_full	(almost_full),
	.full           (full),
	.almost_empty   (almost_empty),
	.empty          (empty)
);

//--------------------------
//	Create clock definition
//--------------------------
always 
begin
	#(`CLKa) clka <= ~clka;
end

always 
begin
	#(`CLKb) clkb <= ~clkb;
end

//--------------
//	Data -> DUT
//--------------
always@(posedge clka)
begin
	if(counter==500) $finish;
	
	if(!almost_full)
	begin
		#1;
	
		ena  = 1'd1;
		wra  = 1'd1;
		dina = data_mem[counter];
		
		counter = counter + 1;
	end
	
	else
	begin
		#1;
	
		ena  = 1'd0;
		wra  = 1'd0;
		dina = data_mem[counter];
		
		counter = counter + 0;
	end
end

always@(posedge clkb)
begin
	if(!almost_empty)
	begin
		#1;
	
		enb  = 1'd1;
	end
	
	else
	begin
		#1;
	
		enb  = 1'd0;
	end
end
endmodule