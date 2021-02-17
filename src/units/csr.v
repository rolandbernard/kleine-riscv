module csr (
    // read port
    input [11:0] read_address,
    output [31:0] read_data,
    output readable,
    output writeable,
    
    // write port
    input write_enable,
    input [11:0] write_address,
    input [31:0] write_data,
);



endmodule