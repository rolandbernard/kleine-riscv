module memory (
    input clk,
    // Misc
    input [31:0] pc_in,
    input [31:0] next_pc_in,
    // MEM
    input [31:0] alu_data_in,
    input [31:0] rs2_data,
    input [31:0] csr_data_in,
    input branch_taken_in,
    input load,
    input store,
    input [1:0] load_store_size,
    input load_signed,
    // WB
    input [1:0] write_select_in,
    input [4:0] rd_addr_in,
    input [11:0] csr_addr_in,
    input mret_in,
    input wfi_in,

    input valid_in,
    input [3:0] ecause_in,
    input exception_in,
    
    input stall_in,
    input invalidate,

    output [4:0] data_hazard,
    output stall_out,

    output [31:0] mem_addr,
    output [31:0] mem_store_data,
    output mem_load,
    output mem_store,
    input [31:0] mem_load_data,
    input mem_ready,
    
    output branch_taken_out,
    output branch_address,

    // Misc
    output reg [31:0] pc_out,
    output reg [31:0] next_pc_out,
    // WB
    output reg [31:0] alu_data_out,
    output reg [31:0] csr_data_out,
    output reg [31:0] load_data_out,
    output reg [1:0] write_select_out,
    output reg [4:0] rd_addr_out,
    output reg [11:0] csr_addr_out,
    output reg mret_out,
    output reg wfi_out,

    output reg valid_out,
    output reg [3:0] ecause_out,
    output reg exception_out,
);

wire to_execute = !exception_in && valid_in;
assign data_hazard = to_execute ? rd_addr_in : 5'b00000;

wire valid_branch_address = (alu_data_in[1:0] == 2'b00);
reg valid_mem_address;

always @(*) begin
    case (load_store_size)
        2'b00: valid_mem_address = 1'b1;
        2'b01: valid_mem_address = (alu_data_in[0] == 1'b0);
        2'b10: valid_mem_address = (alu_data_in[1:0] == 2'b00);
        2'b11: valid_mem_address = 1'b0;
    endcase
end

assign branch_taken_out = valid_branch_address && branch_taken_in;
assign branch_address = alu_data_in;

assign stall_out = stall_in || !mem_ready;

assign mem_load = to_execute && valid_mem_address && load;
assign mem_store = to_execute && valid_mem_address && store;
assign mem_addr = alu_data_in;
assign mem_store_data = rs2_data;

always @(posedge clk) begin
    if (!stall_in) begin
        if (valid_in && mem_ready && !invalidate) begin
            pc_out <= pc_in;
            next_pc_out <= next_pc_in;
            alu_data_out <= alu_data_in;
            csr_data_out <= csr_data_in;
            load_data_out <= mem_load_data;
            write_select_out <= write_select_in;
            rd_addr_out <= rd_addr_in;
            csr_addr_out <= csr_addr_in;
            mret_out <= mret_in;
            wfi_out <= wfi_in;
            if (!exception_in && !valid_branch_address) begin
                ecause_out <= 0;
                exception_out <= 1'b1;
            end else if (!exception_in && !valid_mem_address) begin
                ecause_out <= load ? 4 : 6;
                exception_out <= 1'b1;
            end else begin
                ecause_out <= ecause_in;
                exception_out <= exception_in;
            end
            valid_out <= valid_in;
        end else begin
            valid_out <= 1'b1;
        end
    end
end

endmodule