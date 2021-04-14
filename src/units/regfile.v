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
    input [31:0] rd_data,

    // from memory (bypass)
    input [4:0] bypass_address,
    input [31:0] bypass_data
);

    reg [31:0] registers [0:31];

    always @(*) begin
        if (rs1_address != 0) begin
            if (rs1_address == bypass_address) begin
                rs1_data = bypass_data;
            end else if (rs1_address == rd_address) begin
                rs1_data = rd_data;
            end else begin
                rs1_data = registers[rs1_address];
            end
        end else begin
            rs1_data = 0;
        end
    end
    
    always @(*) begin
        if (rs2_address != 0) begin
            if (rs2_address == bypass_address) begin
                rs2_data = bypass_data;
            end else if (rs2_address == rd_address) begin
                rs2_data = rd_data;
            end else begin
                rs2_data = registers[rs2_address];
            end
        end else begin
            rs2_data = 0;
        end
    end

    always @(posedge clk) begin
        registers[rd_address] <= rd_data;
    end

endmodule
