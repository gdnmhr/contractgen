/*
 * Copyright (c) 2018, Marcelo Samsoniuk
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

`timescale 1ns / 1ps

`define JAL_OP		7'b1101111
`define JALR_OP		7'b1100111
`define BEQ_OP		7'b1100011
`define BNE_OP		7'b1100011
`define BLT_OP		7'b1100011
`define BGE_OP		7'b1100011
`define BLTU_OP		7'b1100011
`define BGEU_OP		7'b1100011

`define BEQ_FUNCT_3		3'b000
`define BNE_FUNCT_3		3'b001
`define BLT_FUNCT_3		3'b100
`define BGE_FUNCT_3		3'b101
`define BLTU_FUNCT_3	3'b110
`define BGEU_FUNCT_3	3'b111

// implemented opcodes:

`define LUI     7'b01101_11      // lui   rd,imm[31:12]
`define AUIPC   7'b00101_11      // auipc rd,imm[31:12]
`define JAL     7'b11011_11      // jal   rd,imm[xxxxx]
`define JALR    7'b11001_11      // jalr  rd,rs1,imm[11:0] 
`define BCC     7'b11000_11      // bcc   rs1,rs2,imm[12:1]
`define LCC     7'b00000_11      // lxx   rd,rs1,imm[11:0]
`define SCC     7'b01000_11      // sxx   rs1,rs2,imm[11:0]
`define MCC     7'b00100_11      // xxxi  rd,rs1,imm[11:0]
`define RCC     7'b01100_11      // xxx   rd,rs1,rs2 
`define MAC     7'b11111_11      // mac   rd,rs1,rs2

// not implemented opcodes:

`define FCC     7'b00011_11      // fencex
`define CCC     7'b11100_11      // exx, csrxx

// configuration file

`include "config_2stages.vh"

module darkriscv_2stages
//#(
//    parameter [31:0] RESET_PC = 0,
//    parameter [31:0] RESET_SP = 4096
//) 
(
    input             CLK,   // clock
    input             RES,   // reset
    input             HLT,   // halt
    
`ifdef __THREADS__    
    output [`__THREADS__-1:0] TPTR,  // thread pointer
`endif    

    input      [31:0] IDATA, // instruction data bus
    output     [31:0] IADDR, // instruction addr bus
    
    input      [31:0] DATAI, // data bus (input)
    output     [31:0] DATAO, // data bus (output)
    output     [31:0] DADDR, // addr bus

`ifdef __FLEXBUZZ__
    output     [ 2:0] DLEN, // data length
    output            RW,   // data read/write
`else    
    output     [ 3:0] BE,   // byte enable
    output            WR,    // write enable
    output            RD,    // read enable 
`endif    

    output            IDLE,   // idle output
    
    output [3:0]  DEBUG,       // old-school osciloscope based debug! :)

    output FLUSH,

  	output        rvfi_valid,
    output [63:0] rvfi_order,
    output [31:0] rvfi_insn,
    output        rvfi_trap,
    output        rvfi_halt,
    output        rvfi_intr,
    output [ 1:0] rvfi_mode,
    output [ 1:0] rvfi_ixl,
    output [ 4:0] rvfi_rs1_addr,
    output [ 4:0] rvfi_rs2_addr,
    output [ 4:0] rvfi_rs3_addr,
    output [31:0] rvfi_rs1_rdata,
    output [31:0] rvfi_rs2_rdata,
    output [31:0] rvfi_rs3_rdata,
    output [ 4:0] rvfi_rd_addr,
    output [31:0] rvfi_rd_wdata,
    output [31:0] rvfi_pc_rdata,
    output [31:0] rvfi_pc_wdata,
    output [31:0] rvfi_mem_addr,
    output [ 3:0] rvfi_mem_rmask,
    output [ 3:0] rvfi_mem_wmask,
    output [31:0] rvfi_mem_rdata,
    output [31:0] rvfi_mem_wdata,

);
    // dummy 32-bit words w/ all-0s and all-1s: 
    wire [31:0] ALL0  = 0;
    wire [31:0] ALL1  = -1;

`ifdef __THREADS__
    reg [`__THREADS__-1:0] XMODE = 0;     // thread ptr
    
    assign TPTR = XMODE;
`endif
    
    // pre-decode: IDATA is break apart as described in the RV32I specification

    reg [31:0] XIDATA;

    `ifdef VERIFICATION
        reg XLUI, XAUIPC, XJAL, XJALR, XBCC, XLCC, XSCC, XMCC, XRCC, XMAC, XRES; //, XFCC, XCCC;
    `else
        reg XLUI, XAUIPC, XJAL, XJALR, XBCC, XLCC, XSCC, XMCC, XRCC, XMAC, XRES; //, XFCC, XCCC;
    `endif

    reg [31:0] XSIMM;
    reg [31:0] XUIMM;

    // `ifdef VERIFICATION
    //     initial begin
    //         XIDATA = 0;
    //         XLUI = 0; 
    //         XAUIPC = 0; 
    //         XJAL = 0;
    //         XJALR = 0;
    //         XBCC = 0;
    //         XLCC = 0;
    //         XSCC = 0;
    //         XMCC = 0;
    //         XRCC = 0;
    //         XMAC = 0;
    //         XSIMM = 0;
    //         XUIMM = 0;
    //     end
    // `endif
    wire decode = XRES ? 0 : HLT ? 0 : FLUSH ? 0  : 1;
    wire [31:0] XIDATA_wire = XRES ? 0 : HLT ? XIDATA : FLUSH ? 0  : IDATA;
    reg decode_reg;
    always@(posedge CLK)
    begin
        decode_reg <= XRES ? 0 : HLT ? 0 : FLUSH ? 0  : 1;

        XIDATA <= XRES ? 0 : HLT ? XIDATA : FLUSH ? 0  : IDATA;
        
        XLUI   <= XRES ? 0 : HLT ? XLUI : FLUSH ? 0    : IDATA[6:0]==`LUI;
        XAUIPC <= XRES ? 0 : HLT ? XAUIPC : FLUSH ? 0  : IDATA[6:0]==`AUIPC;
        XJAL   <= XRES ? 0 : HLT ? XJAL : FLUSH ? 0    : IDATA[6:0]==`JAL;
        XJALR  <= XRES ? 0 : HLT ? XJALR : FLUSH ? 0   : IDATA[6:0]==`JALR;        

        XBCC   <= XRES ? 0 : HLT ? XBCC : FLUSH ? 0    : IDATA[6:0]==`BCC;
        XLCC   <= XRES ? 0 : HLT ? XLCC : FLUSH ? 0    : IDATA[6:0]==`LCC;
        XSCC   <= XRES ? 0 : HLT ? XSCC : FLUSH ? 0    : IDATA[6:0]==`SCC;
        XMCC   <= XRES ? 0 : HLT ? XMCC : FLUSH ? 0    : IDATA[6:0]==`MCC;

        XRCC   <= XRES ? 0 : HLT ? XRCC : FLUSH ? 0    : IDATA[6:0]==`RCC;
        XMAC   <= XRES ? 0 : HLT ? XMAC : FLUSH ? 0    : IDATA[6:0]==`MAC;
        //XFCC   <= XRES ? 0 : HLT ? XFCC   : IDATA[6:0]==`FCC;
        //XCCC   <= XRES ? 0 : HLT ? XCCC   : IDATA[6:0]==`CCC;

        // signal extended immediate, according to the instruction type:
        
        XSIMM  <= XRES ? 0 : HLT ? XSIMM : FLUSH ? 0 :
                 IDATA[6:0]==`SCC ? { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
                 IDATA[6:0]==`BCC ? { IDATA[31] ? ALL1[31:13]:ALL0[31:13], IDATA[31],IDATA[7],IDATA[30:25],IDATA[11:8],ALL0[0] } : // b-type
                 IDATA[6:0]==`JAL ? { IDATA[31] ? ALL1[31:21]:ALL0[31:21], IDATA[31], IDATA[19:12], IDATA[20], IDATA[30:21], ALL0[0] } : // j-type
                 IDATA[6:0]==`LUI||
                 IDATA[6:0]==`AUIPC ? { IDATA[31:12], ALL0[11:0] } : // u-type
                                      { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:20] }; // i-type
        // non-signal extended immediate, according to the instruction type:

        XUIMM  <= XRES ? 0: HLT ? XUIMM : FLUSH ? 0 :
                 IDATA[6:0]==`SCC ? { ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
                 IDATA[6:0]==`BCC ? { ALL0[31:13], IDATA[31],IDATA[7],IDATA[30:25],IDATA[11:8],ALL0[0] } : // b-type
                 IDATA[6:0]==`JAL ? { ALL0[31:21], IDATA[31], IDATA[19:12], IDATA[20], IDATA[30:21], ALL0[0] } : // j-type
                 IDATA[6:0]==`LUI||
                 IDATA[6:0]==`AUIPC ? { IDATA[31:12], ALL0[11:0] } : // u-type
                                      { ALL0[31:12], IDATA[31:20] }; // i-type
    end

    // decode: after XIDATA
`ifdef __3stages__3STAGE__
    reg [1:0] FLUSH ;  // flush instruction pipeline
`else
    reg FLUSH ;  // flush instruction pipeline
`endif

`ifdef __THREADS__    
    `ifdef __RV32E__
    
        `ifdef VERIFICATION
            reg [`__THREADS__+3:0] RESMODE = -1;
        `else
            reg [`__THREADS__+3:0] RESMODE = 0;
        `endif

        wire [`__THREADS__+3:0] DPTR   = XRES ? RESMODE : { XMODE, XIDATA[10: 7] }; // set SP_RESET when RES==1
        wire [`__THREADS__+3:0] S1PTR  = { XMODE, XIDATA[18:15] };
        wire [`__THREADS__+3:0] S2PTR  = { XMODE, XIDATA[23:20] };
    `else
    
        `ifdef VERIFICATION
            reg [`__THREADS__+4:0] RESMODE = 0;
        `else
            reg [`__THREADS__+4:0] RESMODE = -1;
        `endif

        wire [`__THREADS__+4:0] DPTR   = XRES ? RESMODE : { XMODE, XIDATA[11: 7] }; // set SP_RESET when RES==1
        wire [`__THREADS__+4:0] S1PTR  = { XMODE, XIDATA[19:15] };
        wire [`__THREADS__+4:0] S2PTR  = { XMODE, XIDATA[24:20] };
    `endif
`else
    `ifdef __RV32E__    
    
        `ifdef VERIFICATIONS1PTR
            reg [3:0] RESMODE ;
        `else
            reg [3:0] RESMODE ;
        `endif
    
        wire [3:0] DPTR   = XRES ? RESMODE : XIDATA[10: 7]; // set SP_RESET when RES==1
        wire [3:0] S1PTR  = XIDATA[18:15];
        wire [3:0] S2PTR  = XIDATA[23:20];
    `else

        `ifdef VERIFICATION
            reg [4:0] RESMODE;
        `else
            reg [4:0] RESMODE;
        `endif
    
        wire [4:0] DPTR   = XRES ? RESMODE : XIDATA[11: 7]; // set SP_RESET when RES==1
        wire [4:0] S1PTR  = XIDATA[19:15];
        wire [4:0] S2PTR  = XIDATA[24:20];    
    `endif
`endif

    wire [6:0] OPCODE = FLUSH ? 0 : XIDATA[6:0];
    wire [2:0] FCT3   = XIDATA[14:12];
    wire [6:0] FCT7   = XIDATA[31:25];

    wire [31:0] SIMM  = XSIMM;
    wire [31:0] UIMM  = XUIMM;
    
    // main opcode decoder:
                                
    wire    LUI = FLUSH ? 0 : XLUI;   // OPCODE==7'b0110111;
    wire  AUIPC = FLUSH ? 0 : XAUIPC; // OPCODE==7'b0010111;
    wire    JAL = FLUSH ? 0 : XJAL;   // OPCODE==7'b1101111;
    wire   JALR = FLUSH ? 0 : XJALR;  // OPCODE==7'b1100111;
    
    wire    BCC = FLUSH ? 0 : XBCC; // OPCODE==7'b1100011; //FCT3
    wire    LCC = FLUSH ? 0 : XLCC; // OPCODE==7'b0000011; //FCT3
    wire    SCC = FLUSH ? 0 : XSCC; // OPCODE==7'b0100011; //FCT3
    wire    MCC = FLUSH ? 0 : XMCC; // OPCODE==7'b0010011; //FCT3
    
    wire    RCC = FLUSH ? 0 : XRCC; // OPCODE==7'b0110011; //FCT3
    wire    MAC = FLUSH ? 0 : XMAC; // OPCODE==7'b0110011; //FCT3
    //wire    FCC = FLUSH ? 0 : XFCC; // OPCODE==7'b0001111; //FCT3
    //wire    CCC = FLUSH ? 0 : XCCC; // OPCODE==7'b1110011; //FCT3

`ifdef __THREADS__
    `ifdef __3stages__3STAGE__
        reg [31:0] NXPC2 [0:(2**`__THREADS__)-1];       // 32-bit program counter t+2
    `endif

    `ifdef __RV32E__
        reg [31:0] REG1 [0:16*(2**`__THREADS__)-1];	// general-purpose 16x32-bit registers (s1)
        reg [31:0] REG2 [0:16*(2**`__THREADS__)-1];	// general-purpose 16x32-bit registers (s2)
    `else
        reg [31:0] REG1 [0:32*(2**`__THREADS__)-1];	// general-purpose 32x32-bit registers (s1)
        reg [31:0] REG2 [0:32*(2**`__THREADS__)-1];	// general-purpose 32x32-bit registers (s2)    
    `endif
`else
    `ifdef __3stages__3STAGE__
        reg [31:0] NXPC2;       // 32-bit program counter t+2

        // `ifdef VERIFICATION
        //     initial begin
        //         NXPC2 = `__RESETPC__;
        //     end
        // `endif
    `endif

    `ifdef __RV32E__
        reg [31:0] REG1 [0:15];	// general-purpose 16x32-bit registers (s1)
        reg [31:0] REG2 [0:15];	// general-purpose 16x32-bit registers (s2)

        // `ifdef VERIFICATION
        //     integer i_REGS;
        //     initial
        //         for(i_REGS=0;i_REGS<16;i_REGS=i_REGS+1) begin
        //             REG1[i_REGS] = 32'b00000000000000000000000000000000;
        //             REG2[i_REGS] = 32'b00000000000000000000000000000000;
        //         end
        // `endif

    `else
        reg [31:0] REG1 [0:31];	// general-purpose 32x32-bit registers (s1)
        reg [31:0] REG2 [0:31];	// general-purpose 32x32-bit registers (s2)

        // `ifdef VERIFICATION
        //     integer i_REGS;
        //     initial
        //         for(i_REGS=0;i_REGS<32;i_REGS=i_REGS+1) begin
        //             REG1[i_REGS] = 32'b00000000000000000000000000000000;
        //             REG2[i_REGS] = 32'b00000000000000000000000000000000;
        //         end
        // `endif
    `endif
`endif

    reg [31:0] NXPC;        // 32-bit program counter t+1
    reg [31:0] PC;		    // 32-bit program counter t+0

    // `ifdef VERIFICATION
    //         initial begin
    //             PC = `__RESETPC__;
    //             NXPC = `__RESETPC__;
    //         end
    // `endif

    // source-1 and source-1 register selection

    wire          [31:0] U1REG = REG1[S1PTR];
    wire          [31:0] U2REG = REG2[S2PTR];

    wire signed   [31:0] S1REG = U1REG;
    wire signed   [31:0] S2REG = U2REG;
    

    // L-group of instructions (OPCODE==7'b0000011)

`ifdef __FLEXBUZZ__

    wire [31:0] LDATA = FCT3[1:0]==0 ? { FCT3[2]==0&&DATAI[ 7] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[ 7: 0] } :
                        FCT3[1:0]==1 ? { FCT3[2]==0&&DATAI[15] ? ALL1[31:16]:ALL0[31:16] , DATAI[15: 0] } :
                                        DATAI;
`else
    wire [31:0] LDATA = FCT3==0||FCT3==4 ? ( DADDR[1:0]==3 ? { FCT3==0&&DATAI[31] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[31:24] } :
                                             DADDR[1:0]==2 ? { FCT3==0&&DATAI[23] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[23:16] } :
                                             DADDR[1:0]==1 ? { FCT3==0&&DATAI[15] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[15: 8] } :
                                                             { FCT3==0&&DATAI[ 7] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[ 7: 0] } ):
                        FCT3==1||FCT3==5 ? ( DADDR[1]==1   ? { FCT3==1&&DATAI[31] ? ALL1[31:16]:ALL0[31:16] , DATAI[31:16] } :
                                                             { FCT3==1&&DATAI[15] ? ALL1[31:16]:ALL0[31:16] , DATAI[15: 0] } ) :
                                             DATAI;
`endif

    // S-group of instructions (OPCODE==7'b0100011)

`ifdef __FLEXBUZZ__

    wire [31:0] SDATA = U2REG; /* FCT3==0 ? { ALL0 [31: 8], U2REG[ 7:0] } :
                        FCT3==1 ? { ALL0 [31:16], U2REG[15:0] } :
                                    U2REG;*/
`else
    wire [31:0] SDATA = FCT3==0 ? ( DADDR[1:0]==3 ? { U2REG[ 7: 0], ALL0 [23:0] } : 
                                    DADDR[1:0]==2 ? { ALL0 [31:24], U2REG[ 7:0], ALL0[15:0] } : 
                                    DADDR[1:0]==1 ? { ALL0 [31:16], U2REG[ 7:0], ALL0[7:0] } :
                                                    { ALL0 [31: 8], U2REG[ 7:0] } ) :
                        FCT3==1 ? ( DADDR[1]==1   ? { U2REG[15: 0], ALL0 [15:0] } :
                                                    { ALL0 [31:16], U2REG[15:0] } ) :
                                    U2REG;
`endif

    // C-group not implemented yet!
    
    wire [31:0] CDATA = 0;	// status register istructions not implemented yet

    // RM-group of instructions (OPCODEs==7'b0010011/7'b0110011), merged! src=immediate(M)/register(R)

    wire signed [31:0] S2REGX = XMCC ? SIMM : S2REG;
    wire        [31:0] U2REGX = XMCC ? UIMM : U2REG;

    wire [31:0] RMDATA = FCT3==7 ? U1REG&S2REGX :
                         FCT3==6 ? U1REG|S2REGX :
                         FCT3==4 ? U1REG^S2REGX :
                         FCT3==3 ? U1REG<U2REGX?1:0 : // unsigned
                         FCT3==2 ? S1REG<S2REGX?1:0 : // signed
                         FCT3==0 ? (XRCC&&FCT7[5] ? U1REG-U2REGX : U1REG+S2REGX) :
                         FCT3==1 ? U1REG<<U2REGX[4:0] :                         
                         //FCT3==5 ? 
                         !FCT7[5] ? U1REG>>U2REGX[4:0] :
`ifdef MODEL_TECH        
                         FCT7[5] ? -((-U1REG)>>U2REGX[4:0]; // workaround for modelsim
`else
                                   $signed(S1REG>>>U2REGX[4:0]);  // (FCT7[5] ? U1REG>>>U2REG[4:0] : 
`endif                        

`ifdef __MAC16X16__

    // MAC instruction rd += s1*s2 (OPCODE==7'b1111111)
    // 
    // 0000000 01100 01011 100 01100 0110011 xor a2,a1,a2
    // 0000000 01010 01100 000 01010 0110011 add a0,a2,a0
    // 0000000 01100 01011 000 01010 1111111 mac a0,a1,a2
    // 
    // 0000 0000 1100 0101 1000 0101 0111 1111 = 00c5857F

    wire signed [15:0] K1TMP = S1REG[15:0];
    wire signed [15:0] K2TMP = S2REG[15:0];
    wire signed [31:0] KDATA = K1TMP*K2TMP;

`endif

    // J/B-group of instructions (OPCODE==7'b1100011)
    
    wire BMUX       = BCC==1 && (
                          FCT3==4 ? S1REG< S2REGX : // blt
                          FCT3==5 ? S1REG>=S2REG : // bge
                          FCT3==6 ? U1REG< U2REGX : // bltu
                          FCT3==7 ? U1REG>=U2REG : // bgeu
                          FCT3==0 ? !(U1REG^S2REGX) : //U1REG==U2REG : // beq
                          /*FCT3==1 ? */ U1REG^S2REGX); //U1REG!=U2REG); // bne
                                    //0);

    wire [31:0] PCSIMM = PC+SIMM;
    wire        JREQ = (JAL||JALR||BMUX);
    wire [31:0] JVAL = SIMM + (JALR ? U1REG : PC);//JALR ? DADDR : PCSIMM; // SIMM + (JALR ? U1REG : PC);


    // for pipeline invariants
    wire [31:0] XIDATA_next = FLUSH ? 0 : XIDATA;
    reg writeback_reg;
    wire writeback =  XRES ? 0 :           
                       HLT ? 0 : 1;       // halt
                //      !DPTR ? 0 :                // x0 = 0, always!
                //      AUIPC ? 0 :
                //       JAL||
                //       JALR ? 0 :
                //        LUI ? 0 :
                //        LCC ? 1 :
                //   MCC||RCC ? 0:
                //              0; 
    wire filter_pc_reg = decode_reg || (! FLUSH );
    wire filter_pc = decode || (! FLUSH_wire);
    wire FLUSH_wire = XRES ? 1 : HLT ? FLUSH :        // reset and halt
                       (JAL||JALR||BMUX); 

    reg [31:0] DelayU1REG;
    reg DelayBCC;
    reg [31:0] DelayU2REG;
    reg DelayJALR;
    reg [31:0] DelayLDATA;
    reg DelayLCC;
    reg [31:0] DelayDADDR;
    reg DelaySCC;
    reg [31:0] DelayXIDATA_next;

    wire [31:0] PC_flush = FLUSH ? 0 : PC;



////
//// rvfi
    reg [31:0] rvfi_regfile [0:31];
    //assign  rvfi_regfile = REG1;
    always @(posedge CLK) begin
        rvfi_regfile <= REG1;
    end
//     wire [31:0] reg_rd;
// `ifdef __RV32E__
//     assign    reg_rd =   XRES ? (RESMODE[3:0]==2 ? `__RESETSP__ : 0)  :        // reset sp
// `else
//     assign    reg_rd =   XRES ? (RESMODE[4:0]==2 ? `__RESETSP__ : 0)  :        // reset sp
// `endif
//                        HLT ? REG1[DPTR] :        // halt
//                      !DPTR ? 0 :                // x0 = 0, always!
//                      AUIPC ? PCSIMM :
//                       JAL||
//                       JALR ? NXPC :
//                        LUI ? SIMM :
//                        LCC ? LDATA :
//                   MCC||RCC ? RMDATA:
// `ifdef __MAC16X16__                  
//                        MAC ? REG2[DPTR]+KDATA :
// `endif
//                        //CCC ? CDATA : 
//                              REG1[DPTR];

    wire    retire_wire;
    assign  retire_wire = HLT | flushed | FLUSH ? 0 : (XRES || |resetted) ? 0 : 1;
    reg    retire_reg;
    always @(posedge CLK) begin
        retire_reg <= HLT | FLUSH | flushed ? 0 : (XRES || |resetted) ? 0 : 1;
    end

    reg flushed = 0;
    always @(posedge CLK) begin
        if (FLUSH) begin
            flushed <= 1;
        end else begin
            flushed <= 0;
        end
    end

    reg [1:0] resetted = 0;
    always @(posedge CLK) begin
        if (XRES) begin
            resetted <= 2'b11;
        end else begin
            if (resetted == 2'b11) begin
                resetted <= 2'b01;
            end else if (resetted == 2'b01) begin
                resetted <= 2'b00;
            end
        end
    end

    reg [31:0] stalled_instruction = 32'b0;
    always @(posedge CLK) begin
        if (RES) begin
            stalled_instruction <= 32'b0;
        end else begin
            stalled_instruction <= !retire_wire ? stalled_instruction : XIDATA;
        end
    end
    reg [31:0] instruction;
    //assign instruction = !retire_wire ? stalled_instruction : XIDATA;
    always @(posedge CLK) begin
        instruction <= !retire_wire ? stalled_instruction : XIDATA;
    end
    reg [31:0] old_regfile [0:31];
    always @(posedge CLK) begin
        if (RES) begin
            old_regfile <= 0;
        end else begin
            if (retire_reg) begin
                old_regfile <= REG1;
            end
        end
    end
    reg [31:0] old_pc;
    always @(posedge CLK) begin
        if (RES) begin
            old_pc <= 4;
        end else begin
            if (retire_reg) begin
                old_pc <= pc_wdata;
            end
        end
    end
    //assign old_pc = PC;
    reg [31:0] next_pc;
    //assign rvfi_new_pc = NXPC;
    always @(posedge CLK) begin
        next_pc <= NXPC;
    end
    wire [31:0] pc_wdata = FLUSH ? NXPC + 4 : next_pc;

    reg        mem_req = 0;
    reg [31:0] mem_addr = 32'b0;
    reg [31:0] mem_rdata = 32'b0;
    reg [31:0] mem_wdata = 32'b0;
    reg        mem_we = 0;
    reg [3:0]  mem_be = 3'b0;
    always @(posedge CLK) begin
        if (RES) begin
            mem_req <= 0;
            mem_addr <= 32'b0;
            mem_rdata <= 32'b0;
            mem_wdata <= 32'b0;
            mem_we <= 0;
            mem_be <= 4'b0;
        end else begin
            mem_req <= WR || RD;
            mem_addr <= DADDR;
            mem_rdata <= DATAI;
            mem_wdata <= DATAO;
            mem_we <= WR;
            mem_be <= BE;
        end
    end

    RVFI_2stage RVFI_2stage(
        .clock(CLK),
        .retire(retire_reg),
        .instruction(instruction),
        .old_regfile(old_regfile),
        .new_regfile(REG1),
        .old_pc(old_pc),
        .new_pc(pc_wdata),
        .mem_req(mem_req),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata),
        .mem_wdata(mem_wdata),
        .mem_we(mem_we),
        .mem_be(mem_be),
        .rvfi_valid(rvfi_valid),
        .rvfi_order(rvfi_order),
        .rvfi_insn(rvfi_insn),
        .rvfi_trap(rvfi_trap),
        .rvfi_halt(rvfi_halt),
        .rvfi_intr(rvfi_intr),
        .rvfi_mode(rvfi_mode),
        .rvfi_ixl(rvfi_ixl),
        .rvfi_rs1_addr(rvfi_rs1_addr),
        .rvfi_rs2_addr(rvfi_rs2_addr),
        .rvfi_rs3_addr(rvfi_rs3_addr),
        .rvfi_rs1_rdata(rvfi_rs1_rdata),
        .rvfi_rs2_rdata(rvfi_rs2_rdata),
        .rvfi_rs3_rdata(rvfi_rs3_rdata),
        .rvfi_rd_addr(rvfi_rd_addr),
        .rvfi_rd_wdata(rvfi_rd_wdata),
        .rvfi_pc_rdata(rvfi_pc_rdata),
        .rvfi_pc_wdata(rvfi_pc_wdata),
        .rvfi_mem_addr(rvfi_mem_addr),
        .rvfi_mem_rmask(rvfi_mem_rmask),
        .rvfi_mem_wmask(rvfi_mem_wmask),
        .rvfi_mem_rdata(rvfi_mem_rdata),
        .rvfi_mem_wdata(rvfi_mem_wdata),	
    );


//////////////////////////// for contract atoms ////////////////////////////////
	//// frist building block for contract atoms
	wire rvfi_lui_ctr;
	assign rvfi_lui_ctr = (rvfi_insn[6:0] == 7'h37);
	wire rvfi_auipc_ctr;
	assign rvfi_auipc_ctr = (rvfi_insn[6:0] == 7'h17);
	
	wire rvfi_jal_ctr;
	assign rvfi_jal_ctr = (rvfi_insn[6:0] == 7'h6f);
	wire rvfi_jalr_ctr;
	assign rvfi_jalr_ctr = (rvfi_insn[6:0] == 7'h67) && (rvfi_insn[14:12] == 3'b000);

	wire rvfi_beq_ctr;
	assign rvfi_beq_ctr = (rvfi_insn[6:0] == 7'h63) && (rvfi_insn[14:12] == 3'b000);
	wire rvfi_bge_ctr;
	assign rvfi_bge_ctr = (rvfi_insn[6:0] == 7'h63) && (rvfi_insn[14:12] == 3'b101);
	wire rvfi_bgeu_ctr;
	assign rvfi_bgeu_ctr = (rvfi_insn[6:0] == 7'h63) && (rvfi_insn[14:12] == 3'b111);
	wire rvfi_bltu_ctr;
	assign rvfi_bltu_ctr = (rvfi_insn[6:0] == 7'h63) && (rvfi_insn[14:12] == 3'b110);
	wire rvfi_blt_ctr;
	assign rvfi_blt_ctr = (rvfi_insn[6:0] == 7'h63) && (rvfi_insn[14:12] == 3'b100);
	wire rvfi_bne_ctr;
	assign rvfi_bne_ctr = (rvfi_insn[6:0] == 7'h63) && (rvfi_insn[14:12] == 3'b001);
	
	
	wire rvfi_lb_ctr;
	assign rvfi_lb_ctr = (rvfi_insn[6:0] == 7'h03) && (rvfi_insn[14:12] == 3'b000);
	wire rvfi_lh_ctr;
	assign rvfi_lh_ctr = (rvfi_insn[6:0] == 7'h03) && (rvfi_insn[14:12] == 3'b001);
	wire rvfi_lhu_ctr;
	assign rvfi_lhu_ctr = (rvfi_insn[6:0] == 7'h03) && (rvfi_insn[14:12] == 3'b101);
	wire rvfi_lbu_ctr;
	assign rvfi_lbu_ctr = (rvfi_insn[6:0] == 7'h03) && (rvfi_insn[14:12] == 3'b100);
	wire rvfi_lw_ctr;
	assign rvfi_lw_ctr = (rvfi_insn[6:0] == 7'h03) && (rvfi_insn[14:12] == 3'b010);
	
	wire rvfi_sb_ctr;
	assign rvfi_sb_ctr = (rvfi_insn[6:0] == 7'h23) && (rvfi_insn[14:12] == 3'b000);
	wire rvfi_sw_ctr;
	assign rvfi_sw_ctr = (rvfi_insn[6:0] == 7'h23) && (rvfi_insn[14:12] == 3'b010);
	wire rvfi_sh_ctr;
	assign rvfi_sh_ctr = (rvfi_insn[6:0] == 7'h23) && (rvfi_insn[14:12] == 3'b001);

	wire rvfi_addi_ctr;
	assign rvfi_addi_ctr = (rvfi_insn[6:0] == 7'h13) && (rvfi_insn[14:12] == 3'b000);
	wire rvfi_slti_ctr;
	assign rvfi_slti_ctr = (rvfi_insn[6:0] == 7'h13) && (rvfi_insn[14:12] == 3'b010);
	wire rvfi_sltiu_ctr;
	assign rvfi_sltiu_ctr = (rvfi_insn[6:0] == 7'h13) && (rvfi_insn[14:12] == 3'b011);
	wire rvfi_xori_ctr;
	assign rvfi_xori_ctr = (rvfi_insn[6:0] == 7'h13) && (rvfi_insn[14:12] == 3'b100);
	wire rvfi_ori_ctr;
	assign rvfi_ori_ctr = (rvfi_insn[6:0] == 7'h13) && (rvfi_insn[14:12] == 3'b110);
	wire rvfi_andi_ctr;
	assign rvfi_andi_ctr = (rvfi_insn[6:0] == 7'h13) && (rvfi_insn[14:12] == 3'b111);
	wire rvfi_slli_ctr;
	assign rvfi_slli_ctr = (rvfi_insn[6:0] == 7'h13) && (rvfi_insn[14:12] == 3'b001) && (rvfi_insn[31:25] == 7'b0000000);
	wire rvfi_srli_ctr;
	assign rvfi_srli_ctr = (rvfi_insn[6:0] == 7'h13) && (rvfi_insn[14:12] == 3'b101) && (rvfi_insn[31:25] == 7'b0000000);
	wire rvfi_srai_ctr;
	assign rvfi_srai_ctr = (rvfi_insn[6:0] == 7'h13) && (rvfi_insn[14:12] == 3'b101) && (rvfi_insn[31:25] == 7'b0100000);

	wire rvfi_add_ctr;
	assign rvfi_add_ctr = (rvfi_insn[6:0] == 7'h33) && (rvfi_insn[14:12] == 3'b000) && (rvfi_insn[31:25] == 7'b0000000);
	wire rvfi_sub_ctr;
	assign rvfi_sub_ctr = (rvfi_insn[6:0] == 7'h33) && (rvfi_insn[14:12] == 3'b000) && (rvfi_insn[31:25] == 7'b0100000);
	wire rvfi_sll_ctr;
	assign rvfi_sll_ctr = (rvfi_insn[6:0] == 7'h33) && (rvfi_insn[14:12] == 3'b001) && (rvfi_insn[31:25] == 7'b0000000);
	wire rvfi_slt_ctr;
	assign rvfi_slt_ctr = (rvfi_insn[6:0] == 7'h33) && (rvfi_insn[14:12] == 3'b010) && (rvfi_insn[31:25] == 7'b0000000);
	wire rvfi_sltu_ctr;
	assign rvfi_sltu_ctr = (rvfi_insn[6:0] == 7'h33) && (rvfi_insn[14:12] == 3'b011) && (rvfi_insn[31:25] == 7'b0000000);
	wire rvfi_xor_ctr;
	assign rvfi_xor_ctr = (rvfi_insn[6:0] == 7'h33) && (rvfi_insn[14:12] == 3'b100) && (rvfi_insn[31:25] == 7'b0000000);
	wire rvfi_srl_ctr;
	assign rvfi_srl_ctr = (rvfi_insn[6:0] == 7'h33) && (rvfi_insn[14:12] == 3'b101) && (rvfi_insn[31:25] == 7'b0000000);
	wire rvfi_sra_ctr;
	assign rvfi_sra_ctr = (rvfi_insn[6:0] == 7'h33) && (rvfi_insn[14:12] == 3'b101) && (rvfi_insn[31:25] == 7'b0100000);
	wire rvfi_or_ctr;
	assign rvfi_or_ctr = (rvfi_insn[6:0] == 7'h33) && (rvfi_insn[14:12] == 3'b110) && (rvfi_insn[31:25] == 7'b0000000);
	wire rvfi_and_ctr;
	assign rvfi_and_ctr = (rvfi_insn[6:0] == 7'h33) && (rvfi_insn[14:12] == 3'b111) && (rvfi_insn[31:25] == 7'b0000000);

	wire rvfi_mul_ctr;
	assign rvfi_mul_ctr = ( rvfi_insn[6:0] == 7'h33 ) && ( rvfi_insn[31:25] == 7'b0000001 ) && ( rvfi_insn[14:12] == 3'b000 );
	wire rvfi_mulh_ctr;
	assign rvfi_mulh_ctr = ( rvfi_insn[6:0] == 7'h33 ) && ( rvfi_insn[31:25] == 7'b0000001 ) && ( rvfi_insn[14:12] == 3'b001 );
	wire rvfi_mulhsu_ctr;
	assign rvfi_mulhsu_ctr = ( rvfi_insn[6:0] == 7'h33 ) && ( rvfi_insn[31:25] == 7'b0000001 ) && ( rvfi_insn[14:12] == 3'b010 );
	wire rvfi_mulhu_ctr;
	assign rvfi_mulhu_ctr = ( rvfi_insn[6:0] == 7'h33 ) && ( rvfi_insn[31:25] == 7'b0000001 ) && ( rvfi_insn[14:12] == 3'b011 );
	wire rvfi_div_ctr;
	assign rvfi_div_ctr = ( rvfi_insn[6:0] == 7'h33 ) && ( rvfi_insn[31:25] == 7'b0000001 ) && ( rvfi_insn[14:12] == 3'b100 );
	wire rvfi_divu_ctr;
	assign rvfi_divu_ctr = ( rvfi_insn[6:0] == 7'h33 ) && ( rvfi_insn[31:25] == 7'b0000001 ) && ( rvfi_insn[14:12] == 3'b101 );
	wire rvfi_rem_ctr;
	assign rvfi_rem_ctr = ( rvfi_insn[6:0] == 7'h33 ) && ( rvfi_insn[31:25] == 7'b0000001 ) && ( rvfi_insn[14:12] == 3'b110 );
	wire rvfi_remu_ctr;
	assign rvfi_remu_ctr = ( rvfi_insn[6:0] == 7'h33 ) && ( rvfi_insn[31:25] == 7'b0000001 ) && ( rvfi_insn[14:12] == 3'b111 );


	//// second block for contract
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd;
	wire [6:0] opcode;
	wire [31:0] imm;
	wire [2:0] format;
	wire [2:0] funct3;
	wire [6:0] funct7;

    RISCV_Decoder ctr_decode (
        .instr_i            (rvfi_insn),
        .format_o           (format),
        .op_o               (opcode),
        .funct_3_o          (funct3),
        .funct_7_o          (funct7),
        .rd_o               (rd),
        .rs1_o              (rs1),
        .rs2_o              (rs2),
        .imm_o              (imm),
    );

	wire [31:0] new_pc;
	assign new_pc = rvfi_pc_wdata;
	wire  is_branch;
	assign is_branch = rvfi_beq_ctr || rvfi_bge_ctr || rvfi_bgeu_ctr || rvfi_bltu_ctr || rvfi_blt_ctr || rvfi_bne_ctr || rvfi_jal_ctr || rvfi_jalr_ctr;
	

	wire [31:0] reg_rd;
	assign reg_rd = rvfi_rd_wdata;
	wire [31:0] reg_rs1;
	assign reg_rs1 = rvfi_rs1_rdata;
	wire [31:0] reg_rs2;
	assign reg_rs2 = rvfi_rs2_rdata;

	wire reg_rs1_zero;
	assign reg_rs1_zero = ( rvfi_rs1_rdata == 0 );
	wire reg_rs2_zero;
	assign reg_rs2_zero = ( rvfi_rs2_rdata == 0 );
	wire [31:0] reg_rs1_log2;
	assign reg_rs1_log2 = clogb2( rvfi_rs1_rdata );
	wire [31:0] reg_rs2_log2;
	assign reg_rs2_log2 = clogb2( rvfi_rs2_rdata );

	function integer clogb2;
		input [31:0] value;
		integer i;
		begin
			clogb2 = 0;
			for (i = 0; i < 32; i = i + 1) begin
				if (value > 0) begin
					clogb2 = i + 1;
					value = value >> 1; // Shift right to reduce the value
				end
			end
		end
	endfunction




	wire is_aligned;
	assign is_aligned = rvfi_mem_addr[1:0] == 2'b00;
	wire is_half_aligned;
    assign is_half_aligned = rvfi_mem_addr[1:0] != 2'b11;

	wire branch_taken;
    assign branch_taken =
            (opcode == `JAL_OP)
        ||  (opcode == `JALR_OP)
        ||  ((opcode == `BEQ_OP) && (funct3 == `BEQ_FUNCT_3) && (reg_rs1 == reg_rs2))
        ||  ((opcode == `BNE_OP) && (funct3 == `BNE_FUNCT_3) && (reg_rs1 != reg_rs2))
        ||  ((opcode == `BLT_OP) && (funct3 == `BLT_FUNCT_3) && ($signed(reg_rs1) < $signed(reg_rs2)))
        ||  ((opcode == `BGE_OP) && (funct3 == `BGE_FUNCT_3) && ($signed(reg_rs1) >= $signed(reg_rs2)))
        ||  ((opcode == `BLTU_OP) && (funct3 == `BLTU_FUNCT_3) && (reg_rs1 < reg_rs2))
        ||  ((opcode == `BGEU_OP) && (funct3 == `BGEU_FUNCT_3) && (reg_rs1 >= reg_rs2));

	wire [31:0] mem_addr;
	assign mem_addr = rvfi_mem_addr;
	wire [31:0] mem_r_data;
	assign mem_r_data = rvfi_mem_rdata;
	wire [31:0] mem_w_data;
	assign mem_w_data = rvfi_mem_wdata;

////////////////////////////////

    
    always@(posedge CLK) begin
        
        DelayLDATA <= HLT? DelayLDATA : LDATA;
        DelayLCC <= HLT? DelayLCC : LCC;
        DelayDADDR <= HLT? DelayDADDR : DADDR;
        DelaySCC <= HLT? DelaySCC : SCC;
        DelayXIDATA_next <= HLT? DelayXIDATA_next : XIDATA_next;
        DelayU1REG <= HLT? DelayU1REG : U1REG;
        DelayBCC <= HLT? DelayBCC : BCC;
        DelayU2REG <= HLT? DelayU2REG : U2REG;
        DelayJALR <= HLT? DelayJALR : JALR;

        writeback_reg <=  XRES ? 0 :           
                       HLT ? 0 : 1;      // halt
                //      !DPTR ? 0 :                // x0 = 0, always!
                //      AUIPC ? 0 :
                //       JAL||
                //       JALR ? 0 :
                //        LUI ? 0 :
                //        LCC ? 1 :
                //   MCC||RCC ? 0:
                //              0;



        RESMODE <= RES ? -1 : RESMODE ? RESMODE-1 : 0;
        
        XRES <= |RESMODE;


`ifdef __3stages__3STAGE__
	    FLUSH <= XRES ? 2 : HLT ? FLUSH :        // reset and halt                              
	                       FLUSH ? FLUSH-1 :                           
	                       (JAL||JALR||BMUX) ? 2 : 0;  // flush the pipeline!
`else
        FLUSH <= XRES ? 1 : HLT ? FLUSH :        // reset and halt
                       (JAL||JALR||BMUX);  // flush the pipeline!
`endif

`ifdef __RV32E__
        REG1[DPTR] <=   XRES ? (RESMODE[3:0]==2 ? `__RESETSP__ : 0)  :        // reset sp
`else
        REG1[DPTR] <=   XRES ? (RESMODE[4:0]==2 ? `__RESETSP__ : 0)  :        // reset sp
`endif
                       HLT ? REG1[DPTR] :        // halt
                     !DPTR ? 0 :                // x0 = 0, always!
                     AUIPC ? PCSIMM :
                      JAL||
                      JALR ? NXPC :
                       LUI ? SIMM :
                       LCC ? LDATA :
                  MCC||RCC ? RMDATA:
`ifdef __MAC16X16__                  
                       MAC ? REG2[DPTR]+KDATA :
`endif
                       //CCC ? CDATA : 
                             REG1[DPTR];
`ifdef __RV32E__
        REG2[DPTR] <=   XRES ? (RESMODE[3:0]==2 ? `__RESETSP__ : 0) :        // reset sp
`else        
        REG2[DPTR] <=   XRES ? (RESMODE[4:0]==2 ? `__RESETSP__ : 0) :        // reset sp
`endif        
                       HLT ? REG2[DPTR] :        // halt
                     !DPTR ? 0 :                // x0 = 0, always!
                     AUIPC ? PCSIMM :
                      JAL||
                      JALR ? NXPC :
                       LUI ? SIMM :
                       LCC ? LDATA :
                  MCC||RCC ? RMDATA:
`ifdef __MAC16X16__
                       MAC ? REG2[DPTR]+KDATA :
`endif                       
                       //CCC ? CDATA : 
                             REG2[DPTR];

`ifdef __3stages__3STAGE__

    `ifdef __THREADS__

        NXPC <= /*XRES ? `__RESETPC__ :*/ HLT ? NXPC : NXPC2[XMODE];

        NXPC2[XRES ? RESMODE[`__THREADS__-1:0] : XMODE] <=  XRES ? `__RESETPC__ : HLT ? NXPC2[XMODE] :   // reset and halt
                                      JREQ ? JVAL :                            // jmp/bra
	                                         NXPC2[XMODE]+4;                   // normal flow

        XMODE <= XRES ? 0 : HLT ? XMODE :        // reset and halt
                            JAL ? XMODE+1 : XMODE;
	             //XMODE==0/*&& IREQ*/&&(JAL||JALR||BMUX) ? 1 :         // wait pipeflush to switch to irq
                 //XMODE==1/*&&!IREQ*/&&(JAL||JALR||BMUX) ? 0 : XMODE;  // wait pipeflush to return from irq

    `else
        NXPC <= /*XRES ? `__RESETPC__ :*/ HLT ? NXPC : FLUSH ? NXPC : NXPC2;
	
	    NXPC2 <=  XRES ? `__RESETPC__ : HLT ? NXPC2 :   // reset and halt
	                 JREQ ? JVAL :                    // jmp/bra
	                        NXPC2+4;                   // normal flow

    `endif

`else
        NXPC <= XRES ? `__RESETPC__ : HLT ? NXPC :   // reset and halt
              JREQ ? JVAL :                   // jmp/bra
                     NXPC+4;                   // normal flow
`endif
        PC   <= /*XRES ? `__RESETPC__ :*/ HLT ? PC : FLUSH ? PC : NXPC; // current program counter

    end

    // IO and memory interface

    assign DATAO = SCC ? SDATA : 0; //SDATA;
    assign DADDR =  (SCC||LCC) ? U1REG + SIMM : 0;//U1REG + SIMM;

    // based in the Scc and Lcc   

`ifdef __FLEXBUZZ__
    assign RW      = !SCC;
    assign DLEN[0] = (SCC||LCC)&&FCT3[1:0]==0;
    assign DLEN[1] = (SCC||LCC)&&FCT3[1:0]==1;
    assign DLEN[2] = (SCC||LCC)&&FCT3[1:0]==2;
`else
    assign RD = LCC;
    assign WR = SCC;
    assign BE = FCT3==0||FCT3==4 ? ( DADDR[1:0]==3 ? 4'b1000 : // sb/lb
                                     DADDR[1:0]==2 ? 4'b0100 : 
                                     DADDR[1:0]==1 ? 4'b0010 :
                                                     4'b0001 ) :
                FCT3==1||FCT3==5 ? ( DADDR[1]==1   ? 4'b1100 : // sh/lh
                                                     4'b0011 ) :
                                                     4'b1111; // sw/lw
`endif

`ifdef __3stages__3STAGE__
    `ifdef __THREADS__
        assign IADDR = NXPC2[XMODE];
    `else
        assign IADDR = NXPC2;
    `endif    
`else
    assign IADDR = NXPC;
`endif

    assign IDLE = |FLUSH;

    assign DEBUG = { XRES, |FLUSH, SCC, LCC };

endmodule
