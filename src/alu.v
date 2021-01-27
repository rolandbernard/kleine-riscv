module alu (
    input [31:0] in1,
    input [31:0] in2,
    input [2:0] func,
    output reg [31:0] out,
);

localparam ALU_ADD = 3'b000;
localparam ALU_SUB = 3'b001;
localparam ALU_SHR = 3'b010;
localparam ALU_SHA = 3'b011;
localparam ALU_SHL = 3'b100;
localparam ALU_AND = 3'b101;
localparam ALU_OR  = 3'b110;
localparam ALU_XOR = 3'b111;

wire [31:0] add_sub_out = in1 + (func[0] ? -in2 : in2);
wire [31:0] shift_right_out = $signed({func[0] ? in1[31] : 1'b0, in1}) >>> in2[4:0];

always @(*) begin
    casez (func)
        'b00?: out = add_sub_out;
        'b01?: out = shift_right_out;
        'b100: out = in1 << in2[4:0];
        'b101: out = in1 & in2;
        'b110: out = in1 | in2;
        'b111: out = in1 ^ in2;
    endcase
end

endmodule