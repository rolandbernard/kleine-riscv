module alu (
    input [31:0] in1,
    input [31:0] in2,
    input [2:0] func,
    input func_sel,
    output reg [31:0] out,
);

// These are the values also used in the ISA
localparam ALU_ADD_SUB = 3'b000;
localparam ALU_SLL     = 3'b001;
localparam ALU_SLT     = 3'b010;
localparam ALU_SLTU    = 3'b011;
localparam ALU_XOR     = 3'b100;
localparam ALU_SRL_SRA = 3'b101;
localparam ALU_OR      = 3'b110;
localparam ALU_AND_CLR = 3'b111;

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