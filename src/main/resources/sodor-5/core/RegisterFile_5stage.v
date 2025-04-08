module RegisterFile_5stage(
  input         clock,
  input  [4:0]  io_rs1_addr,
  output [31:0] io_rs1_data,
  input  [4:0]  io_rs2_addr,
  output [31:0] io_rs2_data,
  input  [4:0]  io_waddr,
  input  [31:0] io_wdata,
  input         io_wen,
  output [1023:0] rvfi_regfile,
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
  reg [31:0] regfile [0:31]; // @[regfile.scala 35:21]
  wire  regfile_io_rs1_data_MPORT_en; // @[regfile.scala 35:21]
  wire [4:0] regfile_io_rs1_data_MPORT_addr; // @[regfile.scala 35:21]
  wire [31:0] regfile_io_rs1_data_MPORT_data; // @[regfile.scala 35:21]
  wire  regfile_io_rs2_data_MPORT_en; // @[regfile.scala 35:21]
  wire [4:0] regfile_io_rs2_data_MPORT_addr; // @[regfile.scala 35:21]
  wire [31:0] regfile_io_rs2_data_MPORT_data; // @[regfile.scala 35:21]
  wire  regfile_io_dm_rdata_MPORT_en; // @[regfile.scala 35:21]
  wire [4:0] regfile_io_dm_rdata_MPORT_addr; // @[regfile.scala 35:21]
  wire [31:0] regfile_io_dm_rdata_MPORT_data; // @[regfile.scala 35:21]
  wire [31:0] regfile_MPORT_data; // @[regfile.scala 35:21]
  wire [4:0] regfile_MPORT_addr; // @[regfile.scala 35:21]
  wire  regfile_MPORT_mask; // @[regfile.scala 35:21]
  wire  regfile_MPORT_en; // @[regfile.scala 35:21]
  wire [31:0] regfile_MPORT_1_data; // @[regfile.scala 35:21]
  wire [4:0] regfile_MPORT_1_addr; // @[regfile.scala 35:21]
  wire  regfile_MPORT_1_mask; // @[regfile.scala 35:21]
  wire  regfile_MPORT_1_en; // @[regfile.scala 35:21]
  wire  _T = io_waddr != 5'h0; // @[regfile.scala 37:30]
  assign regfile_io_rs1_data_MPORT_en = 1'h1;
  assign regfile_io_rs1_data_MPORT_addr = io_rs1_addr;
  assign regfile_io_rs1_data_MPORT_data = regfile[regfile_io_rs1_data_MPORT_addr]; // @[regfile.scala 35:21]
  assign regfile_io_rs2_data_MPORT_en = 1'h1;
  assign regfile_io_rs2_data_MPORT_addr = io_rs2_addr;
  assign regfile_io_rs2_data_MPORT_data = regfile[regfile_io_rs2_data_MPORT_addr]; // @[regfile.scala 35:21]
  assign regfile_io_dm_rdata_MPORT_en = 1'h1;
  assign regfile_io_dm_rdata_MPORT_addr = 5'h0;
  assign regfile_io_dm_rdata_MPORT_data = regfile[regfile_io_dm_rdata_MPORT_addr]; // @[regfile.scala 35:21]
  assign regfile_MPORT_data = io_wdata;
  assign regfile_MPORT_addr = io_waddr;
  assign regfile_MPORT_mask = 1'h1;
  assign regfile_MPORT_en = io_wen & _T;
  assign regfile_MPORT_1_data = 32'h0;
  assign regfile_MPORT_1_addr = 5'h0;
  assign regfile_MPORT_1_mask = 1'h1;
  assign regfile_MPORT_1_en = 1'h0;
  assign io_rs1_data = io_rs1_addr != 5'h0 ? regfile_io_rs1_data_MPORT_data : 32'h0; // @[regfile.scala 47:22]
  assign io_rs2_data = io_rs2_addr != 5'h0 ? regfile_io_rs2_data_MPORT_data : 32'h0; // @[regfile.scala 48:22]
  always @(posedge clock) begin
    if (regfile_MPORT_en & regfile_MPORT_mask) begin
      regfile[regfile_MPORT_addr] <= regfile_MPORT_data; // @[regfile.scala 35:21]
    end
    if (regfile_MPORT_1_en & regfile_MPORT_1_mask) begin
      regfile[regfile_MPORT_1_addr] <= regfile_MPORT_1_data; // @[regfile.scala 35:21]
    end
  end

reg [1023:0] rvfi_regfile;
integer i;
always @(*) begin
  for (i = 0; i < 32; i = i + 1) begin
      rvfi_regfile[(31 - i) * 32+:32] = regfile[i];
    end
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 32; initvar = initvar+1)
    regfile[initvar] = _RAND_0[31:0];
`endif // RANDOMIZE_MEM_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule