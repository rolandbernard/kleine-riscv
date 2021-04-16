module regfile (
    input clk,

    // from decode (read ports)
    input [4:0] rs1_address,
    input [4:0] rs2_address,
    // to decode (read ports)
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data,

    // from writeback (write port)
    input [4:0] rd_address,
    input [31:0] rd_data
);

    reg [31:0] registers [0:31];

    always @(*) begin
        rs1_data = registers[rs1_address];
    end
    
    always @(*) begin
        rs2_data = registers[rs2_address];
    end

    always @(posedge clk) begin
        registers[rd_address] <= rd_data;
    end

endmodule
