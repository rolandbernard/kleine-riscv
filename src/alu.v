module alu (
    input [31:0] in1,
    input [31:0] in2,
    input [3:0] func,
    output reg [31:0] out,
);

localparam FUNC_ADD = 0;
localparam FUNC_SUB = 1;
localparam FUNC_SHL = 2;
localparam FUNC_SHR = 3;
localparam FUNC_SHA = 4;
localparam FUNC_OR  = 5;
localparam FUNC_AND = 6;
localparam FUNC_XOR = 7;
localparam FUNC_EQ  = 8;
localparam FUNC_NE  = 9;
localparam FUNC_LT  = 10;
localparam FUNC_GE  = 11;
localparam FUNC_LTU = 12;
localparam FUNC_GEU = 13;

wire is_equal;
wire is_less;
wire is_less_uns;

assign is_equal = (in1 == in2);
assign is_less = ($signed(in1) < $signed(in2));
assign is_less_uns = (in1 < in2);

always @(*) begin
    case (func)
        FUNC_ADD : out = in1 + in2;
        FUNC_SUB : out = in1 - in2;
        FUNC_SHL : out = in1 << in2[4:0];
        FUNC_SHR : out = in1 >> in2[4:0];
        FUNC_SHA : out = $signed(in1) >>> in2[4:0];
        FUNC_OR : out = in1 | in2;
        FUNC_AND : out = in1 & in2;
        FUNC_XOR : out = in1 ^ in2;
        FUNC_EQ : out = is_equal;
        FUNC_NE : out = !is_equal;
        FUNC_LT : out = is_less;
        FUNC_GE : out = !is_less;
        FUNC_LTU : out = is_less_uns;
        FUNC_GEU : out = !is_less_uns;
        default : out = 0;
    endcase
end

endmodule