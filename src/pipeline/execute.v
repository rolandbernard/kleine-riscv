module execute (
    input clk,
    // Misc
    input [31:0] pc_in,
    input [31:0] next_pc_in,
    // EX
    input [31:0] rs1_data,
    input [31:0] rs2_data_in,
    input [31:0] csr_data_in,
    input [31:0] imm_data,
    input [5:0] uimm_data,
    input [2:0] alu_func,
    input alu_func_sel,
    input [1:0] alu_a_select,
    input [1:0] alu_b_select,
    input cmp_less,
    input cmp_sign,
    input cmp_negate,
    input jump,
    input branch,
    input read_csr,
    input write_csr,
    input readable_csr,
    input writeable_csr,
    // MEM
    input load_in,
    input store_in,
    input [1:0] load_store_size_in,
    input load_signed_in,
    // WB
    input [1:0] write_select_in,
    input [5:0] rd_addr_in,
    input [11:0] csr_addr_in,
    input mret_in,
    input wfi_in,

    input valid_in,
    input [3:0] ecause_in,
    input exception_in,
    
    input stall,
    input invalidate,
    output [4:0] data_hazard,

    // Misc
    output reg [31:0] pc_out,
    output reg [31:0] next_pc_out,
    // MEM
    output reg [31:0] alu_data,
    output reg [31:0] rs2_data_out,
    output reg [31:0] csr_data_out,
    output reg branch_taken,
    output reg load_out,
    output reg store_out,
    output reg [1:0] load_store_size_out,
    output reg load_signed_out,
    // WB
    output reg [1:0] write_select_out,
    output reg [5:0] rd_addr_out,
    output reg [11:0] csr_addr_out,
    output reg mret_out,
    output reg wfi_out,

    output reg valid_out,
    output reg [3:0] ecause_out,
    output reg exception_out,
);

`include "../params.vh"

wire to_execute = !exception_in && valid_in;
assign data_hazard = to_execute ? rd_addr_in : 5'b00000;

wire cmp_output;
cmp ex_cmp (
    .in1(rs1_data),
    .in2(rs2_data_in),
    .less(cmp_less),
    .sign(cmp_sign),
    .negate(cmp_negate),
    .out(cmp_output),
);

reg [31:0] alu_input_a;
reg [31:0] alu_input_b;

always @(*) begin
    case (alu_a_select)
        ALU_SEL_REG : alu_input_a = rs1_data;
        ALU_SEL_IMM : alu_input_a = {{27{1'b0}}, uimm_data};
        ALU_SEL_PC_CSR : alu_input_a = pc_in;
        ALU_SEL_ZERO : alu_input_a = 32'h00000000;
    endcase
    case (alu_b_select)
        ALU_SEL_REG : alu_input_b = rs2_data_in;
        ALU_SEL_IMM : alu_input_b = imm_data;
        ALU_SEL_PC_CSR : alu_input_b = csr_data_in;
        ALU_SEL_ZERO : alu_input_b = 32'h00000000;
    endcase
end

wire [31:0] alu_output;
alu ex_alu (
    .in1(alu_input_a),
    .in2(alu_input_b),
    .func(alu_func),
    .func_sel(alu_func_sel),
    .out(alu_output),
);

always @(posedge clk) begin
    if (!stall) begin
        if (valid_in) begin
            pc_out <= pc_in;
            next_pc_out <= next_pc_in;
            alu_data <= alu_output;
            rs2_data_out <= rs2_data_in;
            csr_data_out <= csr_data_in;
            branch_taken <= branch && (jump || cmp_output);
            load_out <= load_in;
            store_out <= store_in;
            load_store_size_out <= load_store_size_in;
            load_signed_out <= load_signed_in;
            write_select_out <= write_select_in;
            rd_addr_out <= rd_addr_in;
            csr_addr_out <= csr_addr_in;
            mret_out <= mret_in;
            wfi_out <= wfi_in;

            if (!exception_in && ((read_csr && !readable_csr) || (write_csr && !writeable_csr))) begin
                ecause_out <= 2;
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