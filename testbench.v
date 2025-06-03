`timescale 1ns / 1ps
module testbench_tb;
    //Inputs
	reg reset;
    reg [31:0] inst_rdata;
    reg [31:0] data_rdata;

    //Outputs
    wire [31:0] inst_addr;  
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [3:0] data_we;
	wire trap;

   // Test clock 
   reg clk ; // in this version we do not really need the clock

    reg [10:0] vec_cnt;
   // Define an array called 'testvec' that is wide enough to hold the inputs:
   //   aluop, a, b  and the expected output
	reg [31:0] memory [0:128*1024/4-1];

   // The test clock generation
   always				// process always triggers
	begin
		clk=1; #50;		// clk is 1 for 50 ns 
		clk=0; #50;		// clk is 0 for 50 ns
	end					// generate a 100 ns clock

   // Initialization
	initial
	begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, testbench_tb);
		$readmemh("firmware/firmware.hex", memory);
        vec_cnt=0; // number of vectors
        reset = 1;
        repeat (2) @(posedge clk);
        reset = 0;
	end
	always @ (negedge clk)		// trigger with the test clock
	begin
 		data_rdata = memory[data_addr >> 2];
		if(inst_rdata[6:2]== 5'b00000)
		$display("LOAD 0x%08x: %08x", data_addr, data_rdata);
	end
   // Tests
	always @ (posedge clk)		// trigger with the test clock
	begin
		// Wait 20 ns, so that we can safely apply the inputs
		#20; 

        inst_rdata = memory[inst_addr >> 2];
        $display("inst 0x%08x: 0x%08x", inst_addr, inst_rdata);

        if (data_we[0]) memory[data_addr >> 2][ 7: 0] = data_wdata[ 7: 0];
		if (data_we[1]) memory[data_addr >> 2][15: 8] = data_wdata[15: 8];
		if (data_we[2]) memory[data_addr >> 2][23:16] = data_wdata[23:16];
		if (data_we[3]) memory[data_addr >> 2][31:24] = data_wdata[31:24];

        if (data_we) $display("STORE 0x%08x: %8s (we=%b)", data_addr, data_wdata, data_we);

            	
		if (data_we && data_addr == 32'h1000_0000) begin
			if (32 <= data_wdata && data_wdata < 128)
				$display("OUT: '%c'", data_wdata[7:0]);
			else
				$display("OUT: %3d", data_wdata);
		end

		// Wait another 60ns after which we will be at 80ns
		#80; 
        vec_cnt = vec_cnt + 1;
        if (vec_cnt == 5000 | trap)
		begin
			// End of test, no more entries...
			$display ("%d tests", vec_cnt);
			
			// Wait so that we can see the last result
			#20; 
			$writememh("firmware/mem.hex", memory);
			// Terminate simulation
			$finish;
		end
	end
   // Instantiate the Unit Under Test (UUT)
	rv32i dut (
		.clk(clk),
		.reset(reset),
		.inst_rdata(inst_rdata),
		.inst_addr(inst_addr),
		.data_rdata(data_rdata),
		.data_addr(data_addr),
        .data_wdata(data_wdata),
        .data_we(data_we),
		.trap(trap));
endmodule
