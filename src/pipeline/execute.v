module execute (
    input clk,

    // from decode
    input [31:0] pc_in,
    input [31:0] next_pc_in,
    // from decode (control EX)
    input [31:0] rs1_data_in,
    input [31:0] rs2_data_in,
    input [31:0] csr_data_in,
    input [31:0] imm_data_in,
    input [2:0] alu_function_in,
    input alu_function_modifier_in,
    input [1:0] alu_select_a_in,
    input [1:0] alu_select_b_in,
    input [2:0] cmp_function_in,
    input jump_in,
    input branch_in,
    input csr_read_in,
    input csr_write_in,
    input csr_readable_in,
    input csr_writeable_in,
    // from decode (control MEM)
    input load_in,
    input store_in,
    input [1:0] load_store_size_in,
    input load_signed_in,
    // from decode (control WB)
    input [1:0] write_select_in,
    input [4:0] rd_address_in,
    input [11:0] csr_address_in,
    input mret_in,
    input wfi_in,
    // from decode
    input valid_in,
    input [3:0] ecause_in,
    input exception_in,
    
    // from hazard
    input stall,
    input invalidate,

    // to memory
    output reg [31:0] pc_out,
    output reg [31:0] next_pc_out,
    // to memory (control MEM)
    output reg [31:0] alu_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] csr_data_out,
    output reg branch_taken_out,
    output reg load_out,
    output reg store_out,
    output reg [1:0] load_store_size_out,
    output reg load_signed_out,
    // to memory (control WB)
    output reg [1:0] write_select_out,
    output reg [4:0] rd_address_out,
    output reg [11:0] csr_address_out,
    output reg csr_write_out,
    output reg mret_out,
    output reg wfi_out,
    // to memory
    output reg valid_out,
    output reg [3:0] ecause_out,
    output reg exception_out
);

`include "../params.vh"

wire cmp_output;
cmp ex_cmp (
    .input_a(rs1_data_in),
    .input_b(rs2_data_in),
    .function_select(cmp_function_in),
    .result(cmp_output)
);

reg [31:0] alu_input_a;
reg [31:0] alu_input_b;

always @(*) begin
    case (alu_select_a_in)
        ALU_SEL_REG : alu_input_a = rs1_data_in;
        ALU_SEL_IMM : alu_input_a = imm_data_in;
        ALU_SEL_PC  : alu_input_a = pc_in;
        ALU_SEL_CSR : alu_input_a = csr_data_in;
    endcase
    case (alu_select_b_in)
        ALU_SEL_REG : alu_input_b = rs2_data_in;
        ALU_SEL_IMM : alu_input_b = imm_data_in;
        ALU_SEL_PC  : alu_input_b = pc_in;
        ALU_SEL_CSR : alu_input_b = csr_data_in;
    endcase
end

wire [31:0] alu_output;
alu ex_alu (
    .input_a(alu_input_a),
    .input_b(alu_input_b),
    .function_select(alu_function_in),
    .function_modifier(alu_function_modifier_in),
    .result(alu_output)
);

wire csr_exception = ((csr_read_in && !csr_readable_in) || (csr_write_in && !csr_writeable_in));

always @(posedge clk) begin
    if (!stall) begin
        valid_out <= 0;
        if (valid_in && !invalidate) begin
            pc_out <= pc_in;
            next_pc_out <= next_pc_in;
            alu_data_out <= alu_output;
            rs2_data_out <= rs2_data_in;
            csr_data_out <= csr_data_in;
            branch_taken_out <= branch_in && (jump_in || cmp_output);
            load_out <= load_in;
            store_out <= store_in;
            load_store_size_out <= load_store_size_in;
            load_signed_out <= load_signed_in;
            write_select_out <= write_select_in;
            rd_address_out <= rd_address_in;
            csr_address_out <= csr_address_in;
            csr_write_out <= csr_write_in;
            mret_out <= mret_in;
            wfi_out <= wfi_in;
            if (!exception_in && csr_exception) begin
                ecause_out <= 2;
                exception_out <= 1;
            end else begin
                ecause_out <= ecause_in;
                exception_out <= exception_in;
            end
            valid_out <= 1;
        end
    end
end

endmodule
