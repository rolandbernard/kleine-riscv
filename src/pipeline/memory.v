module memory (
    input clk,
    // from execute
    output reg [31:0] pc_in,
    output reg [31:0] next_pc_in,
    // from execute (control MEM)
    output reg [31:0] alu_data_in,
    output reg [31:0] rs2_data_in,
    output reg [31:0] csr_data_in,
    output reg branch_taken_in,
    output reg load_in,
    output reg store_in,
    output reg [1:0] load_store_size_in,
    output reg load_signed_in,
    // from execute (control WB)
    output reg [1:0] write_select_in,
    output reg [4:0] rd_address_in,
    output reg [11:0] csr_address_in,
    output reg mret_in,
    output reg wfi_in,
    // from execute
    output reg valid_in,
    output reg [3:0] ecause_in,
    output reg exception_in,
    
    // from hazard
    input stall,
    input invalidate,

    // to busio
    output [31:0] mem_address,
    output [31:0] mem_store_data,
    output [1:0] mem_size,
    output mem_signed,
    output mem_load,
    output mem_store,
    
    // from busio
    input [31:0] mem_load_data,
    
    // to fetch
    output branch_taken,
    output [31:0] branch_address,

    // to writeback
    output reg [31:0] pc_out,
    output reg [31:0] next_pc_out,
    // to writeback (control WB)
    output reg [31:0] alu_data_out,
    output reg [31:0] csr_data_out,
    output reg [31:0] load_data_out,
    output reg [1:0] write_select_out,
    output reg [4:0] rd_address_out,
    output reg [11:0] csr_address_out,
    output reg mret_out,
    output reg wfi_out,
    // to writeback
    output reg valid_out,
    output reg [3:0] ecause_out,
    output reg exception_out,
);

wire to_execute = !invalidate && !exception_in && valid_in;

wire valid_branch_address = (alu_data_in[1:0] == 0);
reg valid_mem_address;

always @(*) begin
    case (load_store_size_in)
        2'b00: valid_mem_address = 1;
        2'b01: valid_mem_address = (alu_data_in[0] == 0);
        2'b10: valid_mem_address = (alu_data_in[1:0] == 0);
        2'b11: valid_mem_address = 0;
    endcase
end

assign branch_taken = to_execute && valid_branch_address && branch_taken_in;
assign branch_address = alu_data_in;

assign mem_load = to_execute && valid_mem_address && load_in;
assign mem_store = to_execute && valid_mem_address && store_in;
assign mem_size = load_store_size_in;
assign mem_signed = load_signed_in;
assign mem_address = alu_data_in;
assign mem_store_data = rs2_data_in;

always @(posedge clk) begin
    if (!stall) begin
        if (valid_in && !invalidate) begin
            pc_out <= pc_in;
            next_pc_out <= next_pc_in;
            alu_data_out <= alu_data_in;
            csr_data_out <= csr_data_in;
            load_data_out <= mem_load_data;
            write_select_out <= write_select_in;
            rd_address_out <= rd_address_in;
            csr_address_out <= csr_address_in;
            mret_out <= mret_in;
            wfi_out <= wfi_in;
            if (!exception_in && branch_taken_in && !valid_branch_address) begin
                ecause_out <= 0;
                exception_out <= 1;
            end else if (!exception_in && (load_in || store_in) && !valid_mem_address) begin
                ecause_out <= load_in ? 4 : 6;
                exception_out <= 1;
            end else begin
                ecause_out <= ecause_in;
                exception_out <= exception_in;
            end
            valid_out <= 0;
        end else begin
            valid_out <= 1;
        end
    end
end

endmodule