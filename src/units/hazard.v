module hazard (
    input reset,

    // from decode
    input [4:0] rs1_address_decode,
    input [4:0] rs2_address_decode,

    // from execute
    input [4:0] rd_address_execute,
    input csr_write_execute,
        
    // from memory
    input [4:0] rd_address_memory,
    input csr_write_memory,
    input branch_taken,
    input mret_memory,

    // from writeback
    input csr_write_writeback,
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

assign stall_fetch = !invalidate_fetch && (
    stall_decode
    || rs1_address_decode == rd_address_execute
    || rs2_address_decode == rd_address_execute
    || rs1_address_decode == rd_address_memory
    || rs2_address_decode == rd_address_memory
    || csr_write_execute || csr_write_memory || csr_write_writeback
);
assign stall_decode = !invalidate_decode && stall_execute;
assign stall_execute = !invalidate_execute && (stall_memory || !mem_ready);
assign stall_memory = 0;

wire branch_invalidate = branch_taken || mret_writeback || traped;

assign invalidate_fetch = reset || branch_invalidate || mret_memory || !fetch_ready;
assign invalidate_decode = reset || branch_invalidate || mret_memory;
assign invalidate_execute = reset || branch_invalidate || mret_memory;
assign invalidate_memory = reset || branch_invalidate || !mem_ready;

endmodule
