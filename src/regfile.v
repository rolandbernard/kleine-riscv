module regfile (
    input clk,
    input rs1_enable,
    input [4:0] rs1_sel,
    output reg [31:0] rs1_out,
    input rs2_enable,
    input [4:0] rs2_sel,
    output reg [31:0] rs2_out,
    input rd_enable,
    input [4:0] rd_sel,
    input [31:0] rd_data,
);

    reg [31:0] registers [0:31];

    always @(posedge clk) begin
        if (rs1_enable && rs1_sel != 0) begin
            if (rd_enable && rs1_sel == rd_sel) begin
                rs1_out <= rd_data;
            end else begin
                rs1_out <= registers[rs1_sel];
            end
        end else begin
            rs1_out <= 0;
        end
        if (rs2_enable && rs2_sel != 0) begin
            if (rd_enable && rs2_sel == rd_sel) begin
                rs2_out <= rd_data;
            end else begin
                rs2_out <= registers[rs2_sel];
            end
        end else begin
            rs2_out <= 0;
        end
        if (rd_enable && rd_sel != 0) begin
            registers[rd_sel] <= rd_data;
        end
    end

endmodule