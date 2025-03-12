module Core_2stage(
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
//// for contract
  output [31:0] pc_retire,
  inout  [31:0] instr_ctr,
  // data load from memory
  output [31:0] io_dmem_req_bits_addr_ctr,
//// for state invariant
  output [31:0] exe_reg_pc,

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
  wire  c_io_imem_resp_valid; // @[core.scala 39:18]
  wire  c_io_dmem_req_valid; // @[core.scala 39:18]
  wire  c_io_dmem_req_bits_fcn; // @[core.scala 39:18]
  wire [2:0] c_io_dmem_req_bits_typ; // @[core.scala 39:18]
  wire  c_io_dmem_resp_valid; // @[core.scala 39:18]
  wire  c_io_dat_if_valid_resp; // @[core.scala 39:18]
  wire [31:0] c_io_dat_inst; // @[core.scala 39:18]
  wire  c_io_dat_br_eq; // @[core.scala 39:18]
  wire  c_io_dat_br_lt; // @[core.scala 39:18]
  wire  c_io_dat_br_ltu; // @[core.scala 39:18]
  wire  c_io_dat_inst_misaligned; // @[core.scala 39:18]
  wire  c_io_dat_data_misaligned; // @[core.scala 39:18]
  wire  c_io_dat_mem_store; // @[core.scala 39:18]
  wire  c_io_dat_csr_eret; // @[core.scala 39:18]
  wire  c_io_dat_csr_interrupt; // @[core.scala 39:18]
  wire  c_io_ctl_stall; // @[core.scala 39:18]
  wire  c_io_ctl_if_kill; // @[core.scala 39:18]
  wire [2:0] c_io_ctl_pc_sel; // @[core.scala 39:18]
  wire [1:0] c_io_ctl_op1_sel; // @[core.scala 39:18]
  wire [2:0] c_io_ctl_op2_sel; // @[core.scala 39:18]
  wire [4:0] c_io_ctl_alu_fun; // @[core.scala 39:18]
  wire [1:0] c_io_ctl_wb_sel; // @[core.scala 39:18]
  wire  c_io_ctl_rf_wen; // @[core.scala 39:18]
  wire [2:0] c_io_ctl_csr_cmd; // @[core.scala 39:18]
  wire  c_io_ctl_mem_val; // @[core.scala 39:18]
  wire [1:0] c_io_ctl_mem_fcn; // @[core.scala 39:18]
  wire [2:0] c_io_ctl_mem_typ; // @[core.scala 39:18]
  wire  c_io_ctl_exception; // @[core.scala 39:18]
  wire [31:0] c_io_ctl_exception_cause; // @[core.scala 39:18]
  wire [2:0] c_io_ctl_pc_sel_no_xept; // @[core.scala 39:18]
  wire  d_clock; // @[core.scala 40:18]
  wire  d_reset; // @[core.scala 40:18]
  wire  d_io_imem_req_valid; // @[core.scala 40:18]
  wire [31:0] d_io_imem_req_bits_addr; // @[core.scala 40:18]
  wire  d_io_imem_resp_valid; // @[core.scala 40:18]
  wire [31:0] d_io_imem_resp_bits_data; // @[core.scala 40:18]
  wire [31:0] d_io_dmem_req_bits_addr; // @[core.scala 40:18]
  wire [31:0] d_io_dmem_req_bits_data; // @[core.scala 40:18]
  wire [31:0] d_io_dmem_resp_bits_data; // @[core.scala 40:18]
  wire  d_io_ctl_stall; // @[core.scala 40:18]
  wire  d_io_ctl_if_kill; // @[core.scala 40:18]
  wire [2:0] d_io_ctl_pc_sel; // @[core.scala 40:18]
  wire [1:0] d_io_ctl_op1_sel; // @[core.scala 40:18]
  wire [2:0] d_io_ctl_op2_sel; // @[core.scala 40:18]
  wire [4:0] d_io_ctl_alu_fun; // @[core.scala 40:18]
  wire [1:0] d_io_ctl_wb_sel; // @[core.scala 40:18]
  wire  d_io_ctl_rf_wen; // @[core.scala 40:18]
  wire [2:0] d_io_ctl_csr_cmd; // @[core.scala 40:18]
  wire  d_io_ctl_mem_val; // @[core.scala 40:18]
  wire [1:0] d_io_ctl_mem_fcn; // @[core.scala 40:18]
  wire [2:0] d_io_ctl_mem_typ; // @[core.scala 40:18]
  wire  d_io_ctl_exception; // @[core.scala 40:18]
  wire [31:0] d_io_ctl_exception_cause; // @[core.scala 40:18]
  wire [2:0] d_io_ctl_pc_sel_no_xept; // @[core.scala 40:18]
  wire  d_io_dat_if_valid_resp; // @[core.scala 40:18]
  wire [31:0] d_io_dat_inst; // @[core.scala 40:18]
  wire  d_io_dat_br_eq; // @[core.scala 40:18]
  wire  d_io_dat_br_lt; // @[core.scala 40:18]
  wire  d_io_dat_br_ltu; // @[core.scala 40:18]
  wire  d_io_dat_inst_misaligned; // @[core.scala 40:18]
  wire  d_io_dat_data_misaligned; // @[core.scala 40:18]
  wire  d_io_dat_mem_store; // @[core.scala 40:18]
  wire  d_io_dat_csr_eret; // @[core.scala 40:18]
  wire  d_io_dat_csr_interrupt; // @[core.scala 40:18]
  wire  d_io_interrupt_debug; // @[core.scala 40:18]
  wire  d_io_interrupt_mtip; // @[core.scala 40:18]
  wire  d_io_interrupt_msip; // @[core.scala 40:18]
  wire  d_io_interrupt_meip; // @[core.scala 40:18]
  wire  d_io_hartid; // @[core.scala 40:18]
  wire [31:0] d_io_reset_vector; // @[core.scala 40:18]
  CtlPath_2stage CtlPath_2stage ( // @[core.scala 39:18]
    .io_imem_resp_valid(c_io_imem_resp_valid),
    .io_dmem_req_valid(c_io_dmem_req_valid),
    .io_dmem_req_bits_fcn(c_io_dmem_req_bits_fcn),
    .io_dmem_req_bits_typ(c_io_dmem_req_bits_typ),
    .io_dmem_resp_valid(c_io_dmem_resp_valid),
    .io_dat_if_valid_resp(c_io_dat_if_valid_resp),
    .io_dat_inst(c_io_dat_inst),
    .io_dat_br_eq(c_io_dat_br_eq),
    .io_dat_br_lt(c_io_dat_br_lt),
    .io_dat_br_ltu(c_io_dat_br_ltu),
    .io_dat_inst_misaligned(c_io_dat_inst_misaligned),
    .io_dat_data_misaligned(c_io_dat_data_misaligned),
    .io_dat_mem_store(c_io_dat_mem_store),
    .io_dat_csr_eret(c_io_dat_csr_eret),
    .io_dat_csr_interrupt(c_io_dat_csr_interrupt),
    .io_ctl_stall(c_io_ctl_stall),
    .io_ctl_if_kill(c_io_ctl_if_kill),
    .io_ctl_pc_sel(c_io_ctl_pc_sel),
    .io_ctl_op1_sel(c_io_ctl_op1_sel),
    .io_ctl_op2_sel(c_io_ctl_op2_sel),
    .io_ctl_alu_fun(c_io_ctl_alu_fun),
    .io_ctl_wb_sel(c_io_ctl_wb_sel),
    .io_ctl_rf_wen(c_io_ctl_rf_wen),
    .io_ctl_csr_cmd(c_io_ctl_csr_cmd),
    .io_ctl_mem_val(c_io_ctl_mem_val),
    .io_ctl_mem_fcn(c_io_ctl_mem_fcn),
    .io_ctl_mem_typ(c_io_ctl_mem_typ),
    .io_ctl_exception(c_io_ctl_exception),
    .io_ctl_exception_cause(c_io_ctl_exception_cause),
    .io_ctl_pc_sel_no_xept(c_io_ctl_pc_sel_no_xept),
  //// for contract
    .io_dat_inst_ctr(io_dat_inst_ctr),
    // for data address
    .io_ctl_alu_fun_ctr(io_ctl_alu_fun_ctr),
    .io_ctl_op1_sel_ctr(io_ctl_op1_sel_ctr),
    .io_ctl_op2_sel_ctr(io_ctl_op2_sel_ctr),
    // for branch instuction
    .io_dat_br_eq_ctr(io_dat_br_eq_ctr),
    .io_dat_br_lt_ctr(io_dat_br_lt_ctr),
    .io_dat_br_ltu_ctr(io_dat_br_ltu_ctr),
  );
  wire [31:0] rvfi_regfile [0:31];
  DatPath_2stage DatPath_2stage ( // @[core.scala 40:18]
    .clock(d_clock),
    .reset(d_reset),
    .io_imem_req_valid(d_io_imem_req_valid),
    .io_imem_req_bits_addr(d_io_imem_req_bits_addr),
    .io_imem_resp_valid(d_io_imem_resp_valid),
    .io_imem_resp_bits_data(d_io_imem_resp_bits_data),
    .io_dmem_req_bits_addr(d_io_dmem_req_bits_addr),
    .io_dmem_req_bits_data(d_io_dmem_req_bits_data),
    .io_dmem_resp_bits_data(d_io_dmem_resp_bits_data),
    .io_ctl_stall(d_io_ctl_stall),
    .io_ctl_if_kill(d_io_ctl_if_kill),
    .io_ctl_pc_sel(d_io_ctl_pc_sel),
    .io_ctl_op1_sel(d_io_ctl_op1_sel),
    .io_ctl_op2_sel(d_io_ctl_op2_sel),
    .io_ctl_alu_fun(d_io_ctl_alu_fun),
    .io_ctl_wb_sel(d_io_ctl_wb_sel),
    .io_ctl_rf_wen(d_io_ctl_rf_wen),
    .io_ctl_csr_cmd(d_io_ctl_csr_cmd),
    .io_ctl_mem_val(d_io_ctl_mem_val),
    .io_ctl_mem_fcn(d_io_ctl_mem_fcn),
    .io_ctl_mem_typ(d_io_ctl_mem_typ),
    .io_ctl_exception(d_io_ctl_exception),
    .io_ctl_exception_cause(d_io_ctl_exception_cause),
    .io_ctl_pc_sel_no_xept(d_io_ctl_pc_sel_no_xept),
    .io_dat_if_valid_resp(d_io_dat_if_valid_resp),
    .io_dat_inst(d_io_dat_inst),
    .io_dat_br_eq(d_io_dat_br_eq),
    .io_dat_br_lt(d_io_dat_br_lt),
    .io_dat_br_ltu(d_io_dat_br_ltu),
    .io_dat_inst_misaligned(d_io_dat_inst_misaligned),
    .io_dat_data_misaligned(d_io_dat_data_misaligned),
    .io_dat_mem_store(d_io_dat_mem_store),
    .io_dat_csr_eret(d_io_dat_csr_eret),
    .io_dat_csr_interrupt(d_io_dat_csr_interrupt),
    .io_interrupt_debug(d_io_interrupt_debug),
    .io_interrupt_mtip(d_io_interrupt_mtip),
    .io_interrupt_msip(d_io_interrupt_msip),
    .io_interrupt_meip(d_io_interrupt_meip),
    .io_hartid(d_io_hartid),
    .io_reset_vector(d_io_reset_vector),
//// for contract
    .pc_retire(pc_retire),
    .instr_ctr(instr_ctr),
    .io_dat_inst_ctr(io_dat_inst_ctr),
    // for data address
    .io_ctl_alu_fun_ctr(io_ctl_alu_fun_ctr),
    .io_ctl_op1_sel_ctr(io_ctl_op1_sel_ctr),
    .io_ctl_op2_sel_ctr(io_ctl_op2_sel_ctr),
    // for data load from memory
    .io_dmem_req_bits_addr_ctr(io_dmem_req_bits_addr_ctr),
    // for branch instuction
    .io_dat_br_eq_ctr(io_dat_br_eq_ctr),
    .io_dat_br_lt_ctr(io_dat_br_lt_ctr),
    .io_dat_br_ltu_ctr(io_dat_br_ltu_ctr),
//// for state invariant 
    .exe_reg_pc(exe_reg_pc),
    .new_pc(new_pc),
    .rvfi_regfile(rvfi_regfile),
  );
//// for contract
  wire  [31:0] io_dat_inst_ctr;
  // for data address
  wire  [4:0]  io_ctl_alu_fun_ctr;
  wire  [1:0]  io_ctl_op1_sel_ctr;
  wire  [2:0]  io_ctl_op2_sel_ctr;
  // for data load from memory
  // for branch instuction
    wire io_dat_br_eq_ctr;
    wire io_dat_br_lt_ctr;
    wire io_dat_br_ltu_ctr;


//// for state invariant
  reg        exe_reg_valid = 0;
  always @(posedge clock) begin
    if (reset) begin
      exe_reg_valid <= 0;
    end else begin
      exe_reg_valid <= d_io_ctl_stall ? exe_reg_valid : !d_io_ctl_if_kill;
    end
  end
  wire        retire;
  assign retire = exe_reg_valid & ~d_io_ctl_stall;
  reg [31:0] stalled_instruction = 32'b0;
  always @(posedge clock) begin
    if (reset) begin
      stalled_instruction <= 32'b0;
    end else begin
      stalled_instruction <= !exe_reg_valid ? stalled_instruction : d_io_dat_inst;
    end
  end
  wire [31:0] instruction;
  assign instruction = !exe_reg_valid ? stalled_instruction : d_io_dat_inst;
  reg [31:0] old_regfile [0:31];
  always @(posedge clock) begin
    if (reset) begin
      old_regfile <= 0;
    end else begin
      if (retire) begin
        old_regfile <= rvfi_regfile;
      end
    end
  end
  wire [31:0] old_pc;
  assign old_pc = exe_reg_pc;
  wire [31:0] new_pc;

/*
  reg        mem_req = 0;
  reg [31:0] mem_addr = 32'b0;
  reg [31:0] mem_rdata = 32'b0;
  reg [31:0] mem_wdata = 32'b0;
  reg        mem_we = 0;
  reg [2:0]  mem_be = 3'b0;
  wire       exception;
  assign exception = d_io_ctl_exception;
  always @(posedge clock) begin
    if (reset) begin
      mem_req <= 0;
      mem_addr <= 32'b0;
      mem_rdata <= 32'b0;
      mem_wdata <= 32'b0;
      mem_we <= 0;
      mem_be <= 3'b0;
    end else begin
      mem_req <= io_dmem_req_valid;
      mem_addr <= io_dmem_req_bits_addr;
      mem_rdata <= io_dmem_resp_bits_data;
      mem_wdata <= io_dmem_req_bits_data;
      mem_we <= io_dmem_req_bits_fcn;
      mem_be <= io_dmem_req_bits_typ;
    end
  end
*/

  wire        mem_req;
  assign mem_req = io_dmem_req_valid;
  wire [31:0] mem_addr;
  assign mem_addr = io_dmem_req_bits_addr;
  wire [31:0] mem_rdata;
  assign mem_rdata = io_dmem_resp_bits_data;
  wire [31:0] mem_wdata;
  assign mem_wdata = io_dmem_req_bits_data;
  wire        mem_we;
  assign mem_we = io_dmem_req_bits_fcn;
  wire [2:0]  mem_be;
  assign mem_be = io_dmem_req_bits_typ;
  wire       exception;
  assign exception = d_io_ctl_exception;

  RVFI_2stage RVFI_2stage(
    .clock(clock),
    .retire(retire),
    .instruction(instruction),
    .old_regfile(old_regfile),
    .new_regfile(rvfi_regfile),
    .old_pc(old_pc),
    .new_pc(new_pc),
    .mem_req(mem_req),
    .mem_addr(mem_addr),
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
    .rvfi_mem_wdata(rvfi_mem_wdata),	
  );




  assign io_imem_req_valid = d_io_imem_req_valid; // @[core.scala 46:11]
  assign io_imem_req_bits_addr = d_io_imem_req_bits_addr; // @[core.scala 46:11]
  assign io_dmem_req_valid = c_io_dmem_req_valid; // @[core.scala 50:21]
  assign io_dmem_req_bits_addr = d_io_dmem_req_bits_addr; // @[core.scala 49:11]
  assign io_dmem_req_bits_data = d_io_dmem_req_bits_data; // @[core.scala 49:11]
  assign io_dmem_req_bits_fcn = c_io_dmem_req_bits_fcn; // @[core.scala 52:24]
  assign io_dmem_req_bits_typ = c_io_dmem_req_bits_typ; // @[core.scala 51:24]
  assign c_io_imem_resp_valid = io_imem_resp_valid; // @[core.scala 45:11]
  assign c_io_dmem_resp_valid = io_dmem_resp_valid; // @[core.scala 48:11]
  assign c_io_dat_if_valid_resp = d_io_dat_if_valid_resp; // @[core.scala 43:13]
  assign c_io_dat_inst = d_io_dat_inst; // @[core.scala 43:13]
  assign c_io_dat_br_eq = d_io_dat_br_eq; // @[core.scala 43:13]
  assign c_io_dat_br_lt = d_io_dat_br_lt; // @[core.scala 43:13]
  assign c_io_dat_br_ltu = d_io_dat_br_ltu; // @[core.scala 43:13]
  assign c_io_dat_inst_misaligned = d_io_dat_inst_misaligned; // @[core.scala 43:13]
  assign c_io_dat_data_misaligned = d_io_dat_data_misaligned; // @[core.scala 43:13]
  assign c_io_dat_mem_store = d_io_dat_mem_store; // @[core.scala 43:13]
  assign c_io_dat_csr_eret = d_io_dat_csr_eret; // @[core.scala 43:13]
  assign c_io_dat_csr_interrupt = d_io_dat_csr_interrupt; // @[core.scala 43:13]
  assign d_clock = clock;
  assign d_reset = reset;
  assign d_io_imem_resp_valid = io_imem_resp_valid; // @[core.scala 46:11]
  assign d_io_imem_resp_bits_data = io_imem_resp_bits_data; // @[core.scala 46:11]
  assign d_io_dmem_resp_bits_data = io_dmem_resp_bits_data; // @[core.scala 49:11]
  assign d_io_ctl_stall = c_io_ctl_stall; // @[core.scala 42:13]
  assign d_io_ctl_if_kill = c_io_ctl_if_kill; // @[core.scala 42:13]
  assign d_io_ctl_pc_sel = c_io_ctl_pc_sel; // @[core.scala 42:13]
  assign d_io_ctl_op1_sel = c_io_ctl_op1_sel; // @[core.scala 42:13]
  assign d_io_ctl_op2_sel = c_io_ctl_op2_sel; // @[core.scala 42:13]
  assign d_io_ctl_alu_fun = c_io_ctl_alu_fun; // @[core.scala 42:13]
  assign d_io_ctl_wb_sel = c_io_ctl_wb_sel; // @[core.scala 42:13]
  assign d_io_ctl_rf_wen = c_io_ctl_rf_wen; // @[core.scala 42:13]
  assign d_io_ctl_csr_cmd = c_io_ctl_csr_cmd; // @[core.scala 42:13]
  assign d_io_ctl_mem_val = c_io_ctl_mem_val; // @[core.scala 42:13]
  assign d_io_ctl_mem_fcn = c_io_ctl_mem_fcn; // @[core.scala 42:13]
  assign d_io_ctl_mem_typ = c_io_ctl_mem_typ; // @[core.scala 42:13]
  assign d_io_ctl_exception = c_io_ctl_exception; // @[core.scala 42:13]
  assign d_io_ctl_exception_cause = c_io_ctl_exception_cause; // @[core.scala 42:13]
  assign d_io_ctl_pc_sel_no_xept = c_io_ctl_pc_sel_no_xept; // @[core.scala 42:13]
  assign d_io_interrupt_debug = io_interrupt_debug; // @[core.scala 57:18]
  assign d_io_interrupt_mtip = io_interrupt_mtip; // @[core.scala 57:18]
  assign d_io_interrupt_msip = io_interrupt_msip; // @[core.scala 57:18]
  assign d_io_interrupt_meip = io_interrupt_meip; // @[core.scala 57:18]
  assign d_io_hartid = io_hartid; // @[core.scala 58:15]
  assign d_io_reset_vector = io_reset_vector; // @[core.scala 59:21]
endmodule