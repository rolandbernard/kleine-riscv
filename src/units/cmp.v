module cmp (
    input clk,

    input [31:0] input_a,
    input [31:0] input_b,

    input [2:0] function_select,

    output result
);

reg quasi_result;
reg negate;

wire usign = function_select[1];
wire less = function_select[2];

wire is_equal = (input_a == input_b);
wire is_less = ($signed({usign ? 1'b0 : input_a[31], input_a}) < $signed({usign ? 1'b0 : input_b[31], input_b}));

always @(posedge clk) begin
    negate <= function_select[0];
    quasi_result <= less ? is_less : is_equal;
end


assign result = negate ? !quasi_result : quasi_result;

endmodule
