`timescale 1ns/10ps

`define	CLKa 20.0
`define	CLKb 5.0

`define WIDTH 8
`define DEPTH 64
`define ADDR  7
`define DLEN  500

`define	testData "../data/din.dat"

class Master;
	
	int file;	// File pointer
	int fcheck;	
	int freturn;
	string line;
	
	int counter = 0;
	
	bit [`WIDTH-1:0] master_data_r [$];
	bit [`WIDTH-1:0] master_data_o;	// Master output port.
	bit 	   [0:0] master_data_e; // Data run out.
	
	// Constructor
	function new(string file_name);
		
		bit [`WIDTH-1:0] scan_data;
		
		// The file will be opened when the object has been created.
		file = $fopen(file_name, "r");
		
		// Loding the data to the memory.
		do begin
			
			// Checking and scannig the data from file.
			fcheck = $fgets(line, file);
			freturn = $sscanf(line, "%x", scan_data);
			
			// The valid value will be push to the mem(queue).
			if(fcheck) master_data_r.push_back(scan_data);
		
		end while(fcheck);
		
	endfunction:new
	
	// The data will be fetched from the master memory.
	function bit [`WIDTH:0] get_data();
	
		master_data_o = master_data_r[counter];
		
		if(counter == master_data_r.size())
		begin
			counter = counter; // Keeping. It can be reset by user.
			master_data_e = 1; // All data send to the DUT/Slave.
		end
		
		else
		begin
			counter = counter + 1; // Increment.
			master_data_e = 0;
		end
		
		return {~master_data_e, master_data_o};
		
	endfunction:get_data
	
	// The counter is reset by the user.
	function void reset_();
		
		counter = 0;
	
	endfunction:reset_
	
	// The counter is reset by the user.
	function int data_length();
		
		return master_data_r.size();
	
	endfunction:data_length
	
endclass:Master


module AsyncFIFOtb();

//-------------------------
//	Declare test parameter
//-------------------------
Master m;

bit check = 1;
bit [`WIDTH-1:0] golden;
bit [`WIDTH-1:0] result;

int err = 0;
int counter = 0;

//---------------------
//	Create data memory
//---------------------
reg	[`WIDTH-1:0]	out_mem [$];

//-----------------------
//	TB <-> DUT interface
//-----------------------
reg					clka = 1'd0;
reg					rsta;
reg					ena;
reg					wra;
reg	[`WIDTH-1:0]	dina;

reg					clkb = 1'd0;
reg					rstb;
reg					enb;
wire[`WIDTH-1:0]	doutb;

wire				almost_full;
wire				full;
wire				almost_empty;
wire				empty;

//----------------
//	Initial stage
//----------------
initial
begin
	// Master object(m) is initiated.
	m=new(`testData);
	
	// Loading data
	// $readmemh(`testData, data_mem);
	
	$display("=========================");
	$display("=                       =");
	$display("=   Simulation Start.   =");
	$display("=                       =");
	$display("=========================");
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
	.WIDTH	(`WIDTH),
	.DEPTH	(`DEPTH),
	.ADDR	(`ADDR)
)
async_fifo(

	.clka			(clka),
	.rsta			(rsta),
	.ena    		(ena),
	.wra    		(ena),
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
	if(!almost_full)
	begin
		#1;
		
		{ena, dina} <= m.get_data();
	end
	
	else
	begin
		#1;
	
		ena  <= 1'd0;
		dina <= dina;
	end
end

always@(posedge clkb)
begin
	if(!empty)
	begin
		#1;
		
		enb  <= 1'd1;
		if(enb) out_mem.push_back(doutb);
	end
	
	else
	begin
		#1;
	
		enb  <= 1'd0;
	end
end

// Checking the Transition result.
always@(*)
begin
	if(out_mem.size() == m.data_length())
	begin
		m.reset_();
		
		while(check)
		begin
			{check, golden} = m.get_data();
			result = out_mem[counter];
			counter = counter + 1;
			
			err = golden == result ? (err + 0) : (err + 1);
		end 
		
		if(err != 0) $display("Data transition failed !!!");
		else $display("...Data transition done.");
		$display("=========================");
		$display("=          End          =");
		$finish;
	end
end
endmodule