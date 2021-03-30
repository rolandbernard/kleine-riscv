module pipeline (
    input clk,
    input reset,
    
    // from busio to fetch
    input [31:0] fetch_data,
    // from busio to memory
    input [31:0] mem_load_data,
    // from busio to hazard
    input fetch_ready,
    input mem_ready,

    // to busio from fetch
    output [31:0] fetch_address,
    // to busio from memory
    output [31:0] mem_address,
    output [31:0] mem_store_data,
    output [1:0] mem_size,
    output mem_signed,
    output mem_load,
    output mem_store,
);

csr control_registers (
    .clk(clk),

    // from decode (read port)
    read_address,
    // to decode (read port)
    read_data,
    readable,
    writeable,

    // from writeback (write port)
    write_enable,
    write_address,
    write_data,
    // from writeback
    retired,
    traped,
    mret,
    ecp,
    trap_cause,
    interupt,
    // to writeback
    eip,
    tip,
    sip,

    // to fetch
    trap_vector,
    mret_vector,
);

regfile registers (
    .clk(clk),

    // from decode (read ports)
    rs1_address,
    rs2_address,
    // to decode (read ports)
    rs1_data,
    rs2_data,

    // from writeback (write port)
    rd_address,
    rd_data,
);

hazard hazard_control (
    .reset(reset),

    // from decode
    rs1_address_decode,
    rs2_address_decode,

    // from execute
    rd_address_execute,
    csr_write_execute,
        
    // from memory
    rd_address_memory,
    csr_write_memory,
    branch_taken,
    mret_memory,

    // from writeback
    csr_write_writeback,
    mret_writeback,
    traped,

    // from busio
    .fetch_ready(fetch_ready),
    .mem_ready(mem_ready),

    // to fetch
    stall_fetch,
    invalidate_fetch,

    // to decode
    stall_decode,
    invalidate_decode,

    // to execute
    stall_execute,
    invalidate_execute,

    // to memory
    stall_memory,
    invalidate_memory,
);

fetch pipeline_fetch (
    .clk(clk),
    .reset(reset),

    // from memory
    branch,
    branch_vector,
    
    // from writeback
    trap,
    mret,

    // from csr
    trap_vector,
    mret_vector,

    // from hazard
    stall,
    invalidate,
    
    // to busio
    .fetch_address(fetch_address),
    // from busio
    .fetch_data(fetch_data),

    // to decode
    .pc_out(fetch_to_decode_pc),
    .next_pc_out(fetch_to_decode_next_pc),
    .instruction_out(fetch_to_decode_instruction),
    .valid_out(fetch_to_decode_valid),
);

wire [31:0] fetch_to_decode_pc;
wire [31:0] fetch_to_decode_next_pc;
wire [31:0] fetch_to_decode_instruction;
wire fetch_to_decode_valid;

decode pipeline_decode (
    .clk(clk),

    // from fetch
    .pc_in(fetch_to_decode_pc),
    .next_pc_in(fetch_to_decode_next_pc),
    .instruction_in(fetch_to_decode_instruction),
    .valid_in(fetch_to_decode_valid),

    // from hazard
    stall,
    invalidate,

    // to regfile
    rs1_address,
    rs2_address,
    // from regfile
    rs1_data,
    rs2_data,
    
    // to csr
    csr_address,
    csr_data,
    // from csr
    csr_readable,
    csr_writeable,

    // to execute
    .pc_out(decode_to_execute_pc),
    .next_pc_out(decode_to_execute_next_pc),
    // to execute (control EX)
    .rs1_data_out(decode_to_execute_rs1_data),
    .rs2_data_out(decode_to_execute_rs2_data),
    .csr_data_out(decode_to_execute_csr_data),
    .imm_data_out(decode_to_execute_imm_data),
    .alu_function_out(decode_to_execute_alu_function),
    .alu_function_modifier_out(decode_to_execute_alu_function_modifier),
    .alu_select_a_out(decode_to_execute_alu_select_a),
    .alu_select_b_out(decode_to_execute_alu_select_b),
    .cmp_function_out(decode_to_execute_cmp_function),
    .jump_out(decode_to_execute_jump),
    .branch_out(decode_to_execute_branch),
    .csr_read_out(decode_to_execute_csr_read),
    .csr_write_out(decode_to_execute_csr_write),
    .csr_readable_out(decode_to_execute_csr_readable),
    .csr_writeable_out(decode_to_execute_csr_writeable),
    // to execute (control MEM)
    .load_out(decode_to_execute_load),
    .store_out(decode_to_execute_store),
    .load_store_size_out(decode_to_execute_load_store_size),
    .load_signed_out(decode_to_execute_load_signed),
    // to execute (control WB)
    .write_select_out(decode_to_execute_write_select),
    .rd_address_out(decode_to_execute_rd_address),
    .csr_address_out(decode_to_execute_csr_address),
    .mret_out(decode_to_execute_mret),
    .wfi_out(decode_to_execute_wfi),
    // to execute
    .valid_out(decode_to_execute_valid),
    .ecause_out(decode_to_execute_ecause),
    .exception_out(decode_to_execute_exception),
);

wire [31:0] decode_to_execute_pc;
wire [31:0] decode_to_execute_next_pc;
wire [31:0] decode_to_execute_rs1_data;
wire [31:0] decode_to_execute_rs2_data;
wire [31:0] decode_to_execute_csr_data;
wire [31:0] decode_to_execute_imm_data;
wire [2:0] decode_to_execute_alu_function;
wire decode_to_execute_alu_function_modifier;
wire [1:0] decode_to_execute_alu_select_a;
wire [1:0] decode_to_execute_alu_select_b;
wire [2:0] decode_to_execute_cmp_function;
wire decode_to_execute_jump;
wire decode_to_execute_branch;
wire decode_to_execute_csr_read;
wire decode_to_execute_csr_write;
wire decode_to_execute_csr_readable;
wire decode_to_execute_csr_writeable;
wire decode_to_execute_load;
wire decode_to_execute_store;
wire [1:0] decode_to_execute_load_store_size;
wire decode_to_execute_load_signed;
wire [1:0] decode_to_execute_write_select;
wire [4:0] decode_to_execute_rd_address;
wire [11:0] decode_to_execute_csr_address;
wire decode_to_execute_mret;
wire decode_to_execute_wfi;
wire decode_to_execute_valid;
wire [3:0] decode_to_execute_ecause;
wire decode_to_execute_exception;

execute pipeline_execute (
    .clk(clk),

    // from decode
    .pc_in(decode_to_execute_pc),
    .next_pc_in(decode_to_execute_next_pc),
    // from decode (control EX)
    .rs1_data_in(decode_to_execute_rs1_data),
    .rs2_data_in(decode_to_execute_rs2_data),
    .csr_data_in(decode_to_execute_csr_data),
    .imm_data_in(decode_to_execute_imm_data),
    .alu_function_in(decode_to_execute_alu_function),
    .alu_function_modifier_in(decode_to_execute_alu_function_modifier),
    .alu_select_a_in(decode_to_execute_alu_select_a),
    .alu_select_b_in(decode_to_execute_alu_select_b),
    .cmp_function_in(decode_to_execute_cmp_function),
    .jump_in(decode_to_execute_jump),
    .branch_in(decode_to_execute_branch),
    .csr_read_in(decode_to_execute_csr_read),
    .csr_write_in(decode_to_execute_csr_write),
    .csr_readable_in(decode_to_execute_csr_readable),
    .csr_writeable_in(decode_to_execute_csr_writeable),
    // from decode (control MEM)
    .load_in(decode_to_execute_load),
    .store_in(decode_to_execute_store),
    .load_store_size_in(decode_to_execute_load_store_size),
    .load_signed_in(decode_to_execute_load_signed),
    // from decode (control WB)
    .write_select_in(decode_to_execute_write_select),
    .rd_address_in(decode_to_execute_rd_address),
    .csr_address_in(decode_to_execute_csr_address),
    .mret_in(decode_to_execute_mret),
    .wfi_in(decode_to_execute_wfi),
    // from decode
    .valid_in(decode_to_execute_valid),
    .ecause_in(decode_to_execute_ecause),
    .exception_in(decode_to_execute_exception),
    
    // from hazard
    stall,
    invalidate,

    // to memory
    .pc_out(execute_to_memory_pc),
    .next_pc_out(execute_to_memory_next_pc),
    // to memory (control MEM)
    .alu_data_out(execute_to_memory_alu_data),
    .rs2_data_out(execute_to_memory_rs2_data),
    .csr_data_out(execute_to_memory_csr_data),
    .branch_taken_out(execute_to_memory_branch_taken),
    .load_out(execute_to_memory_load),
    .store_out(execute_to_memory_store),
    .load_store_size_out(execute_to_memory_load_store_size),
    .load_signed_out(execute_to_memory_load_signed),
    // to memory (control WB)
    .write_select_out(execute_to_memory_write_select),
    .rd_address_out(execute_to_memory_rd_address),
    .csr_address_out(execute_to_memory_csr_address),
    .csr_write_out(execute_to_memory_csr_write),
    .mret_out(execute_to_memory_mret),
    .wfi_out(execute_to_memory_wfi),
    // to memory
    .valid_out(execute_to_memory_valid),
    .ecause_out(execute_to_memory_ecause),
    .exception_out(execute_to_memory_exception),
);

wire [31:0] execute_to_memory_pc;
wire [31:0] execute_to_memory_next_pc;
wire [31:0] execute_to_memory_alu_data;
wire [31:0] execute_to_memory_rs2_data;
wire [31:0] execute_to_memory_csr_data;
wire execute_to_memory_branch_taken;
wire execute_to_memory_load;
wire execute_to_memory_store;
wire [1:0] execute_to_memory_load_store_size;
wire execute_to_memory_load_signed;
wire [1:0] execute_to_memory_write_select;
wire [4:0] execute_to_memory_rd_address;
wire [11:0] execute_to_memory_csr_address;
wire execute_to_memory_csr_write;
wire execute_to_memory_mret;
wire execute_to_memory_wfi;
wire execute_to_memory_valid;
wire [3:0] execute_to_memory_ecause;
wire execute_to_memory_exception;

memory pipeline_memory (
    .clk(clk),
    // from execute
    .pc_in(execute_to_memory_pc),
    .next_pc_in(execute_to_memory_next_pc),
    // from execute (control MEM)
    .alu_data_in(execute_to_memory_alu_data),
    .rs2_data_in(execute_to_memory_rs2_data),
    .csr_data_in(execute_to_memory_csr_data),
    .branch_taken_in(execute_to_memory_branch_taken),
    .load_in(execute_to_memory_load),
    .store_in(execute_to_memory_store),
    .load_store_size_in(execute_to_memory_load_store_size),
    .load_signed_in(execute_to_memory_load_signed),
    // from execute (control WB)
    .write_select_in(execute_to_memory_write_select),
    .rd_address_in(execute_to_memory_rd_address),
    .csr_address_in(execute_to_memory_csr_address),
    .csr_write_in(execute_to_memory_csr_write),
    .mret_in(execute_to_memory_mret),
    .wfi_in(execute_to_memory_wfi),
    // from execute
    .valid_in(execute_to_memory_valid),
    .ecause_in(execute_to_memory_ecause),
    .exception_in(execute_to_memory_exception),
    
    // from hazard
    stall,
    invalidate,

    // to busio
    .mem_address(mem_address),
    .mem_store_data(mem_store_data),
    .mem_size(mem_size),
    .mem_signed(mem_signed),
    .mem_load(mem_load),
    .mem_store(mem_store),
    
    // from busio
    .mem_load_data(mem_load_data),
    
    // to fetch
    branch_taken,
    branch_address,

    // to writeback
    .pc_out(memory_to_writeback_pc),
    .next_pc_out(memory_to_writeback_next_pc),
    // to writeback (control WB)
    .alu_data_out(memory_to_writeback_alu_data),
    .csr_data_out(memory_to_writeback_csr_data),
    .load_data_out(memory_to_writeback_load_data),
    .write_select_out(memory_to_writeback_write_select),
    .rd_address_out(memory_to_writeback_rd_address),
    .csr_address_out(memory_to_writeback_csr_address),
    .csr_write_out(memory_to_writeback_csr_write),
    .mret_out(memory_to_writeback_mret),
    .wfi_out(memory_to_writeback_wfi),
    // to writeback
    .valid_out(memory_to_writeback_valid),
    .ecause_out(memory_to_writeback_ecause),
    .exception_out(memory_to_writeback_exception),
);

wire [31:0] memory_to_writeback_pc;
wire [31:0] memory_to_writeback_next_pc;
wire [31:0] memory_to_writeback_alu_data;
wire [31:0] memory_to_writeback_csr_data;
wire [31:0] memory_to_writeback_load_data;
wire [1:0] memory_to_writeback_write_select;
wire [4:0] memory_to_writeback_rd_address;
wire [11:0] memory_to_writeback_csr_address;
wire memory_to_writeback_csr_write;
wire memory_to_writeback_mret;
wire memory_to_writeback_wfi;
wire memory_to_writeback_valid;
wire [3:0] memory_to_writeback_ecause;
wire memory_to_writeback_exception;

writeback pipeline_writeback (
    .clk(clk),

    // from memory
    .pc_in(memory_to_writeback_pc),
    .next_pc_in(memory_to_writeback_next_pc),
    // from memory (control WB)
    .alu_data_in(memory_to_writeback_alu_data),
    .csr_data_in(memory_to_writeback_csr_data),
    .load_data_in(memory_to_writeback_load_data),
    .write_select_in(memory_to_writeback_write_select),
    .rd_address_in(memory_to_writeback_rd_address),
    .csr_address_in(memory_to_writeback_csr_address),
    .csr_write_in(memory_to_writeback_csr_write),
    .mret_in(memory_to_writeback_mret),
    .wfi_in(memory_to_writeback_wfi),
    // from memory
    .valid_in(memory_to_writeback_valid),
    .ecause_in(memory_to_writeback_ecause),
    .exception_in(memory_to_writeback_exception),

    // from csr
    sip,
    tip,
    eip,

    // to regfile
    rd_address,
    rd_data,

    // to csr
    csr_write,
    csr_address,
    csr_data,

    // to fetch and csr and hazard
    traped,
    mret,

    // to csr
    retired,
    ecp,
    ecause,
    interupt,
);

endmodule
