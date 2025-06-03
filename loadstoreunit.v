`timescale 1ns / 1ps
module loadstoreunit(
    input [2:0] funct3,
    input [31:0] data_w, addr, data_rdata,
    input mem_rw,
    output [31:0] data_r, data_addr, data_wdata,
    output [3:0] data_we
);

// interpretion of funct3
localparam [1:0] LB_LBU = 2'b00;
localparam [1:0] LH_LHU = 2'b01;
localparam [1:0] LW = 2'b10;

localparam [1:0] SB = 2'b00;
localparam [1:0] SH = 2'b01;
localparam [1:0] SW = 2'b10;

localparam [1:0] BYTE_0 = 2'b00;
localparam [1:0] BYTE_1 = 2'b01;
localparam [1:0] BYTE_2 = 2'b10;
localparam [1:0] BYTE_3 = 2'b11;

// byte/halfword to load; signed/unsigned extention
wire [7:0] lb_sel;
wire [31:0] lb_s_u; 
wire [15:0] lh_sel;
wire [31:0] lh_s_u;

// byte/halfword to store
wire [3:0] we_sb_sel, we_sh_sel, we_sel;

// 32-bit address alignment
assign data_addr = {addr[31:2], 2'b0};

// select the addressed byte
assign lb_sel = (addr[1:0] == BYTE_0) ? data_rdata[7:0] :
                (addr[1:0] == BYTE_1) ? data_rdata[15:8] :
                (addr[1:0] == BYTE_2) ? data_rdata[23:16] :
                data_rdata[31:24]; //BYTE_3

// select signed or unsigned load
assign lb_s_u = funct3[2] ? {24'b0, lb_sel} : {{24{lb_sel[7]}}, lb_sel};

// select the addressed halfword
assign lh_sel = addr[1] ? data_rdata[31:16] : data_rdata[15:0];

// select signed or unsigned load
assign lh_s_u = funct3[2] ? {16'b0, lh_sel} : {{16{lh_sel[15]}}, lh_sel};

// final select lb,lh,lw data
assign data_r = (funct3[1:0] == LB_LBU) ? lb_s_u :
             (funct3[1:0] == LH_LHU) ? lh_s_u :
             data_rdata; //LW

//data to wirte
assign data_wdata = (funct3[1:0] == SB) ? {4{data_w[7:0]}} :
                    (funct3[1:0] == SH) ? {2{data_w[15:0]}} :
                    data_w; //SW


// select the addressed byte
assign we_sb_sel = (addr[1:0] == BYTE_0) ? 4'b0001 :
                   (addr[1:0] == BYTE_1) ? 4'b0010 :
                   (addr[1:0] == BYTE_2) ? 4'b0100 :
                   4'b1000; //BYTE_3

// select the addressed halfword
assign we_sh_sel = addr[1] ? 4'b1100 : 4'b0011;

// 
assign we_sel = (funct3[1:0] == SB) ? we_sb_sel :
                (funct3[1:0] == SH) ? we_sh_sel :
                4'b1111; //SW
//                
assign data_we = mem_rw ? we_sel : 4'b0000;

endmodule