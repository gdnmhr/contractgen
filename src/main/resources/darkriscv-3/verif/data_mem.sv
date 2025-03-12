`define COUNT 32
module data_mem (
    input  logic clk_i,
    input  logic data_req_i,
    input  logic data_we_i,
    input  logic  [3:0]  data_be_i,
    input  logic [31:0]  data_addr_i,
    input  logic [31:0]  data_wdata_i,
    output logic data_gnt_o,
    output logic data_rvalid_o,
    output logic [31:0]  data_rdata_o,
    output logic data_err_o,
    output logic [31:0] mem_addr_o [`COUNT - 1:0],
    output logic [7:0] mem_data_o [`COUNT - 1:0],
);

    reg [31:0] last_addr [`COUNT - 1:0];
    reg [7:0] last_values [`COUNT - 1:0];
    
    initial begin
        last_addr = 0;
        last_values = 0;
    end

    assign data_gnt_o = data_req_i;
    assign data_rvalid_o = data_req_i && !data_we_i;
    
    integer i;
    always_comb begin : data_rdata_o_gen
        data_rdata_o = 0;
        for (int i = 0; i < `COUNT; i = i + 1) begin
            if (data_be_i[0] && data_addr_i == last_addr[i]) begin
                data_rdata_o[7:0] = last_values[i];
            end
            if (data_be_i[1] && data_addr_i + 1 == last_addr[i]) begin
                data_rdata_o[15:8] = last_values[i];
            end
            if (data_be_i[2] && data_addr_i + 2 == last_addr[i]) begin
                data_rdata_o[23:16] = last_values[i];
            end
            if (data_be_i[3] && data_addr_i + 3 == last_addr[i]) begin
                data_rdata_o[31:24] = last_values[i];
            end
        end
        
    end
    assign data_err_o = 0;
    assign mem_addr_o = last_addr;
    assign mem_data_o = last_values;

    always @(negedge clk_i) begin
        if (data_req_i == 1'b1) begin
            if (data_we_i) begin
                if (data_be_i[0]) begin
                    for (i = 1; i < `COUNT; i = i + 1) begin
                        last_addr[i-1] = last_addr[i];
                        last_values[i-1] = last_values[i];
                    end
                    last_addr[`COUNT - 1] = data_addr_i + 0;
                    last_values[`COUNT - 1] = data_wdata_i[(0 * 8) + 7:(0 * 8)];
                end
                if (data_be_i[1]) begin
                    for (i = 1; i < `COUNT; i = i + 1) begin
                        last_addr[i-1] = last_addr[i];
                        last_values[i-1] = last_values[i];
                    end
                    last_addr[`COUNT - 1] = data_addr_i + 1;
                    last_values[`COUNT - 1] = data_wdata_i[(1 * 8) + 7:(1 * 8)];
                end
                if (data_be_i[2]) begin
                    for (i = 1; i < `COUNT; i = i + 1) begin
                        last_addr[i-1] = last_addr[i];
                        last_values[i-1] = last_values[i];
                    end
                    last_addr[`COUNT - 1] = data_addr_i + 2;
                    last_values[`COUNT - 1] = data_wdata_i[(2 * 8) + 7:(2 * 8)];
                end
                if (data_be_i[3]) begin
                    for (i = 1; i < `COUNT; i = i + 1) begin
                        last_addr[i-1] = last_addr[i];
                        last_values[i-1] = last_values[i];
                    end
                    last_addr[`COUNT - 1] = data_addr_i + 3;
                    last_values[`COUNT - 1] = data_wdata_i[(3 * 8) + 7:(3 * 8)];
                end
            end
        end
    end

endmodule