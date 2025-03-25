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

    logic [31:0] last_addr [`COUNT - 1:0];
    logic [7:0] last_values [`COUNT - 1:0];
    logic [32:0] temp;
    
    initial begin
        last_addr = 0;
        last_values = 0;
    end

    assign data_gnt_o = data_req_i;
    assign data_rvalid_o = data_req_i && !data_we_i;
    assign data_err_o = 1'b0;
    
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

    integer j;
    integer k;
    integer l;
    integer m;
    always @(posedge clk_i) begin
        if (data_req_i == 1'b1) begin
            if (data_we_i) begin
                if (data_be_i[0]) begin
                    for (j = 1; j < `COUNT; j = j + 1) begin
                        last_addr[j-1] = last_addr[j];
                        last_values[j-1] = last_values[j];
                    end
                    last_addr[`COUNT - 1] = data_addr_i + 0;
                    last_values[`COUNT - 1] = data_wdata_i[(0 * 8) + 7:(0 * 8)];
                end
                if (data_be_i[1]) begin
                    for (k = 1; k < `COUNT; k = k + 1) begin
                        last_addr[k-1] = last_addr[k];
                        last_values[k-1] = last_values[k];
                    end
                    last_addr[`COUNT - 1] = data_addr_i + 1;
                    last_values[`COUNT - 1] = data_wdata_i[(1 * 8) + 7:(1 * 8)];
                end
                if (data_be_i[2]) begin
                    for (l = 1; l < `COUNT; l = l + 1) begin
                        last_addr[l-1] = last_addr[l];
                        last_values[l-1] = last_values[l];
                    end
                    last_addr[`COUNT - 1] = data_addr_i + 2;
                    last_values[`COUNT - 1] = data_wdata_i[(2 * 8) + 7:(2 * 8)];
                end
                if (data_be_i[3]) begin
                    for (m = 1; m < `COUNT; m = m + 1) begin
                        last_addr[m-1] = last_addr[m];
                        last_values[m-1] = last_values[m];
                    end
                    last_addr[`COUNT - 1] = data_addr_i + 3;
                    last_values[`COUNT - 1] = data_wdata_i[(3 * 8) + 7:(3 * 8)];
                end
            end
        end
    end

    /*
    (* nomem2reg *)
    logic [7:0] mem [31:0];

    initial begin
        mem = 0;
    end

    assign mem_o = mem;

    always @(posedge clk_i) begin
        if(data_req_i == 1'b1) begin
            // TODO figure out which bits of BE are which byte
            //TODO figure out byte order
            data_rdata_o <= {data_be_i[0] ? mem[data_addr_i] : 8'b0, data_be_i[1] ? mem[data_addr_i + 1] : 8'b0, data_be_i[2] ? mem[data_addr_i + 2] : 8'b0, data_be_i[3] ? mem[data_addr_i + 3] : 8'b0};
            if (data_we_i) begin
                if (data_be_i[0])
                    mem[data_addr_i] <= data_wdata_i[7:0];
                if (data_be_i[1])
                    mem[data_addr_i] <= data_wdata_i[15:8];
                if (data_be_i[2])
                    mem[data_addr_i] <= data_wdata_i[23:16];
                if (data_be_i[3])
                    mem[data_addr_i] <= data_wdata_i[31:24];
            end
            data_gnt_o <= 1'b1;
            data_rvalid_o <= 1'b1;
            data_err_o <= 1'b0;
        end
        else begin
            data_gnt_o <= 1'b0;
            data_rvalid_o <= 1'b0;
            data_err_o <= 1'b0;
        end
    end
    */
endmodule