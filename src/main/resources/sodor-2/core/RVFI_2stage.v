module RVFI_2stage(
	input		clock,
	input		retire,
	input [31:0] instruction,
	input [31:0] old_regfile [0:31],
	input [31:0] new_regfile [0:31],
	input [31:0] old_pc,
	input [31:0] new_pc,
	input        mem_req,
	input [31:0] mem_addr,
	input [31:0] mem_rdata,
	input [31:0] mem_wdata,
	input        mem_we,
	input [2:0]  mem_be,
	input        exception,
	
	output reg        rvfi_valid,
    output reg [63:0] rvfi_order,
    output reg [31:0] rvfi_insn,
    output reg        rvfi_trap,
    output reg        rvfi_halt,
    output reg        rvfi_intr,
    output reg [ 1:0] rvfi_mode,
    output reg [ 1:0] rvfi_ixl,
    output reg [ 4:0] rvfi_rs1_addr,
    output reg [ 4:0] rvfi_rs2_addr,
    output reg [ 4:0] rvfi_rs3_addr,
    output reg [31:0] rvfi_rs1_rdata,
    output reg [31:0] rvfi_rs2_rdata,
    output reg [31:0] rvfi_rs3_rdata,
    output reg [ 4:0] rvfi_rd_addr,
    output reg [31:0] rvfi_rd_wdata,
    output reg [31:0] rvfi_pc_rdata,
    output reg [31:0] rvfi_pc_wdata,
    output reg [31:0] rvfi_mem_addr,
    output reg [ 3:0] rvfi_mem_rmask,
    output reg [ 3:0] rvfi_mem_wmask,
    output reg [31:0] rvfi_mem_rdata,
    output reg [31:0] rvfi_mem_wdata,
);

	wire [6:0] op;
    wire [2:0] funct_3;
    wire [6:0] funct_7;
    wire [2:0] format;
    wire [31:0] imm;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

	RISCV_Decoder RISCV_Decoder(
		.instr_i(instruction),
		.format_o(format),
		.op_o(op),
		.funct_3_o(funct_3),
		.funct_7_o(funct_7),
		.rd_o(rd),
		.rs1_o(rs1),
		.rs2_o(rs2),
		.imm_o(imm),
	);
	
	initial begin
		rvfi_valid <= 0;
		rvfi_order <= 0;
		rvfi_insn <= 32'b0;
		rvfi_trap <= 0;
		rvfi_halt <= 0;
		rvfi_intr <= 0;
		rvfi_mode <= 2'b0;
		rvfi_ixl <= 2'b0;
		rvfi_rs1_addr <= 5'b0;
		rvfi_rs2_addr <= 5'b0;
		rvfi_rs3_addr <= 5'b0;
		rvfi_rs1_rdata <= 32'b0;
		rvfi_rs2_rdata <= 32'b0;
		rvfi_rs3_rdata <= 32'b0;
		rvfi_rd_addr <= 5'b0;
		rvfi_rd_wdata <= 32'b0 ;
		rvfi_pc_rdata <= 32'b0;
		rvfi_pc_wdata <= 32'b0;
		rvfi_mem_addr <= 32'b0;
		rvfi_mem_rdata <= 32'b0;
		rvfi_mem_rmask <= 4'b0;
		rvfi_mem_wdata <= 32'b0;
		rvfi_mem_wmask <= 4'b0;
	end
    

	always @(posedge clock) begin
		if (retire == 1'b1) begin
			rvfi_valid <= 1;
			rvfi_order <= rvfi_order + 1;
			rvfi_insn <= instruction;
			rvfi_trap <= exception;
			rvfi_halt <= 0;
			rvfi_intr <= 0;
			rvfi_mode <= 2'b0;
			rvfi_ixl <= 2'b0;
			rvfi_rs1_addr <= rs1;
			rvfi_rs2_addr <= rs2;
			rvfi_rs3_addr <= 5'b0;
			rvfi_rs1_rdata <= rs1 == 0 ? 32'b0 : old_regfile[rs1];
			rvfi_rs2_rdata <= rs2 == 0 ? 32'b0 : old_regfile[rs2];
			rvfi_rs3_rdata <= 32'b0;
			rvfi_rd_addr <= rd;
			rvfi_rd_wdata <= rd == 0 ? 32'b0 : new_regfile[rd];
			rvfi_pc_rdata <= old_pc;
			rvfi_pc_wdata <= new_pc;
			rvfi_mem_addr <= mem_req == 0 ? 32'b0 : mem_addr;
			rvfi_mem_rdata <= mem_req == 0 ? 
								32'b0
							:
								(mem_we == 1 ? 
									32'b0 
								:
									(mem_be == 0 ?
										32'b0
									:
										((mem_be == 3'b001 || mem_be == 3'b101) ?
											(mem_rdata & 32'h000000FF)
										:
											((mem_be == 3'b010 || mem_be == 3'b110) ? 
												(mem_rdata & 32'h0000FFFF)
											:
												mem_rdata
											)
										)
									)
								)
							;
			rvfi_mem_rmask <= mem_req == 0 ?
								4'b0
							:
								(mem_we == 1 ?
									4'b0
								:
									(mem_be == 0 ?
										4'b0
									:
										((mem_be == 3'b001 || mem_be == 3'b101) ?
											4'b0001
										:
											((mem_be == 3'b010 || mem_be == 3'b110) ? 
												4'b0011
											:
												4'b1111
											)
										)
									)
								)
							;
			rvfi_mem_wdata <= mem_req == 0 ? 
								32'b0
							:
								(mem_we == 0 ? 
									32'b0 
								:
									(mem_be == 0 ?
										32'b0
									:
										(mem_be == 3'b00 ?
											(mem_wdata & 32'h000000FF)
										:
											(mem_be == 3'b010 ? 
												(mem_wdata & 32'h0000FFFF)
											:
												mem_wdata
											)
										)
									)
								)
							;
			rvfi_mem_wmask <= mem_req == 0 ?
								4'b0
							:
								(mem_we == 0 ?
									4'b0
								:
									(mem_be == 0 ?
										4'b0
									:
										(mem_be == 3'b001 ?
											4'b0001
										:
											(mem_be == 3'b010 ? 
												4'b0011
											:
												4'b1111
											)
										)
									)
								)
							;
		end else begin
		rvfi_valid <= 0;
		rvfi_order <= rvfi_order;
		rvfi_insn <= 32'b0;
		rvfi_trap <= 0;
		rvfi_halt <= 0;
		rvfi_intr <= 0;
		rvfi_mode <= 2'b0;
		rvfi_ixl <= 2'b0;
		rvfi_rs1_addr <= 5'b0;
		rvfi_rs2_addr <= 5'b0;
		rvfi_rs3_addr <= 5'b0;
		rvfi_rs1_rdata <= 32'b0;
		rvfi_rs2_rdata <= 32'b0;
		rvfi_rs3_rdata <= 32'b0;
		rvfi_rd_addr <= 5'b0;
		rvfi_rd_wdata <= 32'b0 ;
		rvfi_pc_rdata <= 32'b0;
		rvfi_pc_wdata <= 32'b0;
		rvfi_mem_addr <= 32'b0;
		rvfi_mem_rdata <= 32'b0;
		rvfi_mem_rmask <= 4'b0;
		rvfi_mem_wdata <= 32'b0;
		rvfi_mem_wmask <= 4'b0;		
		end
	end

	

endmodule