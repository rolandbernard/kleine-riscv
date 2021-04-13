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
    input load_store,

    // from writeback
    input csr_write_writeback,
    input mret_writeback,
    input wfi,
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
    output invalidate_memory
);

// TODO: review stall/invalidate logic

assign stall_fetch = !invalidate_fetch && (stall_decode || invalidate_decode);
assign stall_decode = !invalidate_decode && (stall_execute || invalidate_execute);
assign stall_execute = !invalidate_execute && (stall_memory || invalidate_memory || (!mem_ready && load_store) || mret_memory);
assign stall_memory = !invalidate_memory && wfi;

wire trap_invalidate = mret_writeback || traped;
wire branch_invalidate = branch_taken || trap_invalidate;

assign invalidate_fetch = reset || branch_invalidate || (!fetch_ready && !invalidate_decode);
assign invalidate_decode = reset || branch_invalidate
    || (rd_address_execute != 0 && (
        rs1_address_decode == rd_address_execute
        || rs2_address_decode == rd_address_execute
    ))
    || (rd_address_memory != 0 && (
        rs1_address_decode == rd_address_memory
        || rs2_address_decode == rd_address_memory
    ))
    || csr_write_execute || csr_write_memory || csr_write_writeback;
assign invalidate_execute = reset || branch_invalidate;
assign invalidate_memory = reset || trap_invalidate || (!mem_ready && load_store);

endmodule
