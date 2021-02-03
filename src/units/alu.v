module alu (
    input [31:0] in1,
    input [31:0] in2,
    input [2:0] func,
    input func_sel,
    output reg [31:0] out,
);

`include "../params.vh"

always @(*) begin
    case (func)
        ALU_ADD_SUB: out = in1 + (func_sel ? -in2 : in2);
        ALU_SLL: out = in1 << in2[4:0];
        ALU_SLT, ALU_SLTU: out = {{31{1'b0}}, ($signed({func[0] ? 1'b0 : in1[31], in1}) < $signed({func[0] ? 1'b0 : in2[31], in2}))}; 
        ALU_XOR: out = in1 ^ in2;
        ALU_SRL_SRA: out = $signed({func_sel ? in1[31] : 1'b0, in1}) >>> in2[4:0];
        ALU_OR: out = in1 | in2;
        ALU_AND_CLR: out = (func_sel ? ~in1 : in1) & in2;
    endcase
end

endmodule