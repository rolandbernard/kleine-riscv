module fetch (
    input clk,
    input branch,
    input [31:0] branch_vec,
    input trap,
    input [31:0] trap_vec,
    input stall,
    
    output [31:0] fetch_addr,
    input [31:0] fetch_data,
    input fetch_valid,

    output reg [31:0] pc_out,
    output reg [31:0] next_pc_out,
    output reg valid,
    output reg [31:0] instr,
);

reg [31:0] pc;

assign fetch_addr = pc;
wire next_pc = pc + 4;

always @(posedge clk) begin
    if (trap) begin
        pc <= trap_vec;
    end else if (branch) begin
        pc <= branch_vec;
    end else begin
        pc <= (stall || fetch_valid) ? pc : next_pc;
    end
end

always @(posedge clk) begin
    if (!stall && fetch_valid) begin
        pc_out <= pc;
        next_pc_out <= next_pc;
        valid <= 1'b1;
        instr <= fetch_data;
    end else begin
        valid <= 1'b0;
    end
end

endmodule