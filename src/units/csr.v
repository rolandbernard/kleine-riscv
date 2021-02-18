module csr (
    // from decode (read port)
    input [11:0] read_address,
    // to decode (read port)
    output [31:0] read_data,
    output readable,
    output writeable,

    // from writeback (write port)
    input write_enable,
    input [11:0] write_address,
    input [31:0] write_data,
    
    // from writeback
    input retired,
    input traped,
    input [31:0] ecp,
    // to writeback
    output eip,
    output tip,
    output sip,

    // to fetch
    output [31:0] trap_vector,
    output [31:0] mret_vector,
);



endmodule