`timescale 1ns / 1ps
module branchcomp (
    input [31:0] a, 
    input [31:0] b,
    input br_un,
    output br_eq,
	output br_lt
);

wire [31:0] b_n;
/* verilator lint_off UNUSEDSIGNAL */
wire [31:0] addout; // only MSB (sign bit) is used for comparison
/* verilator lint_on UNUSEDSIGNAL */

assign br_eq = a == b;
assign b_n = ~b;
assign addout = a + b_n + 1;
assign br_lt = (a[31] == b[31]) ? addout[31] :
                (br_un) ? b[31] : 
                a[31];

endmodule
