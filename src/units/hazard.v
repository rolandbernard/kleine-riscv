module hazard (
    // from decode
    input [4:0] rs1_address_decode,
    input [4:0] rs2_address_decode,
    input [4:0] csr_address_decode,

    // from execute
    input [4:0] rd_address_execute,
    input [4:0] csr_address_execute,
        
    // from memory
    input [4:0] rd_address_memory,
    input [4:0] csr_address_memory,
    input branch_taken,
    input mret_memory,

    // from writeback
    input [4:0] csr_address_writeback,
    input mret_writeback,
    input traped,

    // from busio
    input fetch_ready,
    input mem_ready,

    // to fetch
    output stall_fetch,
    output invalidate_fetch,

    // to decode
    output stall_decode,
    output invalidate_decode,

    // to execute
    output stall_execute,
    output invalidate_execute,

    // to memory
    output stall_memory,
    output invalidate_memory,
);

assign stall_fetch = stall_decode || !fetch_ready;
assign stall_decode = stall_execute
    || rs1_address_decode == rd_address_execute
    || rs2_address_decode == rd_address_execute
    || rs1_address_decode == rd_address_memory
    || rs2_address_decode == rd_address_memory
    || csr_address_decode == csr_address_execute
    || csr_address_decode == csr_address_memory
    || csr_address_decode == csr_address_writeback;
assign stall_execute = stall_memory;
assign stall_memory = !mem_ready;

assign invalidate_fetch = invalidate_decode;
assign invalidate_decode = stall_fetch || invalidate_execute;
assign invalidate_execute = stall_decode || invalidate_memory || mret_memory;
assign invalidate_memory = stall_execute || branch_taken || mret_writeback || traped;

endmodule