`ifdef RISCV_FORMAL
    `define RVFI
`endif

module top (

);
    (* gclk *) reg clk;

    logic clock;
    initial clock = 0;
    always @(posedge clk) begin
        clock <= !clock;
    end

    logic clock_1;
    logic clock_2;

    logic reset_1;
    logic reset_2;
	initial begin
        #10;
		reset_1 <= 1;
		reset_2 <= 1;
        #40;
		reset_1 <= 0;
		reset_2 <= 0;

	end
	//always @(posedge clock) begin
	//	reset_1 <= 0;
	//	reset_2 <= 0;
    //end

    
	integer counter;
	initial counter <= 0;
	always @(posedge clock) begin
		counter <= counter +1;
	end


    logic instr_req_1;
    logic instr_req_2;
    logic [31:0] instr_addr_1;
    logic [31:0] instr_addr_2;
    logic instr_gnt_1;
    logic instr_gnt_2;
    logic [31:0] instr_1;
    logic [31:0] instr_2;


    logic data_req_1;
    logic data_req_2;
    logic data_we_1;
    logic data_we_2;
    logic [3:0] data_be_1;
    logic [3:0] data_be_2;
    logic [31:0] data_addr_1;
    logic [31:0] data_addr_2;
    logic data_gnt_1;
    logic data_gnt_2;
    logic data_rvalid_1;
    logic data_rvalid_2;
    logic [31:0] data_rdata_1;
    logic [31:0] data_rdata_2;
    logic [31:0] data_wdata_1;
    logic [31:0] data_wdata_2;
    logic data_err_1;
    logic data_err_2;

    logic        irq_x_ack_1;
    logic        irq_x_ack_2;
    logic [4:0]  irq_x_ack_id_1;
    logic [4:0]  irq_x_ack_id_2;

    logic alert_major_1;
    logic alert_major_2;
    logic alert_minor_1;
    logic alert_minor_2;
    logic core_sleep_1;
    logic core_sleep_2;


    logic retire_1;
    logic retire_2;
    logic [31:0] retire_instr_1;
    logic [31:0] retire_instr_2;
    logic fetch_1;
    logic fetch_2;
    logic [31:0] mem_r_data_1;
    logic [31:0] mem_w_data_1;
    logic [31:0] mem_r_data_2;
    logic [31:0] mem_w_data_2;

    logic retire;
    logic atk_equiv;
    logic ctr_equiv;

    logic enable_1;
    logic enable_2;
    logic finished;

    `ifdef RVFI
        logic valid_1;
        logic valid_2;
        logic [31:0] insn_1;
        logic [31:0] insn_2;
        logic [4:0] rd_1;
        logic [4:0] rd_2;
        logic [4:0] rs1_1;
        logic [4:0] rs1_2;
        logic [4:0] rs2_1;
        logic [4:0] rs2_2;
        logic [31:0] rs1_rdata_1;
        logic [31:0] rs1_rdata_2;
        logic [31:0] rs2_rdata_1;
        logic [31:0] rs2_rdata_2;
        logic [31:0] rd_wdata_1;
        logic [31:0] rd_wdata_2;
        logic [31:0] mem_addr_1;
        logic [31:0] mem_addr_2;
        logic [31:0] mem_rdata_1;
        logic [31:0] mem_rdata_2;
        logic [31:0] mem_wdata_1;
        logic [31:0] mem_wdata_2;
        logic [3:0] mem_rmask_1;
        logic [3:0] mem_rmask_2;
        logic [3:0] mem_wmask_1;
        logic [3:0] mem_wmask_2;
        logic [31:0] mem_addr_real_1;
        logic [31:0] mem_addr_real_2;
        logic [31:0] new_pc_1;
        logic [31:0] new_pc_2;
        logic rvfi_trap_1;
        logic rvfi_trap_2;
    `endif


    instr_mem #(
        .ID                     (1),
    ) instr_mem_1 (
        .clk_i                  (clock_1),
        .enable_i               (enable_1),
        .instr_req_i            (instr_req_1),
        .instr_addr_i           (instr_addr_1),
        .instr_gnt_o            (instr_gnt_1),
        .instr_o                (instr_1),
    );

    instr_mem #(
        .ID                     (2),
    ) instr_mem_2 (
        .clk_i                  (clock_2),
        .enable_i               (enable_2),
        .instr_req_i            (instr_req_2),
        .instr_addr_i           (instr_addr_2),
        .instr_gnt_o            (instr_gnt_2),
        .instr_o                (instr_2),
    );

    data_mem data_mem_1 (
        .clk_i                  (clock_1),
        .data_req_i             (data_req_1),
        .data_we_i              (data_we_1),
        .data_be_i              (data_be_1),
        .data_addr_i            (data_addr_1),
        .data_wdata_i           (data_wdata_1),
        .data_gnt_o             (data_gnt_1),
        .data_rvalid_o          (data_rvalid_1),
        .data_rdata_o           (data_rdata_1),
        .data_err_o             (data_err_1),
    );

    data_mem data_mem_2 (
        .clk_i                  (clock_2),
        .data_req_i             (data_req_2),
        .data_we_i              (data_we_2),
        .data_be_i              (data_be_2),
        .data_addr_i            (data_addr_2),
        .data_wdata_i           (data_wdata_2),
        .data_gnt_o             (data_gnt_2),
        .data_rvalid_o          (data_rvalid_2),
        .data_rdata_o           (data_rdata_2),
        .data_err_o             (data_err_2),
    );

    wire data_re_1;
    wire flush_1;
    darkriscv_2stages core_1 (
        .CLK(clock_1),
        .RES(reset_1),
        .HLT(1'b0),
        .IDATA(instr_1),
        .IADDR(instr_addr_1),
        .DATAI(data_rdata_1),
        .DATAO(data_wdata_1),
        .DADDR(data_addr_1),
        .BE(data_be_1),
        .WR(data_we_1),
        .RD(data_re_1),
        .IDLE(),
        .DEBUG(),
        .FLUSH(flush_1),
        .rvfi_valid(retire_1),
        .rvfi_order(),
        .rvfi_insn(retire_instr_1),
        .rvfi_trap(retire_trap_1),
        .rvfi_halt(),
        .rvfi_intr(),
        .rvfi_mode(),
        .rvfi_ixl(),
        .rvfi_rs1_addr(rs1_1),
        .rvfi_rs2_addr(rs2_1),
        .rvfi_rs3_addr(),
        .rvfi_rs1_rdata(rs1_rdata_1),
        .rvfi_rs2_rdata(rs2_rdata_1),
        .rvfi_rs3_rdata(),
        .rvfi_rd_addr(rd_1),
        .rvfi_rd_wdata(rd_wdata_1),
        .rvfi_pc_rdata(),
        .rvfi_pc_wdata(new_pc_1),
        .rvfi_mem_addr(mem_addr_1),
        .rvfi_mem_rmask(mem_rmask_1),
        .rvfi_mem_wmask(mem_wmask_1),
        .rvfi_mem_rdata(mem_rdata_1),
        .rvfi_mem_wdata(mem_wdata_1),
    );
    assign instr_req_1 = 1'b1;
    assign data_req_1 = data_re_1 || data_we_1;
    reg flushed_1;
    always @(posedge clock_1) begin
        flushed_1 <= flush_1;
    end
    assign fetch_1 = !flush_1;

    wire data_re_2;
    wire flush_2;
    darkriscv_2stages core_2 (
        .CLK(clock_2),
        .RES(reset_2),
        .HLT(1'b0),
        .IDATA(instr_2),
        .IADDR(instr_addr_2),
        .DATAI(data_rdata_2),
        .DATAO(data_wdata_2),
        .DADDR(data_addr_2),
        .BE(data_be_2),
        .WR(data_we_2),
        .RD(data_re_2),
        .IDLE(),
        .DEBUG(),
        .FLUSH(flush_2),
        .rvfi_valid(retire_2),
        .rvfi_order(),
        .rvfi_insn(retire_instr_2),
        .rvfi_trap(retire_trap_2),
        .rvfi_halt(),
        .rvfi_intr(),
        .rvfi_mode(),
        .rvfi_ixl(),
        .rvfi_rs1_addr(rs1_2),
        .rvfi_rs2_addr(rs2_2),
        .rvfi_rs3_addr(),
        .rvfi_rs1_rdata(rs1_rdata_2),
        .rvfi_rs2_rdata(rs2_rdata_2),
        .rvfi_rs3_rdata(),
        .rvfi_rd_addr(rd_2),
        .rvfi_rd_wdata(rd_wdata_2),
        .rvfi_pc_rdata(),
        .rvfi_pc_wdata(new_pc_2),
        .rvfi_mem_addr(mem_addr_2),
        .rvfi_mem_rmask(mem_rmask_2),
        .rvfi_mem_wmask(mem_wmask_2),
        .rvfi_mem_rdata(mem_rdata_2),
        .rvfi_mem_wdata(mem_wdata_2),
    );
    assign instr_req_2 = 1'b1;
    assign data_req_2 = data_re_2 || data_we_2;
    reg flushed_2;
    always @(posedge clock_2) begin
        flushed_2 <= flush_2;
    end
    assign fetch_2 = !flush_2;

    atk atk (
        .clk_i(clock),
        .atk_observation_1_i    (clock_1),
        .atk_observation_2_i    (clock_2),
        .atk_equiv_o            (atk_equiv),
    );

    assign mem_r_data_1 = {
            mem_rmask_1[3] ? mem_rdata_1[31:24] : 8'b0,
            mem_rmask_1[2] ? mem_rdata_1[23:16] : 8'b0,
            mem_rmask_1[1] ? mem_rdata_1[15:8] : 8'b0,
            mem_rmask_1[0] ? mem_rdata_1[7:0] : 8'b0
        };
    assign mem_w_data_1 = {
            mem_wmask_1[3] ? mem_wdata_1[31:24] : 8'b0,
            mem_wmask_1[2] ? mem_wdata_1[23:16] : 8'b0,
            mem_wmask_1[1] ? mem_wdata_1[15:8] : 8'b0,
            mem_wmask_1[0] ? mem_wdata_1[7:0] : 8'b0
        };

    assign mem_r_data_2 = {
            mem_rmask_2[3] ? mem_rdata_2[31:24] : 8'b0,
            mem_rmask_2[2] ? mem_rdata_2[23:16] : 8'b0,
            mem_rmask_2[1] ? mem_rdata_2[15:8] : 8'b0,
            mem_rmask_2[0] ? mem_rdata_2[7:0] : 8'b0
        };
    assign mem_w_data_2 = {
            mem_wmask_2[3] ? mem_wdata_2[31:24] : 8'b0,
            mem_wmask_2[2] ? mem_wdata_2[23:16] : 8'b0,
            mem_wmask_2[1] ? mem_wdata_2[15:8] : 8'b0,
            mem_wmask_2[0] ? mem_wdata_2[7:0] : 8'b0
        };

    assign mem_addr_real_1 = (mem_rmask_1 == 0 && mem_wmask_1 == 0) ? 0 : mem_addr_1;
    assign mem_addr_real_2 = (mem_rmask_2 == 0 && mem_wmask_2 == 0) ? 0 : mem_addr_2;
    ctr ctr (
        .clk_i                  (clock),
        .retire_i               (retire),
        .instr_1_i              (retire_instr_1),
        .instr_2_i              (retire_instr_2),
        .rd_1                   (rd_1),
        .rd_2                   (rd_2),
        .rs1_1                  (rs1_1),
        .rs1_2                  (rs1_2),
        .rs2_1                  (rs2_1),
        .rs2_2                  (rs2_2),
        .reg_rs1_1              (rs1_rdata_1),
        .reg_rs1_2              (rs1_rdata_2),
        .reg_rs2_1              (rs2_rdata_1),
        .reg_rs2_2              (rs2_rdata_2),
        .reg_rd_1               (rd_wdata_1),
        .reg_rd_2               (rd_wdata_2),
        .mem_addr_1             (mem_addr_real_1),
        .mem_addr_2             (mem_addr_real_2),
        .mem_r_data_1           (mem_r_data_1),
        .mem_r_data_2           (mem_r_data_2),
        .mem_r_mask_1           (mem_rmask_1),
        .mem_r_mask_2           (mem_rmask_2),
        .mem_w_data_1           (mem_w_data_1),
        .mem_w_data_2           (mem_w_data_2),
        .mem_w_mask_1           (mem_wmask_1),
        .mem_w_mask_2           (mem_wmask_2),
        .new_pc_1               (new_pc_1),
        .new_pc_2               (new_pc_2),
        .ctr_equiv_o            (ctr_equiv),
    );

    clk_sync clk_sync (
        .clk_i                  (clock),
        .retire_1_i             (retire_1),
        .retire_2_i             (retire_2),
        .clk_1_o                (clock_1),
        .clk_2_o                (clock_2),
        .retire_o               (retire),
    );

    control control (
        .clk_i                  (clock),
        .retire_i               (retire),
        .fetch_1_i              (fetch_1),
        .fetch_2_i              (fetch_2),
        .instr_addr_1_i         (instr_addr_1),
        .instr_addr_2_i         (instr_addr_2),
        .enable_1_o             (enable_1),
        .enable_2_o             (enable_2),
        .finished_o             (finished),
    );

//    always @(posedge clk) begin
//        if (finished && ctr_equiv && !atk_equiv) {
//            $finish();
//        }
//    end

endmodule
