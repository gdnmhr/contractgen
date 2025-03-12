`define NO_OP     32'h00000013
`define MAX_INSTR 128

module instr_mem #(
    parameter int unsigned        ID   = 0,
) (
    input logic clk_i,
    input logic enable_i,
    input logic instr_req_i,
    input  logic [31:0]  instr_addr_i,
    output logic instr_gnt_o,
    output logic [31:0] instr_o,
);
    (* nomem2reg *)
    logic [31:0] mem [(`MAX_INSTR - 1):0];

    logic [31:0]  instr_addr;
    assign instr_addr = instr_addr_i - 32'h0;
    assign instr_o = enable_i ? ((instr_addr_i >> 2) < `MAX_INSTR ? mem[(instr_addr_i >> 2)] : `NO_OP) : `NO_OP;
    assign instr_gnt_o = instr_req_i;

    /* Instruction Memory 2 - Variables */

    initial begin
		for(int i = 0; i < `MAX_INSTR; i = i+1) begin
			mem[i] = `NO_OP;
		end
        
//		$readmemh({"init_", ID, ".dat"}, mem, 0, 31);
//		$readmemh({"memory_", ID, ".dat"}, mem, 32, (`MAX_INSTR - 1));
		
        instr_o <= `NO_OP;
    end
endmodule