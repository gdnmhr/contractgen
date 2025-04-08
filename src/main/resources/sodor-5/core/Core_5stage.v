module Core_5stage(
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
  input         io_dmem_resp_valid,
  input  [31:0] io_dmem_resp_bits_data,
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
  wire  c_clock; // @[core.scala 26:19]
  wire  c_reset; // @[core.scala 26:19]
  wire  c_io_dmem_resp_valid; // @[core.scala 26:19]
  wire [31:0] c_io_dat_dec_inst; // @[core.scala 26:19]
  wire  c_io_dat_dec_valid; // @[core.scala 26:19]
  wire  c_io_dat_exe_br_eq; // @[core.scala 26:19]
  wire  c_io_dat_exe_br_lt; // @[core.scala 26:19]
  wire  c_io_dat_exe_br_ltu; // @[core.scala 26:19]
  wire [3:0] c_io_dat_exe_br_type; // @[core.scala 26:19]
  wire  c_io_dat_exe_inst_misaligned; // @[core.scala 26:19]
  wire  c_io_dat_mem_ctrl_dmem_val; // @[core.scala 26:19]
  wire  c_io_dat_mem_data_misaligned; // @[core.scala 26:19]
  wire  c_io_dat_mem_store; // @[core.scala 26:19]
  wire  c_io_dat_csr_eret; // @[core.scala 26:19]
  wire  c_io_dat_csr_interrupt; // @[core.scala 26:19]
  wire  c_io_ctl_dec_stall; // @[core.scala 26:19]
  wire  c_io_ctl_full_stall; // @[core.scala 26:19]
  wire [1:0] c_io_ctl_exe_pc_sel; // @[core.scala 26:19]
  wire [3:0] c_io_ctl_br_type; // @[core.scala 26:19]
  wire  c_io_ctl_if_kill; // @[core.scala 26:19]
  wire  c_io_ctl_dec_kill; // @[core.scala 26:19]
  wire [1:0] c_io_ctl_op1_sel; // @[core.scala 26:19]
  wire [2:0] c_io_ctl_op2_sel; // @[core.scala 26:19]
  wire [3:0] c_io_ctl_alu_fun; // @[core.scala 26:19]
  wire [1:0] c_io_ctl_wb_sel; // @[core.scala 26:19]
  wire  c_io_ctl_rf_wen; // @[core.scala 26:19]
  wire  c_io_ctl_mem_val; // @[core.scala 26:19]
  wire [1:0] c_io_ctl_mem_fcn; // @[core.scala 26:19]
  wire [2:0] c_io_ctl_mem_typ; // @[core.scala 26:19]
  wire [2:0] c_io_ctl_csr_cmd; // @[core.scala 26:19]
  wire  c_io_ctl_fencei; // @[core.scala 26:19]
  wire  c_io_ctl_pipeline_kill; // @[core.scala 26:19]
  wire  c_io_ctl_mem_exception; // @[core.scala 26:19]
  wire [31:0] c_io_ctl_mem_exception_cause; // @[core.scala 26:19]
  wire  d_clock; // @[core.scala 27:19]
  wire  d_reset; // @[core.scala 27:19]
  wire  d_io_imem_req_valid; // @[core.scala 27:19]
  wire [31:0] d_io_imem_req_bits_addr; // @[core.scala 27:19]
  wire  d_io_imem_resp_valid; // @[core.scala 27:19]
  wire [31:0] d_io_imem_resp_bits_data; // @[core.scala 27:19]
  wire  d_io_dmem_req_valid; // @[core.scala 27:19]
  wire [31:0] d_io_dmem_req_bits_addr; // @[core.scala 27:19]
  wire [31:0] d_io_dmem_req_bits_data; // @[core.scala 27:19]
  wire  d_io_dmem_req_bits_fcn; // @[core.scala 27:19]
  wire [2:0] d_io_dmem_req_bits_typ; // @[core.scala 27:19]
  wire [31:0] d_io_dmem_resp_bits_data; // @[core.scala 27:19]
  wire  d_io_ctl_dec_stall; // @[core.scala 27:19]
  wire  d_io_ctl_full_stall; // @[core.scala 27:19]
  wire [1:0] d_io_ctl_exe_pc_sel; // @[core.scala 27:19]
  wire [3:0] d_io_ctl_br_type; // @[core.scala 27:19]
  wire  d_io_ctl_if_kill; // @[core.scala 27:19]
  wire  d_io_ctl_dec_kill; // @[core.scala 27:19]
  wire [1:0] d_io_ctl_op1_sel; // @[core.scala 27:19]
  wire [2:0] d_io_ctl_op2_sel; // @[core.scala 27:19]
  wire [3:0] d_io_ctl_alu_fun; // @[core.scala 27:19]
  wire [1:0] d_io_ctl_wb_sel; // @[core.scala 27:19]
  wire  d_io_ctl_rf_wen; // @[core.scala 27:19]
  wire  d_io_ctl_mem_val; // @[core.scala 27:19]
  wire [1:0] d_io_ctl_mem_fcn; // @[core.scala 27:19]
  wire [2:0] d_io_ctl_mem_typ; // @[core.scala 27:19]
  wire [2:0] d_io_ctl_csr_cmd; // @[core.scala 27:19]
  wire  d_io_ctl_fencei; // @[core.scala 27:19]
  wire  d_io_ctl_pipeline_kill; // @[core.scala 27:19]
  wire  d_io_ctl_mem_exception; // @[core.scala 27:19]
  wire [31:0] d_io_ctl_mem_exception_cause; // @[core.scala 27:19]
  wire [31:0] d_io_dat_dec_inst; // @[core.scala 27:19]
  wire  d_io_dat_dec_valid; // @[core.scala 27:19]
  wire  d_io_dat_exe_br_eq; // @[core.scala 27:19]
  wire  d_io_dat_exe_br_lt; // @[core.scala 27:19]
  wire  d_io_dat_exe_br_ltu; // @[core.scala 27:19]
  wire [3:0] d_io_dat_exe_br_type; // @[core.scala 27:19]
  wire  d_io_dat_exe_inst_misaligned; // @[core.scala 27:19]
  wire  d_io_dat_mem_ctrl_dmem_val; // @[core.scala 27:19]
  wire  d_io_dat_mem_data_misaligned; // @[core.scala 27:19]
  wire  d_io_dat_mem_store; // @[core.scala 27:19]
  wire  d_io_dat_csr_eret; // @[core.scala 27:19]
  wire  d_io_dat_csr_interrupt; // @[core.scala 27:19]
  wire  d_io_interrupt_debug; // @[core.scala 27:19]
  wire  d_io_interrupt_mtip; // @[core.scala 27:19]
  wire  d_io_interrupt_msip; // @[core.scala 27:19]
  wire  d_io_interrupt_meip; // @[core.scala 27:19]
  wire  d_io_hartid; // @[core.scala 27:19]
  wire [31:0] d_io_reset_vector; // @[core.scala 27:19]
  CtlPath_5stage CtlPath_5stage ( // @[core.scala 26:19]
    .clock(c_clock),
    .reset(c_reset),
    .io_dmem_resp_valid(c_io_dmem_resp_valid),
    .io_dat_dec_inst(c_io_dat_dec_inst),
    .io_dat_dec_valid(c_io_dat_dec_valid),
    .io_dat_exe_br_eq(c_io_dat_exe_br_eq),
    .io_dat_exe_br_lt(c_io_dat_exe_br_lt),
    .io_dat_exe_br_ltu(c_io_dat_exe_br_ltu),
    .io_dat_exe_br_type(c_io_dat_exe_br_type),
    .io_dat_exe_inst_misaligned(c_io_dat_exe_inst_misaligned),
    .io_dat_mem_ctrl_dmem_val(c_io_dat_mem_ctrl_dmem_val),
    .io_dat_mem_data_misaligned(c_io_dat_mem_data_misaligned),
    .io_dat_mem_store(c_io_dat_mem_store),
    .io_dat_csr_eret(c_io_dat_csr_eret),
    .io_dat_csr_interrupt(c_io_dat_csr_interrupt),
    .io_ctl_dec_stall(c_io_ctl_dec_stall),
    .io_ctl_full_stall(c_io_ctl_full_stall),
    .io_ctl_exe_pc_sel(c_io_ctl_exe_pc_sel),
    .io_ctl_br_type(c_io_ctl_br_type),
    .io_ctl_if_kill(c_io_ctl_if_kill),
    .io_ctl_dec_kill(c_io_ctl_dec_kill),
    .io_ctl_op1_sel(c_io_ctl_op1_sel),
    .io_ctl_op2_sel(c_io_ctl_op2_sel),
    .io_ctl_alu_fun(c_io_ctl_alu_fun),
    .io_ctl_wb_sel(c_io_ctl_wb_sel),
    .io_ctl_rf_wen(c_io_ctl_rf_wen),
    .io_ctl_mem_val(c_io_ctl_mem_val),
    .io_ctl_mem_fcn(c_io_ctl_mem_fcn),
    .io_ctl_mem_typ(c_io_ctl_mem_typ),
    .io_ctl_csr_cmd(c_io_ctl_csr_cmd),
    .io_ctl_fencei(c_io_ctl_fencei),
    .io_ctl_pipeline_kill(c_io_ctl_pipeline_kill),
    .io_ctl_mem_exception(c_io_ctl_mem_exception),
    .io_ctl_mem_exception_cause(c_io_ctl_mem_exception_cause)
  );
  DatPath_5stage DatPath_5stage ( // @[core.scala 27:19]
    .clock(d_clock),
    .reset(d_reset),
    .io_imem_req_valid(d_io_imem_req_valid),
    .io_imem_req_bits_addr(d_io_imem_req_bits_addr),
    .io_imem_resp_valid(d_io_imem_resp_valid),
    .io_imem_resp_bits_data(d_io_imem_resp_bits_data),
    .io_dmem_req_valid(d_io_dmem_req_valid),
    .io_dmem_req_bits_addr(d_io_dmem_req_bits_addr),
    .io_dmem_req_bits_data(d_io_dmem_req_bits_data),
    .io_dmem_req_bits_fcn(d_io_dmem_req_bits_fcn),
    .io_dmem_req_bits_typ(d_io_dmem_req_bits_typ),
    .io_dmem_resp_bits_data(d_io_dmem_resp_bits_data),
    .io_ctl_dec_stall(d_io_ctl_dec_stall),
    .io_ctl_full_stall(d_io_ctl_full_stall),
    .io_ctl_exe_pc_sel(d_io_ctl_exe_pc_sel),
    .io_ctl_br_type(d_io_ctl_br_type),
    .io_ctl_if_kill(d_io_ctl_if_kill),
    .io_ctl_dec_kill(d_io_ctl_dec_kill),
    .io_ctl_op1_sel(d_io_ctl_op1_sel),
    .io_ctl_op2_sel(d_io_ctl_op2_sel),
    .io_ctl_alu_fun(d_io_ctl_alu_fun),
    .io_ctl_wb_sel(d_io_ctl_wb_sel),
    .io_ctl_rf_wen(d_io_ctl_rf_wen),
    .io_ctl_mem_val(d_io_ctl_mem_val),
    .io_ctl_mem_fcn(d_io_ctl_mem_fcn),
    .io_ctl_mem_typ(d_io_ctl_mem_typ),
    .io_ctl_csr_cmd(d_io_ctl_csr_cmd),
    .io_ctl_fencei(d_io_ctl_fencei),
    .io_ctl_pipeline_kill(d_io_ctl_pipeline_kill),
    .io_ctl_mem_exception(d_io_ctl_mem_exception),
    .io_ctl_mem_exception_cause(d_io_ctl_mem_exception_cause),
    .io_dat_dec_inst(d_io_dat_dec_inst),
    .io_dat_dec_valid(d_io_dat_dec_valid),
    .io_dat_exe_br_eq(d_io_dat_exe_br_eq),
    .io_dat_exe_br_lt(d_io_dat_exe_br_lt),
    .io_dat_exe_br_ltu(d_io_dat_exe_br_ltu),
    .io_dat_exe_br_type(d_io_dat_exe_br_type),
    .io_dat_exe_inst_misaligned(d_io_dat_exe_inst_misaligned),
    .io_dat_mem_ctrl_dmem_val(d_io_dat_mem_ctrl_dmem_val),
    .io_dat_mem_data_misaligned(d_io_dat_mem_data_misaligned),
    .io_dat_mem_store(d_io_dat_mem_store),
    .io_dat_csr_eret(d_io_dat_csr_eret),
    .io_dat_csr_interrupt(d_io_dat_csr_interrupt),
    .io_interrupt_debug(d_io_interrupt_debug),
    .io_interrupt_mtip(d_io_interrupt_mtip),
    .io_interrupt_msip(d_io_interrupt_msip),
    .io_interrupt_meip(d_io_interrupt_meip),
    .io_hartid(d_io_hartid),
    .io_reset_vector(d_io_reset_vector),
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
  assign io_imem_req_valid = d_io_imem_req_valid; // @[core.scala 33:12]
  assign io_imem_req_bits_addr = d_io_imem_req_bits_addr; // @[core.scala 33:12]
  assign io_dmem_req_valid = d_io_dmem_req_valid; // @[core.scala 36:12]
  assign io_dmem_req_bits_addr = d_io_dmem_req_bits_addr; // @[core.scala 36:12]
  assign io_dmem_req_bits_data = d_io_dmem_req_bits_data; // @[core.scala 36:12]
  assign io_dmem_req_bits_fcn = d_io_dmem_req_bits_fcn; // @[core.scala 36:12]
  assign io_dmem_req_bits_typ = d_io_dmem_req_bits_typ; // @[core.scala 36:12]
  assign c_clock = clock;
  assign c_reset = reset;
  assign c_io_dmem_resp_valid = io_dmem_resp_valid; // @[core.scala 35:12]
  assign c_io_dat_dec_inst = d_io_dat_dec_inst; // @[core.scala 30:14]
  assign c_io_dat_dec_valid = d_io_dat_dec_valid; // @[core.scala 30:14]
  assign c_io_dat_exe_br_eq = d_io_dat_exe_br_eq; // @[core.scala 30:14]
  assign c_io_dat_exe_br_lt = d_io_dat_exe_br_lt; // @[core.scala 30:14]
  assign c_io_dat_exe_br_ltu = d_io_dat_exe_br_ltu; // @[core.scala 30:14]
  assign c_io_dat_exe_br_type = d_io_dat_exe_br_type; // @[core.scala 30:14]
  assign c_io_dat_exe_inst_misaligned = d_io_dat_exe_inst_misaligned; // @[core.scala 30:14]
  assign c_io_dat_mem_ctrl_dmem_val = d_io_dat_mem_ctrl_dmem_val; // @[core.scala 30:14]
  assign c_io_dat_mem_data_misaligned = d_io_dat_mem_data_misaligned; // @[core.scala 30:14]
  assign c_io_dat_mem_store = d_io_dat_mem_store; // @[core.scala 30:14]
  assign c_io_dat_csr_eret = d_io_dat_csr_eret; // @[core.scala 30:14]
  assign c_io_dat_csr_interrupt = d_io_dat_csr_interrupt; // @[core.scala 30:14]
  assign d_clock = clock;
  assign d_reset = reset;
  assign d_io_imem_resp_valid = io_imem_resp_valid; // @[core.scala 33:12]
  assign d_io_imem_resp_bits_data = io_imem_resp_bits_data; // @[core.scala 33:12]
  assign d_io_dmem_resp_bits_data = io_dmem_resp_bits_data; // @[core.scala 36:12]
  assign d_io_ctl_dec_stall = c_io_ctl_dec_stall; // @[core.scala 29:14]
  assign d_io_ctl_full_stall = c_io_ctl_full_stall; // @[core.scala 29:14]
  assign d_io_ctl_exe_pc_sel = c_io_ctl_exe_pc_sel; // @[core.scala 29:14]
  assign d_io_ctl_br_type = c_io_ctl_br_type; // @[core.scala 29:14]
  assign d_io_ctl_if_kill = c_io_ctl_if_kill; // @[core.scala 29:14]
  assign d_io_ctl_dec_kill = c_io_ctl_dec_kill; // @[core.scala 29:14]
  assign d_io_ctl_op1_sel = c_io_ctl_op1_sel; // @[core.scala 29:14]
  assign d_io_ctl_op2_sel = c_io_ctl_op2_sel; // @[core.scala 29:14]
  assign d_io_ctl_alu_fun = c_io_ctl_alu_fun; // @[core.scala 29:14]
  assign d_io_ctl_wb_sel = c_io_ctl_wb_sel; // @[core.scala 29:14]
  assign d_io_ctl_rf_wen = c_io_ctl_rf_wen; // @[core.scala 29:14]
  assign d_io_ctl_mem_val = c_io_ctl_mem_val; // @[core.scala 29:14]
  assign d_io_ctl_mem_fcn = c_io_ctl_mem_fcn; // @[core.scala 29:14]
  assign d_io_ctl_mem_typ = c_io_ctl_mem_typ; // @[core.scala 29:14]
  assign d_io_ctl_csr_cmd = c_io_ctl_csr_cmd; // @[core.scala 29:14]
  assign d_io_ctl_fencei = c_io_ctl_fencei; // @[core.scala 29:14]
  assign d_io_ctl_pipeline_kill = c_io_ctl_pipeline_kill; // @[core.scala 29:14]
  assign d_io_ctl_mem_exception = c_io_ctl_mem_exception; // @[core.scala 29:14]
  assign d_io_ctl_mem_exception_cause = c_io_ctl_mem_exception_cause; // @[core.scala 29:14]
  assign d_io_interrupt_debug = io_interrupt_debug; // @[core.scala 41:19]
  assign d_io_interrupt_mtip = io_interrupt_mtip; // @[core.scala 41:19]
  assign d_io_interrupt_msip = io_interrupt_msip; // @[core.scala 41:19]
  assign d_io_interrupt_meip = io_interrupt_meip; // @[core.scala 41:19]
  assign d_io_hartid = io_hartid; // @[core.scala 42:16]
  assign d_io_reset_vector = io_reset_vector; // @[core.scala 43:22]
endmodule