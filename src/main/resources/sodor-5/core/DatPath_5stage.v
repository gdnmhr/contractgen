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

module DatPath_5stage(
  input         clock,
  input         reset,
  output        io_imem_req_valid,
  output [31:0] io_imem_req_bits_addr,
  input         io_imem_resp_valid,
  input  [31:0] io_imem_resp_bits_data,
  output        io_dmem_req_valid,
  output [31:0] io_dmem_req_bits_addr,
  output [31:0] io_dmem_req_bits_data,
  output        io_dmem_req_bits_fcn,
  output [2:0]  io_dmem_req_bits_typ,
  input  [31:0] io_dmem_resp_bits_data,
  input         io_ctl_dec_stall,
  input         io_ctl_full_stall,
  input  [1:0]  io_ctl_exe_pc_sel,
  input  [3:0]  io_ctl_br_type,
  input         io_ctl_if_kill,
  input         io_ctl_dec_kill,
  input  [1:0]  io_ctl_op1_sel,
  input  [2:0]  io_ctl_op2_sel,
  input  [3:0]  io_ctl_alu_fun,
  input  [1:0]  io_ctl_wb_sel,
  input         io_ctl_rf_wen,
  input         io_ctl_mem_val,
  input  [1:0]  io_ctl_mem_fcn,
  input  [2:0]  io_ctl_mem_typ,
  input  [2:0]  io_ctl_csr_cmd,
  input         io_ctl_fencei,
  input         io_ctl_pipeline_kill,
  input         io_ctl_mem_exception,
  input  [31:0] io_ctl_mem_exception_cause,
  output [31:0] io_dat_dec_inst,
  output        io_dat_dec_valid,
  output        io_dat_exe_br_eq,
  output        io_dat_exe_br_lt,
  output        io_dat_exe_br_ltu,
  output [3:0]  io_dat_exe_br_type,
  output        io_dat_exe_inst_misaligned,
  output        io_dat_mem_ctrl_dmem_val,
  output        io_dat_mem_data_misaligned,
  output        io_dat_mem_store,
  output        io_dat_csr_eret,
  output        io_dat_csr_interrupt,
  input         io_interrupt_debug,
  input         io_interrupt_mtip,
  input         io_interrupt_msip,
  input         io_interrupt_meip,
  input         io_hartid,
  input  [31:0] io_reset_vector,

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
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
  reg [31:0] _RAND_24;
  reg [31:0] _RAND_25;
  reg [31:0] _RAND_26;
  reg [31:0] _RAND_27;
  reg [31:0] _RAND_28;
  reg [31:0] _RAND_29;
  reg [31:0] _RAND_30;
  reg [31:0] _RAND_31;
  reg [31:0] _RAND_32;
  reg [31:0] _RAND_33;
  reg [31:0] _RAND_34;
  reg [31:0] _RAND_35;
  reg [31:0] _RAND_36;
  reg [31:0] _RAND_37;
  reg [31:0] _RAND_38;
  reg [31:0] _RAND_39;
  reg [31:0] _RAND_40;
  reg [31:0] _RAND_41;
  reg [31:0] _RAND_42;
  reg [31:0] _RAND_43;
  reg [31:0] _RAND_44;
  reg [31:0] _RAND_45;
  reg [31:0] _RAND_46;
  reg [31:0] _RAND_47;
  reg [31:0] _RAND_48;
  reg [31:0] _RAND_49;
  reg [31:0] _RAND_50;
`endif // RANDOMIZE_REG_INIT
  wire  if_buffer_out_clock; // @[Decoupled.scala 361:21]
  wire  if_buffer_out_reset; // @[Decoupled.scala 361:21]
  wire  if_buffer_out_io_enq_ready; // @[Decoupled.scala 361:21]
  wire  if_buffer_out_io_enq_valid; // @[Decoupled.scala 361:21]
  wire [31:0] if_buffer_out_io_enq_bits_data; // @[Decoupled.scala 361:21]
  wire  if_buffer_out_io_deq_ready; // @[Decoupled.scala 361:21]
  wire  if_buffer_out_io_deq_valid; // @[Decoupled.scala 361:21]
  wire [31:0] if_buffer_out_io_deq_bits_data; // @[Decoupled.scala 361:21]
  wire  if_pc_buffer_out_clock; // @[Decoupled.scala 361:21]
  wire  if_pc_buffer_out_reset; // @[Decoupled.scala 361:21]
  wire  if_pc_buffer_out_io_enq_ready; // @[Decoupled.scala 361:21]
  wire  if_pc_buffer_out_io_enq_valid; // @[Decoupled.scala 361:21]
  wire [31:0] if_pc_buffer_out_io_enq_bits; // @[Decoupled.scala 361:21]
  wire  if_pc_buffer_out_io_deq_ready; // @[Decoupled.scala 361:21]
  wire  if_pc_buffer_out_io_deq_valid; // @[Decoupled.scala 361:21]
  wire [31:0] if_pc_buffer_out_io_deq_bits; // @[Decoupled.scala 361:21]
  wire  regfile_clock; // @[dpath.scala 216:24]
  wire [4:0] regfile_io_rs1_addr; // @[dpath.scala 216:24]
  wire [31:0] regfile_io_rs1_data; // @[dpath.scala 216:24]
  wire [4:0] regfile_io_rs2_addr; // @[dpath.scala 216:24]
  wire [31:0] regfile_io_rs2_data; // @[dpath.scala 216:24]
  wire [4:0] regfile_io_waddr; // @[dpath.scala 216:24]
  wire [31:0] regfile_io_wdata; // @[dpath.scala 216:24]
  wire  regfile_io_wen; // @[dpath.scala 216:24]
  wire  csr_clock; // @[dpath.scala 427:20]
  wire  csr_reset; // @[dpath.scala 427:20]
  wire  csr_io_ungated_clock; // @[dpath.scala 427:20]
  wire  csr_io_interrupts_debug; // @[dpath.scala 427:20]
  wire  csr_io_interrupts_mtip; // @[dpath.scala 427:20]
  wire  csr_io_interrupts_msip; // @[dpath.scala 427:20]
  wire  csr_io_interrupts_meip; // @[dpath.scala 427:20]
  wire  csr_io_hartid; // @[dpath.scala 427:20]
  wire [11:0] csr_io_rw_addr; // @[dpath.scala 427:20]
  wire [2:0] csr_io_rw_cmd; // @[dpath.scala 427:20]
  wire [31:0] csr_io_rw_rdata; // @[dpath.scala 427:20]
  wire [31:0] csr_io_rw_wdata; // @[dpath.scala 427:20]
  wire  csr_io_csr_stall; // @[dpath.scala 427:20]
  wire  csr_io_eret; // @[dpath.scala 427:20]
  wire  csr_io_singleStep; // @[dpath.scala 427:20]
  wire  csr_io_status_debug; // @[dpath.scala 427:20]
  wire  csr_io_status_cease; // @[dpath.scala 427:20]
  wire  csr_io_status_wfi; // @[dpath.scala 427:20]
  wire [31:0] csr_io_status_isa; // @[dpath.scala 427:20]
  wire [1:0] csr_io_status_dprv; // @[dpath.scala 427:20]
  wire  csr_io_status_dv; // @[dpath.scala 427:20]
  wire [1:0] csr_io_status_prv; // @[dpath.scala 427:20]
  wire  csr_io_status_v; // @[dpath.scala 427:20]
  wire  csr_io_status_sd; // @[dpath.scala 427:20]
  wire [22:0] csr_io_status_zero2; // @[dpath.scala 427:20]
  wire  csr_io_status_mpv; // @[dpath.scala 427:20]
  wire  csr_io_status_gva; // @[dpath.scala 427:20]
  wire  csr_io_status_mbe; // @[dpath.scala 427:20]
  wire  csr_io_status_sbe; // @[dpath.scala 427:20]
  wire [1:0] csr_io_status_sxl; // @[dpath.scala 427:20]
  wire [1:0] csr_io_status_uxl; // @[dpath.scala 427:20]
  wire  csr_io_status_sd_rv32; // @[dpath.scala 427:20]
  wire [7:0] csr_io_status_zero1; // @[dpath.scala 427:20]
  wire  csr_io_status_tsr; // @[dpath.scala 427:20]
  wire  csr_io_status_tw; // @[dpath.scala 427:20]
  wire  csr_io_status_tvm; // @[dpath.scala 427:20]
  wire  csr_io_status_mxr; // @[dpath.scala 427:20]
  wire  csr_io_status_sum; // @[dpath.scala 427:20]
  wire  csr_io_status_mprv; // @[dpath.scala 427:20]
  wire [1:0] csr_io_status_xs; // @[dpath.scala 427:20]
  wire [1:0] csr_io_status_fs; // @[dpath.scala 427:20]
  wire [1:0] csr_io_status_mpp; // @[dpath.scala 427:20]
  wire [1:0] csr_io_status_vs; // @[dpath.scala 427:20]
  wire  csr_io_status_spp; // @[dpath.scala 427:20]
  wire  csr_io_status_mpie; // @[dpath.scala 427:20]
  wire  csr_io_status_ube; // @[dpath.scala 427:20]
  wire  csr_io_status_spie; // @[dpath.scala 427:20]
  wire  csr_io_status_upie; // @[dpath.scala 427:20]
  wire  csr_io_status_mie; // @[dpath.scala 427:20]
  wire  csr_io_status_hie; // @[dpath.scala 427:20]
  wire  csr_io_status_sie; // @[dpath.scala 427:20]
  wire  csr_io_status_uie; // @[dpath.scala 427:20]
  wire [31:0] csr_io_evec; // @[dpath.scala 427:20]
  wire  csr_io_exception; // @[dpath.scala 427:20]
  wire  csr_io_retire; // @[dpath.scala 427:20]
  wire [31:0] csr_io_cause; // @[dpath.scala 427:20]
  wire [31:0] csr_io_pc; // @[dpath.scala 427:20]
  wire [31:0] csr_io_tval; // @[dpath.scala 427:20]
  wire [31:0] csr_io_time; // @[dpath.scala 427:20]
  wire  csr_io_interrupt; // @[dpath.scala 427:20]
  wire [31:0] csr_io_interrupt_cause; // @[dpath.scala 427:20]
  reg [31:0] if_reg_pc; // @[dpath.scala 68:39]
  reg  dec_reg_valid; // @[dpath.scala 71:39]
  reg [31:0] dec_reg_inst; // @[dpath.scala 72:39]
  reg [31:0] dec_reg_pc; // @[dpath.scala 73:39]
  reg  exe_reg_valid; // @[dpath.scala 76:39]
  reg [31:0] exe_reg_inst; // @[dpath.scala 77:39]
  reg [31:0] exe_reg_pc; // @[dpath.scala 78:39]
  reg [4:0] exe_reg_wbaddr; // @[dpath.scala 79:35]
  reg [4:0] exe_reg_rs1_addr; // @[dpath.scala 80:35]
  reg [4:0] exe_reg_rs2_addr; // @[dpath.scala 81:35]
  reg [31:0] exe_alu_op1; // @[dpath.scala 82:35]
  reg [31:0] brjmp_offset; // @[dpath.scala 83:35]
  reg [31:0] exe_reg_rs2_data; // @[dpath.scala 84:35]
  reg [3:0] exe_reg_ctrl_br_type; // @[dpath.scala 85:39]
  reg [3:0] exe_reg_ctrl_alu_fun; // @[dpath.scala 87:35]
  reg [1:0] exe_reg_ctrl_wb_sel; // @[dpath.scala 88:35]
  reg  exe_reg_ctrl_rf_wen; // @[dpath.scala 89:39]
  reg  exe_reg_ctrl_mem_val; // @[dpath.scala 90:39]
  reg  exe_reg_ctrl_mem_fcn; // @[dpath.scala 91:39]
  reg [2:0] exe_reg_ctrl_mem_typ; // @[dpath.scala 92:39]
  reg [2:0] exe_reg_ctrl_csr_cmd; // @[dpath.scala 93:39]
  reg  mem_reg_valid; // @[dpath.scala 96:39]
  reg [31:0] mem_reg_pc; // @[dpath.scala 97:35]
  reg [31:0] mem_reg_inst; // @[dpath.scala 98:35]
  reg [31:0] mem_reg_alu_out; // @[dpath.scala 99:35]
  reg [4:0] mem_reg_wbaddr; // @[dpath.scala 100:35]
  reg [4:0] mem_reg_rs1_addr; // @[dpath.scala 101:35]
  reg [4:0] mem_reg_rs2_addr; // @[dpath.scala 102:35]
  reg [31:0] mem_reg_op1_data; // @[dpath.scala 103:35]
  reg [31:0] mem_reg_op2_data; // @[dpath.scala 104:35]
  reg [31:0] mem_reg_rs2_data; // @[dpath.scala 105:35]
  reg  mem_reg_ctrl_rf_wen; // @[dpath.scala 106:39]
  reg  mem_reg_ctrl_mem_val; // @[dpath.scala 107:39]
  reg  mem_reg_ctrl_mem_fcn; // @[dpath.scala 108:39]
  reg [2:0] mem_reg_ctrl_mem_typ; // @[dpath.scala 109:39]
  reg [1:0] mem_reg_ctrl_wb_sel; // @[dpath.scala 110:35]
  reg [2:0] mem_reg_ctrl_csr_cmd; // @[dpath.scala 111:39]
  reg  wb_reg_valid; // @[dpath.scala 114:39]
  reg [4:0] wb_reg_wbaddr; // @[dpath.scala 115:35]
  reg [31:0] wb_reg_wbdata; // @[dpath.scala 116:35]
  reg  wb_reg_ctrl_rf_wen; // @[dpath.scala 117:39]
  wire  if_buffer_in_ready = if_buffer_out_io_enq_ready; // @[dpath.scala 128:27 Decoupled.scala 365:17]
  wire  _T_4 = ~reset; // @[dpath.scala 131:10]
  wire  _if_buffer_out_io_deq_ready_T = ~io_ctl_dec_stall; // @[dpath.scala 134:27]
  wire  _if_buffer_out_io_deq_ready_T_1 = ~io_ctl_full_stall; // @[dpath.scala 134:48]
  wire  _if_buffer_out_io_deq_ready_T_2 = ~io_ctl_dec_stall & ~io_ctl_full_stall; // @[dpath.scala 134:45]
  reg  if_reg_killed; // @[dpath.scala 145:31]
  wire  _T_7 = if_buffer_out_io_deq_ready & if_buffer_out_io_deq_valid; // @[Decoupled.scala 50:35]
  wire  _T_9 = (io_ctl_pipeline_kill | io_ctl_if_kill) & ~_T_7; // @[dpath.scala 146:51]
  wire  _GEN_0 = _T_9 | if_reg_killed; // @[dpath.scala 147:4 148:21 145:31]
  wire  _T_11 = if_reg_killed & _T_7; // @[dpath.scala 150:24]
  wire  _T_12 = if_buffer_in_ready & io_imem_resp_valid; // @[Decoupled.scala 50:35]
  wire  _T_16 = _T_12 & ~if_reg_killed | io_ctl_if_kill | io_ctl_pipeline_kill; // @[dpath.scala 156:66]
  wire  _T_17 = io_ctl_exe_pc_sel == 2'h0; // @[dpath.scala 169:45]
  wire  _T_20 = io_ctl_fencei & io_ctl_exe_pc_sel == 2'h0 & _if_buffer_out_io_deq_ready_T; // @[dpath.scala 169:54]
  wire  _T_24 = _T_20 & _if_buffer_out_io_deq_ready_T_1 & ~io_ctl_pipeline_kill; // @[dpath.scala 170:50]
  wire [31:0] if_pc_plus4 = if_reg_pc + 32'h4; // @[dpath.scala 161:33]
  wire  _if_pc_next_T_1 = io_ctl_exe_pc_sel == 2'h1; // @[dpath.scala 164:40]
  wire [31:0] exe_brjmp_target = exe_reg_pc + brjmp_offset; // @[dpath.scala 382:38]
  wire  _if_pc_next_T_2 = io_ctl_exe_pc_sel == 2'h2; // @[dpath.scala 165:40]
  wire [31:0] exe_adder_out = exe_alu_op1 + brjmp_offset; // @[dpath.scala 362:37]
  wire [31:0] exe_jump_reg_target = exe_adder_out & 32'hfffffffe; // @[dpath.scala 383:41]
  wire [31:0] exception_target = csr_io_evec; // @[dpath.scala 125:34 437:21]
  wire [31:0] _if_pc_next_T_3 = io_ctl_exe_pc_sel == 2'h2 ? exe_jump_reg_target : exception_target; // @[dpath.scala 165:21]
  wire [31:0] _if_pc_next_T_4 = io_ctl_exe_pc_sel == 2'h1 ? exe_brjmp_target : _if_pc_next_T_3; // @[dpath.scala 164:21]
  wire  _T_28 = io_ctl_if_kill | if_reg_killed; // @[dpath.scala 188:28]
  wire  _GEN_4 = if_buffer_out_io_deq_valid; // @[dpath.scala 194:7 195:24 200:24]
  wire [31:0] _GEN_5 = if_buffer_out_io_deq_valid ? if_buffer_out_io_deq_bits_data : 32'h4033; // @[dpath.scala 194:7 196:23 201:23]
  wire [4:0] dec_rs1_addr = dec_reg_inst[19:15]; // @[dpath.scala 210:35]
  wire [4:0] dec_rs2_addr = dec_reg_inst[24:20]; // @[dpath.scala 211:35]
  wire [4:0] dec_wbaddr = dec_reg_inst[11:7]; // @[dpath.scala 212:35]
  wire [11:0] imm_itype = dec_reg_inst[31:20]; // @[dpath.scala 233:33]
  wire [11:0] imm_stype = {dec_reg_inst[31:25],dec_wbaddr}; // @[Cat.scala 31:58]
  wire [11:0] imm_sbtype = {dec_reg_inst[31],dec_reg_inst[7],dec_reg_inst[30:25],dec_reg_inst[11:8]}; // @[Cat.scala 31:58]
  wire [19:0] imm_utype = dec_reg_inst[31:12]; // @[dpath.scala 236:33]
  wire [19:0] imm_ujtype = {dec_reg_inst[31],dec_reg_inst[19:12],dec_reg_inst[20],dec_reg_inst[30:21]}; // @[Cat.scala 31:58]
  wire [31:0] imm_z = {27'h0,dec_rs1_addr}; // @[Cat.scala 31:58]
  wire [19:0] _imm_itype_sext_T_2 = imm_itype[11] ? 20'hfffff : 20'h0; // @[Bitwise.scala 74:12]
  wire [31:0] imm_itype_sext = {_imm_itype_sext_T_2,imm_itype}; // @[Cat.scala 31:58]
  wire [19:0] _imm_stype_sext_T_2 = imm_stype[11] ? 20'hfffff : 20'h0; // @[Bitwise.scala 74:12]
  wire [31:0] imm_stype_sext = {_imm_stype_sext_T_2,dec_reg_inst[31:25],dec_wbaddr}; // @[Cat.scala 31:58]
  wire [18:0] _imm_sbtype_sext_T_2 = imm_sbtype[11] ? 19'h7ffff : 19'h0; // @[Bitwise.scala 74:12]
  wire [31:0] imm_sbtype_sext = {_imm_sbtype_sext_T_2,dec_reg_inst[31],dec_reg_inst[7],dec_reg_inst[30:25],dec_reg_inst[
    11:8],1'h0}; // @[Cat.scala 31:58]
  wire [31:0] imm_utype_sext = {imm_utype,12'h0}; // @[Cat.scala 31:58]
  wire [10:0] _imm_ujtype_sext_T_2 = imm_ujtype[19] ? 11'h7ff : 11'h0; // @[Bitwise.scala 74:12]
  wire [31:0] imm_ujtype_sext = {_imm_ujtype_sext_T_2,dec_reg_inst[31],dec_reg_inst[19:12],dec_reg_inst[20],dec_reg_inst
    [30:21],1'h0}; // @[Cat.scala 31:58]
  wire  _dec_alu_op2_T = io_ctl_op2_sel == 3'h0; // @[dpath.scala 250:32]
  wire  _dec_alu_op2_T_1 = io_ctl_op2_sel == 3'h1; // @[dpath.scala 251:32]
  wire  _dec_alu_op2_T_2 = io_ctl_op2_sel == 3'h2; // @[dpath.scala 252:32]
  wire  _dec_alu_op2_T_3 = io_ctl_op2_sel == 3'h3; // @[dpath.scala 253:32]
  wire  _dec_alu_op2_T_4 = io_ctl_op2_sel == 3'h4; // @[dpath.scala 254:32]
  wire  _dec_alu_op2_T_5 = io_ctl_op2_sel == 3'h5; // @[dpath.scala 255:32]
  wire [31:0] _dec_alu_op2_T_6 = _dec_alu_op2_T_5 ? imm_ujtype_sext : 32'h0; // @[Mux.scala 101:16]
  wire [31:0] _dec_alu_op2_T_7 = _dec_alu_op2_T_4 ? imm_utype_sext : _dec_alu_op2_T_6; // @[Mux.scala 101:16]
  wire [31:0] _dec_alu_op2_T_8 = _dec_alu_op2_T_3 ? imm_sbtype_sext : _dec_alu_op2_T_7; // @[Mux.scala 101:16]
  wire [31:0] _dec_alu_op2_T_9 = _dec_alu_op2_T_2 ? imm_stype_sext : _dec_alu_op2_T_8; // @[Mux.scala 101:16]
  wire [31:0] _dec_alu_op2_T_10 = _dec_alu_op2_T_1 ? imm_itype_sext : _dec_alu_op2_T_9; // @[Mux.scala 101:16]
  wire [31:0] dec_alu_op2 = _dec_alu_op2_T ? regfile_io_rs2_data : _dec_alu_op2_T_10; // @[Mux.scala 101:16]
  wire  _dec_op1_data_T = io_ctl_op1_sel == 2'h2; // @[dpath.scala 272:45]
  wire  _dec_op1_data_T_1 = io_ctl_op1_sel == 2'h1; // @[dpath.scala 273:45]
  wire  _dec_op1_data_T_3 = dec_rs1_addr != 5'h0; // @[dpath.scala 274:80]
  wire  _dec_op1_data_T_5 = exe_reg_wbaddr == dec_rs1_addr & dec_rs1_addr != 5'h0 & exe_reg_ctrl_rf_wen; // @[dpath.scala 274:89]
  wire  _dec_op1_data_T_9 = mem_reg_wbaddr == dec_rs1_addr & _dec_op1_data_T_3 & mem_reg_ctrl_rf_wen; // @[dpath.scala 275:89]
  wire  _dec_op1_data_T_13 = wb_reg_wbaddr == dec_rs1_addr & _dec_op1_data_T_3 & wb_reg_ctrl_rf_wen; // @[dpath.scala 276:89]
  wire [31:0] _dec_op1_data_T_14 = _dec_op1_data_T_13 ? wb_reg_wbdata : regfile_io_rs1_data; // @[Mux.scala 101:16]
  wire  _mem_wbdata_T = mem_reg_ctrl_wb_sel == 2'h0; // @[dpath.scala 473:40]
  wire  _mem_wbdata_T_1 = mem_reg_ctrl_wb_sel == 2'h2; // @[dpath.scala 474:40]
  wire  _mem_wbdata_T_2 = mem_reg_ctrl_wb_sel == 2'h1; // @[dpath.scala 475:40]
  wire  _mem_wbdata_T_3 = mem_reg_ctrl_wb_sel == 2'h3; // @[dpath.scala 476:40]
  wire [31:0] _mem_wbdata_T_4 = _mem_wbdata_T_3 ? csr_io_rw_rdata : mem_reg_alu_out; // @[Mux.scala 101:16]
  wire [31:0] _mem_wbdata_T_5 = _mem_wbdata_T_2 ? io_dmem_resp_bits_data : _mem_wbdata_T_4; // @[Mux.scala 101:16]
  wire [31:0] _mem_wbdata_T_6 = _mem_wbdata_T_1 ? mem_reg_alu_out : _mem_wbdata_T_5; // @[Mux.scala 101:16]
  wire [31:0] mem_wbdata = _mem_wbdata_T ? mem_reg_alu_out : _mem_wbdata_T_6; // @[Mux.scala 101:16]
  wire [31:0] _dec_op1_data_T_15 = _dec_op1_data_T_9 ? mem_wbdata : _dec_op1_data_T_14; // @[Mux.scala 101:16]
  wire  _exe_alu_out_T = exe_reg_ctrl_alu_fun == 4'h0; // @[dpath.scala 366:41]
  wire  _exe_alu_out_T_1 = exe_reg_ctrl_alu_fun == 4'h1; // @[dpath.scala 367:41]
  wire [31:0] _exe_alu_out_T_3 = exe_alu_op1 - brjmp_offset; // @[dpath.scala 367:71]
  wire  _exe_alu_out_T_4 = exe_reg_ctrl_alu_fun == 4'h5; // @[dpath.scala 368:41]
  wire [31:0] _exe_alu_out_T_5 = exe_alu_op1 & brjmp_offset; // @[dpath.scala 368:71]
  wire  _exe_alu_out_T_6 = exe_reg_ctrl_alu_fun == 4'h6; // @[dpath.scala 369:41]
  wire [31:0] _exe_alu_out_T_7 = exe_alu_op1 | brjmp_offset; // @[dpath.scala 369:71]
  wire  _exe_alu_out_T_8 = exe_reg_ctrl_alu_fun == 4'h7; // @[dpath.scala 370:41]
  wire [31:0] _exe_alu_out_T_9 = exe_alu_op1 ^ brjmp_offset; // @[dpath.scala 370:71]
  wire  _exe_alu_out_T_10 = exe_reg_ctrl_alu_fun == 4'h8; // @[dpath.scala 371:41]
  wire  _exe_alu_out_T_13 = $signed(exe_alu_op1) < $signed(brjmp_offset); // @[dpath.scala 371:80]
  wire  _exe_alu_out_T_14 = exe_reg_ctrl_alu_fun == 4'h9; // @[dpath.scala 372:41]
  wire  _exe_alu_out_T_15 = exe_alu_op1 < brjmp_offset; // @[dpath.scala 372:71]
  wire  _exe_alu_out_T_16 = exe_reg_ctrl_alu_fun == 4'h2; // @[dpath.scala 373:41]
  wire [4:0] alu_shamt = brjmp_offset[4:0]; // @[dpath.scala 361:35]
  wire [62:0] _GEN_3 = {{31'd0}, exe_alu_op1}; // @[dpath.scala 373:72]
  wire [62:0] _exe_alu_out_T_17 = _GEN_3 << alu_shamt; // @[dpath.scala 373:72]
  wire  _exe_alu_out_T_19 = exe_reg_ctrl_alu_fun == 4'h4; // @[dpath.scala 374:41]
  wire [31:0] _exe_alu_out_T_22 = $signed(exe_alu_op1) >>> alu_shamt; // @[dpath.scala 374:100]
  wire  _exe_alu_out_T_23 = exe_reg_ctrl_alu_fun == 4'h3; // @[dpath.scala 375:41]
  wire [31:0] _exe_alu_out_T_24 = exe_alu_op1 >> alu_shamt; // @[dpath.scala 375:71]
  wire  _exe_alu_out_T_25 = exe_reg_ctrl_alu_fun == 4'ha; // @[dpath.scala 376:41]
  wire  _exe_alu_out_T_26 = exe_reg_ctrl_alu_fun == 4'hb; // @[dpath.scala 377:41]
  wire [31:0] _exe_alu_out_T_27 = _exe_alu_out_T_26 ? brjmp_offset : exe_reg_inst; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_28 = _exe_alu_out_T_25 ? exe_alu_op1 : _exe_alu_out_T_27; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_29 = _exe_alu_out_T_23 ? _exe_alu_out_T_24 : _exe_alu_out_T_28; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_30 = _exe_alu_out_T_19 ? _exe_alu_out_T_22 : _exe_alu_out_T_29; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_31 = _exe_alu_out_T_16 ? _exe_alu_out_T_17[31:0] : _exe_alu_out_T_30; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_32 = _exe_alu_out_T_14 ? {{31'd0}, _exe_alu_out_T_15} : _exe_alu_out_T_31; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_33 = _exe_alu_out_T_10 ? {{31'd0}, _exe_alu_out_T_13} : _exe_alu_out_T_32; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_34 = _exe_alu_out_T_8 ? _exe_alu_out_T_9 : _exe_alu_out_T_33; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_35 = _exe_alu_out_T_6 ? _exe_alu_out_T_7 : _exe_alu_out_T_34; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_36 = _exe_alu_out_T_4 ? _exe_alu_out_T_5 : _exe_alu_out_T_35; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_37 = _exe_alu_out_T_1 ? _exe_alu_out_T_3 : _exe_alu_out_T_36; // @[Mux.scala 101:16]
  wire [31:0] exe_alu_out = _exe_alu_out_T ? exe_adder_out : _exe_alu_out_T_37; // @[Mux.scala 101:16]
  wire [31:0] _dec_op1_data_T_16 = _dec_op1_data_T_5 ? exe_alu_out : _dec_op1_data_T_15; // @[Mux.scala 101:16]
  wire  _dec_op2_data_T_1 = dec_rs2_addr != 5'h0; // @[dpath.scala 280:80]
  wire  _dec_op2_data_T_3 = exe_reg_wbaddr == dec_rs2_addr & dec_rs2_addr != 5'h0 & exe_reg_ctrl_rf_wen; // @[dpath.scala 280:89]
  wire  _dec_op2_data_T_5 = exe_reg_wbaddr == dec_rs2_addr & dec_rs2_addr != 5'h0 & exe_reg_ctrl_rf_wen & _dec_alu_op2_T
    ; // @[dpath.scala 280:112]
  wire  _dec_op2_data_T_9 = mem_reg_wbaddr == dec_rs2_addr & _dec_op2_data_T_1 & mem_reg_ctrl_rf_wen; // @[dpath.scala 281:89]
  wire  _dec_op2_data_T_11 = mem_reg_wbaddr == dec_rs2_addr & _dec_op2_data_T_1 & mem_reg_ctrl_rf_wen & _dec_alu_op2_T; // @[dpath.scala 281:112]
  wire  _dec_op2_data_T_15 = wb_reg_wbaddr == dec_rs2_addr & _dec_op2_data_T_1 & wb_reg_ctrl_rf_wen; // @[dpath.scala 282:89]
  wire  _dec_op2_data_T_17 = wb_reg_wbaddr == dec_rs2_addr & _dec_op2_data_T_1 & wb_reg_ctrl_rf_wen & _dec_alu_op2_T; // @[dpath.scala 282:112]
  wire [31:0] _dec_op2_data_T_18 = _dec_op2_data_T_17 ? wb_reg_wbdata : dec_alu_op2; // @[Mux.scala 101:16]
  wire [31:0] _dec_rs2_data_T_12 = _dec_op2_data_T_15 ? wb_reg_wbdata : regfile_io_rs2_data; // @[Mux.scala 101:16]
  wire  _T_31 = io_ctl_dec_stall & _if_buffer_out_io_deq_ready_T_1 | io_ctl_pipeline_kill; // @[dpath.scala 303:51]
  wire [1:0] _GEN_19 = io_ctl_dec_kill ? 2'h0 : io_ctl_mem_fcn; // @[dpath.scala 330:7 336:32 347:32]
  wire [1:0] _GEN_37 = _if_buffer_out_io_deq_ready_T_2 ? _GEN_19 : {{1'd0}, exe_reg_ctrl_mem_fcn}; // @[dpath.scala 317:4 91:39]
  wire [1:0] _GEN_46 = _T_31 ? 2'h0 : _GEN_37; // @[dpath.scala 304:4 312:29]
  wire  _io_dat_exe_inst_misaligned_T_7 = |exe_jump_reg_target[1:0] & _if_pc_next_T_2; // @[dpath.scala 389:65]
  reg [31:0] mem_tval_inst_ma_REG; // @[dpath.scala 390:31]
  wire [31:0] exe_pc_plus4 = exe_reg_pc + 32'h4; // @[dpath.scala 392:38]
  wire  _csr_io_tval_T = io_ctl_mem_exception_cause == 32'h2; // @[dpath.scala 440:47]
  reg [31:0] csr_io_tval_REG; // @[dpath.scala 440:91]
  wire  _csr_io_tval_T_1 = io_ctl_mem_exception_cause == 32'h0; // @[dpath.scala 441:47]
  wire  _csr_io_tval_T_2 = io_ctl_mem_exception_cause == 32'h6; // @[dpath.scala 442:47]
  wire  _csr_io_tval_T_3 = io_ctl_mem_exception_cause == 32'h4; // @[dpath.scala 443:47]
  wire [31:0] _csr_io_tval_T_4 = _csr_io_tval_T_3 ? mem_reg_alu_out : 32'h0; // @[Mux.scala 101:16]
  wire [31:0] _csr_io_tval_T_5 = _csr_io_tval_T_2 ? mem_reg_alu_out : _csr_io_tval_T_4; // @[Mux.scala 101:16]
  wire [31:0] _csr_io_tval_T_6 = _csr_io_tval_T_1 ? mem_tval_inst_ma_REG : _csr_io_tval_T_5; // @[Mux.scala 101:16]
  reg  reg_interrupt_handled; // @[dpath.scala 447:39]
  wire  interrupt_edge = csr_io_interrupt & ~reg_interrupt_handled; // @[dpath.scala 448:42]
  wire [2:0] _misaligned_mask_T_1 = mem_reg_ctrl_mem_typ - 3'h1; // @[dpath.scala 466:59]
  wire [5:0] _misaligned_mask_T_3 = 6'h7 << _misaligned_mask_T_1[1:0]; // @[dpath.scala 466:34]
  wire [5:0] _misaligned_mask_T_4 = ~_misaligned_mask_T_3; // @[dpath.scala 466:23]
  wire [2:0] misaligned_mask = _misaligned_mask_T_4[2:0]; // @[dpath.scala 465:30 466:20]
  wire [2:0] _io_dat_mem_data_misaligned_T_1 = misaligned_mask & mem_reg_alu_out[2:0]; // @[dpath.scala 467:51]
  wire  _wb_reg_ctrl_rf_wen_T_1 = io_ctl_mem_exception | interrupt_edge ? 1'h0 : mem_reg_ctrl_rf_wen; // @[dpath.scala 488:34]
  wire  _GEN_91 = _if_buffer_out_io_deq_ready_T_1 & (mem_reg_valid & ~io_ctl_mem_exception & ~interrupt_edge); // @[dpath.scala 484:4 485:28 492:28]
  wire  _GEN_94 = _if_buffer_out_io_deq_ready_T_1 & _wb_reg_ctrl_rf_wen_T_1; // @[dpath.scala 484:4 488:28 493:28]
  reg [31:0] wb_reg_inst; // @[dpath.scala 518:29]
  wire [31:0] _T_37 = csr_io_time; // @[dpath.scala 521:18]
  reg [31:0] REG; // @[dpath.scala 523:14]
  reg [4:0] REG_1; // @[dpath.scala 527:14]
  reg [31:0] REG_2; // @[dpath.scala 528:14]
  reg [4:0] REG_3; // @[dpath.scala 529:14]
  reg [31:0] REG_4; // @[dpath.scala 530:14]
  wire [7:0] _T_38 = io_ctl_dec_stall ? 8'h53 : 8'h20; // @[Mux.scala 101:16]
  wire [7:0] _T_39 = io_ctl_full_stall ? 8'h46 : _T_38; // @[Mux.scala 101:16]
  wire [7:0] _T_40 = io_ctl_pipeline_kill ? 8'h4b : _T_39; // @[Mux.scala 101:16]
  wire [7:0] _T_42 = 2'h2 == io_ctl_exe_pc_sel ? 8'h52 : 8'h42; // @[Mux.scala 81:58]
  wire [7:0] _T_44 = 2'h3 == io_ctl_exe_pc_sel ? 8'h45 : _T_42; // @[Mux.scala 81:58]
  wire [7:0] _T_46 = 2'h0 == io_ctl_exe_pc_sel ? 8'h20 : _T_44; // @[Mux.scala 81:58]
  wire [7:0] _T_47 = csr_io_exception ? 8'h58 : 8'h20; // @[dpath.scala 541:10]
  Queue_21_5stage Queue_21_5stage ( // @[Decoupled.scala 361:21]
    .clock(if_buffer_out_clock),
    .reset(if_buffer_out_reset),
    .io_enq_ready(if_buffer_out_io_enq_ready),
    .io_enq_valid(if_buffer_out_io_enq_valid),
    .io_enq_bits_data(if_buffer_out_io_enq_bits_data),
    .io_deq_ready(if_buffer_out_io_deq_ready),
    .io_deq_valid(if_buffer_out_io_deq_valid),
    .io_deq_bits_data(if_buffer_out_io_deq_bits_data)
  );
  Queue_22_5stage Queue_22_5stage ( // @[Decoupled.scala 361:21]
    .clock(if_pc_buffer_out_clock),
    .reset(if_pc_buffer_out_reset),
    .io_enq_ready(if_pc_buffer_out_io_enq_ready),
    .io_enq_valid(if_pc_buffer_out_io_enq_valid),
    .io_enq_bits(if_pc_buffer_out_io_enq_bits),
    .io_deq_ready(if_pc_buffer_out_io_deq_ready),
    .io_deq_valid(if_pc_buffer_out_io_deq_valid),
    .io_deq_bits(if_pc_buffer_out_io_deq_bits)
  );
  RegisterFile_5stage RegisterFile_5stage ( // @[dpath.scala 216:24]
    .clock(regfile_clock),
    .reset(reset),
    .io_rs1_addr(regfile_io_rs1_addr),
    .io_rs1_data(regfile_io_rs1_data),
    .io_rs2_addr(regfile_io_rs2_addr),
    .io_rs2_data(regfile_io_rs2_data),
    .io_waddr(regfile_io_waddr),
    .io_wdata(regfile_io_wdata),
    .io_wen(regfile_io_wen),
    .rvfi_regfile(rvfi_regfile)
  );
  CSRFile_5stage CSRFile_5stage ( // @[dpath.scala 427:20]
    .clock(csr_clock),
    .reset(csr_reset),
    .io_ungated_clock(csr_io_ungated_clock),
    .io_interrupts_debug(csr_io_interrupts_debug),
    .io_interrupts_mtip(csr_io_interrupts_mtip),
    .io_interrupts_msip(csr_io_interrupts_msip),
    .io_interrupts_meip(csr_io_interrupts_meip),
    .io_hartid(csr_io_hartid),
    .io_rw_addr(csr_io_rw_addr),
    .io_rw_cmd(csr_io_rw_cmd),
    .io_rw_rdata(csr_io_rw_rdata),
    .io_rw_wdata(csr_io_rw_wdata),
    .io_csr_stall(csr_io_csr_stall),
    .io_eret(csr_io_eret),
    .io_singleStep(csr_io_singleStep),
    .io_status_debug(csr_io_status_debug),
    .io_status_cease(csr_io_status_cease),
    .io_status_wfi(csr_io_status_wfi),
    .io_status_isa(csr_io_status_isa),
    .io_status_dprv(csr_io_status_dprv),
    .io_status_dv(csr_io_status_dv),
    .io_status_prv(csr_io_status_prv),
    .io_status_v(csr_io_status_v),
    .io_status_sd(csr_io_status_sd),
    .io_status_zero2(csr_io_status_zero2),
    .io_status_mpv(csr_io_status_mpv),
    .io_status_gva(csr_io_status_gva),
    .io_status_mbe(csr_io_status_mbe),
    .io_status_sbe(csr_io_status_sbe),
    .io_status_sxl(csr_io_status_sxl),
    .io_status_uxl(csr_io_status_uxl),
    .io_status_sd_rv32(csr_io_status_sd_rv32),
    .io_status_zero1(csr_io_status_zero1),
    .io_status_tsr(csr_io_status_tsr),
    .io_status_tw(csr_io_status_tw),
    .io_status_tvm(csr_io_status_tvm),
    .io_status_mxr(csr_io_status_mxr),
    .io_status_sum(csr_io_status_sum),
    .io_status_mprv(csr_io_status_mprv),
    .io_status_xs(csr_io_status_xs),
    .io_status_fs(csr_io_status_fs),
    .io_status_mpp(csr_io_status_mpp),
    .io_status_vs(csr_io_status_vs),
    .io_status_spp(csr_io_status_spp),
    .io_status_mpie(csr_io_status_mpie),
    .io_status_ube(csr_io_status_ube),
    .io_status_spie(csr_io_status_spie),
    .io_status_upie(csr_io_status_upie),
    .io_status_mie(csr_io_status_mie),
    .io_status_hie(csr_io_status_hie),
    .io_status_sie(csr_io_status_sie),
    .io_status_uie(csr_io_status_uie),
    .io_evec(csr_io_evec),
    .io_exception(csr_io_exception),
    .io_retire(csr_io_retire),
    .io_cause(csr_io_cause),
    .io_pc(csr_io_pc),
    .io_tval(csr_io_tval),
    .io_time(csr_io_time),
    .io_interrupt(csr_io_interrupt),
    .io_interrupt_cause(csr_io_interrupt_cause)
  );
  assign io_imem_req_valid = if_buffer_out_io_enq_ready; // @[dpath.scala 128:27 Decoupled.scala 365:17]
  assign io_imem_req_bits_addr = if_reg_pc; // @[dpath.scala 179:26]
  assign io_dmem_req_valid = mem_reg_ctrl_mem_val & ~io_dat_mem_data_misaligned; // @[dpath.scala 512:50]
  assign io_dmem_req_bits_addr = mem_reg_alu_out; // @[dpath.scala 513:26]
  assign io_dmem_req_bits_data = mem_reg_rs2_data; // @[dpath.scala 516:26]
  assign io_dmem_req_bits_fcn = mem_reg_ctrl_mem_fcn; // @[dpath.scala 514:26]
  assign io_dmem_req_bits_typ = mem_reg_ctrl_mem_typ; // @[dpath.scala 515:26]
  assign io_dat_dec_inst = dec_reg_inst; // @[dpath.scala 503:22]
  assign io_dat_dec_valid = dec_reg_valid; // @[dpath.scala 502:22]
  assign io_dat_exe_br_eq = exe_alu_op1 == exe_reg_rs2_data; // @[dpath.scala 504:43]
  assign io_dat_exe_br_lt = $signed(exe_alu_op1) < $signed(exe_reg_rs2_data); // @[dpath.scala 505:52]
  assign io_dat_exe_br_ltu = exe_alu_op1 < exe_reg_rs2_data; // @[dpath.scala 506:52]
  assign io_dat_exe_br_type = exe_reg_ctrl_br_type; // @[dpath.scala 507:22]
  assign io_dat_exe_inst_misaligned = |exe_brjmp_target[1:0] & _if_pc_next_T_1 | _io_dat_exe_inst_misaligned_T_7; // @[dpath.scala 388:100]
  assign io_dat_mem_ctrl_dmem_val = mem_reg_ctrl_mem_val; // @[dpath.scala 509:29]
  assign io_dat_mem_data_misaligned = |_io_dat_mem_data_misaligned_T_1 & mem_reg_ctrl_mem_val; // @[dpath.scala 467:93]
  assign io_dat_mem_store = mem_reg_ctrl_mem_fcn; // @[dpath.scala 468:45]
  assign io_dat_csr_eret = csr_io_eret; // @[dpath.scala 456:20]
  assign io_dat_csr_interrupt = csr_io_interrupt & ~reg_interrupt_handled; // @[dpath.scala 448:42]
  assign if_buffer_out_clock = clock;
  assign if_buffer_out_reset = reset;
  assign if_buffer_out_io_enq_valid = io_imem_resp_valid; // @[dpath.scala 128:27 130:23]
  assign if_buffer_out_io_enq_bits_data = io_imem_resp_bits_data; // @[dpath.scala 128:27 129:22]
  assign if_buffer_out_io_deq_ready = ~io_ctl_dec_stall & ~io_ctl_full_stall; // @[dpath.scala 134:45]
  assign if_pc_buffer_out_clock = clock;
  assign if_pc_buffer_out_reset = reset;
  assign if_pc_buffer_out_io_enq_valid = io_imem_resp_valid; // @[dpath.scala 128:27 130:23]
  assign if_pc_buffer_out_io_enq_bits = if_reg_pc; // @[dpath.scala 137:30 138:25]
  assign if_pc_buffer_out_io_deq_ready = if_buffer_out_io_deq_ready; // @[dpath.scala 142:27]
  assign regfile_clock = clock;
  assign regfile_io_rs1_addr = dec_reg_inst[19:15]; // @[dpath.scala 210:35]
  assign regfile_io_rs2_addr = dec_reg_inst[24:20]; // @[dpath.scala 211:35]
  assign regfile_io_waddr = wb_reg_wbaddr; // @[dpath.scala 221:21]
  assign regfile_io_wdata = wb_reg_wbdata; // @[dpath.scala 222:21]
  assign regfile_io_wen = wb_reg_ctrl_rf_wen; // @[dpath.scala 223:21]
  assign csr_clock = clock;
  assign csr_reset = reset;
  assign csr_io_ungated_clock = clock; // @[dpath.scala 454:25]
  assign csr_io_interrupts_debug = io_interrupt_debug; // @[dpath.scala 450:22]
  assign csr_io_interrupts_mtip = io_interrupt_mtip; // @[dpath.scala 450:22]
  assign csr_io_interrupts_msip = io_interrupt_msip; // @[dpath.scala 450:22]
  assign csr_io_interrupts_meip = io_interrupt_meip; // @[dpath.scala 450:22]
  assign csr_io_hartid = io_hartid; // @[dpath.scala 451:18]
  assign csr_io_rw_addr = mem_reg_inst[31:20]; // @[dpath.scala 430:36]
  assign csr_io_rw_cmd = mem_reg_ctrl_csr_cmd; // @[dpath.scala 432:21]
  assign csr_io_rw_wdata = mem_reg_alu_out; // @[dpath.scala 431:21]
  assign csr_io_exception = io_ctl_mem_exception; // @[dpath.scala 435:21]
  assign csr_io_retire = wb_reg_valid; // @[dpath.scala 434:21]
  assign csr_io_cause = io_ctl_mem_exception ? io_ctl_mem_exception_cause : csr_io_interrupt_cause; // @[dpath.scala 453:23]
  assign csr_io_pc = mem_reg_pc; // @[dpath.scala 436:21]
  assign csr_io_tval = _csr_io_tval_T ? csr_io_tval_REG : _csr_io_tval_T_6; // @[Mux.scala 101:16]

  // reg [31:0] exe_reg_new_pc = 0;
  reg [31:0] mem_reg_new_pc = 32'b00000000000000000000000000000000;
  reg [31:0] wb_reg_new_pc = 32'b00000000000000000000000000000000;
  always @(posedge clock) begin
    if (reset) begin // @[dpath.scala 68:39]
      if_reg_pc <= io_reset_vector; // @[dpath.scala 68:39]
    end else if (_T_16) begin // @[dpath.scala 157:4]
      if (!(_T_24)) begin // @[dpath.scala 171:4]
        if (_T_17) begin // @[dpath.scala 163:21]
          if_reg_pc <= if_pc_plus4;
          mem_reg_new_pc <= if_pc_plus4;
        end else begin
          if_reg_pc <= _if_pc_next_T_4;
          mem_reg_new_pc <= _if_pc_next_T_4;
        end
      end
    end
    if (reset) begin // @[dpath.scala 71:39]
      dec_reg_valid <= 1'h0; // @[dpath.scala 71:39]
    end else if (io_ctl_pipeline_kill) begin // @[dpath.scala 182:4]
      dec_reg_valid <= 1'h0; // @[dpath.scala 183:21]
    end else if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 187:4]
      if (_T_28) begin // @[dpath.scala 189:7]
        dec_reg_valid <= 1'h0; // @[dpath.scala 190:24]
      end else begin
        dec_reg_valid <= _GEN_4;
      end
    end
    if (reset) begin // @[dpath.scala 72:39]
      dec_reg_inst <= 32'h4033; // @[dpath.scala 72:39]
    end else if (io_ctl_pipeline_kill) begin // @[dpath.scala 182:4]
      dec_reg_inst <= 32'h4033; // @[dpath.scala 184:20]
    end else if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 187:4]
      if (_T_28) begin // @[dpath.scala 189:7]
        dec_reg_inst <= 32'h4033; // @[dpath.scala 191:23]
      end else begin
        dec_reg_inst <= _GEN_5;
      end
    end
    if (reset) begin // @[dpath.scala 73:39]
      dec_reg_pc <= 32'h0; // @[dpath.scala 73:39]
    end else if (!(io_ctl_pipeline_kill)) begin // @[dpath.scala 182:4]
      if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 187:4]
        dec_reg_pc <= if_pc_buffer_out_io_deq_bits; // @[dpath.scala 204:18]
      end
    end
    if (reset) begin // @[dpath.scala 76:39]
      exe_reg_valid <= 1'h0; // @[dpath.scala 76:39]
    end else if (_T_31) begin // @[dpath.scala 304:4]
      exe_reg_valid <= 1'h0; // @[dpath.scala 307:29]
    end else if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
      if (io_ctl_dec_kill) begin // @[dpath.scala 330:7]
        exe_reg_valid <= 1'h0; // @[dpath.scala 331:32]
      end else begin
        exe_reg_valid <= dec_reg_valid; // @[dpath.scala 342:32]
      end
    end
    if (reset) begin // @[dpath.scala 77:39]
      exe_reg_inst <= 32'h4033; // @[dpath.scala 77:39]
    end else if (_T_31) begin // @[dpath.scala 304:4]
      exe_reg_inst <= 32'h4033; // @[dpath.scala 308:29]
    end else if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
      if (io_ctl_dec_kill) begin // @[dpath.scala 330:7]
        exe_reg_inst <= 32'h4033; // @[dpath.scala 332:32]
      end else begin
        exe_reg_inst <= dec_reg_inst; // @[dpath.scala 343:32]
      end
    end
    if (reset) begin // @[dpath.scala 78:39]
      exe_reg_pc <= 32'h0; // @[dpath.scala 78:39]
    end else if (!(_T_31)) begin // @[dpath.scala 304:4]
      if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
        exe_reg_pc <= dec_reg_pc; // @[dpath.scala 319:29]
      end
    end
    if (_T_31) begin // @[dpath.scala 304:4]
      exe_reg_wbaddr <= 5'h0; // @[dpath.scala 309:29]
    end else if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
      if (io_ctl_dec_kill) begin // @[dpath.scala 330:7]
        exe_reg_wbaddr <= 5'h0; // @[dpath.scala 333:32]
      end else begin
        exe_reg_wbaddr <= dec_wbaddr; // @[dpath.scala 344:32]
      end
    end
    if (!(_T_31)) begin // @[dpath.scala 304:4]
      if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
        exe_reg_rs1_addr <= dec_rs1_addr; // @[dpath.scala 320:29]
      end
    end
    if (!(_T_31)) begin // @[dpath.scala 304:4]
      if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
        exe_reg_rs2_addr <= dec_rs2_addr; // @[dpath.scala 321:29]
      end
    end
    if (!(_T_31)) begin // @[dpath.scala 304:4]
      if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
        if (_dec_op1_data_T) begin // @[Mux.scala 101:16]
          exe_alu_op1 <= imm_z;
        end else if (_dec_op1_data_T_1) begin // @[Mux.scala 101:16]
          exe_alu_op1 <= dec_reg_pc;
        end else begin
          exe_alu_op1 <= _dec_op1_data_T_16;
        end
      end
    end
    if (!(_T_31)) begin // @[dpath.scala 304:4]
      if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
        if (_dec_op2_data_T_5) begin // @[Mux.scala 101:16]
          if (_exe_alu_out_T) begin // @[Mux.scala 101:16]
            brjmp_offset <= exe_adder_out;
          end else begin
            brjmp_offset <= _exe_alu_out_T_37;
          end
        end else if (_dec_op2_data_T_11) begin // @[Mux.scala 101:16]
          brjmp_offset <= mem_wbdata;
        end else begin
          brjmp_offset <= _dec_op2_data_T_18;
        end
      end
    end
    if (!(_T_31)) begin // @[dpath.scala 304:4]
      if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
        if (_dec_op2_data_T_3) begin // @[Mux.scala 101:16]
          if (_exe_alu_out_T) begin // @[Mux.scala 101:16]
            exe_reg_rs2_data <= exe_adder_out;
          end else begin
            exe_reg_rs2_data <= _exe_alu_out_T_37;
          end
        end else if (_dec_op2_data_T_9) begin // @[Mux.scala 101:16]
          exe_reg_rs2_data <= mem_wbdata;
        end else begin
          exe_reg_rs2_data <= _dec_rs2_data_T_12;
        end
      end
    end
    if (reset) begin // @[dpath.scala 85:39]
      exe_reg_ctrl_br_type <= 4'h0; // @[dpath.scala 85:39]
    end else if (_T_31) begin // @[dpath.scala 304:4]
      exe_reg_ctrl_br_type <= 4'h0; // @[dpath.scala 314:29]
    end else if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
      if (io_ctl_dec_kill) begin // @[dpath.scala 330:7]
        exe_reg_ctrl_br_type <= 4'h0; // @[dpath.scala 338:32]
      end else begin
        exe_reg_ctrl_br_type <= io_ctl_br_type; // @[dpath.scala 350:32]
      end
    end
    if (!(_T_31)) begin // @[dpath.scala 304:4]
      if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
        exe_reg_ctrl_alu_fun <= io_ctl_alu_fun; // @[dpath.scala 326:29]
      end
    end
    if (!(_T_31)) begin // @[dpath.scala 304:4]
      if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
        exe_reg_ctrl_wb_sel <= io_ctl_wb_sel; // @[dpath.scala 327:29]
      end
    end
    if (reset) begin // @[dpath.scala 89:39]
      exe_reg_ctrl_rf_wen <= 1'h0; // @[dpath.scala 89:39]
    end else if (_T_31) begin // @[dpath.scala 304:4]
      exe_reg_ctrl_rf_wen <= 1'h0; // @[dpath.scala 310:29]
    end else if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
      if (io_ctl_dec_kill) begin // @[dpath.scala 330:7]
        exe_reg_ctrl_rf_wen <= 1'h0; // @[dpath.scala 334:32]
      end else begin
        exe_reg_ctrl_rf_wen <= io_ctl_rf_wen; // @[dpath.scala 345:32]
      end
    end
    if (reset) begin // @[dpath.scala 90:39]
      exe_reg_ctrl_mem_val <= 1'h0; // @[dpath.scala 90:39]
    end else if (_T_31) begin // @[dpath.scala 304:4]
      exe_reg_ctrl_mem_val <= 1'h0; // @[dpath.scala 311:29]
    end else if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
      if (io_ctl_dec_kill) begin // @[dpath.scala 330:7]
        exe_reg_ctrl_mem_val <= 1'h0; // @[dpath.scala 335:32]
      end else begin
        exe_reg_ctrl_mem_val <= io_ctl_mem_val; // @[dpath.scala 346:32]
      end
    end
    if (reset) begin // @[dpath.scala 91:39]
      exe_reg_ctrl_mem_fcn <= 1'h0; // @[dpath.scala 91:39]
    end else begin
      exe_reg_ctrl_mem_fcn <= _GEN_46[0];
    end
    if (reset) begin // @[dpath.scala 92:39]
      exe_reg_ctrl_mem_typ <= 3'h0; // @[dpath.scala 92:39]
    end else if (!(_T_31)) begin // @[dpath.scala 304:4]
      if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
        if (!(io_ctl_dec_kill)) begin // @[dpath.scala 330:7]
          exe_reg_ctrl_mem_typ <= io_ctl_mem_typ; // @[dpath.scala 348:32]
        end
      end
    end
    if (reset) begin // @[dpath.scala 93:39]
      exe_reg_ctrl_csr_cmd <= 3'h0; // @[dpath.scala 93:39]
    end else if (_T_31) begin // @[dpath.scala 304:4]
      exe_reg_ctrl_csr_cmd <= 3'h0; // @[dpath.scala 313:29]
    end else if (_if_buffer_out_io_deq_ready_T_2) begin // @[dpath.scala 317:4]
      if (io_ctl_dec_kill) begin // @[dpath.scala 330:7]
        exe_reg_ctrl_csr_cmd <= 3'h0; // @[dpath.scala 337:32]
      end else begin
        exe_reg_ctrl_csr_cmd <= io_ctl_csr_cmd; // @[dpath.scala 349:32]
      end
    end
    if (reset) begin // @[dpath.scala 96:39]
      mem_reg_valid <= 1'h0; // @[dpath.scala 96:39]
    end else if (io_ctl_pipeline_kill) begin // @[dpath.scala 395:4]
      mem_reg_valid <= 1'h0; // @[dpath.scala 396:29]
    end else if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
      mem_reg_valid <= exe_reg_valid; // @[dpath.scala 404:29]
    end
    if (!(io_ctl_pipeline_kill)) begin // @[dpath.scala 395:4]
      if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
        mem_reg_pc <= exe_reg_pc; // @[dpath.scala 405:29]
      end
    end
    if (io_ctl_pipeline_kill) begin // @[dpath.scala 395:4]
      mem_reg_inst <= 32'h4033; // @[dpath.scala 397:29]
    end else if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
      mem_reg_inst <= exe_reg_inst; // @[dpath.scala 406:29]
    end
    if (!(io_ctl_pipeline_kill)) begin // @[dpath.scala 395:4]
      if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
        if (exe_reg_ctrl_wb_sel == 2'h2) begin // @[dpath.scala 407:35]
          mem_reg_alu_out <= exe_pc_plus4;
        end else if (_exe_alu_out_T) begin // @[Mux.scala 101:16]
          mem_reg_alu_out <= exe_adder_out;
        end else begin
          mem_reg_alu_out <= _exe_alu_out_T_37;
        end
      end
    end
    if (!(io_ctl_pipeline_kill)) begin // @[dpath.scala 395:4]
      if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
        mem_reg_wbaddr <= exe_reg_wbaddr; // @[dpath.scala 408:29]
      end
    end
    if (!(io_ctl_pipeline_kill)) begin // @[dpath.scala 395:4]
      if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
        mem_reg_rs1_addr <= exe_reg_rs1_addr; // @[dpath.scala 409:29]
      end
    end
    if (!(io_ctl_pipeline_kill)) begin // @[dpath.scala 395:4]
      if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
        mem_reg_rs2_addr <= exe_reg_rs2_addr; // @[dpath.scala 410:29]
      end
    end
    if (!(io_ctl_pipeline_kill)) begin // @[dpath.scala 395:4]
      if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
        mem_reg_op1_data <= exe_alu_op1; // @[dpath.scala 411:29]
      end
    end
    if (!(io_ctl_pipeline_kill)) begin // @[dpath.scala 395:4]
      if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
        mem_reg_op2_data <= brjmp_offset; // @[dpath.scala 412:29]
      end
    end
    if (!(io_ctl_pipeline_kill)) begin // @[dpath.scala 395:4]
      if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
        mem_reg_rs2_data <= exe_reg_rs2_data; // @[dpath.scala 413:29]
      end
    end
    if (reset) begin // @[dpath.scala 106:39]
      mem_reg_ctrl_rf_wen <= 1'h0; // @[dpath.scala 106:39]
    end else if (io_ctl_pipeline_kill) begin // @[dpath.scala 395:4]
      mem_reg_ctrl_rf_wen <= 1'h0; // @[dpath.scala 398:29]
    end else if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
      mem_reg_ctrl_rf_wen <= exe_reg_ctrl_rf_wen; // @[dpath.scala 414:29]
    end
    if (reset) begin // @[dpath.scala 107:39]
      mem_reg_ctrl_mem_val <= 1'h0; // @[dpath.scala 107:39]
    end else if (io_ctl_pipeline_kill) begin // @[dpath.scala 395:4]
      mem_reg_ctrl_mem_val <= 1'h0; // @[dpath.scala 399:29]
    end else if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
      mem_reg_ctrl_mem_val <= exe_reg_ctrl_mem_val; // @[dpath.scala 415:29]
    end
    if (reset) begin // @[dpath.scala 108:39]
      mem_reg_ctrl_mem_fcn <= 1'h0; // @[dpath.scala 108:39]
    end else if (!(io_ctl_pipeline_kill)) begin // @[dpath.scala 395:4]
      if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
        mem_reg_ctrl_mem_fcn <= exe_reg_ctrl_mem_fcn; // @[dpath.scala 416:29]
      end
    end
    if (reset) begin // @[dpath.scala 109:39]
      mem_reg_ctrl_mem_typ <= 3'h0; // @[dpath.scala 109:39]
    end else if (!(io_ctl_pipeline_kill)) begin // @[dpath.scala 395:4]
      if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
        mem_reg_ctrl_mem_typ <= exe_reg_ctrl_mem_typ; // @[dpath.scala 417:29]
      end
    end
    if (!(io_ctl_pipeline_kill)) begin // @[dpath.scala 395:4]
      if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
        mem_reg_ctrl_wb_sel <= exe_reg_ctrl_wb_sel; // @[dpath.scala 418:29]
      end
    end
    if (reset) begin // @[dpath.scala 111:39]
      mem_reg_ctrl_csr_cmd <= 3'h0; // @[dpath.scala 111:39]
    end else if (io_ctl_pipeline_kill) begin // @[dpath.scala 395:4]
      mem_reg_ctrl_csr_cmd <= 3'h0; // @[dpath.scala 400:29]
    end else if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 403:4]
      mem_reg_ctrl_csr_cmd <= exe_reg_ctrl_csr_cmd; // @[dpath.scala 419:29]
    end
    if (reset) begin // @[dpath.scala 114:39]
      wb_reg_valid <= 1'h0; // @[dpath.scala 114:39]
    end else begin
      wb_reg_valid <= _GEN_91;
    end
    if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 484:4]
      wb_reg_wbaddr <= mem_reg_wbaddr; // @[dpath.scala 486:28]
    end
    if (_if_buffer_out_io_deq_ready_T_1) begin // @[dpath.scala 484:4]
      if (_mem_wbdata_T) begin // @[Mux.scala 101:16]
        wb_reg_wbdata <= mem_reg_alu_out;
      end else if (_mem_wbdata_T_1) begin // @[Mux.scala 101:16]
        wb_reg_wbdata <= mem_reg_alu_out;
      end else if (_mem_wbdata_T_2) begin // @[Mux.scala 101:16]
        wb_reg_wbdata <= io_dmem_resp_bits_data;
      end else begin
        wb_reg_wbdata <= _mem_wbdata_T_4;
      end
    end
    if (reset) begin // @[dpath.scala 117:39]
      wb_reg_ctrl_rf_wen <= 1'h0; // @[dpath.scala 117:39]
    end else begin
      wb_reg_ctrl_rf_wen <= _GEN_94;
    end
    if (reset) begin // @[dpath.scala 145:31]
      if_reg_killed <= 1'h0; // @[dpath.scala 145:31]
    end else if (_T_11) begin // @[dpath.scala 151:4]
      if_reg_killed <= 1'h0; // @[dpath.scala 152:21]
    end else begin
      if_reg_killed <= _GEN_0;
    end
    if (_if_pc_next_T_1) begin // @[dpath.scala 390:35]
      mem_tval_inst_ma_REG <= exe_brjmp_target;
    end else begin
      mem_tval_inst_ma_REG <= exe_jump_reg_target;
    end
    csr_io_tval_REG <= exe_reg_inst; // @[dpath.scala 440:91]
    if (reset) begin // @[dpath.scala 447:39]
      reg_interrupt_handled <= 1'h0; // @[dpath.scala 447:39]
    end else begin
      reg_interrupt_handled <= csr_io_interrupt; // @[dpath.scala 447:39]
    end
    wb_reg_inst <= mem_reg_inst; // @[dpath.scala 518:29]
    wb_reg_new_pc <= mem_reg_new_pc;
    REG <= mem_reg_pc; // @[dpath.scala 523:14]
    REG_1 <= mem_reg_rs1_addr; // @[dpath.scala 527:14]
    REG_2 <= mem_reg_op1_data; // @[dpath.scala 528:14]
    REG_3 <= mem_reg_rs2_addr; // @[dpath.scala 529:14]
    REG_4 <= mem_reg_op2_data; // @[dpath.scala 530:14]
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (~(~(io_imem_resp_valid & ~if_buffer_in_ready)) & ~reset) begin
          $fatal; // @[dpath.scala 131:10]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~reset & ~(~(io_imem_resp_valid & ~if_buffer_in_ready))) begin
          $fwrite(32'h80000002,
            "Assertion failed: Instruction backlog\n    at dpath.scala:131 assert(!(if_buffer_in.valid && !if_buffer_in.ready), \"Instruction backlog\")\n"
            ); // @[dpath.scala 131:10]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_4) begin
          $fwrite(32'h80000002,
            "Cyc= %d [%d] pc=[%x] W[r%d=%x][%d] Op1=[r%d][%x] Op2=[r%d][%x] inst=[%x] %c%c%c DASM(%x)\n",_T_37,
            csr_io_retire,REG,wb_reg_wbaddr,wb_reg_wbdata,wb_reg_ctrl_rf_wen,REG_1,REG_2,REG_3,REG_4,wb_reg_inst,_T_40,
            _T_46,_T_47,wb_reg_inst); // @[dpath.scala 520:10]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  if_reg_pc = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  dec_reg_valid = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  dec_reg_inst = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  dec_reg_pc = _RAND_3[31:0];
  _RAND_4 = {1{`RANDOM}};
  exe_reg_valid = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  exe_reg_inst = _RAND_5[31:0];
  _RAND_6 = {1{`RANDOM}};
  exe_reg_pc = _RAND_6[31:0];
  _RAND_7 = {1{`RANDOM}};
  exe_reg_wbaddr = _RAND_7[4:0];
  _RAND_8 = {1{`RANDOM}};
  exe_reg_rs1_addr = _RAND_8[4:0];
  _RAND_9 = {1{`RANDOM}};
  exe_reg_rs2_addr = _RAND_9[4:0];
  _RAND_10 = {1{`RANDOM}};
  exe_alu_op1 = _RAND_10[31:0];
  _RAND_11 = {1{`RANDOM}};
  brjmp_offset = _RAND_11[31:0];
  _RAND_12 = {1{`RANDOM}};
  exe_reg_rs2_data = _RAND_12[31:0];
  _RAND_13 = {1{`RANDOM}};
  exe_reg_ctrl_br_type = _RAND_13[3:0];
  _RAND_14 = {1{`RANDOM}};
  exe_reg_ctrl_alu_fun = _RAND_14[3:0];
  _RAND_15 = {1{`RANDOM}};
  exe_reg_ctrl_wb_sel = _RAND_15[1:0];
  _RAND_16 = {1{`RANDOM}};
  exe_reg_ctrl_rf_wen = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  exe_reg_ctrl_mem_val = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  exe_reg_ctrl_mem_fcn = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  exe_reg_ctrl_mem_typ = _RAND_19[2:0];
  _RAND_20 = {1{`RANDOM}};
  exe_reg_ctrl_csr_cmd = _RAND_20[2:0];
  _RAND_21 = {1{`RANDOM}};
  mem_reg_valid = _RAND_21[0:0];
  _RAND_22 = {1{`RANDOM}};
  mem_reg_pc = _RAND_22[31:0];
  _RAND_23 = {1{`RANDOM}};
  mem_reg_inst = _RAND_23[31:0];
  _RAND_24 = {1{`RANDOM}};
  mem_reg_alu_out = _RAND_24[31:0];
  _RAND_25 = {1{`RANDOM}};
  mem_reg_wbaddr = _RAND_25[4:0];
  _RAND_26 = {1{`RANDOM}};
  mem_reg_rs1_addr = _RAND_26[4:0];
  _RAND_27 = {1{`RANDOM}};
  mem_reg_rs2_addr = _RAND_27[4:0];
  _RAND_28 = {1{`RANDOM}};
  mem_reg_op1_data = _RAND_28[31:0];
  _RAND_29 = {1{`RANDOM}};
  mem_reg_op2_data = _RAND_29[31:0];
  _RAND_30 = {1{`RANDOM}};
  mem_reg_rs2_data = _RAND_30[31:0];
  _RAND_31 = {1{`RANDOM}};
  mem_reg_ctrl_rf_wen = _RAND_31[0:0];
  _RAND_32 = {1{`RANDOM}};
  mem_reg_ctrl_mem_val = _RAND_32[0:0];
  _RAND_33 = {1{`RANDOM}};
  mem_reg_ctrl_mem_fcn = _RAND_33[0:0];
  _RAND_34 = {1{`RANDOM}};
  mem_reg_ctrl_mem_typ = _RAND_34[2:0];
  _RAND_35 = {1{`RANDOM}};
  mem_reg_ctrl_wb_sel = _RAND_35[1:0];
  _RAND_36 = {1{`RANDOM}};
  mem_reg_ctrl_csr_cmd = _RAND_36[2:0];
  _RAND_37 = {1{`RANDOM}};
  wb_reg_valid = _RAND_37[0:0];
  _RAND_38 = {1{`RANDOM}};
  wb_reg_wbaddr = _RAND_38[4:0];
  _RAND_39 = {1{`RANDOM}};
  wb_reg_wbdata = _RAND_39[31:0];
  _RAND_40 = {1{`RANDOM}};
  wb_reg_ctrl_rf_wen = _RAND_40[0:0];
  _RAND_41 = {1{`RANDOM}};
  if_reg_killed = _RAND_41[0:0];
  _RAND_42 = {1{`RANDOM}};
  mem_tval_inst_ma_REG = _RAND_42[31:0];
  _RAND_43 = {1{`RANDOM}};
  csr_io_tval_REG = _RAND_43[31:0];
  _RAND_44 = {1{`RANDOM}};
  reg_interrupt_handled = _RAND_44[0:0];
  _RAND_45 = {1{`RANDOM}};
  wb_reg_inst = _RAND_45[31:0];
  _RAND_46 = {1{`RANDOM}};
  REG = _RAND_46[31:0];
  _RAND_47 = {1{`RANDOM}};
  REG_1 = _RAND_47[4:0];
  _RAND_48 = {1{`RANDOM}};
  REG_2 = _RAND_48[31:0];
  _RAND_49 = {1{`RANDOM}};
  REG_3 = _RAND_49[4:0];
  _RAND_50 = {1{`RANDOM}};
  REG_4 = _RAND_50[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS

//////////////////////////// RVFI /////////////////////////////////

	wire [1023:0] rvfi_regfile;
 	// Trace: core/Core_2stage.v:166:3
	wire [31:0] new_pc_wire;
  assign new_pc_wire = wb_reg_new_pc;
  wire [31:0] register_wdata;
  assign register_wdata = regfile_io_wdata;
	wire retire_wire;
	// Trace: core/Core_2stage.v:249:3
	assign retire_wire = wb_reg_valid;
	reg retire;
	always @(posedge clock)
		retire <= retire_wire;
	// Trace: core/Core_2stage.v:259:3
  wire [31:0] instruction;
	assign instruction = wb_reg_inst;
	// Trace: core/Core_2stage.v:260:3
	// Trace: core/Core_2stage.v:270:3
	wire [31:0] old_pc;
	// Trace: core/Core_2stage.v:271:3
	assign old_pc = REG;
	// Trace: core/Core_2stage.v:272:3
	// Trace: core/Core_2stage.v:274:3
	reg mem_req = 0;
	// Trace: core/Core_2stage.v:275:3
	reg [31:0] mem_addr1 = 32'b00000000000000000000000000000000;
	// Trace: core/Core_2stage.v:276:3
	reg [31:0] mem_rdata = 32'b00000000000000000000000000000000;
	// Trace: core/Core_2stage.v:277:3
	reg [31:0] mem_wdata = 32'b00000000000000000000000000000000;
	// Trace: core/Core_2stage.v:278:3
	reg mem_we = 0;
	// Trace: core/Core_2stage.v:279:3
	reg [2:0] mem_be = 3'b000;
	// Trace: core/Core_2stage.v:280:3
	wire exception;
	// Trace: core/Core_2stage.v:281:3
	assign exception = 0;
	// Trace: core/Core_2stage.v:282:3
	// always @(posedge clock)
	// 	// Trace: core/Core_2stage.v:283:5
	// 	if (reset) begin
	// 		// Trace: core/Core_2stage.v:284:7
	// 		mem_req <= 0;
	// 		// Trace: core/Core_2stage.v:285:7
	// 		mem_addr1 <= 32'b00000000000000000000000000000000;
	// 		// Trace: core/Core_2stage.v:286:7
	// 		mem_rdata <= 32'b00000000000000000000000000000000;
	// 		// Trace: core/Core_2stage.v:287:7
	// 		mem_wdata <= 32'b00000000000000000000000000000000;
	// 		// Trace: core/Core_2stage.v:288:7
	// 		mem_we <= 0;
	// 		// Trace: core/Core_2stage.v:289:7
	// 		mem_be <= 3'b000;
	// 	end
	// 	else begin
	// 		// Trace: core/Core_2stage.v:291:7
	// 		mem_req <= io_dmem_req_valid;
	// 		// Trace: core/Core_2stage.v:292:7
	// 		mem_addr1 <= io_dmem_req_bits_addr;
	// 		// Trace: core/Core_2stage.v:293:7
	// 		mem_rdata <= io_dmem_resp_bits_data;
	// 		// Trace: core/Core_2stage.v:294:7
	// 		mem_wdata <= io_dmem_req_bits_data;
	// 		// Trace: core/Core_2stage.v:295:7
	// 		mem_we <= io_dmem_req_bits_fcn;
	// 		// Trace: core/Core_2stage.v:296:7
	// 		mem_be <= io_dmem_req_bits_typ;
	// 	end
	always @(posedge clock)
		// Trace: core/Core_2stage.v:283:5
		if (reset) begin
			// Trace: core/Core_2stage.v:284:7
			mem_req <= 0;
			// Trace: core/Core_2stage.v:285:7
			mem_addr1 <= 32'b00000000000000000000000000000000;
			// Trace: core/Core_2stage.v:286:7
			mem_rdata <= 32'b00000000000000000000000000000000;
			// Trace: core/Core_2stage.v:287:7
			mem_wdata <= 32'b00000000000000000000000000000000;
			// Trace: core/Core_2stage.v:288:7
			mem_we <= 0;
			// Trace: core/Core_2stage.v:289:7
			mem_be <= 3'b000;
		end
		else begin
			// Trace: core/Core_2stage.v:291:7
			mem_req <= io_dmem_req_valid;
			// Trace: core/Core_2stage.v:292:7
			mem_addr1 <= io_dmem_req_bits_addr;
			// Trace: core/Core_2stage.v:293:7
			mem_rdata <= io_dmem_resp_bits_data;
			// Trace: core/Core_2stage.v:294:7
			mem_wdata <= io_dmem_req_bits_data;
			// Trace: core/Core_2stage.v:295:7
			mem_we <= io_dmem_req_bits_fcn;
			// Trace: core/Core_2stage.v:296:7
			mem_be <= io_dmem_req_bits_typ;
		end
	// Trace: core/Core_2stage.v:300:3
	RVFI_5stage RVFI_5stage(
		.clock(clock),
		.retire(retire_wire),
		.instruction(instruction),
		.old_regfile(rvfi_regfile),
		.register_wdata(register_wdata),
		.old_pc(old_pc),
		.new_pc(new_pc_wire),
		.mem_req(mem_req),
		.mem_addr(mem_addr1),
		.mem_rdata(mem_rdata),
		.mem_wdata(mem_wdata),
		.mem_we(mem_we),
		.mem_be(mem_be),
		.exception(exception),
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
		.rvfi_mem_wdata(rvfi_mem_wdata)
	); 

	//wire rvfi_valid;
	//wire [63:0] rvfi_order;
	//wire [31:0] rvfi_insn;
	//wire rvfi_trap;
    //wire rvfi_halt;
	//wire rvfi_intr;
	//wire [1:0] rvfi_mode;
	//wire [1:0] rvfi_ixl;
	//wire [4:0] rvfi_rs1_addr;
	//wire [4:0] rvfi_rs2_addr;
	//wire [4:0] rvfi_rs3_addr;
	//wire [31:0] rvfi_rs1_rdata;
	//wire [31:0] rvfi_rs2_rdata;
	//wire [31:0] rvfi_rs3_rdata;
	//wire [4:0] rvfi_rd_addr;
	//wire [31:0] rvfi_rd_wdata;
	//wire [31:0] rvfi_pc_rdata;
	//wire [31:0] rvfi_pc_wdata;
	//wire [31:0] rvfi_mem_addr;
	//wire [3:0] rvfi_mem_rmask;
	//wire [3:0] rvfi_mem_wmask;
	//wire [31:0] rvfi_mem_rdata;
	//wire [31:0] rvfi_mem_wdata;

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

    ctr_decode ctr_decode (
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
	wire reg_rd_zero;
	assign reg_rd_zero = ( rvfi_rd_wdata == 0 );
	wire [31:0] reg_rd_log2;
	assign reg_rd_log2 = clogb2( rvfi_rd_wdata );

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



  wire [4:0] rd_1;
  assign rd_1 = rd;
  wire [4:0] rs1_1;
  assign rs1_1 = rs1;
  wire [4:0] rs2_1;
  assign rs2_1 = rs2;
  wire [4:0] rd_2;
  assign rd_2 = 0;
  wire [4:0] rs1_2;
  assign rs1_2 = 0;
  wire [4:0] rs2_2;
  assign rs2_2 = 0;
  reg [5:0] old_rd_1_1 = 0;
  reg [5:0] old_rd_1_2 = 0;
  reg [5:0] old_rd_1_3 = 0;
  reg [5:0] old_rd_1_4 = 0;
  reg [5:0] old_rd_2_1 = 0;
  reg [5:0] old_rd_2_2 = 0;
  reg [5:0] old_rd_2_3 = 0;
  reg [5:0] old_rd_2_4 = 0;
  always @(posedge clock) begin
      if (retire == 1) begin
          old_rd_1_1 <= rd_1;
          old_rd_1_2 <= old_rd_1_1;
          old_rd_1_3 <= old_rd_1_2;
          old_rd_1_4 <= old_rd_1_3;
          old_rd_2_1 <= rd_2;
          old_rd_2_2 <= old_rd_2_1;
          old_rd_2_3 <= old_rd_2_2;
          old_rd_2_4 <= old_rd_2_3;
      end
  end

  wire raw_rs1_1_1;
  assign raw_rs1_1_1 = (rs1_1 == old_rd_1_1);
  wire raw_rs2_1_1;
  assign raw_rs2_1_1 = rs2_1 == old_rd_1_1;
  wire waw_1_1;
  assign waw_1_1 = rd_1 == old_rd_1_1;

  wire raw_rs1_1_2;
  assign raw_rs1_1_2 = rs1_2 == old_rd_2_1;
  wire raw_rs2_1_2;
  assign raw_rs2_1_2 = rs2_2 == old_rd_2_1;
  wire waw_1_2;
  assign waw_1_2 = rd_2 == old_rd_2_1;

  wire raw_rs1_2_1;
  assign raw_rs1_2_1 = rs1_1 == old_rd_1_2;
  wire raw_rs2_2_1;
  assign raw_rs2_2_1 = rs2_1 == old_rd_1_2;
  wire waw_2_1;
  assign waw_2_1 = rd_1 == old_rd_1_2;

  wire raw_rs1_2_2;
  assign raw_rs1_2_2 = rs1_2 == old_rd_2_2;
  wire raw_rs2_2_2;
  assign raw_rs2_2_2 = rs2_2 == old_rd_2_2;
  wire waw_2_2;
  assign waw_2_2 = rd_2 == old_rd_2_2;

  wire raw_rs1_3_1;
  assign raw_rs1_3_1 = rs1_1 == old_rd_1_3;
  wire raw_rs2_3_1;
  assign raw_rs2_3_1 = rs2_1 == old_rd_1_3;
  wire waw_3_1;
  assign waw_3_1 = rd_1 == old_rd_1_3;

  wire raw_rs1_3_2;
  assign raw_rs1_3_2 =  rs1_2 == old_rd_2_3;
  wire raw_rs2_3_2;
  assign raw_rs2_3_2 = rs2_2 == old_rd_2_3;
  wire waw_3_2;
  assign waw_3_2 = rd_2 == old_rd_2_3;

  wire raw_rs1_4_1;
  assign raw_rs1_4_1 = rs1_1 == old_rd_1_4;
  wire raw_rs2_4_1;
  assign raw_rs2_4_1 = rs2_1 == old_rd_1_4;
  wire waw_4_1;
  assign waw_4_1 = rd_1 == old_rd_1_4;

  wire raw_rs1_4_2;
  assign raw_rs1_4_2 = rs1_2 == old_rd_2_4;
  wire raw_rs2_4_2;
  assign raw_rs2_4_2 = rs2_2 == old_rd_2_4;
  wire waw_4_2;
  assign waw_4_2 = rd_2 == old_rd_2_4;
endmodule
