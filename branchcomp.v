`timescale 1ns / 1ps
module branchcomp (
    input [31:0] a, 
    input [31:0] b,
    input br_un,
    output br_eq,
	output br_lt
);

wire [31:0] b_n;
wire [31:0] addout;
wire cout;

assign br_eq = a == b;
assign b_n = ~b;
assign addout = a + b_n + 1;
assign br_lt = (a[31] == b[31]) ? addout[31] :
                (br_un) ? b[31] : 
                a[31];

endmodule
