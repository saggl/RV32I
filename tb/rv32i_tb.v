`timescale 1ns / 1ps
module rv32i_tb;
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

    // Tie off irq (no interrupts in unit test)
    reg [2:0] irq;
    initial irq = 3'b0;

   // Test clock 
   reg clk ; // in this version we do not really need the clock

   // Expected outputs
    reg [31:0] exp_inst_addr;  
    reg [31:0] exp_data_addr;
    reg [31:0] exp_data_wdata;
    reg [3:0] exp_data_we;


   // Vector and Error counts
   reg [10:0] vec_cnt, err_cnt;

   // Define an array called 'testvec' that is wide enough to hold the inputs:
   //   aluop, a, b  and the expected output
	reg [164:0] testvec [0:9];

   // The test clock generation
   initial clk = 0;
   always #50 clk = ~clk;	// 100 ns clock period

   // Initialization
	initial
	begin
		// Read the content of the file testvectors_hex.txt into the
		// array testvec.
		$readmemh("tb/rv32i_testvec.txt", testvec);
		err_cnt=0; // number of errors
		vec_cnt=0; // number of vectors
		// Apply reset before first posedge so PC initializes to 0
		reset=1;
		inst_rdata=32'h00000000;
		data_rdata=32'hxxxxxxxx;
	end
   // Tests
	always @ (posedge clk)		// trigger with the test clock
	begin
		// Wait 20 ns, so that we can safely apply the inputs
		#20; 

		// Assign the signals from the testvec array
		{reset, inst_rdata, data_rdata, exp_inst_addr, exp_data_addr, exp_data_wdata, exp_data_we} = testvec[vec_cnt]; 

		// Wait another 60ns after which we will be at 80ns
		#60; 

		// Check if output is not what we expect to see
		if ((inst_addr !== exp_inst_addr) | (data_addr !== exp_data_addr) | (data_wdata !== exp_data_wdata) | (data_we !== exp_data_we))
		begin                                         
			// Display message
			$display("Error at %5d: reset=%h inst_rdata=%h data_rdata=%h \n     inst_addr=%h     data_addr=%h     data_wdata=%h     data_we=%h \n exp_inst_addr=%h exp_data_addr=%h exp_data_wdata=%h exp_data_we=%h", vec_cnt+2, reset, inst_rdata, data_rdata, inst_addr, data_addr, data_wdata, data_we, exp_inst_addr, exp_data_addr, exp_data_wdata, exp_data_we);
			err_cnt = err_cnt + 1; // increment error count
		end

		vec_cnt = vec_cnt + 1;																	// next vector
	
		// We use === so that we can also test for X
		if ((testvec[vec_cnt][164:161] === 4'bxxxx))

		begin
			// End of test, no more entries...
			$display ("%d tests completed with %d errors: rv32i", vec_cnt, err_cnt);
			
			// Wait so that we can see the last result
			#20; 
			
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
		.irq(irq),
		.trap(trap));
endmodule
