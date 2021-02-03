module fetch (
    input clk,
    input reset,
    input branch,
    input [31:0] branch_vec,
    input trap,
    input [31:0] trap_vec,

    input stall,
    input invalidate,
    
    output [31:0] fetch_addr,
    input [31:0] fetch_data,
    input fetch_ready,

    output reg [31:0] pc_out,
    output reg [31:0] next_pc_out,
    output reg valid,
    output reg [31:0] instr,
);

reg [31:0] pc;

assign fetch_addr = pc;
wire next_pc = pc + 4;

always @(posedge clk) begin
    if (reset) begin
        pc <= 32'h00000000;
    end else if (trap) begin
        pc <= trap_vec;
    end else if (branch) begin
        pc <= branch_vec;
    end else begin
        pc <= (stall || !fetch_ready) ? pc : next_pc;
    end
end

always @(posedge clk) begin
    if (!stall) begin
        if (fetch_ready && !invalidate) begin
            pc_out <= pc;
            next_pc_out <= next_pc;
            instr <= fetch_data;
            valid <= 1'b1;
        end else begin
            valid <= 1'b0;
        end
    end
end

endmodule