`timescale 1ns / 1ps
module controlunit_tb;
	// Inputs
    reg [4:0] opcode;
	reg [2:0] funct3;
	reg funct7;
	reg br_eq;
	reg br_lt;
    // Outputs
    wire pc_sel;
	wire [2:0] imm_sel;
	wire reg_wen;
	wire br_un;
	wire [1:0] a_sel;
	wire b_sel;
	wire [3:0] alu_sel;
	wire mem_rw;
	wire [1:0] wb_sel;
	wire trap;

   // Test clock 
   reg clk; // in this version we do not really need the clock

   // Expected outputs
    reg exp_pc_sel;
	reg [2:0] exp_imm_sel;
	reg exp_reg_wen;
	reg exp_br_un;
	reg [1:0] exp_a_sel;
	reg exp_b_sel;
	reg [3:0] exp_alu_sel;
	reg exp_mem_rw;
	reg [1:0] exp_wb_sel;
	reg exp_trap;

   // Vector and Error counts
   reg [10:0] vec_cnt, err_cnt;

   // Define an array called 'testvec' that is wide enough to hold the inputs:
   //   aluop, a, b  and the expected output
    reg [27:0] testvec [0:99-2];

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
		$readmemb("testbench/controlunit_testvec.txt", testvec);
		err_cnt=0; // number of errors
		vec_cnt=0; // number of vectors
	end
   // Tests
	always @ (posedge clk)		// trigger with the test clock
	begin
		// Wait 20 ns, so that we can safely apply the inputs
		#20; 

		// Assign the signals from the testvec array
		{opcode, funct3, funct7, br_eq, br_lt,exp_pc_sel,exp_imm_sel,exp_reg_wen,exp_br_un,exp_a_sel,exp_b_sel,exp_alu_sel,exp_mem_rw,exp_wb_sel,exp_trap} = testvec[vec_cnt]; 

		// Wait another 60ns after which we will be at 80ns
		#60; 

		// Check if output is not what we expect to see
		if ((pc_sel !== exp_pc_sel) | (imm_sel !== exp_imm_sel) | (reg_wen !== exp_reg_wen) | (br_un !== exp_br_un) | (a_sel !== exp_a_sel) | (b_sel !== exp_b_sel) | (alu_sel !== exp_alu_sel) | (mem_rw !== exp_mem_rw) | (wb_sel !== exp_wb_sel) | (trap !== exp_trap))

		begin                                         
			// Display message
$display("Error at %5d ns: opcode=%b funct3=%b funct7=%b br_eq=%b br_lt=%b",$time, opcode, funct3, funct7, br_eq, br_lt);
$display("    pc_sel=%b     imm_sel=%b     reg_wen=%b     br_un=%b     a_sel=%b     b_sel=%b     alu_sel=%b     mem_rw=%b     wb_sel=%b trap=%b",pc_sel,imm_sel,reg_wen,br_un,a_sel,b_sel,alu_sel,mem_rw,wb_sel,trap);
$display("exp_pc_sel=%b exp_imm_sel=%b exp_reg_wen=%b exp_br_un=%b exp_a_sel=%b exp_b_sel=%b exp_alu_sel=%b exp_mem_rw=%b exp_wb_sel=%b exp_trap=%b", exp_pc_sel,exp_imm_sel,exp_reg_wen,exp_br_un,exp_a_sel,exp_b_sel,exp_alu_sel,exp_mem_rw,exp_wb_sel, exp_trap);
			err_cnt = err_cnt + 1; // increment error count
		end

		vec_cnt = vec_cnt + 1; // next vector
	
		// We use === so that we can also test for X
		if ((testvec[vec_cnt][26:23] === 4'bxxxx))
		begin
			// End of test, no more entries...
			$display ("%d tests completed with %d errors: controlunit", vec_cnt, err_cnt);
			
			// Wait so that we can see the last result
			#20; 
			
			// Terminate simulation
			$finish;
		end
	end
   // Instantiate the Unit Under Test (UUT)
   controlunit dut(
	   .opcode(opcode),
	   .funct3(funct3),
	   .funct7(funct7),
       .br_eq(br_eq),
       .br_lt(br_lt),
       .pc_sel(pc_sel),
       .imm_sel(imm_sel),
       .reg_wen(reg_wen),
       .br_un(br_un),
       .a_sel(a_sel),
       .b_sel(b_sel),
       .alu_sel(alu_sel),
       .mem_rw(mem_rw),
       .wb_sel(wb_sel),
	   .trap(trap));
endmodule
