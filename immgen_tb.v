`timescale 1ns / 1ps
module immgen_tb;
	// Inputs
   reg [2:0] imm_sel;
   reg [31:7] inst;
   
   // Outputs
   wire [31:0] imm;
   // Test clock 
   reg clk ; // in this version we do not really need the clock

   // Expected outputs
   reg [31:0] exp_imm;

   // Vector and Error counts
   reg [10:0] vec_cnt, err_cnt;


   // Define an array called 'testvec' that is wide enough to hold the inputs:
   //   aluop, a, b  and the expected output
	reg [60:0] testvec [0:20-2];

   // The test clock generation
   always				// process always triggers
	begin
		clk=1; #50;		// clk is 1 for 50 ns 
		clk=0; #50;		// clk is 0 for 50 ns
	end					// generate a 100 ns clock

   // Initialization
	initial
	begin
		// Read the content of the file testvectors_hex.txt into the 
		// array testvec. 
		$readmemb("testbench/immgen_testvec.txt", testvec);
		err_cnt=0; // number of errors
		vec_cnt=0; // number of vectors
	end
   // Tests
	always @ (posedge clk)		// trigger with the test clock
	begin
		// Wait 20 ns, so that we can safely apply the inputs
		#20; 

		// Assign the signals from the testvec array
		{imm_sel, inst, exp_imm} = testvec[vec_cnt]; 

		// Wait another 60ns after which we will be at 80ns
		#60; 

		// Check if output is not what we expect to see
		if (imm !== exp_imm)
		begin                                         
			// Display message
			$display("Error at %5d ns: imm_sel=%h inst=%h imm=%h exp_imm=%h", $time, imm_sel, inst, imm,  exp_imm);	// %h displays hex
			err_cnt = err_cnt + 1; // increment error count
		end

		vec_cnt = vec_cnt + 1; // next vector
	
		// We use === so that we can also test for X
		if ((testvec[vec_cnt][60:57] === 4'bxxxx))
		begin
			// End of test, no more entries...
			$display ("%d tests completed with %d errors: immgen", vec_cnt, err_cnt);
			
			// Wait so that we can see the last result
			#20; 
			
			// Terminate simulation
			$finish;
		end
	end
   // Instantiate the Unit Under Test (UUT)
   immgen dut(
	   .imm_sel(imm_sel),
	   .inst(inst),
	   .imm(imm));
endmodule
