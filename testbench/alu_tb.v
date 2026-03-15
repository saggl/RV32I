`timescale 1ns / 1ps
module alu_tb;
	// Inputs
   reg [31:0] a;
   reg [31:0] b;
   reg [3:0] aluop;

   // Outputs
   wire [31:0] result;
   // Test clock 
   reg clk ; // in this version we do not really need the clock

   // Expected outputs
   reg [31:0] exp_result;

   // Vector and Error counts
   reg [10:0] vec_cnt, err_cnt;


   // Define an array called 'testvec' that is wide enough to hold the inputs:
   //   aluop, a, b  and the expected output
	reg [99:0] testvec [0:27];

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
		$readmemh("testbench/alu_testvec.txt", testvec);
		err_cnt=0; // number of errors
		vec_cnt=0; // number of vectors
	end
   // Tests
	always @ (posedge clk)		// trigger with the test clock
	begin
		// Wait 20 ns, so that we can safely apply the inputs
		#20; 

		// Assign the signals from the testvec array
		{aluop,a,b,exp_result} = testvec[vec_cnt]; 

		// Wait another 60ns after which we will be at 80ns
		#60; 

		// Check if output is not what we expect to see
		if (result !== exp_result)
		begin                                         
			// Display message
			$display("Error at %5d ns: Aluop %b a=%h b=%h result=%h (%h expected)", $time, aluop,a,b,result,exp_result);	// %h displays hex
			err_cnt = err_cnt + 1;																// increment error count
		end

		vec_cnt = vec_cnt + 1;																	// next vector
	
		// We use === so that we can also test for X
		if ((testvec[vec_cnt][99:96] === 4'bxxxx))
		begin
			// End of test, no more entries...
			$display ("%d tests completed with %d errors: alu", vec_cnt, err_cnt);
			
			// Wait so that we can see the last result
			#20; 
			
			// Terminate simulation
			$finish;
		end
	end
   // Instantiate the Unit Under Test (UUT)
   alu dut(
	   .a(a),
	   .b(b),
	   .aluop(aluop),
	   .result(result));
endmodule
