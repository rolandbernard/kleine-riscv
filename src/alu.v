module alu (
    input [31:0] in1,
    input [31:0] in2,
    input [3:0] func,
    output reg [31:0] out,
);

localparam FUNC_SHIFT_LEFT = 0;
localparam FUNC_SHIFT_RIGHT = 1;
localparam FUNC_SHIFT_ARITH = 2;
localparam FUNC_ADD = 3;
localparam FUNC_SUB = 4;
localparam FUNC_OR = 5;
localparam FUNC_AND = 6;
localparam FUNC_XOR = 7;
localparam FUNC_CMP_EQ = 8;
localparam FUNC_CMP_NE = 9;
localparam FUNC_CMP_GT = 10;
localparam FUNC_CMP_GE = 11;
localparam FUNC_CMP_LT = 12;
localparam FUNC_CMP_LE = 13;

always @(*) begin
    case (func)
        FUNC_SHIFT_LEFT : out <= in1 << in2;
        FUNC_SHIFT_RIGHT : out <= in1 >> in2;
        FUNC_SHIFT_ARITH : out <= in1 >>> in2;
        FUNC_ADD : out <= in1 + in2;
        FUNC_SUB : out <= in1 - in2;
        FUNC_OR : out <= in1 | in2;
        FUNC_AND : out <= in1 & in2;
        FUNC_XOR : out <= in1 ^ in2;
        FUNC_CMP_EQ : out <= (in1 == in2) ? 1 : 0;
        FUNC_CMP_NE : out <= (in1 != in2) ? 1 : 0;
        FUNC_CMP_GT : out <= (in1 > in2) ? 1 : 0;
        FUNC_CMP_GE : out <= (in1 >= in2) ? 1 : 0;
        FUNC_CMP_LT : out <= (in1 < in2) ? 1 : 0;
        FUNC_CMP_LE : out <= (in1 <= in2) ? 1 : 0;
        default : out <= 0;
    endcase
end

endmodule