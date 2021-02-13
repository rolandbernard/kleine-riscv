module writeback (
    input clk,
    // Misc
    input [31:0] pc,
    input [31:0] next_pc,
    // WB
    input [31:0] alu_data,
    input [31:0] csr_data,
    input [31:0] load_data,
    input [1:0] write_select,
    input [4:0] rd_addr_in,
    input [11:0] csr_addr,
    input mret,
    input wfi_in,

    input valid,
    input [3:0] ecause_in,
    input exception,
    
    input sip,
    input tip,
    input eip,

    output [4:0] rd_addr_out,
    output reg [31:0] rd_data,

    output stall,
    output traped,
    output reg ecause,
    output reg interupt,
    output [31:0] ecp,
);

`include "../params.vh"
    
reg wfi = 0;

assign stall = wfi;
assign traped = (sip || tip || eip || exception);
assign ecp = pc;

always @(*) begin
    if (eip) begin
        ecause = 11;
        interupt = 1'b1;
    end else if (tip) begin
        ecause = 7;
        interupt = 1'b1;
    end else if (sip) begin
        ecause = 3;
        interupt = 1'b1;
    end else if (exception) begin
        ecause = ecause_in;
        interupt = 1'b0;
    end else begin
        ecause = 0;
        interupt = 1'b0;
    end
end

assign rd_addr_out = traped ? 5'b00000 : rd_addr_in;

always @(*) begin
    case (write_select)
        WRITE_SEL_ALU: rd_data = alu_data;
        WRITE_SEL_CSR: rd_data = csr_data;
        WRITE_SEL_LOAD: rd_data = load_data;
        WRITE_SEL_NEXT_PC: rd_data = next_pc;
    endcase
end

always @(posedge clk) begin
    if (traped) begin
        wfi <= 1'b0;
    end else begin
        wfi <= wfi_in;
    end
end

endmodule