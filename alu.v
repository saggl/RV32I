`timescale 1ns / 1ps
module alu (
    input [31:0] a, b,
    input [3:0] aluop,
    output [31:0] result
);    
    wire [31:0] logicout; // output of the logic block
    wire [31:0] addout; // adder subtractor out
    wire [31:0] arithout; // output after alt
    wire [31:0] n_b; // inverted b
    wire [31:0] sel_b; // select b or n_b;
    wire [31:0] sltu_slt; // output of the slt extension
    wire [31:0] sll; // output shift left
    wire [32:0] shift_right; // output shift right
    wire cout; // carry out

/*
0 000 add 0
1 000 sub 8
0 001 sll 1
0 010 slt 2
0 011 sltu 3
0 100 xor 4
0 101 srl 5
1 101 sra 13
0 110 or 6
0 111 and 7
not used combos
9
10
11
12
14
15
*/
// shift right arith or logic
assign shift_right = $signed({(aluop[3]) ? a[31] : 1'b0, a[31:0]}) >>> b[4:0];

// logic xor, or, and
assign logicout = (aluop[1:0] == 2'b00) ? a ^ b :
                  (aluop[1:0] == 2'b10) ? a | b :
                  (aluop[1:0] == 2'b11) ? a & b :
                  shift_right[31:0];

// adder subtractor
assign n_b = ~b;

// select n_b for sub and slt
assign sel_b = (aluop[3] | aluop[1]) ? n_b : b;

// add or sub
assign addout = a + sel_b + {31'b0, (aluop[3] | aluop[1])};

// set less than unsigned or signed
assign sltu_slt = (a[31] == b[31]) ? {31'b0, addout[31]} :
                  (aluop[0]) ? {31'b0, b[31]} : 
                  {31'b0, a[31]};

// shift left
assign sll = a << b[4:0];

// arith out
assign arithout = (aluop[1:0] == 2'b00) ? addout :
                  (aluop[1:0] == 2'b01) ? sll :
                  sltu_slt;
// final out
assign result = (aluop[2]) ? logicout : arithout;

endmodule
