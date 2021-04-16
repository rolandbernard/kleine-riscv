module alu (
    input clk,

    input [31:0] input_a,
    input [31:0] input_b,

    input [2:0] function_select,
    input function_modifier,

    // 1st cycle output
    output [31:0] add_result,
    // 2nd cycle output
    output reg [31:0] result
);

localparam ALU_ADD_SUB = 3'b000;
localparam ALU_SLL     = 3'b001;
localparam ALU_SLT     = 3'b010;
localparam ALU_SLTU    = 3'b011;
localparam ALU_XOR     = 3'b100;
localparam ALU_SRL_SRA = 3'b101;
localparam ALU_OR      = 3'b110;
localparam ALU_AND_CLR = 3'b111;

/* verilator lint_off UNUSED */ // The first bit [32] will intentionally be ignored
wire [32:0] tmp_shifted = $signed({function_modifier ? input_a[31] : 1'b0, input_a}) >>> input_b[4:0];
/* verilator lint_on UNUSED */

assign add_result = result_add_sub;

reg [31:0] result_add_sub;
reg [31:0] result_sll;
reg [31:0] result_slt;
reg [31:0] result_xor;
reg [31:0] result_srl_sra;
reg [31:0] result_or;
reg [31:0] result_and_clr;

reg [2:0] old_function;

always @(posedge clk) begin
    old_function <= function_select;
    result_add_sub <= input_a + (function_modifier ? -input_b : input_b);
    result_sll <= input_a << input_b[4:0];
    result_slt <= {
        {31{1'b0}},
        (
            $signed({function_select[0] ? 1'b0 : input_a[31], input_a})
            < $signed({function_select[0] ? 1'b0 : input_b[31], input_b})
        )
    }; 
    result_xor <= input_a ^ input_b;
    result_srl_sra <= tmp_shifted[31:0];
    result_or <= input_a | input_b;
    result_and_clr <= (function_modifier ? ~input_a : input_a) & input_b;
end

always @(*) begin
    case (old_function)
        ALU_ADD_SUB: result = result_add_sub;
        ALU_SLL:     result = result_sll;
        ALU_SLT,
        ALU_SLTU:    result = result_slt; 
        ALU_XOR:     result = result_xor;
        ALU_SRL_SRA: result = result_srl_sra;
        ALU_OR:      result = result_or;
        ALU_AND_CLR: result = result_and_clr;
    endcase
end

endmodule
