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


    logic imem_req_1;
    logic imem_req_2;
    logic [31:0] imem_addr_1;
    logic [31:0] imem_addr_2;
    logic imem_gnt_1;
    logic imem_gnt_2;
    logic [31:0] imem_data_1;
    logic [31:0] imem_data_2;


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
        .instr_req_i            (imem_req_1),
        .instr_addr_i           (imem_addr_1),
        .instr_gnt_o            (imem_gnt_1),
        .instr_o                (imem_data_1),
    );

    instr_mem #(
        .ID                     (2),
    ) instr_mem_2 (
        .clk_i                  (clock_2),
        .enable_i               (enable_2),
        .instr_req_i            (imem_req_2),
        .instr_addr_i           (imem_addr_2),
        .instr_gnt_o            (imem_gnt_2),
        .instr_o                (imem_data_2),
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

    wire [2:0] mem_typ_1;


    logic instr_req_1;
    logic [31:0] instr_addr_1;

    reg [31:0] prev_instr_addr_1;
    always @(posedge clock_1) begin
        if (instr_req_1)
            prev_instr_addr_1 <= instr_addr_1;
    end
    reg prev_gnt_1;
    always @(posedge clock_1) begin
        if (instr_req_1)
            prev_gnt_1 <= imem_gnt_1;
    end
    reg [31:0] prev_instr_1;
    always @(posedge clock_1) begin
        if (instr_req_1)
            prev_instr_1 <= imem_data_1;
    end

    assign imem_req_1 = 1;
    assign imem_addr_1 = instr_req_1 ? instr_addr_1 : prev_instr_addr_1;

    wire instr_gnt_1;
    assign instr_gnt_1 = instr_req_1 ? imem_gnt_1 : prev_gnt_1;
    wire [31:0] instr_1;
    assign instr_1 = instr_req_1 ? imem_data_1 : prev_instr_1;

    Core_2stage core_1 (
        .clock                      (clock_1),
        .reset                      (reset_1),
        .io_imem_req_valid          (instr_req_1),
        .io_imem_req_bits_addr      (instr_addr_1),
        .io_imem_resp_valid         (instr_gnt_1),
        .io_imem_resp_bits_data     (instr_1),
        .io_dmem_req_valid          (data_req_1),
        .io_dmem_req_bits_addr      (data_addr_1),
        .io_dmem_req_bits_data      (data_wdata_1),
        .io_dmem_req_bits_fcn       (data_we_1),
        .io_dmem_req_bits_typ       (mem_typ_1),
        .io_dmem_resp_valid         (data_gnt_1),
        .io_dmem_resp_bits_data     (data_rdata_1),
        .io_interrupt_debug         (1'b0),
        .io_interrupt_mtip          (1'b0),
        .io_interrupt_msip          (1'b0),
        .io_interrupt_meip          (1'b0),
        .io_hartid                  (1'b0),
        .io_reset_vector            (32'h0),
        //// for contract
        .pc_retire                  (),
        .instr_ctr                  (),
        // data load from memory
        .io_dmem_req_bits_addr_ctr  (),
        //// for state invariant
        .exe_reg_pc                 (),

        .rvfi_valid                 (retire_1),
        .rvfi_order                 (),
        .rvfi_insn                  (retire_instr_1),
        .rvfi_trap                  (rvfi_trap_1),
        .rvfi_halt                  (),
        .rvfi_intr                  (),
        .rvfi_mode                  (),
        .rvfi_ixl                   (),
        .rvfi_rs1_addr              (rs1_1),
        .rvfi_rs2_addr              (rs2_1),
        .rvfi_rs3_addr              (),
        .rvfi_rs1_rdata             (rs1_rdata_1),
        .rvfi_rs2_rdata             (rs2_rdata_1),
        .rvfi_rs3_rdata             (),
        .rvfi_rd_addr               (rd_1),
        .rvfi_rd_wdata              (rd_wdata_1),
        .rvfi_pc_rdata              (),
        .rvfi_pc_wdata              (new_pc_1),
        .rvfi_mem_addr              (mem_addr_1),
        .rvfi_mem_rmask             (mem_rmask_1),
        .rvfi_mem_wmask             (mem_wmask_1),
        .rvfi_mem_rdata             (mem_rdata_1),
        .rvfi_mem_wdata             (mem_wdata_1),
    );

    assign fetch_1 = instr_req_1;
    assign data_be_1 = (mem_typ_1 == 3'b001 || mem_typ_1 == 3'b101) ? 4'b0001 : ((mem_typ_1 == 3'b010 || mem_typ_1 ==3'b110) ? 4'b0011 : 4'b1111);


    wire [2:0] mem_typ_2;

    logic instr_req_2;
    logic [31:0] instr_addr_2;

    reg [31:0] prev_instr_addr_2;
    always @(posedge clock_2) begin
        if (instr_req_2)
            prev_instr_addr_2 <= instr_addr_2;
    end
    reg prev_gnt_2;
    always @(posedge clock_2) begin
        if (instr_req_2)
            prev_gnt_2 <= imem_gnt_2;
    end
    reg [31:0] prev_instr_2;
    always @(posedge clock_2) begin
        if (instr_req_2)
            prev_instr_2 <= imem_data_2;
    end

    assign imem_req_2 = 1;
    assign imem_addr_2 = instr_req_2 ? instr_addr_2 : prev_instr_addr_2;

    wire instr_gnt_2;
    assign instr_gnt_2 = instr_req_2 ? imem_gnt_2 : prev_gnt_2;
    wire [31:0] instr_2;
    assign instr_2 = instr_req_2 ? imem_data_2 : prev_instr_2;

    Core_2stage core_2 (
        .clock                      (clock_2),
        .reset                      (reset_2),
        .io_imem_req_valid          (instr_req_2),
        .io_imem_req_bits_addr      (instr_addr_2),
        .io_imem_resp_valid         (instr_gnt_2),
        .io_imem_resp_bits_data     (instr_2),
        .io_dmem_req_valid          (data_req_2),
        .io_dmem_req_bits_addr      (data_addr_2),
        .io_dmem_req_bits_data      (data_wdata_2),
        .io_dmem_req_bits_fcn       (data_we_2),
        .io_dmem_req_bits_typ       (mem_typ_2),
        .io_dmem_resp_valid         (data_gnt_2),
        .io_dmem_resp_bits_data     (data_rdata_2),
        .io_interrupt_debug         (1'b0),
        .io_interrupt_mtip          (1'b0),
        .io_interrupt_msip          (1'b0),
        .io_interrupt_meip          (1'b0),
        .io_hartid                  (1'b0),
        .io_reset_vector            (32'h0),
        //// for contract
        .pc_retire                  (),
        .instr_ctr                  (),
        // data load from memory
        .io_dmem_req_bits_addr_ctr  (),
        //// for state invariant
        .exe_reg_pc                 (),

        .rvfi_valid                 (retire_2),
        .rvfi_order                 (),
        .rvfi_insn                  (retire_instr_2),
        .rvfi_trap                  (rvfi_trap_2),
        .rvfi_halt                  (),
        .rvfi_intr                  (),
        .rvfi_mode                  (),
        .rvfi_ixl                   (),
        .rvfi_rs1_addr              (rs1_2),
        .rvfi_rs2_addr              (rs2_2),
        .rvfi_rs3_addr              (),
        .rvfi_rs1_rdata             (rs1_rdata_2),
        .rvfi_rs2_rdata             (rs2_rdata_2),
        .rvfi_rs3_rdata             (),
        .rvfi_rd_addr               (rd_2),
        .rvfi_rd_wdata              (rd_wdata_2),
        .rvfi_pc_rdata              (),
        .rvfi_pc_wdata              (new_pc_2),
        .rvfi_mem_addr              (mem_addr_2),
        .rvfi_mem_rmask             (mem_rmask_2),
        .rvfi_mem_wmask             (mem_wmask_2),
        .rvfi_mem_rdata             (mem_rdata_2),
        .rvfi_mem_wdata             (mem_wdata_2),
    );

    assign fetch_2 = instr_req_2;
    assign data_be_2 = (mem_typ_2 == 3'b001 || mem_typ_2 == 3'b101) ? 4'b0001 : ((mem_typ_2 == 3'b010 || mem_typ_2 ==3'b110) ? 4'b0011 : 4'b1111);
    
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
