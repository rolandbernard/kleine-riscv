module alu (
    input [31:0] input_a,
    input [31:0] input_b,

    input [2:0] function_select,
    input function_modifier,

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

/* verilator lint_off UNUSED */ // The first bit [32] will intentionally be ignored (TODO?)
wire [32:0] tmp_shifted = $signed({function_modifier ? input_a[31] : 1'b0, input_a}) >>> input_b[4:0];
/* verilator lint_on UNUSED */

always @(*) begin
    case (function_select)
        ALU_ADD_SUB: result = input_a + (function_modifier ? -input_b : input_b);
        ALU_SLL:     result = input_a << input_b[4:0];
        ALU_SLT,
        ALU_SLTU:    result = {
            {31{1'b0}},
            (
                $signed({function_select[0] ? 1'b0 : input_a[31], input_a})
                < $signed({function_select[0] ? 1'b0 : input_b[31], input_b})
            )
        }; 
        ALU_XOR:     result = input_a ^ input_b;
        ALU_SRL_SRA: result = tmp_shifted[31:0];
        ALU_OR:      result = input_a | input_b;
        ALU_AND_CLR: result = (function_modifier ? ~input_a : input_a) & input_b;
    endcase
end

endmodule
