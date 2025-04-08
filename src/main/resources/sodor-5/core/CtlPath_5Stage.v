module CtlPath_5stage(
  input         clock,
  input         reset,
  input         io_dmem_resp_valid,
  input  [31:0] io_dat_dec_inst,
  input         io_dat_dec_valid,
  input         io_dat_exe_br_eq,
  input         io_dat_exe_br_lt,
  input         io_dat_exe_br_ltu,
  input  [3:0]  io_dat_exe_br_type,
  input         io_dat_exe_inst_misaligned,
  input         io_dat_mem_ctrl_dmem_val,
  input         io_dat_mem_data_misaligned,
  input         io_dat_mem_store,
  input         io_dat_csr_eret,
  input         io_dat_csr_interrupt,
  output        io_ctl_dec_stall,
  output        io_ctl_full_stall,
  output [1:0]  io_ctl_exe_pc_sel,
  output [3:0]  io_ctl_br_type,
  output        io_ctl_if_kill,
  output        io_ctl_dec_kill,
  output [1:0]  io_ctl_op1_sel,
  output [2:0]  io_ctl_op2_sel,
  output [3:0]  io_ctl_alu_fun,
  output [1:0]  io_ctl_wb_sel,
  output        io_ctl_rf_wen,
  output        io_ctl_mem_val,
  output [1:0]  io_ctl_mem_fcn,
  output [2:0]  io_ctl_mem_typ,
  output [2:0]  io_ctl_csr_cmd,
  output        io_ctl_fencei,
  output        io_ctl_pipeline_kill,
  output        io_ctl_mem_exception,
  output [31:0] io_ctl_mem_exception_cause
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
`endif // RANDOMIZE_REG_INIT
  wire [31:0] _csignals_T = io_dat_dec_inst & 32'h707f; // @[Lookup.scala 31:38]
  wire  _csignals_T_1 = 32'h2003 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_3 = 32'h3 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_5 = 32'h4003 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_7 = 32'h1003 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_9 = 32'h5003 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_11 = 32'h2023 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_13 = 32'h23 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_15 = 32'h1023 == _csignals_T; // @[Lookup.scala 31:38]
  wire [31:0] _csignals_T_16 = io_dat_dec_inst & 32'h7f; // @[Lookup.scala 31:38]
  wire  _csignals_T_17 = 32'h17 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_19 = 32'h37 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_21 = 32'h13 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_23 = 32'h7013 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_25 = 32'h6013 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_27 = 32'h4013 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_29 = 32'h2013 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_31 = 32'h3013 == _csignals_T; // @[Lookup.scala 31:38]
  wire [31:0] _csignals_T_32 = io_dat_dec_inst & 32'hfc00707f; // @[Lookup.scala 31:38]
  wire  _csignals_T_33 = 32'h1013 == _csignals_T_32; // @[Lookup.scala 31:38]
  wire  _csignals_T_35 = 32'h40005013 == _csignals_T_32; // @[Lookup.scala 31:38]
  wire  _csignals_T_37 = 32'h5013 == _csignals_T_32; // @[Lookup.scala 31:38]
  wire [31:0] _csignals_T_38 = io_dat_dec_inst & 32'hfe00707f; // @[Lookup.scala 31:38]
  wire  _csignals_T_39 = 32'h1033 == _csignals_T_38; // @[Lookup.scala 31:38]
  wire  _csignals_T_41 = 32'h33 == _csignals_T_38; // @[Lookup.scala 31:38]
  wire  _csignals_T_43 = 32'h40000033 == _csignals_T_38; // @[Lookup.scala 31:38]
  wire  _csignals_T_45 = 32'h2033 == _csignals_T_38; // @[Lookup.scala 31:38]
  wire  _csignals_T_47 = 32'h3033 == _csignals_T_38; // @[Lookup.scala 31:38]
  wire  _csignals_T_49 = 32'h7033 == _csignals_T_38; // @[Lookup.scala 31:38]
  wire  _csignals_T_51 = 32'h6033 == _csignals_T_38; // @[Lookup.scala 31:38]
  wire  _csignals_T_53 = 32'h4033 == _csignals_T_38; // @[Lookup.scala 31:38]
  wire  _csignals_T_55 = 32'h40005033 == _csignals_T_38; // @[Lookup.scala 31:38]
  wire  _csignals_T_57 = 32'h5033 == _csignals_T_38; // @[Lookup.scala 31:38]
  wire  _csignals_T_59 = 32'h6f == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_61 = 32'h67 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_63 = 32'h63 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_65 = 32'h1063 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_67 = 32'h5063 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_69 = 32'h7063 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_71 = 32'h4063 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_73 = 32'h6063 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_75 = 32'h5073 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_77 = 32'h6073 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_79 = 32'h1073 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_81 = 32'h2073 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_83 = 32'h3073 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_85 = 32'h7073 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_87 = 32'h73 == io_dat_dec_inst; // @[Lookup.scala 31:38]
  wire  _csignals_T_89 = 32'h30200073 == io_dat_dec_inst; // @[Lookup.scala 31:38]
  wire  _csignals_T_91 = 32'h7b200073 == io_dat_dec_inst; // @[Lookup.scala 31:38]
  wire  _csignals_T_93 = 32'h100073 == io_dat_dec_inst; // @[Lookup.scala 31:38]
  wire  _csignals_T_95 = 32'h10500073 == io_dat_dec_inst; // @[Lookup.scala 31:38]
  wire  _csignals_T_97 = 32'h100f == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_99 = 32'hf == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_130 = _csignals_T_39 | (_csignals_T_41 | (_csignals_T_43 | (_csignals_T_45 | (_csignals_T_47 | (
    _csignals_T_49 | (_csignals_T_51 | (_csignals_T_53 | (_csignals_T_55 | (_csignals_T_57 | (_csignals_T_59 | (
    _csignals_T_61 | (_csignals_T_63 | (_csignals_T_65 | (_csignals_T_67 | (_csignals_T_69 | (_csignals_T_71 | (
    _csignals_T_73 | (_csignals_T_75 | (_csignals_T_77 | (_csignals_T_79 | (_csignals_T_81 | (_csignals_T_83 | (
    _csignals_T_85 | (_csignals_T_87 | (_csignals_T_89 | (_csignals_T_91 | (_csignals_T_93 | (_csignals_T_95 | (
    _csignals_T_97 | _csignals_T_99))))))))))))))))))))))))))))); // @[Lookup.scala 34:39]
  wire  cs_val_inst = _csignals_T_1 | (_csignals_T_3 | (_csignals_T_5 | (_csignals_T_7 | (_csignals_T_9 | (
    _csignals_T_11 | (_csignals_T_13 | (_csignals_T_15 | (_csignals_T_17 | (_csignals_T_19 | (_csignals_T_21 | (
    _csignals_T_23 | (_csignals_T_25 | (_csignals_T_27 | (_csignals_T_29 | (_csignals_T_31 | (_csignals_T_33 | (
    _csignals_T_35 | (_csignals_T_37 | _csignals_T_130)))))))))))))))))); // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_162 = _csignals_T_73 ? 4'h6 : 4'h0; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_163 = _csignals_T_71 ? 4'h5 : _csignals_T_162; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_164 = _csignals_T_69 ? 4'h4 : _csignals_T_163; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_165 = _csignals_T_67 ? 4'h3 : _csignals_T_164; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_166 = _csignals_T_65 ? 4'h1 : _csignals_T_165; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_167 = _csignals_T_63 ? 4'h2 : _csignals_T_166; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_168 = _csignals_T_61 ? 4'h8 : _csignals_T_167; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_169 = _csignals_T_59 ? 4'h7 : _csignals_T_168; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_170 = _csignals_T_57 ? 4'h0 : _csignals_T_169; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_171 = _csignals_T_55 ? 4'h0 : _csignals_T_170; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_172 = _csignals_T_53 ? 4'h0 : _csignals_T_171; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_173 = _csignals_T_51 ? 4'h0 : _csignals_T_172; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_174 = _csignals_T_49 ? 4'h0 : _csignals_T_173; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_175 = _csignals_T_47 ? 4'h0 : _csignals_T_174; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_176 = _csignals_T_45 ? 4'h0 : _csignals_T_175; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_177 = _csignals_T_43 ? 4'h0 : _csignals_T_176; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_178 = _csignals_T_41 ? 4'h0 : _csignals_T_177; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_179 = _csignals_T_39 ? 4'h0 : _csignals_T_178; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_180 = _csignals_T_37 ? 4'h0 : _csignals_T_179; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_181 = _csignals_T_35 ? 4'h0 : _csignals_T_180; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_182 = _csignals_T_33 ? 4'h0 : _csignals_T_181; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_183 = _csignals_T_31 ? 4'h0 : _csignals_T_182; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_184 = _csignals_T_29 ? 4'h0 : _csignals_T_183; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_185 = _csignals_T_27 ? 4'h0 : _csignals_T_184; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_186 = _csignals_T_25 ? 4'h0 : _csignals_T_185; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_187 = _csignals_T_23 ? 4'h0 : _csignals_T_186; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_188 = _csignals_T_21 ? 4'h0 : _csignals_T_187; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_189 = _csignals_T_19 ? 4'h0 : _csignals_T_188; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_190 = _csignals_T_17 ? 4'h0 : _csignals_T_189; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_191 = _csignals_T_15 ? 4'h0 : _csignals_T_190; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_192 = _csignals_T_13 ? 4'h0 : _csignals_T_191; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_193 = _csignals_T_11 ? 4'h0 : _csignals_T_192; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_194 = _csignals_T_9 ? 4'h0 : _csignals_T_193; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_195 = _csignals_T_7 ? 4'h0 : _csignals_T_194; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_196 = _csignals_T_5 ? 4'h0 : _csignals_T_195; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_197 = _csignals_T_3 ? 4'h0 : _csignals_T_196; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_205 = _csignals_T_85 ? 2'h2 : 2'h0; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_206 = _csignals_T_83 ? 2'h0 : _csignals_T_205; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_207 = _csignals_T_81 ? 2'h0 : _csignals_T_206; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_208 = _csignals_T_79 ? 2'h0 : _csignals_T_207; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_209 = _csignals_T_77 ? 2'h2 : _csignals_T_208; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_210 = _csignals_T_75 ? 2'h2 : _csignals_T_209; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_211 = _csignals_T_73 ? 2'h0 : _csignals_T_210; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_212 = _csignals_T_71 ? 2'h0 : _csignals_T_211; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_213 = _csignals_T_69 ? 2'h0 : _csignals_T_212; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_214 = _csignals_T_67 ? 2'h0 : _csignals_T_213; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_215 = _csignals_T_65 ? 2'h0 : _csignals_T_214; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_216 = _csignals_T_63 ? 2'h0 : _csignals_T_215; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_217 = _csignals_T_61 ? 2'h0 : _csignals_T_216; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_218 = _csignals_T_59 ? 2'h0 : _csignals_T_217; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_219 = _csignals_T_57 ? 2'h0 : _csignals_T_218; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_220 = _csignals_T_55 ? 2'h0 : _csignals_T_219; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_221 = _csignals_T_53 ? 2'h0 : _csignals_T_220; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_222 = _csignals_T_51 ? 2'h0 : _csignals_T_221; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_223 = _csignals_T_49 ? 2'h0 : _csignals_T_222; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_224 = _csignals_T_47 ? 2'h0 : _csignals_T_223; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_225 = _csignals_T_45 ? 2'h0 : _csignals_T_224; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_226 = _csignals_T_43 ? 2'h0 : _csignals_T_225; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_227 = _csignals_T_41 ? 2'h0 : _csignals_T_226; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_228 = _csignals_T_39 ? 2'h0 : _csignals_T_227; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_229 = _csignals_T_37 ? 2'h0 : _csignals_T_228; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_230 = _csignals_T_35 ? 2'h0 : _csignals_T_229; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_231 = _csignals_T_33 ? 2'h0 : _csignals_T_230; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_232 = _csignals_T_31 ? 2'h0 : _csignals_T_231; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_233 = _csignals_T_29 ? 2'h0 : _csignals_T_232; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_234 = _csignals_T_27 ? 2'h0 : _csignals_T_233; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_235 = _csignals_T_25 ? 2'h0 : _csignals_T_234; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_236 = _csignals_T_23 ? 2'h0 : _csignals_T_235; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_237 = _csignals_T_21 ? 2'h0 : _csignals_T_236; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_238 = _csignals_T_19 ? 2'h0 : _csignals_T_237; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_239 = _csignals_T_17 ? 2'h1 : _csignals_T_238; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_240 = _csignals_T_15 ? 2'h0 : _csignals_T_239; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_241 = _csignals_T_13 ? 2'h0 : _csignals_T_240; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_242 = _csignals_T_11 ? 2'h0 : _csignals_T_241; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_243 = _csignals_T_9 ? 2'h0 : _csignals_T_242; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_244 = _csignals_T_7 ? 2'h0 : _csignals_T_243; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_245 = _csignals_T_5 ? 2'h0 : _csignals_T_244; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_246 = _csignals_T_3 ? 2'h0 : _csignals_T_245; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_260 = _csignals_T_73 ? 3'h3 : 3'h0; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_261 = _csignals_T_71 ? 3'h3 : _csignals_T_260; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_262 = _csignals_T_69 ? 3'h3 : _csignals_T_261; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_263 = _csignals_T_67 ? 3'h3 : _csignals_T_262; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_264 = _csignals_T_65 ? 3'h3 : _csignals_T_263; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_265 = _csignals_T_63 ? 3'h3 : _csignals_T_264; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_266 = _csignals_T_61 ? 3'h1 : _csignals_T_265; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_267 = _csignals_T_59 ? 3'h5 : _csignals_T_266; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_268 = _csignals_T_57 ? 3'h0 : _csignals_T_267; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_269 = _csignals_T_55 ? 3'h0 : _csignals_T_268; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_270 = _csignals_T_53 ? 3'h0 : _csignals_T_269; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_271 = _csignals_T_51 ? 3'h0 : _csignals_T_270; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_272 = _csignals_T_49 ? 3'h0 : _csignals_T_271; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_273 = _csignals_T_47 ? 3'h0 : _csignals_T_272; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_274 = _csignals_T_45 ? 3'h0 : _csignals_T_273; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_275 = _csignals_T_43 ? 3'h0 : _csignals_T_274; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_276 = _csignals_T_41 ? 3'h0 : _csignals_T_275; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_277 = _csignals_T_39 ? 3'h0 : _csignals_T_276; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_278 = _csignals_T_37 ? 3'h1 : _csignals_T_277; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_279 = _csignals_T_35 ? 3'h1 : _csignals_T_278; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_280 = _csignals_T_33 ? 3'h1 : _csignals_T_279; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_281 = _csignals_T_31 ? 3'h1 : _csignals_T_280; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_282 = _csignals_T_29 ? 3'h1 : _csignals_T_281; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_283 = _csignals_T_27 ? 3'h1 : _csignals_T_282; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_284 = _csignals_T_25 ? 3'h1 : _csignals_T_283; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_285 = _csignals_T_23 ? 3'h1 : _csignals_T_284; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_286 = _csignals_T_21 ? 3'h1 : _csignals_T_285; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_287 = _csignals_T_19 ? 3'h4 : _csignals_T_286; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_288 = _csignals_T_17 ? 3'h4 : _csignals_T_287; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_289 = _csignals_T_15 ? 3'h2 : _csignals_T_288; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_290 = _csignals_T_13 ? 3'h2 : _csignals_T_289; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_291 = _csignals_T_11 ? 3'h2 : _csignals_T_290; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_292 = _csignals_T_9 ? 3'h1 : _csignals_T_291; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_293 = _csignals_T_7 ? 3'h1 : _csignals_T_292; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_294 = _csignals_T_5 ? 3'h1 : _csignals_T_293; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_295 = _csignals_T_3 ? 3'h1 : _csignals_T_294; // @[Lookup.scala 34:39]
  wire  _csignals_T_316 = _csignals_T_59 ? 1'h0 : _csignals_T_61 | (_csignals_T_63 | (_csignals_T_65 | (_csignals_T_67
     | (_csignals_T_69 | (_csignals_T_71 | (_csignals_T_73 | (_csignals_T_75 | (_csignals_T_77 | (_csignals_T_79 | (
    _csignals_T_81 | (_csignals_T_83 | _csignals_T_85))))))))))); // @[Lookup.scala 34:39]
  wire  _csignals_T_336 = _csignals_T_19 ? 1'h0 : _csignals_T_21 | (_csignals_T_23 | (_csignals_T_25 | (_csignals_T_27
     | (_csignals_T_29 | (_csignals_T_31 | (_csignals_T_33 | (_csignals_T_35 | (_csignals_T_37 | (_csignals_T_39 | (
    _csignals_T_41 | (_csignals_T_43 | (_csignals_T_45 | (_csignals_T_47 | (_csignals_T_49 | (_csignals_T_51 | (
    _csignals_T_53 | (_csignals_T_55 | (_csignals_T_57 | _csignals_T_316)))))))))))))))))); // @[Lookup.scala 34:39]
  wire  _csignals_T_337 = _csignals_T_17 ? 1'h0 : _csignals_T_336; // @[Lookup.scala 34:39]
  wire  cs_rs1_oen = _csignals_T_1 | (_csignals_T_3 | (_csignals_T_5 | (_csignals_T_7 | (_csignals_T_9 | (_csignals_T_11
     | (_csignals_T_13 | (_csignals_T_15 | _csignals_T_337))))))); // @[Lookup.scala 34:39]
  wire  _csignals_T_364 = _csignals_T_61 ? 1'h0 : _csignals_T_63 | (_csignals_T_65 | (_csignals_T_67 | (_csignals_T_69
     | (_csignals_T_71 | (_csignals_T_73 | (_csignals_T_75 | (_csignals_T_77 | (_csignals_T_79 | (_csignals_T_81 | (
    _csignals_T_83 | _csignals_T_85)))))))))); // @[Lookup.scala 34:39]
  wire  _csignals_T_365 = _csignals_T_59 ? 1'h0 : _csignals_T_364; // @[Lookup.scala 34:39]
  wire  _csignals_T_376 = _csignals_T_37 ? 1'h0 : _csignals_T_39 | (_csignals_T_41 | (_csignals_T_43 | (_csignals_T_45
     | (_csignals_T_47 | (_csignals_T_49 | (_csignals_T_51 | (_csignals_T_53 | (_csignals_T_55 | (_csignals_T_57 |
    _csignals_T_365))))))))); // @[Lookup.scala 34:39]
  wire  _csignals_T_377 = _csignals_T_35 ? 1'h0 : _csignals_T_376; // @[Lookup.scala 34:39]
  wire  _csignals_T_378 = _csignals_T_33 ? 1'h0 : _csignals_T_377; // @[Lookup.scala 34:39]
  wire  _csignals_T_379 = _csignals_T_31 ? 1'h0 : _csignals_T_378; // @[Lookup.scala 34:39]
  wire  _csignals_T_380 = _csignals_T_29 ? 1'h0 : _csignals_T_379; // @[Lookup.scala 34:39]
  wire  _csignals_T_381 = _csignals_T_27 ? 1'h0 : _csignals_T_380; // @[Lookup.scala 34:39]
  wire  _csignals_T_382 = _csignals_T_25 ? 1'h0 : _csignals_T_381; // @[Lookup.scala 34:39]
  wire  _csignals_T_383 = _csignals_T_23 ? 1'h0 : _csignals_T_382; // @[Lookup.scala 34:39]
  wire  _csignals_T_384 = _csignals_T_21 ? 1'h0 : _csignals_T_383; // @[Lookup.scala 34:39]
  wire  _csignals_T_385 = _csignals_T_19 ? 1'h0 : _csignals_T_384; // @[Lookup.scala 34:39]
  wire  _csignals_T_386 = _csignals_T_17 ? 1'h0 : _csignals_T_385; // @[Lookup.scala 34:39]
  wire  _csignals_T_390 = _csignals_T_9 ? 1'h0 : _csignals_T_11 | (_csignals_T_13 | (_csignals_T_15 | _csignals_T_386)); // @[Lookup.scala 34:39]
  wire  _csignals_T_391 = _csignals_T_7 ? 1'h0 : _csignals_T_390; // @[Lookup.scala 34:39]
  wire  _csignals_T_392 = _csignals_T_5 ? 1'h0 : _csignals_T_391; // @[Lookup.scala 34:39]
  wire  _csignals_T_393 = _csignals_T_3 ? 1'h0 : _csignals_T_392; // @[Lookup.scala 34:39]
  wire  cs_rs2_oen = _csignals_T_1 ? 1'h0 : _csignals_T_393; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_401 = _csignals_T_85 ? 4'ha : 4'h0; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_402 = _csignals_T_83 ? 4'ha : _csignals_T_401; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_403 = _csignals_T_81 ? 4'ha : _csignals_T_402; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_404 = _csignals_T_79 ? 4'ha : _csignals_T_403; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_405 = _csignals_T_77 ? 4'ha : _csignals_T_404; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_406 = _csignals_T_75 ? 4'ha : _csignals_T_405; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_407 = _csignals_T_73 ? 4'h0 : _csignals_T_406; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_408 = _csignals_T_71 ? 4'h0 : _csignals_T_407; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_409 = _csignals_T_69 ? 4'h0 : _csignals_T_408; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_410 = _csignals_T_67 ? 4'h0 : _csignals_T_409; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_411 = _csignals_T_65 ? 4'h0 : _csignals_T_410; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_412 = _csignals_T_63 ? 4'h0 : _csignals_T_411; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_413 = _csignals_T_61 ? 4'h0 : _csignals_T_412; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_414 = _csignals_T_59 ? 4'h0 : _csignals_T_413; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_415 = _csignals_T_57 ? 4'h3 : _csignals_T_414; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_416 = _csignals_T_55 ? 4'h4 : _csignals_T_415; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_417 = _csignals_T_53 ? 4'h7 : _csignals_T_416; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_418 = _csignals_T_51 ? 4'h6 : _csignals_T_417; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_419 = _csignals_T_49 ? 4'h5 : _csignals_T_418; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_420 = _csignals_T_47 ? 4'h9 : _csignals_T_419; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_421 = _csignals_T_45 ? 4'h8 : _csignals_T_420; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_422 = _csignals_T_43 ? 4'h1 : _csignals_T_421; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_423 = _csignals_T_41 ? 4'h0 : _csignals_T_422; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_424 = _csignals_T_39 ? 4'h2 : _csignals_T_423; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_425 = _csignals_T_37 ? 4'h3 : _csignals_T_424; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_426 = _csignals_T_35 ? 4'h4 : _csignals_T_425; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_427 = _csignals_T_33 ? 4'h2 : _csignals_T_426; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_428 = _csignals_T_31 ? 4'h9 : _csignals_T_427; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_429 = _csignals_T_29 ? 4'h8 : _csignals_T_428; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_430 = _csignals_T_27 ? 4'h7 : _csignals_T_429; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_431 = _csignals_T_25 ? 4'h6 : _csignals_T_430; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_432 = _csignals_T_23 ? 4'h5 : _csignals_T_431; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_433 = _csignals_T_21 ? 4'h0 : _csignals_T_432; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_434 = _csignals_T_19 ? 4'hb : _csignals_T_433; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_435 = _csignals_T_17 ? 4'h0 : _csignals_T_434; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_436 = _csignals_T_15 ? 4'h0 : _csignals_T_435; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_437 = _csignals_T_13 ? 4'h0 : _csignals_T_436; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_438 = _csignals_T_11 ? 4'h0 : _csignals_T_437; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_439 = _csignals_T_9 ? 4'h0 : _csignals_T_438; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_440 = _csignals_T_7 ? 4'h0 : _csignals_T_439; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_441 = _csignals_T_5 ? 4'h0 : _csignals_T_440; // @[Lookup.scala 34:39]
  wire [3:0] _csignals_T_442 = _csignals_T_3 ? 4'h0 : _csignals_T_441; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_450 = _csignals_T_85 ? 2'h3 : 2'h0; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_451 = _csignals_T_83 ? 2'h3 : _csignals_T_450; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_452 = _csignals_T_81 ? 2'h3 : _csignals_T_451; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_453 = _csignals_T_79 ? 2'h3 : _csignals_T_452; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_454 = _csignals_T_77 ? 2'h3 : _csignals_T_453; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_455 = _csignals_T_75 ? 2'h3 : _csignals_T_454; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_456 = _csignals_T_73 ? 2'h0 : _csignals_T_455; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_457 = _csignals_T_71 ? 2'h0 : _csignals_T_456; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_458 = _csignals_T_69 ? 2'h0 : _csignals_T_457; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_459 = _csignals_T_67 ? 2'h0 : _csignals_T_458; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_460 = _csignals_T_65 ? 2'h0 : _csignals_T_459; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_461 = _csignals_T_63 ? 2'h0 : _csignals_T_460; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_462 = _csignals_T_61 ? 2'h2 : _csignals_T_461; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_463 = _csignals_T_59 ? 2'h2 : _csignals_T_462; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_464 = _csignals_T_57 ? 2'h0 : _csignals_T_463; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_465 = _csignals_T_55 ? 2'h0 : _csignals_T_464; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_466 = _csignals_T_53 ? 2'h0 : _csignals_T_465; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_467 = _csignals_T_51 ? 2'h0 : _csignals_T_466; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_468 = _csignals_T_49 ? 2'h0 : _csignals_T_467; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_469 = _csignals_T_47 ? 2'h0 : _csignals_T_468; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_470 = _csignals_T_45 ? 2'h0 : _csignals_T_469; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_471 = _csignals_T_43 ? 2'h0 : _csignals_T_470; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_472 = _csignals_T_41 ? 2'h0 : _csignals_T_471; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_473 = _csignals_T_39 ? 2'h0 : _csignals_T_472; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_474 = _csignals_T_37 ? 2'h0 : _csignals_T_473; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_475 = _csignals_T_35 ? 2'h0 : _csignals_T_474; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_476 = _csignals_T_33 ? 2'h0 : _csignals_T_475; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_477 = _csignals_T_31 ? 2'h0 : _csignals_T_476; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_478 = _csignals_T_29 ? 2'h0 : _csignals_T_477; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_479 = _csignals_T_27 ? 2'h0 : _csignals_T_478; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_480 = _csignals_T_25 ? 2'h0 : _csignals_T_479; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_481 = _csignals_T_23 ? 2'h0 : _csignals_T_480; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_482 = _csignals_T_21 ? 2'h0 : _csignals_T_481; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_483 = _csignals_T_19 ? 2'h0 : _csignals_T_482; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_484 = _csignals_T_17 ? 2'h0 : _csignals_T_483; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_485 = _csignals_T_15 ? 2'h0 : _csignals_T_484; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_486 = _csignals_T_13 ? 2'h0 : _csignals_T_485; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_487 = _csignals_T_11 ? 2'h0 : _csignals_T_486; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_488 = _csignals_T_9 ? 2'h1 : _csignals_T_487; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_489 = _csignals_T_7 ? 2'h1 : _csignals_T_488; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_490 = _csignals_T_5 ? 2'h1 : _csignals_T_489; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_491 = _csignals_T_3 ? 2'h1 : _csignals_T_490; // @[Lookup.scala 34:39]
  wire  _csignals_T_505 = _csignals_T_73 ? 1'h0 : _csignals_T_75 | (_csignals_T_77 | (_csignals_T_79 | (_csignals_T_81
     | (_csignals_T_83 | _csignals_T_85)))); // @[Lookup.scala 34:39]
  wire  _csignals_T_506 = _csignals_T_71 ? 1'h0 : _csignals_T_505; // @[Lookup.scala 34:39]
  wire  _csignals_T_507 = _csignals_T_69 ? 1'h0 : _csignals_T_506; // @[Lookup.scala 34:39]
  wire  _csignals_T_508 = _csignals_T_67 ? 1'h0 : _csignals_T_507; // @[Lookup.scala 34:39]
  wire  _csignals_T_509 = _csignals_T_65 ? 1'h0 : _csignals_T_508; // @[Lookup.scala 34:39]
  wire  _csignals_T_510 = _csignals_T_63 ? 1'h0 : _csignals_T_509; // @[Lookup.scala 34:39]
  wire  _csignals_T_534 = _csignals_T_15 ? 1'h0 : _csignals_T_17 | (_csignals_T_19 | (_csignals_T_21 | (_csignals_T_23
     | (_csignals_T_25 | (_csignals_T_27 | (_csignals_T_29 | (_csignals_T_31 | (_csignals_T_33 | (_csignals_T_35 | (
    _csignals_T_37 | (_csignals_T_39 | (_csignals_T_41 | (_csignals_T_43 | (_csignals_T_45 | (_csignals_T_47 | (
    _csignals_T_49 | (_csignals_T_51 | (_csignals_T_53 | (_csignals_T_55 | (_csignals_T_57 | (_csignals_T_59 | (
    _csignals_T_61 | _csignals_T_510)))))))))))))))))))))); // @[Lookup.scala 34:39]
  wire  _csignals_T_535 = _csignals_T_13 ? 1'h0 : _csignals_T_534; // @[Lookup.scala 34:39]
  wire  _csignals_T_536 = _csignals_T_11 ? 1'h0 : _csignals_T_535; // @[Lookup.scala 34:39]
  wire  cs0_3 = _csignals_T_1 | (_csignals_T_3 | (_csignals_T_5 | (_csignals_T_7 | (_csignals_T_9 | (_csignals_T_11 | (
    _csignals_T_13 | _csignals_T_15)))))); // @[Lookup.scala 34:39]
  wire  _csignals_T_635 = _csignals_T_9 ? 1'h0 : _csignals_T_11 | (_csignals_T_13 | _csignals_T_15); // @[Lookup.scala 34:39]
  wire  _csignals_T_636 = _csignals_T_7 ? 1'h0 : _csignals_T_635; // @[Lookup.scala 34:39]
  wire  _csignals_T_637 = _csignals_T_5 ? 1'h0 : _csignals_T_636; // @[Lookup.scala 34:39]
  wire  _csignals_T_638 = _csignals_T_3 ? 1'h0 : _csignals_T_637; // @[Lookup.scala 34:39]
  wire  cs0_4 = _csignals_T_1 ? 1'h0 : _csignals_T_638; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_681 = _csignals_T_15 ? 3'h2 : 3'h0; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_682 = _csignals_T_13 ? 3'h1 : _csignals_T_681; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_683 = _csignals_T_11 ? 3'h3 : _csignals_T_682; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_684 = _csignals_T_9 ? 3'h6 : _csignals_T_683; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_685 = _csignals_T_7 ? 3'h2 : _csignals_T_684; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_686 = _csignals_T_5 ? 3'h5 : _csignals_T_685; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_687 = _csignals_T_3 ? 3'h1 : _csignals_T_686; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_691 = _csignals_T_93 ? 3'h4 : 3'h0; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_692 = _csignals_T_91 ? 3'h4 : _csignals_T_691; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_693 = _csignals_T_89 ? 3'h4 : _csignals_T_692; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_694 = _csignals_T_87 ? 3'h4 : _csignals_T_693; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_695 = _csignals_T_85 ? 3'h7 : _csignals_T_694; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_696 = _csignals_T_83 ? 3'h7 : _csignals_T_695; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_697 = _csignals_T_81 ? 3'h6 : _csignals_T_696; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_698 = _csignals_T_79 ? 3'h5 : _csignals_T_697; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_699 = _csignals_T_77 ? 3'h6 : _csignals_T_698; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_700 = _csignals_T_75 ? 3'h5 : _csignals_T_699; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_701 = _csignals_T_73 ? 3'h0 : _csignals_T_700; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_702 = _csignals_T_71 ? 3'h0 : _csignals_T_701; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_703 = _csignals_T_69 ? 3'h0 : _csignals_T_702; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_704 = _csignals_T_67 ? 3'h0 : _csignals_T_703; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_705 = _csignals_T_65 ? 3'h0 : _csignals_T_704; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_706 = _csignals_T_63 ? 3'h0 : _csignals_T_705; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_707 = _csignals_T_61 ? 3'h0 : _csignals_T_706; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_708 = _csignals_T_59 ? 3'h0 : _csignals_T_707; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_709 = _csignals_T_57 ? 3'h0 : _csignals_T_708; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_710 = _csignals_T_55 ? 3'h0 : _csignals_T_709; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_711 = _csignals_T_53 ? 3'h0 : _csignals_T_710; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_712 = _csignals_T_51 ? 3'h0 : _csignals_T_711; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_713 = _csignals_T_49 ? 3'h0 : _csignals_T_712; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_714 = _csignals_T_47 ? 3'h0 : _csignals_T_713; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_715 = _csignals_T_45 ? 3'h0 : _csignals_T_714; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_716 = _csignals_T_43 ? 3'h0 : _csignals_T_715; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_717 = _csignals_T_41 ? 3'h0 : _csignals_T_716; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_718 = _csignals_T_39 ? 3'h0 : _csignals_T_717; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_719 = _csignals_T_37 ? 3'h0 : _csignals_T_718; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_720 = _csignals_T_35 ? 3'h0 : _csignals_T_719; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_721 = _csignals_T_33 ? 3'h0 : _csignals_T_720; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_722 = _csignals_T_31 ? 3'h0 : _csignals_T_721; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_723 = _csignals_T_29 ? 3'h0 : _csignals_T_722; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_724 = _csignals_T_27 ? 3'h0 : _csignals_T_723; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_725 = _csignals_T_25 ? 3'h0 : _csignals_T_724; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_726 = _csignals_T_23 ? 3'h0 : _csignals_T_725; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_727 = _csignals_T_21 ? 3'h0 : _csignals_T_726; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_728 = _csignals_T_19 ? 3'h0 : _csignals_T_727; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_729 = _csignals_T_17 ? 3'h0 : _csignals_T_728; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_730 = _csignals_T_15 ? 3'h0 : _csignals_T_729; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_731 = _csignals_T_13 ? 3'h0 : _csignals_T_730; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_732 = _csignals_T_11 ? 3'h0 : _csignals_T_731; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_733 = _csignals_T_9 ? 3'h0 : _csignals_T_732; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_734 = _csignals_T_7 ? 3'h0 : _csignals_T_733; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_735 = _csignals_T_5 ? 3'h0 : _csignals_T_734; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_736 = _csignals_T_3 ? 3'h0 : _csignals_T_735; // @[Lookup.scala 34:39]
  wire [2:0] cs0_6 = _csignals_T_1 ? 3'h0 : _csignals_T_736; // @[Lookup.scala 34:39]
  wire  _csignals_T_739 = _csignals_T_95 ? 1'h0 : _csignals_T_97; // @[Lookup.scala 34:39]
  wire  _csignals_T_740 = _csignals_T_93 ? 1'h0 : _csignals_T_739; // @[Lookup.scala 34:39]
  wire  _csignals_T_741 = _csignals_T_91 ? 1'h0 : _csignals_T_740; // @[Lookup.scala 34:39]
  wire  _csignals_T_742 = _csignals_T_89 ? 1'h0 : _csignals_T_741; // @[Lookup.scala 34:39]
  wire  _csignals_T_743 = _csignals_T_87 ? 1'h0 : _csignals_T_742; // @[Lookup.scala 34:39]
  wire  _csignals_T_744 = _csignals_T_85 ? 1'h0 : _csignals_T_743; // @[Lookup.scala 34:39]
  wire  _csignals_T_745 = _csignals_T_83 ? 1'h0 : _csignals_T_744; // @[Lookup.scala 34:39]
  wire  _csignals_T_746 = _csignals_T_81 ? 1'h0 : _csignals_T_745; // @[Lookup.scala 34:39]
  wire  _csignals_T_747 = _csignals_T_79 ? 1'h0 : _csignals_T_746; // @[Lookup.scala 34:39]
  wire  _csignals_T_748 = _csignals_T_77 ? 1'h0 : _csignals_T_747; // @[Lookup.scala 34:39]
  wire  _csignals_T_749 = _csignals_T_75 ? 1'h0 : _csignals_T_748; // @[Lookup.scala 34:39]
  wire  _csignals_T_750 = _csignals_T_73 ? 1'h0 : _csignals_T_749; // @[Lookup.scala 34:39]
  wire  _csignals_T_751 = _csignals_T_71 ? 1'h0 : _csignals_T_750; // @[Lookup.scala 34:39]
  wire  _csignals_T_752 = _csignals_T_69 ? 1'h0 : _csignals_T_751; // @[Lookup.scala 34:39]
  wire  _csignals_T_753 = _csignals_T_67 ? 1'h0 : _csignals_T_752; // @[Lookup.scala 34:39]
  wire  _csignals_T_754 = _csignals_T_65 ? 1'h0 : _csignals_T_753; // @[Lookup.scala 34:39]
  wire  _csignals_T_755 = _csignals_T_63 ? 1'h0 : _csignals_T_754; // @[Lookup.scala 34:39]
  wire  _csignals_T_756 = _csignals_T_61 ? 1'h0 : _csignals_T_755; // @[Lookup.scala 34:39]
  wire  _csignals_T_757 = _csignals_T_59 ? 1'h0 : _csignals_T_756; // @[Lookup.scala 34:39]
  wire  _csignals_T_758 = _csignals_T_57 ? 1'h0 : _csignals_T_757; // @[Lookup.scala 34:39]
  wire  _csignals_T_759 = _csignals_T_55 ? 1'h0 : _csignals_T_758; // @[Lookup.scala 34:39]
  wire  _csignals_T_760 = _csignals_T_53 ? 1'h0 : _csignals_T_759; // @[Lookup.scala 34:39]
  wire  _csignals_T_761 = _csignals_T_51 ? 1'h0 : _csignals_T_760; // @[Lookup.scala 34:39]
  wire  _csignals_T_762 = _csignals_T_49 ? 1'h0 : _csignals_T_761; // @[Lookup.scala 34:39]
  wire  _csignals_T_763 = _csignals_T_47 ? 1'h0 : _csignals_T_762; // @[Lookup.scala 34:39]
  wire  _csignals_T_764 = _csignals_T_45 ? 1'h0 : _csignals_T_763; // @[Lookup.scala 34:39]
  wire  _csignals_T_765 = _csignals_T_43 ? 1'h0 : _csignals_T_764; // @[Lookup.scala 34:39]
  wire  _csignals_T_766 = _csignals_T_41 ? 1'h0 : _csignals_T_765; // @[Lookup.scala 34:39]
  wire  _csignals_T_767 = _csignals_T_39 ? 1'h0 : _csignals_T_766; // @[Lookup.scala 34:39]
  wire  _csignals_T_768 = _csignals_T_37 ? 1'h0 : _csignals_T_767; // @[Lookup.scala 34:39]
  wire  _csignals_T_769 = _csignals_T_35 ? 1'h0 : _csignals_T_768; // @[Lookup.scala 34:39]
  wire  _csignals_T_770 = _csignals_T_33 ? 1'h0 : _csignals_T_769; // @[Lookup.scala 34:39]
  wire  _csignals_T_771 = _csignals_T_31 ? 1'h0 : _csignals_T_770; // @[Lookup.scala 34:39]
  wire  _csignals_T_772 = _csignals_T_29 ? 1'h0 : _csignals_T_771; // @[Lookup.scala 34:39]
  wire  _csignals_T_773 = _csignals_T_27 ? 1'h0 : _csignals_T_772; // @[Lookup.scala 34:39]
  wire  _csignals_T_774 = _csignals_T_25 ? 1'h0 : _csignals_T_773; // @[Lookup.scala 34:39]
  wire  _csignals_T_775 = _csignals_T_23 ? 1'h0 : _csignals_T_774; // @[Lookup.scala 34:39]
  wire  _csignals_T_776 = _csignals_T_21 ? 1'h0 : _csignals_T_775; // @[Lookup.scala 34:39]
  wire  _csignals_T_777 = _csignals_T_19 ? 1'h0 : _csignals_T_776; // @[Lookup.scala 34:39]
  wire  _csignals_T_778 = _csignals_T_17 ? 1'h0 : _csignals_T_777; // @[Lookup.scala 34:39]
  wire  _csignals_T_779 = _csignals_T_15 ? 1'h0 : _csignals_T_778; // @[Lookup.scala 34:39]
  wire  _csignals_T_780 = _csignals_T_13 ? 1'h0 : _csignals_T_779; // @[Lookup.scala 34:39]
  wire  _csignals_T_781 = _csignals_T_11 ? 1'h0 : _csignals_T_780; // @[Lookup.scala 34:39]
  wire  _csignals_T_782 = _csignals_T_9 ? 1'h0 : _csignals_T_781; // @[Lookup.scala 34:39]
  wire  _csignals_T_783 = _csignals_T_7 ? 1'h0 : _csignals_T_782; // @[Lookup.scala 34:39]
  wire  _csignals_T_784 = _csignals_T_5 ? 1'h0 : _csignals_T_783; // @[Lookup.scala 34:39]
  wire  _csignals_T_785 = _csignals_T_3 ? 1'h0 : _csignals_T_784; // @[Lookup.scala 34:39]
  wire  cs0_7 = _csignals_T_1 ? 1'h0 : _csignals_T_785; // @[Lookup.scala 34:39]
  wire [1:0] _ctrl_exe_pc_sel_T_3 = ~io_dat_exe_br_eq ? 2'h1 : 2'h0; // @[cpath.scala 137:64]
  wire [1:0] _ctrl_exe_pc_sel_T_5 = io_dat_exe_br_eq ? 2'h1 : 2'h0; // @[cpath.scala 138:64]
  wire [1:0] _ctrl_exe_pc_sel_T_8 = ~io_dat_exe_br_lt ? 2'h1 : 2'h0; // @[cpath.scala 139:64]
  wire [1:0] _ctrl_exe_pc_sel_T_11 = ~io_dat_exe_br_ltu ? 2'h1 : 2'h0; // @[cpath.scala 140:64]
  wire [1:0] _ctrl_exe_pc_sel_T_13 = io_dat_exe_br_lt ? 2'h1 : 2'h0; // @[cpath.scala 141:64]
  wire [1:0] _ctrl_exe_pc_sel_T_15 = io_dat_exe_br_ltu ? 2'h1 : 2'h0; // @[cpath.scala 142:64]
  wire [1:0] _ctrl_exe_pc_sel_T_18 = io_dat_exe_br_type == 4'h8 ? 2'h2 : 2'h0; // @[cpath.scala 144:29]
  wire [1:0] _ctrl_exe_pc_sel_T_19 = io_dat_exe_br_type == 4'h7 ? 2'h1 : _ctrl_exe_pc_sel_T_18; // @[cpath.scala 143:29]
  wire [1:0] _ctrl_exe_pc_sel_T_20 = io_dat_exe_br_type == 4'h6 ? _ctrl_exe_pc_sel_T_15 : _ctrl_exe_pc_sel_T_19; // @[cpath.scala 142:29]
  wire [1:0] _ctrl_exe_pc_sel_T_21 = io_dat_exe_br_type == 4'h5 ? _ctrl_exe_pc_sel_T_13 : _ctrl_exe_pc_sel_T_20; // @[cpath.scala 141:29]
  wire [1:0] _ctrl_exe_pc_sel_T_22 = io_dat_exe_br_type == 4'h4 ? _ctrl_exe_pc_sel_T_11 : _ctrl_exe_pc_sel_T_21; // @[cpath.scala 140:29]
  wire [1:0] _ctrl_exe_pc_sel_T_23 = io_dat_exe_br_type == 4'h3 ? _ctrl_exe_pc_sel_T_8 : _ctrl_exe_pc_sel_T_22; // @[cpath.scala 139:29]
  wire [1:0] _ctrl_exe_pc_sel_T_24 = io_dat_exe_br_type == 4'h2 ? _ctrl_exe_pc_sel_T_5 : _ctrl_exe_pc_sel_T_23; // @[cpath.scala 138:29]
  wire [1:0] _ctrl_exe_pc_sel_T_25 = io_dat_exe_br_type == 4'h1 ? _ctrl_exe_pc_sel_T_3 : _ctrl_exe_pc_sel_T_24; // @[cpath.scala 137:29]
  wire [1:0] _ctrl_exe_pc_sel_T_26 = io_dat_exe_br_type == 4'h0 ? 2'h0 : _ctrl_exe_pc_sel_T_25; // @[cpath.scala 136:29]
  wire [1:0] ctrl_exe_pc_sel = io_ctl_pipeline_kill ? 2'h3 : _ctrl_exe_pc_sel_T_26; // @[cpath.scala 135:29]
  wire  _ifkill_T = ctrl_exe_pc_sel != 2'h0; // @[cpath.scala 148:35]
  reg  ifkill_REG; // @[cpath.scala 148:68]
  wire  dec_illegal = ~cs_val_inst & io_dat_dec_valid; // @[cpath.scala 155:36]
  wire [4:0] dec_rs1_addr = io_dat_dec_inst[19:15]; // @[cpath.scala 160:38]
  wire [4:0] dec_rs2_addr = io_dat_dec_inst[24:20]; // @[cpath.scala 161:38]
  wire [4:0] dec_wbaddr = io_dat_dec_inst[11:7]; // @[cpath.scala 162:38]
  wire  dec_rs1_oen = _ifkill_T ? 1'h0 : cs_rs1_oen; // @[cpath.scala 163:26]
  wire  dec_rs2_oen = _ifkill_T ? 1'h0 : cs_rs2_oen; // @[cpath.scala 164:26]
  reg [4:0] exe_reg_wbaddr; // @[cpath.scala 166:33]
  reg  exe_reg_illegal; // @[cpath.scala 172:37]
  reg  exe_reg_is_csr; // @[cpath.scala 174:32]
  reg  exe_inst_is_load; // @[cpath.scala 210:34]
  wire  _stall_T_2 = exe_reg_wbaddr != 5'h0; // @[cpath.scala 229:92]
  wire  _stall_T_9 = exe_inst_is_load & exe_reg_wbaddr == dec_rs2_addr & _stall_T_2 & dec_rs2_oen; // @[cpath.scala 230:101]
  wire  _stall_T_10 = exe_inst_is_load & exe_reg_wbaddr == dec_rs1_addr & exe_reg_wbaddr != 5'h0 & dec_rs1_oen | _stall_T_9; // @[cpath.scala 229:117]
  wire  stall = _stall_T_10 | exe_reg_is_csr; // @[cpath.scala 230:117]
  wire  full_stall = ~(io_dat_mem_ctrl_dmem_val & io_dmem_resp_valid | ~io_dat_mem_ctrl_dmem_val); // @[cpath.scala 250:18]
  wire  _T_1 = ~full_stall; // @[cpath.scala 178:20]
  wire  _T_2 = ~stall & ~full_stall; // @[cpath.scala 178:17]
  wire  _T_4 = stall & _T_1; // @[cpath.scala 195:21]
  reg  io_ctl_fencei_REG; // @[cpath.scala 267:45]
  reg  io_ctl_mem_exception_REG; // @[cpath.scala 270:35]
  reg  io_ctl_mem_exception_cause_REG; // @[cpath.scala 271:45]
  reg  io_ctl_mem_exception_cause_REG_1; // @[cpath.scala 272:45]
  wire [2:0] _io_ctl_mem_exception_cause_T = io_dat_mem_store ? 3'h6 : 3'h4; // @[cpath.scala 273:37]
  wire [2:0] _io_ctl_mem_exception_cause_T_1 = io_ctl_mem_exception_cause_REG_1 ? 3'h0 : _io_ctl_mem_exception_cause_T; // @[cpath.scala 272:37]
  wire [2:0] _io_ctl_mem_exception_cause_T_2 = io_ctl_mem_exception_cause_REG ? 3'h2 : _io_ctl_mem_exception_cause_T_1; // @[cpath.scala 271:37]
  wire  csr_ren = (cs0_6 == 3'h6 | cs0_6 == 3'h7) & dec_rs1_addr == 5'h0; // @[cpath.scala 279:65]
  assign io_ctl_dec_stall = _stall_T_10 | exe_reg_is_csr; // @[cpath.scala 230:117]
  assign io_ctl_full_stall = ~(io_dat_mem_ctrl_dmem_val & io_dmem_resp_valid | ~io_dat_mem_ctrl_dmem_val); // @[cpath.scala 250:18]
  assign io_ctl_exe_pc_sel = io_ctl_pipeline_kill ? 2'h3 : _ctrl_exe_pc_sel_T_26; // @[cpath.scala 135:29]
  assign io_ctl_br_type = _csignals_T_1 ? 4'h0 : _csignals_T_197; // @[Lookup.scala 34:39]
  assign io_ctl_if_kill = ctrl_exe_pc_sel != 2'h0 | cs0_7 | ifkill_REG; // @[cpath.scala 148:58]
  assign io_ctl_dec_kill = ctrl_exe_pc_sel != 2'h0; // @[cpath.scala 149:35]
  assign io_ctl_op1_sel = _csignals_T_1 ? 2'h0 : _csignals_T_246; // @[Lookup.scala 34:39]
  assign io_ctl_op2_sel = _csignals_T_1 ? 3'h1 : _csignals_T_295; // @[Lookup.scala 34:39]
  assign io_ctl_alu_fun = _csignals_T_1 ? 4'h0 : _csignals_T_442; // @[Lookup.scala 34:39]
  assign io_ctl_wb_sel = _csignals_T_1 ? 2'h1 : _csignals_T_491; // @[Lookup.scala 34:39]
  assign io_ctl_rf_wen = _csignals_T_1 | (_csignals_T_3 | (_csignals_T_5 | (_csignals_T_7 | (_csignals_T_9 |
    _csignals_T_536)))); // @[Lookup.scala 34:39]
  assign io_ctl_mem_val = _csignals_T_1 | (_csignals_T_3 | (_csignals_T_5 | (_csignals_T_7 | (_csignals_T_9 | (
    _csignals_T_11 | (_csignals_T_13 | _csignals_T_15)))))); // @[Lookup.scala 34:39]
  assign io_ctl_mem_fcn = {{1'd0}, cs0_4}; // @[cpath.scala 283:22]
  assign io_ctl_mem_typ = _csignals_T_1 ? 3'h3 : _csignals_T_687; // @[Lookup.scala 34:39]
  assign io_ctl_csr_cmd = csr_ren ? 3'h2 : cs0_6; // @[cpath.scala 280:25]
  assign io_ctl_fencei = cs0_7 | io_ctl_fencei_REG; // @[cpath.scala 267:35]
  assign io_ctl_pipeline_kill = io_dat_csr_eret | io_ctl_mem_exception | io_dat_csr_interrupt; // @[cpath.scala 153:69]
  assign io_ctl_mem_exception = io_ctl_mem_exception_REG | io_dat_mem_data_misaligned; // @[cpath.scala 270:105]
  assign io_ctl_mem_exception_cause = {{29'd0}, _io_ctl_mem_exception_cause_T_2}; // @[cpath.scala 271:31]
  always @(posedge clock) begin
    if (_csignals_T_1) begin // @[Lookup.scala 34:39]
      ifkill_REG <= 1'h0;
    end else if (_csignals_T_3) begin // @[Lookup.scala 34:39]
      ifkill_REG <= 1'h0;
    end else if (_csignals_T_5) begin // @[Lookup.scala 34:39]
      ifkill_REG <= 1'h0;
    end else if (_csignals_T_7) begin // @[Lookup.scala 34:39]
      ifkill_REG <= 1'h0;
    end else begin
      ifkill_REG <= _csignals_T_782;
    end
    if (_T_2) begin // @[cpath.scala 179:4]
      if (_ifkill_T) begin // @[cpath.scala 181:7]
        exe_reg_wbaddr <= 5'h0; // @[cpath.scala 182:30]
      end else begin
        exe_reg_wbaddr <= dec_wbaddr; // @[cpath.scala 189:30]
      end
    end else if (_T_4) begin // @[cpath.scala 196:4]
      exe_reg_wbaddr <= 5'h0; // @[cpath.scala 198:27]
    end
    if (reset) begin // @[cpath.scala 172:37]
      exe_reg_illegal <= 1'h0; // @[cpath.scala 172:37]
    end else if (io_dat_csr_eret) begin // @[cpath.scala 219:4]
      exe_reg_illegal <= 1'h0; // @[cpath.scala 220:26]
    end else if (_T_2) begin // @[cpath.scala 179:4]
      if (_ifkill_T) begin // @[cpath.scala 181:7]
        exe_reg_illegal <= 1'h0; // @[cpath.scala 185:30]
      end else begin
        exe_reg_illegal <= dec_illegal; // @[cpath.scala 192:30]
      end
    end else if (_T_4) begin // @[cpath.scala 196:4]
      exe_reg_illegal <= 1'h0; // @[cpath.scala 201:27]
    end
    if (reset) begin // @[cpath.scala 174:32]
      exe_reg_is_csr <= 1'h0; // @[cpath.scala 174:32]
    end else if (_T_2) begin // @[cpath.scala 179:4]
      if (_ifkill_T) begin // @[cpath.scala 181:7]
        exe_reg_is_csr <= 1'h0; // @[cpath.scala 184:30]
      end else begin
        exe_reg_is_csr <= cs0_6 != 3'h0 & cs0_6 != 3'h4; // @[cpath.scala 191:30]
      end
    end else if (_T_4) begin // @[cpath.scala 196:4]
      exe_reg_is_csr <= 1'h0; // @[cpath.scala 200:27]
    end
    if (reset) begin // @[cpath.scala 210:34]
      exe_inst_is_load <= 1'h0; // @[cpath.scala 210:34]
    end else if (_T_1) begin // @[cpath.scala 213:4]
      exe_inst_is_load <= cs0_3 & ~cs0_4; // @[cpath.scala 214:24]
    end
    if (_csignals_T_1) begin // @[Lookup.scala 34:39]
      io_ctl_fencei_REG <= 1'h0;
    end else if (_csignals_T_3) begin // @[Lookup.scala 34:39]
      io_ctl_fencei_REG <= 1'h0;
    end else if (_csignals_T_5) begin // @[Lookup.scala 34:39]
      io_ctl_fencei_REG <= 1'h0;
    end else if (_csignals_T_7) begin // @[Lookup.scala 34:39]
      io_ctl_fencei_REG <= 1'h0;
    end else begin
      io_ctl_fencei_REG <= _csignals_T_782;
    end
    io_ctl_mem_exception_REG <= (exe_reg_illegal | io_dat_exe_inst_misaligned) & ~io_dat_csr_eret; // @[cpath.scala 270:84]
    io_ctl_mem_exception_cause_REG <= exe_reg_illegal; // @[cpath.scala 271:45]
    io_ctl_mem_exception_cause_REG_1 <= io_dat_exe_inst_misaligned; // @[cpath.scala 272:45]
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
  ifkill_REG = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  exe_reg_wbaddr = _RAND_1[4:0];
  _RAND_2 = {1{`RANDOM}};
  exe_reg_illegal = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  exe_reg_is_csr = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  exe_inst_is_load = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  io_ctl_fencei_REG = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  io_ctl_mem_exception_REG = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  io_ctl_mem_exception_cause_REG = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  io_ctl_mem_exception_cause_REG_1 = _RAND_8[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule