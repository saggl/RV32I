`timescale 1ns / 1ps
module csr(
    input clk,
    input reset,
    input [31:0] pc,
    input [31:0] inst,
    input [31:0] rs1,
    input [2:0] irq,
    input [31:0] reset_vector,
	output [31:0] csr,
    output csr_sel,
    output [31:0] pc_trap,
    output pc_trap_sel
);

// a_csr 
//Counters
localparam [11:0] CYCLE = 12'hC00;
//localparam [11:0] TIME = 12'hC01; RDTIME trap and in traphandler lw mtime
localparam [11:0] INSTRET = 12'hC02;
localparam [11:0] CYCLEH = 12'hC80;
//localparam [11:0] TIMEH = 12'hC81; RDTIME trap and in traphandler lw mtime
localparam [11:0] INSTRETH = 12'hC82;
//Machine Information Registers
localparam [11:0] MVENDORID = 12'hF11;
localparam [11:0] MARCHID = 12'hF12;
localparam [11:0] MIMPID = 12'hF13;
localparam [11:0] MHARTID = 12'hF14;
//Machine Trap Setup
localparam [11:0] MSTATUS = 12'h300;
localparam [11:0] MISA = 12'h301;
localparam [11:0] MIE = 12'h304;
localparam [11:0] MTVEC = 12'h305;
//Machine Trap Handling
localparam [11:0] MSCRATCH = 12'h340;
localparam [11:0] MEPC = 12'h341;
localparam [11:0] MCAUSE = 12'h342;
localparam [11:0] MTVAL = 12'h343;
localparam [11:0] MIP = 12'h344;
//Machine Counter / Timers
localparam [11:0] MCYCLE = 12'hB00;
localparam [11:0] MINSTRET = 12'hB02;
localparam [11:0] MHPMCOUNTER3 = 12'hB03;
localparam [11:0] MHPMCOUNTER4 = 12'hB04;
localparam [11:0] MHPMCOUNTER5 = 12'hB05;
localparam [11:0] MHPMCOUNTER6 = 12'hB06;
localparam [11:0] MHPMCOUNTER7 = 12'hB07;
localparam [11:0] MHPMCOUNTER8 = 12'hB08;
localparam [11:0] MHPMCOUNTER9 = 12'hB09;
localparam [11:0] MHPMCOUNTER10 = 12'hB0A;
localparam [11:0] MHPMCOUNTER11 = 12'hB0B;
localparam [11:0] MHPMCOUNTER12 = 12'hB0C;
localparam [11:0] MHPMCOUNTER13 = 12'hB0D;
localparam [11:0] MHPMCOUNTER14 = 12'hB0E;
localparam [11:0] MHPMCOUNTER15 = 12'hB0F;
localparam [11:0] MHPMCOUNTER16 = 12'hB10;
localparam [11:0] MHPMCOUNTER17 = 12'hB11;
localparam [11:0] MHPMCOUNTER18 = 12'hB12;
localparam [11:0] MHPMCOUNTER19 = 12'hB13;
localparam [11:0] MHPMCOUNTER20 = 12'hB14;
localparam [11:0] MHPMCOUNTER21 = 12'hB15;
localparam [11:0] MHPMCOUNTER22 = 12'hB16;
localparam [11:0] MHPMCOUNTER23 = 12'hB17;
localparam [11:0] MHPMCOUNTER24 = 12'hB18;
localparam [11:0] MHPMCOUNTER25 = 12'hB19;
localparam [11:0] MHPMCOUNTER26 = 12'hB1A;
localparam [11:0] MHPMCOUNTER27 = 12'hB1B;
localparam [11:0] MHPMCOUNTER28 = 12'hB1C;
localparam [11:0] MHPMCOUNTER29 = 12'hB1D;
localparam [11:0] MHPMCOUNTER30 = 12'hB1E;
localparam [11:0] MHPMCOUNTER31 = 12'hB1F;
localparam [11:0] MCYCLEH = 12'hB80;
localparam [11:0] MINSTRETH = 12'hB82;
localparam [11:0] MHPMCOUNTER3H = 12'hB83;
localparam [11:0] MHPMCOUNTER4H = 12'hB84;
localparam [11:0] MHPMCOUNTER5H = 12'hB85;
localparam [11:0] MHPMCOUNTER6H = 12'hB86;
localparam [11:0] MHPMCOUNTER7H = 12'hB87;
localparam [11:0] MHPMCOUNTER8H = 12'hB88;
localparam [11:0] MHPMCOUNTER9H = 12'hB89;
localparam [11:0] MHPMCOUNTER10H = 12'hB8A;
localparam [11:0] MHPMCOUNTER11H = 12'hB8B;
localparam [11:0] MHPMCOUNTER12H = 12'hB8C;
localparam [11:0] MHPMCOUNTER13H = 12'hB8D;
localparam [11:0] MHPMCOUNTER14H = 12'hB8E;
localparam [11:0] MHPMCOUNTER15H = 12'hB8F;
localparam [11:0] MHPMCOUNTER16H = 12'hB90;
localparam [11:0] MHPMCOUNTER17H = 12'hB91;
localparam [11:0] MHPMCOUNTER18H = 12'hB92;
localparam [11:0] MHPMCOUNTER19H = 12'hB93;
localparam [11:0] MHPMCOUNTER20H = 12'hB94;
localparam [11:0] MHPMCOUNTER21H = 12'hB95;
localparam [11:0] MHPMCOUNTER22H = 12'hB96;
localparam [11:0] MHPMCOUNTER23H = 12'hB97;
localparam [11:0] MHPMCOUNTER24H = 12'hB98;
localparam [11:0] MHPMCOUNTER25H = 12'hB99;
localparam [11:0] MHPMCOUNTER26H = 12'hB9A;
localparam [11:0] MHPMCOUNTER27H = 12'hB9B;
localparam [11:0] MHPMCOUNTER28H = 12'hB9C;
localparam [11:0] MHPMCOUNTER29H = 12'hB9D;
localparam [11:0] MHPMCOUNTER30H = 12'hB9E;
localparam [11:0] MHPMCOUNTER31H = 12'hB9F;
//Machine Counter Setup
localparam [11:0] MCOUNTINHIBIT = 12'h320;
localparam [11:0] MHPMEVENT3 = 12'h323;
localparam [11:0] MHPMEVENT4 = 12'h324;
localparam [11:0] MHPMEVENT5 = 12'h325;
localparam [11:0] MHPMEVENT6 = 12'h326;
localparam [11:0] MHPMEVENT7 = 12'h327;
localparam [11:0] MHPMEVENT8 = 12'h328;
localparam [11:0] MHPMEVENT9 = 12'h329;
localparam [11:0] MHPMEVENT10 = 12'h32A;
localparam [11:0] MHPMEVENT11 = 12'h32B;
localparam [11:0] MHPMEVENT12 = 12'h32C;
localparam [11:0] MHPMEVENT13 = 12'h32D;
localparam [11:0] MHPMEVENT14 = 12'h32E;
localparam [11:0] MHPMEVENT15 = 12'h32F;
localparam [11:0] MHPMEVENT16 = 12'h330;
localparam [11:0] MHPMEVENT17 = 12'h331;
localparam [11:0] MHPMEVENT18 = 12'h332;
localparam [11:0] MHPMEVENT19 = 12'h333;
localparam [11:0] MHPMEVENT20 = 12'h334;
localparam [11:0] MHPMEVENT21 = 12'h335;
localparam [11:0] MHPMEVENT22 = 12'h336;
localparam [11:0] MHPMEVENT23 = 12'h337;
localparam [11:0] MHPMEVENT24 = 12'h338;
localparam [11:0] MHPMEVENT25 = 12'h339;
localparam [11:0] MHPMEVENT26 = 12'h33A;
localparam [11:0] MHPMEVENT27 = 12'h33B;
localparam [11:0] MHPMEVENT28 = 12'h33C;
localparam [11:0] MHPMEVENT29 = 12'h33D;
localparam [11:0] MHPMEVENT30 = 12'h33E;
localparam [11:0] MHPMEVENT31 = 12'h33F;

// interpretion of the opcode
localparam [4:0] SYSTEM = 5'b11100;

// inst decoding
wire [4:0] opcode;
wire [11:0] a_csr;
wire [2:0] funct3;
wire [4:0] a_rs1_uimm;
wire [4:0] a_rd;

assign opcode = inst[6:2];
assign a_csr = inst[31:20];
assign funct3 = inst[14:12];
assign a_rs1_uimm = inst[19:15];
assign a_rd = inst[11:7];

// select read csr value
assign csr_sel = (opcode == SYSTEM) & |funct3;

// select pc
assign pc_trap_sel = exception | interrupt | trap_ret;
assign pc_trap = trap_ret ? mepc : 
                 exception ? mtvec_ext :
                 interrupt & mtvec[0] ? mtvec_ext + mcause << 2 :
                 mtvec_ext;

wire trap_ret;
assign trap_ret = (opcode == SYSTEM) & (funct3 == PRIV) & (funct12 == MRET);
wire [31:0] mtvec_ext;
assign mtvec_ext = {mtvec[31:2], 2'b00};

//Chapter 9: “Zicsr”, Control and Status Register (CSR) Instructions, Version 2.0
wire [31:0] uimm_rs1;
wire [31:0] w_data;
wire read_en;
wire write_en;
// select immediate or register operand
assign uimm_rs1 = funct3[2] ? {{27'b0, a_rs1_uimm} : rs1;
// select data write, set or clear
assign w_data = (funct3[1:0] == 2'b01) ? uimm_rs1 :
                (funct3[1:0] == 2'b10) ? r_data | uimm_rs1 :
                r_data & ~uimm_rs1;
//CSRRW[I], if rd=x0, then the instruction shall not read the CSR and shall not cause any of the side effects that might occur on a CSR read.
assign read_en = ~(~funct3[1] & a_rd == 5'b0);
//CSRRS/C[I], if rs1=x0, then the instruction will not write to the CSR at all, and so shall not cause any of the side effects that might otherwise occur on a CSR write, such as raising illegal instruction exceptions on accesses to read-only CSRs
assign write_en = ~(funct3[1] & a_rs1_uimm == 5'b0) & csr_wen;

//the top two bits (csr[11:10]) indicate whether the register is read/write (00, 01, or 10) or read-only (11)
assign read_only = a_csr[11:10] == 2'b11;

//The next two bits (csr[9:8]) encode the lowest privilege level that can access the CSR.
assign lpl = a_csr[9:8];

//1. 0x7B0–0x7BF are only visible to debug mode. Implementations should raise illegal instruction exceptions on machine-mode access to the latter set of registers and attempts to access a non-existent CSR raise an illegal instruction exception. 
//2. Attempts to access a CSR without appropriate privilege level or to write a read-only register also raise illegal instruction exceptions. 
assign illegal_exception = /*todo: non-existen CSR*/ (current_pl < lpl) | (read_only & write_en);

//csr read 
always @* begin
    case(a_csr)
        CYCLE: csr = mcycle[31:0];
        CYCLEH: csr = mcycle[63:32];
        //TIME: csr = mcycle[31:0]; RDTIME trap and in traphandler lw mtime
        //TIMEH: csr = mcycle[63:32]; RDTIMEh trap and in traphandler lw mtimeh
        INSTRET: csr = minstret[31:0];
        INSTRETH: csr = minstret[63:32];
        MVENDORID: csr = mvendorid;
        MARCHID: csr = marchid;
        MIMPID: csr = mimpid;
        MHARTID: csr = mhartid;
        MSTATUS: csr = mstatus;
        MISA: csr = misa;
        MIE: csr = mie;
        MTVEC: csr = mtvec;
        MSCRATCH: csr = mscratch;
        MEPC: csr = mepc;
        MCAUSE: csr = mcause;
        MTVAL: csr = mtval;
        MIP: csr = mip;
        MCYCLE: csr = mcycle[31:0];
        MHPMCOUNTER3: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER4: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER5: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER6: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER7: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER8: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER9: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER10: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER11: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER12: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER13: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER14: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER15: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER16: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER17: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER18: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER19: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER20: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER21: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER22: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER23: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER24: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER25: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER26: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER27: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER28: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER29: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER30: csr = mhpmcounter3_31[31:0];
        MHPMCOUNTER31: csr = mhpmcounter3_31[31:0];

        MHPMCOUNTER3H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER4H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER5H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER6H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER7H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER8H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER9H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER10H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER11H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER12H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER13H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER14H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER15H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER16H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER17H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER18H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER19H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER20H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER21H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER22H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER23H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER24H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER25H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER26H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER27H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER28H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER29H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER30H: csr = mhpmcounter3_31[63:32];
        MHPMCOUNTER31H: csr = mhpmcounter3_31[63:32];
        MCYCLEH: csr = mcycle[63:32];
        MINSTRET: csr = minstret[31:0];
        MINSTRETH: csr = minstret[63:32];
        MCOUNTINHIBIT: csr = mcountinhibit;

        MHPMEVENT3: csr = mhpmevent3_31;
        MHPMEVENT4: csr = mhpmevent3_31;
        MHPMEVENT5: csr = mhpmevent3_31;
        MHPMEVENT6: csr = mhpmevent3_31;
        MHPMEVENT7: csr = mhpmevent3_31;
        MHPMEVENT8: csr = mhpmevent3_31;
        MHPMEVENT9: csr = mhpmevent3_31;
        MHPMEVENT10: csr = mhpmevent3_31;
        MHPMEVENT11: csr = mhpmevent3_31;
        MHPMEVENT12: csr = mhpmevent3_31;
        MHPMEVENT13: csr = mhpmevent3_31;
        MHPMEVENT14: csr = mhpmevent3_31;
        MHPMEVENT15: csr = mhpmevent3_31;
        MHPMEVENT16: csr = mhpmevent3_31;
        MHPMEVENT17: csr = mhpmevent3_31;
        MHPMEVENT18: csr = mhpmevent3_31;
        MHPMEVENT19: csr = mhpmevent3_31;
        MHPMEVENT20: csr = mhpmevent3_31;
        MHPMEVENT21: csr = mhpmevent3_31;
        MHPMEVENT22: csr = mhpmevent3_31;
        MHPMEVENT23: csr = mhpmevent3_31;
        MHPMEVENT24: csr = mhpmevent3_31;
        MHPMEVENT25: csr = mhpmevent3_31;
        MHPMEVENT26: csr = mhpmevent3_31;
        MHPMEVENT27: csr = mhpmevent3_31;
        MHPMEVENT28: csr = mhpmevent3_31;
        MHPMEVENT29: csr = mhpmevent3_31;
        MHPMEVENT30: csr = mhpmevent3_31;
        MHPMEVENT31: csr = mhpmevent3_31;
        default:
            csr = 32'b0;
    endcase
end

// interpretion of the opcode
localparam [4:0] SYSTEM = 5'b11100;


//Machine ISA Register misa
wire [31:0] misa;
wire [1:0] mxl;
wire [25:0] ext;
assign misa = {mxl, 3'b0, ext};
assign [1:0] mxl = 2'b1; // fix XLEN = 32
assign [25:0] ext = 26'b100000000 // only I 

//Machine Vendor ID Register mvendorid
//This register must be readable in any implementation, but a value of 0 can be returned to indicate the field is not implemented or that this is a non-commercial implementation.
wire [31:0] mvendorid;
assign mvendorid = 32'b0;

//Machine Architecture ID Register marchid
//This register must be readable in any implementation, but a value of 0 can be returned to indicate the field is not implemented.
wire [31:0] marchid;
assign marchid  = 32'b0;

//Machine Implementation ID Register mimpid
//This register must be readable in any implementation, but a value of 0 can be returned to indicate that the field is not implemented.
wire [31:0] mimpid;
assign mimpid  = 32'b0;

//Hart ID Register mhartid
wire [31:0] mhartid;
assign mhartid  = 32'b0;

//Machine Status Registers (mstatus and mstatush)
wire [31:0] mstatus;
wire [31:0] mstatush;
wire SIE, SPIE, UBE, SPP, MPRV, SUM, MXR, TVM, TW, TSR, SD, SBE, MBE;
wire [1:0] MPP, FS, XS;
reg MIE_; //Global interrupt-enable bit
reg MPIE; //holds the value of the interrupt-enable bit active prior to the trap, and MPP holds the previous privilege mode.

assign SIE = 1'b0;
assign SPIE = 1'b0;
assign UBE = 1'b0;
assign SPP = 1'b0;
assign MPRV = 1'b0;
assign SUM = 1'b0;
assign MXR = 1'b0;
assign TVM = 1'b0;
assign TW = 1'b0;
assign TSR = 1'b0;
assign SD = 1'b0;
assign MPP = 2'b11;
assign FS = 2'b00;
assign XS = 2'b00;
assign mstatus = {SD, 8'b0, TSR, TW, TVM, MXR, SUM MPRV, XS, FS, MPP, SPP, MPIE, UBE, SPIE, MIE_, SIE};
assign mstatush = {26'b0, MBE, SBE, 4'b0};

always @(posedge clk) begin
	if (reset) begin
        MIE_ <= 1'b0;
    end
    else if (write_en & a_csr == MSTATUS) begin
        MIE_ <= w_data[3];
        MPIE <= w_data[7];
    end
    //When a trap is taken from privilege mode y into privilege mode x, xPIE is set to the value of xIE; xIE is set to 0; and xPP is set to y.
    else if (trap) begin
        MPIE <= MIE_;
        MIE_ <= 1'b0;
    end
    //An MRET instruction is used to return from a trap in M-mode. When executing an MRET instruction MIE is set to MPIE, MPIE is set to 1.
    else if (trap_ret) begin
        MIE_ <= MPIE;
        MPIE <= 1'b1;
    end
end

//Machine Trap-Vector Base-Address Register (mtvec)
wire [31:0] mtvec;
reg [1:0] MODE;
reg [29:0] BASE;
assign mtvec = {BASE, MODE};

always @(posedge clk) begin
	if (reset) begin
        MODE <= 2'b0;
        BASE <= 30'b0;
    end
    else if (write_en & a_csr == MTVEC) begin
        MODE <= w_data[1:0];
        BASE <= w_data[31:2];
    end
end

//When MODE=Direct, all traps into machine mode cause the pc to be set to the address in the BASE field. When MODE=Vectored, all synchronous exceptions into machine mode cause the pc to be set to the address in the BASE field, whereas interrupts cause the pc to be set to the address in the BASE field plus four times the interrupt cause number.

//Machine Interrupt Registers (mip and mie)
wire [31:0] mip; //containing information on pending interrupts
wire [31:0] mie; //containing interrupt enable bits
wire MEIP, SEIP, MTIP, STIP, MSIP, SSIP;
reg MEIE, MTIE, MSIE;
wire SEIE, STIE, SSIE;
assign SEIP = 1'b0;
assign STIP = 1'b0;
assign SSIP = 1'b0;
assign SEIE = 1'b0;
assign STIE = 1'b0;
assign SSIE = 1'b0;
assign mip = {4'b0, MEIP, 1'b0, SEIP, 1'b0, MTIP, 1'b0, STIP, 1'b0, MSIP, 1'b0, SSIP, 1'b0};
assign mie = {4'b0, MEIE, 1'b0, SEIE, 1'b0, MTIE, 1'b0, STIE, 1'b0, MSIE, 1'b0, SSIE, 1'b0};

//Bits mip.MEIP and mie.MEIE are the interrupt-pending and interrupt-enable bits for machine- level external interrupts. MEIP is read-only in mip, and is set and cleared by a platform-specific interrupt controller.
assign MEIP = irq[2]; /*platform-specific interrupt controller*/
always @(posedge clk) begin
	if (reset) MEIE <= 1'b0;
    else (write_en & a_csr == MIE) MEIE <= w_data[11];
end

//Bits mip.MTIP and mie.MTIE are the interrupt-pending and interrupt-enable bits for machine timer interrupts. MTIP is read-only in mip, and is cleared by writing to the memory-mapped machine-mode timer compare register.
assign MTIP = irq[1]; /*platform-specific interrupt controller*/
always @(posedge clk) begin
	if (reset) MTIE <= 1'b0;
    else (write_en & a_csr == MIE) MTIE <= w_data[7];
end

//Bits mip.MSIP and mie.MSIE are the interrupt-pending and interrupt-enable bits for machine- level software interrupts. MSIP is read-only in mip, and is written by accesses to memory-mapped control registers, which are used by remote harts to provide machine-level interprocessor interrupts. A hart can write its own MSIP bit using the same memory-mapped control register.
assign MSIP = irq[0]; /*platform-specific interrupt controller*/
always @(posedge clk) begin
	if (reset) MSIE <= 1'b0;
    else (write_en & a_csr == MIE) MSIE <= w_data[3];
end

//An interrupt i will be taken if bit i is set in both mip and mie, and if interrupts are globally enabled. By default, M-mode interrupts are globally enabled if the hart’s current privilege mode is less than M, or if the current privilege mode is M and the MIE bit in the mstatus register is set.
wire interrupt;
assign interrupt = |(mip & mie) & MIE_;

//The non-maskable interrupt is not made visible via the mip register as its presence is implicitly known when executing the NMI trap handler

//Interrupt cause number i (as reported in CSR mcause, Section 3.1.15) corresponds with bit i in both mip and mie.

//Multiple simultaneous interrupts destined for different privilege modes are handled in decreasing order of destined privilege mode. Multiple simultaneous interrupts destined for the same privilege mode are handled in the following decreasing priority order: MEI, MSI, MTI. Synchronous exceptions are of lower priority than all interrupts.

//Hardware Performance Monitor

reg [63:0] mcycle;
always @(posedge clk) begin
	if (reset) mcycle <= 64'b0;
    else if (write_en & a_csr == MCYCLE) mcycle[31:0] <= w_data;
    else if (write_en & a_csr == MCYCLEH) mcycle[63:32] <= w_data;
    else if (~CY) mcycle <= mcycle + 1;
end

reg [63:0] minstret;
always @(posedge clk) begin
	if (reset) minstret <= 64'b0;
    else if (write_en & a_csr == MINSTRET) minstret[31:0] <= w_data;
    else if (write_en & a_csr == MINSTRETH) minstret[63:32] <= w_data;
    else if (~IR) minstret <= minstret + 1;
end

//All counters should be implemented, but a legal implementation is to hard-wire both the counter and its corresponding event selector to 0.
wire [63:0] mhpmcounter3_31;
assign mhpmcounter3_31 = 64'b0;
wire [31:0] mhpmevent3_31;
assign mhpmevent3_31 0 32'b0;

//Machine Counter-Inhibit CSR (mcountinhibit)
wire [31:0] mcountinhibit;
reg IR, CY;
assign mcountinhibit = {29'b1, IR, 1'b0, CY} //HPM31-HPM3 = 1

always @(posedge clk) begin
	if (reset) begin
        IR <= 1'b0;
        CY <= 1'b0;
    end
    else (write_en & a_csr == MCOUNTINHIBIT) begin
        IR <= w_data[2];
        CY <= w_data[0];
    end
end

//Machine Scratch Register (mscratch)
reg [31:0] mscratch;
always @(posedge clk) begin
	if (reset) mscratch <= 32'b0;
    else  (write_en & a_csr == MSCRATCH) mscratch <= w_data;
end

//Machine Exception Program Counter (mepc)
reg [31:0] mepc;

always @(posedge clk) begin
	if (reset) mepc_ <= 32'b0;
    else if (write_en & a_csr == MEPC) mepc <= {w_data[31:2], 2'b0};
    //When a trap is taken into M-mode, mepc is written with the virtual address of the instruction that was interrupted or that encountered the exception.
    else if (trap) mepc_[31:0] <= {pc[31:2], 2'b0};
end

//Machine Cause Register (mcause)
reg [31:0] mcause;

always @(posedge clk) begin
	if (reset) mcause <= 32'b0;
    else if (write_en & a_csr == MCAUSE) mcause <= w_data;
    //When a trap is taken into M-mode, mcause is written with a code indicating the event that caused the trap.
    else if (trap) mcause <= /*trap cause*/;
end
//The Interrupt bit in the mcause register is set if the trap was caused by an interrupt. The Exception Code field contains a code identifying the last exception or interrupt.

//Machine Trap Value Register (mtval)
reg [31:0] mtval;

always @(posedge clk) begin
	if (reset) mtval <= 32'b0;
    else if (write_en & a_csr == MTVAL) mtval <= w_data;
    //When a trap is taken into M-mode, mtval is either set to zero or written with exception-specific information to assist software in handling the trap.
    else if (trap) mtval <= /**/;
end


//When a breakpoint, address-misaligned, access-fault, or page-fault exception occurs on an instruc- tion fetch, load, or store, mtval is written with the faulting virtual address. On an illegal instruction trap, mtval may be written with the first XLEN or ILEN bits of the faulting instruction as de- scribed below. For other traps, mtval is set to zero, but a future standard may redefine mtval’s setting for other traps.

//For misaligned loads and stores that cause access-fault or page-fault exceptions, mtval will contain the virtual address of the portion of the access that caused the fault. For instruction access-fault or page-fault exceptions on systems with variable-length instructions, mtval will contain the virtual address of the portion of the instruction that caused the fault while mepc will point to the beginning of the instruction.

//more too read.....



//Machine-Level Memory-Mapped Registers
//Machine Timer Registers (mtime and mtimecmp)

//A machine timer interrupt becomes pending whenever mtime contains a value greater than or equal to mtimecmp, treating the values as unsigned integers. The interrupt remains posted until mtimecmp becomes greater than mtime (typically as a result of writing mtimecmp). The interrupt will only be taken if interrupts are enabled and the MTIE bit is set in the mie register.



endmodule
