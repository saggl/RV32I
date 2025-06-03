`timescale 1ns / 1ps
module rv32i(
   input clk,
	input reset,
   input  [31:0] inst_rdata,
   output [31:0] inst_addr,
   input [31:0] data_rdata,
   output [31:0] data_addr,
   output [31:0] data_wdata,
   output [3:0] data_we,
   output trap
);

// Instruction Decoding
wire [31:0] inst; // The output of the Instruction memory

// Address controls 
reg [31:0] pc; // The Program counter (registered)
wire [31:0] pc_next; // Next state value of the Program counter, PC' in the diagram
wire [31:0] pc_plus_4; // The current value of PC + 4, default next memory address

// regfile
wire [31:0] wb;
wire [31:0] rs1;
wire [31:0] rs2;
wire [4:0] a_rs1;

// Imm. Gen
wire [31:0] imm; 

// ALU related
wire [31:0] a; // One input of the ALU
wire [31:0] b; // Other input of the ALU
wire [31:0] alu; // The output of the ALU
	
// Data Memory
wire [31:0] mem; // End result that will be written back to register file
	
// Control Signals
wire pc_sel; // 0: pc+4, 1: alu
wire [2:0] imm_sel;
wire reg_wen;
wire br_un;
wire br_eq;
wire br_lt;
wire [1:0] a_sel; // 0: rs1, 1: pc, 2:zero
wire b_sel; // 0: rs2, 1: imm
wire [3:0] alu_sel;
wire mem_rw;
wire [1:0] wb_sel; // 0: mem, 1:alu, 2: pc+2

// The Main Part of the RV32I processor 

// The Program Counter
always @ (posedge clk) begin
	if (reset) pc <= 32'b0; // default program counter 
	else pc <= pc_next; // Copy next value to present
end

// Select next PC value
assign pc_plus_4 = pc + 4; 
assign pc_next = pc_sel ? alu : pc_plus_4;

// Instantiate the Instruction Memory
assign inst = inst_rdata;
assign inst_addr = pc;
										
// Imm. Gen
immgen i_imm (
   .imm_sel(imm_sel),
   .inst(inst[31:7]),
   .imm(imm));

//  Register File
regfile i_regf (
   .a_rs1(inst[19:15]),
   .a_rs2(inst[24:20]),
   .a_rd(inst[11:7]),
   .rs1(rs1),
   .rs2(rs2),
   .rd(wb),
   .we(reg_wen),
   .clk(clk));

// Branch Comp
branchcomp i_branchcomp(
   .a(rs1),
   .b(rs2),
   .br_un(br_un),
   .br_eq(br_eq),
   .br_lt(br_lt));

// alu
assign a = (a_sel == 2'b00) ? rs1 : 
           (a_sel == 2'b01) ? pc :
           32'b0;

assign b = b_sel ? rs2 : imm;

alu i_alu (
   .a(a),
   .b(b),
   .result(alu),
   .aluop(alu_sel));	

loadstoreunit i_lsu(
   .funct3(inst[14:12]),
   .data_r(mem),
   .addr(alu),
   .mem_rw(mem_rw),
   .data_w(rs2),
   .data_rdata(data_rdata),
   .data_addr(data_addr),
   .data_we(data_we),
   .data_wdata(data_wdata));

/// Select Writeback value
assign wb = (wb_sel == 2'b00) ? mem :
            (wb_sel == 2'b01) ? alu :
            pc_plus_4;

// The Control Unit
controlunit i_cont (
   .opcode(inst[6:2]),
	.funct3(inst[14:12]),
	.funct7(inst[30]),
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
