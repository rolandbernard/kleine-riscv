module cmp (
    input [31:0] in1,
    input [31:0] in2,
    input less,
    input sign,
    input negate,
    output out,
);

wire is_equal = (in1 == in2);
wire is_less = ($signed({sign ? in1[31] : 1'b0, in1}) < $signed({sign ? in2[31] : 1'b0, in2}));
wire func_out = less ? is_less : is_equal;

assign out = negate ? !func_out : func_out;

endmodule