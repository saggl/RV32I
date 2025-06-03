`timescale 1ns / 1ps
module controlunit(
	input [4:0] opcode,
	input [2:0] funct3,
	input funct7,
	input br_eq,
	input br_lt,
	output pc_sel,
	output [2:0] imm_sel,
	output reg_wen,
	output br_un,
	output [1:0] a_sel,
	output b_sel,
	output [3:0] alu_sel,
	output mem_rw,
	output [1:0] wb_sel,
	output trap
);

//////////////////////////////////////////////////////////////////////////////////
// interpretion of the opcode
localparam [4:0] LOAD = 5'b00000;
localparam [4:0] OP_IMM = 5'b00100;
localparam [4:0] AUIPC = 5'b00101;
localparam [4:0] STORE = 5'b01000;
localparam [4:0] OP = 5'b01100;
localparam [4:0] LUI = 5'b01101;
localparam [4:0] BRANCH = 5'b11000;
localparam [4:0] JALR = 5'b11001;
localparam [4:0] JAL = 5'b11011;

localparam [4:0] SYSTEM = 5'b11100;


// interpretion of funct3 in branch
localparam [2:0] BEQ = 3'b000;
localparam [2:0] BNE = 3'b001;
localparam [2:0] BLT = 3'b100;
localparam [2:0] BGE = 3'b101;
localparam [2:0] BLTU = 3'b110;
localparam [2:0] BGEU = 3'b111;


localparam [2:0] SRAI_SRLI = 3'b101;
//////////////////////////////////////////////////////////////////////////////////
// DEFINE THE MAIN CONTROL SIGNALS
// The control signals are mostly based on the table 7.5 on page 379
// Don't care statements have been mapped to '0' in most cases
//
// All signals are handled separately, see alternative for an example

wire branch_taken;
wire alu4_imm; // alu[4] if op_imm

// pc select					  
assign pc_sel = ((opcode == JALR) | (opcode == JAL) | branch_taken);

// is branch taken 
assign branch_taken = ((opcode == BRANCH) & (funct3 == BEQ) & br_eq) |
					  ((opcode == BRANCH) & (funct3 == BNE) & ~br_eq) | 
					  ((opcode == BRANCH) & (funct3 == BLT) & br_lt) |
					  ((opcode == BRANCH) & (funct3 == BLTU) & br_lt) |
					  ((opcode == BRANCH) & (funct3 == BGE) & ~br_lt) |
					  ((opcode == BRANCH) & (funct3 == BGEU) & ~br_lt);

// imm selcet
assign imm_sel = (opcode == STORE) ? 3'b001 : //S
				 (opcode == BRANCH) ? 3'b010 : //B
				 ((opcode == AUIPC) | (opcode == LUI)) ? 3'b011 : //U
				 (opcode == JAL) ? 3'b101 : //J
				 3'b000; //I

// We will write to registers when opcode is:
assign reg_wen = ~((opcode == STORE) | (opcode == BRANCH));

// branch unsigned 
assign br_un = (opcode == BRANCH) & funct3[1];

// Select the a input of the ALU
assign a_sel = (opcode == LUI) ? 2'b10 :
			   (opcode == AUIPC) | (opcode == BRANCH) | (opcode == JAL) ? 2'b01 :
			   2'b00;

// Select the b input of the ALU
assign b_sel = (opcode == OP);

// Bit 4 of alu_sel is funct7 if SLLI, SRAI or SRLI else 0 
assign alu4_imm = (funct3[2:0] == SRAI_SRLI) ? funct7 : 1'b0;

//alu select
assign alu_sel = (opcode == OP) ? {funct7, funct3[2:0]} : 
				 (opcode == OP_IMM) ? {alu4_imm, funct3[2:0]} : 
				 4'b0000; //add

// We wil write to memory when opcode is STORE
assign mem_rw = (opcode == STORE);

// Writeback select
assign wb_sel = (opcode == LOAD) ? 2'b00 : //mem
				((opcode == JALR) | (opcode == JAL)) ? 2'b10 :// pc+4
				2'b01; //alu

// We wil trigger trap when opcode is SYSTEM
assign trap = (opcode == SYSTEM); //ECALL and EBREAK
endmodule
