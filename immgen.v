`timescale 1ns / 1ps
module immgen(
  input [2:0] imm_sel,
  input [31:7] inst,
  output [31:0] imm
);

assign imm = (imm_sel == 3'b000) ? {{21{inst[31]}}, inst[30:20]} : //I
             (imm_sel == 3'b001) ? {{21{inst[31]}}, inst[30:25], inst[11:7]} : //S
             (imm_sel == 3'b010) ? {{20{inst[31]}}, inst[7], inst[30:25],inst[11:8], 1'b0}  : //B
             (imm_sel == 3'b011) ? {inst[31], inst[30:12], 12'b0} : //U
             {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}; //J

endmodule