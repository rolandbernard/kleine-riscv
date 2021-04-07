module alu (
    input [31:0] input_a,
    input [31:0] input_b,

    input [2:0] function_select,
    input function_modifier,

    output reg [31:0] result
);

`include "../params.vh"

wire [32:0] tmp_shifted = $signed({function_modifier ? input_a[31] : 1'b0, input_a}) >>> input_b[4:0];

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
