module RVFI_5stage (
	clock,
	retire,
	instruction,
	old_regfile,
	register_wdata,
	old_pc,
	new_pc,
	mem_req,
	mem_addr,
	mem_rdata,
	mem_wdata,
	mem_we,
	mem_be,
	exception,
	rvfi_valid,
	rvfi_order,
	rvfi_insn,
	rvfi_trap,
	rvfi_halt,
	rvfi_intr,
	rvfi_mode,
	rvfi_ixl,
	rvfi_rs1_addr,
	rvfi_rs2_addr,
	rvfi_rs3_addr,
	rvfi_rs1_rdata,
	rvfi_rs2_rdata,
	rvfi_rs3_rdata,
	rvfi_rd_addr,
	rvfi_rd_wdata,
	rvfi_pc_rdata,
	rvfi_pc_wdata,
	rvfi_mem_addr,
	rvfi_mem_rmask,
	rvfi_mem_wmask,
	rvfi_mem_rdata,
	rvfi_mem_wdata
);
	// Trace: core/RVFI_2stage.v:2:2
	input clock;
	// Trace: core/RVFI_2stage.v:3:2
	input retire;
	// Trace: core/RVFI_2stage.v:4:2
	input [31:0] instruction;
	// Trace: core/RVFI_2stage.v:5:2
	input [1023:0] old_regfile;
	// Trace: core/RVFI_2stage.v:6:2
	input [31:0] register_wdata;
	// Trace: core/RVFI_2stage.v:7:2
	input [31:0] old_pc;
	// Trace: core/RVFI_2stage.v:8:2
	input [31:0] new_pc;
	// Trace: core/RVFI_2stage.v:9:2
	input mem_req;
	// Trace: core/RVFI_2stage.v:10:2
	input [31:0] mem_addr;
	// Trace: core/RVFI_2stage.v:11:2
	input [31:0] mem_rdata;
	// Trace: core/RVFI_2stage.v:12:2
	input [31:0] mem_wdata;
	// Trace: core/RVFI_2stage.v:13:2
	input mem_we;
	// Trace: core/RVFI_2stage.v:14:2
	input [2:0] mem_be;
	// Trace: core/RVFI_2stage.v:15:2
	input exception;
	// Trace: core/RVFI_2stage.v:17:2
	output reg rvfi_valid;
	// Trace: core/RVFI_2stage.v:18:5
	output reg [63:0] rvfi_order;
	// Trace: core/RVFI_2stage.v:19:5
	output reg [31:0] rvfi_insn;
	// Trace: core/RVFI_2stage.v:20:5
	output reg rvfi_trap;
	// Trace: core/RVFI_2stage.v:21:5
	output reg rvfi_halt;
	// Trace: core/RVFI_2stage.v:22:5
	output reg rvfi_intr;
	// Trace: core/RVFI_2stage.v:23:5
	output reg [1:0] rvfi_mode;
	// Trace: core/RVFI_2stage.v:24:5
	output reg [1:0] rvfi_ixl;
	// Trace: core/RVFI_2stage.v:25:5
	output reg [4:0] rvfi_rs1_addr;
	// Trace: core/RVFI_2stage.v:26:5
	output reg [4:0] rvfi_rs2_addr;
	// Trace: core/RVFI_2stage.v:27:5
	output reg [4:0] rvfi_rs3_addr;
	// Trace: core/RVFI_2stage.v:28:5
	output reg [31:0] rvfi_rs1_rdata;
	// Trace: core/RVFI_2stage.v:29:5
	output reg [31:0] rvfi_rs2_rdata;
	// Trace: core/RVFI_2stage.v:30:5
	output reg [31:0] rvfi_rs3_rdata;
	// Trace: core/RVFI_2stage.v:31:5
	output reg [4:0] rvfi_rd_addr;
	// Trace: core/RVFI_2stage.v:32:5
	output reg [31:0] rvfi_rd_wdata;
	// Trace: core/RVFI_2stage.v:33:5
	output reg [31:0] rvfi_pc_rdata;
	// Trace: core/RVFI_2stage.v:34:5
	output reg [31:0] rvfi_pc_wdata;
	// Trace: core/RVFI_2stage.v:35:5
	output reg [31:0] rvfi_mem_addr;
	// Trace: core/RVFI_2stage.v:36:5
	output reg [3:0] rvfi_mem_rmask;
	// Trace: core/RVFI_2stage.v:37:5
	output reg [3:0] rvfi_mem_wmask;
	// Trace: core/RVFI_2stage.v:38:5
	output reg [31:0] rvfi_mem_rdata;
	// Trace: core/RVFI_2stage.v:39:5
	output reg [31:0] rvfi_mem_wdata;
	// Trace: core/RVFI_2stage.v:42:2
	wire [6:0] op;
	// Trace: core/RVFI_2stage.v:43:5
	wire [2:0] funct_3;
	// Trace: core/RVFI_2stage.v:44:5
	wire [6:0] funct_7;
	// Trace: core/RVFI_2stage.v:45:5
	wire [2:0] format;
	// Trace: core/RVFI_2stage.v:46:5
	wire [31:0] imm;
	// Trace: core/RVFI_2stage.v:47:5
	wire [4:0] rs1;
	// Trace: core/RVFI_2stage.v:48:5
	wire [4:0] rs2;
	// Trace: core/RVFI_2stage.v:49:5
	wire [4:0] rd;
	// Trace: core/RVFI_2stage.v:51:2
	RISCV_Decoder RISCV_Decoder(
		.instr_i(instruction),
		.format_o(format),
		.op_o(op),
		.funct_3_o(funct_3),
		.funct_7_o(funct_7),
		.rd_o(rd),
		.rs1_o(rs1),
		.rs2_o(rs2),
		.imm_o(imm)
	);
	// Trace: core/RVFI_2stage.v:63:2
	initial begin
		// Trace: core/RVFI_2stage.v:64:3
		rvfi_valid <= 0;
		// Trace: core/RVFI_2stage.v:65:3
		rvfi_order <= 0;
		// Trace: core/RVFI_2stage.v:66:3
		rvfi_insn <= 32'b00000000000000000000000000000000;
		// Trace: core/RVFI_2stage.v:67:3
		rvfi_trap <= 0;
		// Trace: core/RVFI_2stage.v:68:3
		rvfi_halt <= 0;
		// Trace: core/RVFI_2stage.v:69:3
		rvfi_intr <= 0;
		// Trace: core/RVFI_2stage.v:70:3
		rvfi_mode <= 2'b00;
		// Trace: core/RVFI_2stage.v:71:3
		rvfi_ixl <= 2'b00;
		// Trace: core/RVFI_2stage.v:72:3
		rvfi_rs1_addr <= 5'b00000;
		// Trace: core/RVFI_2stage.v:73:3
		rvfi_rs2_addr <= 5'b00000;
		// Trace: core/RVFI_2stage.v:74:3
		rvfi_rs3_addr <= 5'b00000;
		// Trace: core/RVFI_2stage.v:75:3
		rvfi_rs1_rdata <= 32'b00000000000000000000000000000000;
		// Trace: core/RVFI_2stage.v:76:3
		rvfi_rs2_rdata <= 32'b00000000000000000000000000000000;
		// Trace: core/RVFI_2stage.v:77:3
		rvfi_rs3_rdata <= 32'b00000000000000000000000000000000;
		// Trace: core/RVFI_2stage.v:78:3
		rvfi_rd_addr <= 5'b00000;
		// Trace: core/RVFI_2stage.v:79:3
		rvfi_rd_wdata <= 32'b00000000000000000000000000000000;
		// Trace: core/RVFI_2stage.v:80:3
		rvfi_pc_rdata <= 32'b00000000000000000000000000000000;
		// Trace: core/RVFI_2stage.v:81:3
		rvfi_pc_wdata <= 32'b00000000000000000000000000000000;
		// Trace: core/RVFI_2stage.v:82:3
		rvfi_mem_addr <= 32'b00000000000000000000000000000000;
		// Trace: core/RVFI_2stage.v:83:3
		rvfi_mem_rdata <= 32'b00000000000000000000000000000000;
		// Trace: core/RVFI_2stage.v:84:3
		rvfi_mem_rmask <= 4'b0000;
		// Trace: core/RVFI_2stage.v:85:3
		rvfi_mem_wdata <= 32'b00000000000000000000000000000000;
		// Trace: core/RVFI_2stage.v:86:3
		rvfi_mem_wmask <= 4'b0000;
	end
	// Trace: core/RVFI_2stage.v:90:2
	always @(posedge clock)
		// Trace: core/RVFI_2stage.v:91:3
		if (retire == 1'b1) begin
			// Trace: core/RVFI_2stage.v:92:4
			rvfi_valid <= 1;
			// Trace: core/RVFI_2stage.v:93:4
			rvfi_order <= rvfi_order + 1;
			// Trace: core/RVFI_2stage.v:94:4
			rvfi_insn <= instruction;
			// Trace: core/RVFI_2stage.v:95:4
			rvfi_trap <= exception;
			// Trace: core/RVFI_2stage.v:96:4
			rvfi_halt <= 0;
			// Trace: core/RVFI_2stage.v:97:4
			rvfi_intr <= 0;
			// Trace: core/RVFI_2stage.v:98:4
			rvfi_mode <= 2'b00;
			// Trace: core/RVFI_2stage.v:99:4
			rvfi_ixl <= 2'b00;
			// Trace: core/RVFI_2stage.v:100:4
			rvfi_rs1_addr <= rs1;
			// Trace: core/RVFI_2stage.v:101:4
			rvfi_rs2_addr <= rs2;
			// Trace: core/RVFI_2stage.v:102:4
			rvfi_rs3_addr <= 5'b00000;
			// Trace: core/RVFI_2stage.v:103:4
			rvfi_rs1_rdata <= (rs1 == 0 ? 32'b00000000000000000000000000000000 : old_regfile[(31 - rs1) * 32+:32]);
			// Trace: core/RVFI_2stage.v:104:4
			rvfi_rs2_rdata <= (rs2 == 0 ? 32'b00000000000000000000000000000000 : old_regfile[(31 - rs2) * 32+:32]);
			// Trace: core/RVFI_2stage.v:105:4
			rvfi_rs3_rdata <= 32'b00000000000000000000000000000000;
			// Trace: core/RVFI_2stage.v:106:4
			rvfi_rd_addr <= rd;
			// Trace: core/RVFI_2stage.v:107:4
			rvfi_rd_wdata <= (rd == 0 ? 32'b00000000000000000000000000000000 : register_wdata);
			// Trace: core/RVFI_2stage.v:108:4
			rvfi_pc_rdata <= old_pc;
			// Trace: core/RVFI_2stage.v:109:4
			rvfi_pc_wdata <= new_pc;
			// Trace: core/RVFI_2stage.v:110:4
			rvfi_mem_addr <= (mem_req == 0 ? 32'b00000000000000000000000000000000 : mem_addr);
			// Trace: core/RVFI_2stage.v:111:4
			rvfi_mem_rdata <= (mem_req == 0 ? 32'b00000000000000000000000000000000 : (mem_we == 1 ? 32'b00000000000000000000000000000000 : (mem_be == 0 ? 32'b00000000000000000000000000000000 : ((mem_be == 3'b001) || (mem_be == 3'b101) ? mem_rdata & 32'h000000ff : ((mem_be == 3'b010) || (mem_be == 3'b110) ? mem_rdata & 32'h0000ffff : mem_rdata)))));
			// Trace: core/RVFI_2stage.v:132:4
			rvfi_mem_rmask <= (mem_req == 0 ? 4'b0000 : (mem_we == 1 ? 4'b0000 : (mem_be == 0 ? 4'b0000 : ((mem_be == 3'b001) || (mem_be == 3'b101) ? 4'b0001 : ((mem_be == 3'b010) || (mem_be == 3'b110) ? 4'b0011 : 4'b1111)))));
			// Trace: core/RVFI_2stage.v:153:4
			rvfi_mem_wdata <= (mem_req == 0 ? 32'b00000000000000000000000000000000 : (mem_we == 0 ? 32'b00000000000000000000000000000000 : (mem_be == 0 ? 32'b00000000000000000000000000000000 : (mem_be == 3'b000 ? mem_wdata & 32'h000000ff : (mem_be == 3'b010 ? mem_wdata & 32'h0000ffff : mem_wdata)))));
			// Trace: core/RVFI_2stage.v:174:4
			rvfi_mem_wmask <= (mem_req == 0 ? 4'b0000 : (mem_we == 0 ? 4'b0000 : (mem_be == 0 ? 4'b0000 : (mem_be == 3'b001 ? 4'b0001 : (mem_be == 3'b010 ? 4'b0011 : 4'b1111)))));
		end
		else begin
			// Trace: core/RVFI_2stage.v:196:3
			rvfi_valid <= 0;
			// Trace: core/RVFI_2stage.v:197:3
			rvfi_order <= rvfi_order;
			// Trace: core/RVFI_2stage.v:198:3
			rvfi_insn <= 32'b00000000000000000000000000000000;
			// Trace: core/RVFI_2stage.v:199:3
			rvfi_trap <= 0;
			// Trace: core/RVFI_2stage.v:200:3
			rvfi_halt <= 0;
			// Trace: core/RVFI_2stage.v:201:3
			rvfi_intr <= 0;
			// Trace: core/RVFI_2stage.v:202:3
			rvfi_mode <= 2'b00;
			// Trace: core/RVFI_2stage.v:203:3
			rvfi_ixl <= 2'b00;
			// Trace: core/RVFI_2stage.v:204:3
			rvfi_rs1_addr <= 5'b00000;
			// Trace: core/RVFI_2stage.v:205:3
			rvfi_rs2_addr <= 5'b00000;
			// Trace: core/RVFI_2stage.v:206:3
			rvfi_rs3_addr <= 5'b00000;
			// Trace: core/RVFI_2stage.v:207:3
			rvfi_rs1_rdata <= 32'b00000000000000000000000000000000;
			// Trace: core/RVFI_2stage.v:208:3
			rvfi_rs2_rdata <= 32'b00000000000000000000000000000000;
			// Trace: core/RVFI_2stage.v:209:3
			rvfi_rs3_rdata <= 32'b00000000000000000000000000000000;
			// Trace: core/RVFI_2stage.v:210:3
			rvfi_rd_addr <= 5'b00000;
			// Trace: core/RVFI_2stage.v:211:3
			rvfi_rd_wdata <= 32'b00000000000000000000000000000000;
			// Trace: core/RVFI_2stage.v:212:3
			rvfi_pc_rdata <= 32'b00000000000000000000000000000000;
			// Trace: core/RVFI_2stage.v:213:3
			rvfi_pc_wdata <= 32'b00000000000000000000000000000000;
			// Trace: core/RVFI_2stage.v:214:3
			rvfi_mem_addr <= 32'b00000000000000000000000000000000;
			// Trace: core/RVFI_2stage.v:215:3
			rvfi_mem_rdata <= 32'b00000000000000000000000000000000;
			// Trace: core/RVFI_2stage.v:216:3
			rvfi_mem_rmask <= 4'b0000;
			// Trace: core/RVFI_2stage.v:217:3
			rvfi_mem_wdata <= 32'b00000000000000000000000000000000;
			// Trace: core/RVFI_2stage.v:218:3
			rvfi_mem_wmask <= 4'b0000;
		end
endmodule
