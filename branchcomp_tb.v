`timescale 1ns / 1ps
module branchcomp_tb;
	// Inputs
    reg [31:0] a;
    reg [31:0] b;
    reg br_un;

    // Outputs
    wire br_eq;
	wire br_lt;

    reg [2:0] tmp0,tmp1,tmp2;
   // Test clock 
   reg clk ; // in this version we do not really need the clock

   // Expected outputs
   reg exp_br_eq, exp_br_lt;

   // Vector and Error counts
   reg [10:0] vec_cnt, err_cnt;

   // Define an array called 'testvec' that is wide enough to hold the inputs:
   //   aluop, a, b  and the expected output
	reg [75:0] testvec [0:17];

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
		$readmemh("testbench/branchcomp_testvec.txt", testvec);
		err_cnt=0; // number of errors
		vec_cnt=0; // number of vectors
	end
   // Tests
	always @ (posedge clk)		// trigger with the test clock
	begin
		// Wait 20 ns, so that we can safely apply the inputs
		#20; 

		// Assign the signals from the testvec array
		{tmp0, br_un, a, b, tmp1, exp_br_eq, tmp2, exp_br_lt} = testvec[vec_cnt]; 

		// Wait another 60ns after which we will be at 80ns
		#60; 

		// Check if output is not what we expect to see
		if ((br_eq !== exp_br_eq) | (br_lt !== exp_br_lt))
		begin                                         
			// Display message
			$display("Error at %5d ns: br_un %b a=%h b=%h br_eq=%b br_lt=%b exp_br_eq=%b exp_br_lt=%b", $time, br_un,a,b,br_eq,br_lt,exp_br_eq,exp_br_lt);
			err_cnt = err_cnt + 1; // increment error count
		end

		vec_cnt = vec_cnt + 1; // next vector
	
		// We use === so that we can also test for X
		if ((testvec[vec_cnt][75:72] === 4'bxxxx))
		begin
			// End of test, no more entries...
			$display ("%d tests completed with %d errors: branchcomp", vec_cnt, err_cnt);
			
			// Wait so that we can see the last result
			#20; 
			
			// Terminate simulation
			$finish;
		end
	end
   // Instantiate the Unit Under Test (UUT)
   branchcomp dut(
	   .a(a),
	   .b(b),
	   .br_un(br_un),
       .br_eq(br_eq),
       .br_lt(br_lt));
endmodule
