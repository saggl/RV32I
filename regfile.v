`timescale 1ns / 1ps
module regfile(
    input [4:0] a_rs1,
	output [31:0] rs1,
	input [4:0] a_rs2,
	output [31:0] rs2,
	input [4:0] a_rd,
	input [31:0] rd,
	input we, 
	input clk 
);

reg [31:0] regfile [31:0];  

assign rs1 = a_rs1!=0 ? regfile[a_rs1] : 0;
assign rs2 = a_rs2!=0 ? regfile[a_rs2] : 0;

always @(posedge clk) begin
	if (we)
		regfile[a_rd] <= rd;
end

endmodule
