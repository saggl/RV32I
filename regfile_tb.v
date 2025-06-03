`timescale 1ns / 1ps
module regfile_tb;
	// Inputs
   reg [4:0] a_rs1;
   reg [4:0] a_rs2;
   reg [4:0] a_rd;
   reg [31:0] rd;
   reg we;


   // Outputs
    wire [31:0] rs1;
    wire [31:0] rs2;

   // Test clock 
   reg clk ; // in this version we do not really need the clock

   // Expected outputs
    reg [31:0] exp_rs1;
    reg [31:0] exp_rs2;

   // Vector and Error counts
   reg [10:0] vec_cnt, err_cnt;

   // Define an array called 'testvec' that is wide enough to hold the inputs:
   //   aluop, a, b  and the expected output
	reg [111:0] testvec [0:9-2];

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
		$readmemh("testbench/regfile_testvec.txt", testvec);
		err_cnt=0; // number of errors
		vec_cnt=0; // number of vectors
	end
   // Tests
	always @ (posedge clk)		// trigger with the test clock
	begin
		// Wait 20 ns, so that we can safely apply the inputs
		#20; 

		// Assign the signals from the testvec array
		{a_rs1, a_rs2, a_rd, we, rd, exp_rs1, exp_rs2} = testvec[vec_cnt]; 

		// Wait another 60ns after which we will be at 80ns
		#60; 

		// Check if output is not what we expect to see
		if ((rs1 !== exp_rs1) | (rs2 !== exp_rs2))
		begin                                         
			// Display message
			$display("Error at %5d ns: a_rs1=%h a_rs2=%h a_rd=%h rd=%h we=%h rs1=%h rs2=%h exp_rs1=%h exp_rs2=%h", $time, a_rs1, a_rs2, a_rd, rd, we, rs1, rs2, exp_rs1, exp_rs2);
			err_cnt = err_cnt + 1; // increment error count
		end

		vec_cnt = vec_cnt + 1;																	// next vector
	
		// We use === so that we can also test for X
		if ((testvec[vec_cnt][111:108] === 4'bxxxx))
		begin
			// End of test, no more entries...
			$display ("%d tests completed with %d errors: regfile", vec_cnt, err_cnt);
			
			// Wait so that we can see the last result
			#20; 
			
			// Terminate simulation
			$finish;
		end
	end
   // Instantiate the Unit Under Test (UUT)
   regfile dut(
	   .a_rs1(a_rs1),
	   .rs1(rs1),
	   .a_rs2(a_rs2),
       .rs2(rs2),
	   .a_rd(a_rd),
       .rd(rd),
       .we(we),
       .clk(clk));
endmodule
