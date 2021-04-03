module busio (
    input clk,
    
    // External interface
    output ext_valid,
    output ext_instruction,
    input ext_ready,
    output [31:0] ext_address,
    output [31:0] ext_write_data,
    output reg [3:0] ext_write_strobe,
    input [31:0] ext_read_data,

    // Internal interface
    input [31:0] fetch_address,
    output [31:0] fetch_data,
    output fetch_ready,

    output reg [31:0] mem_load_data,
    output mem_ready,
    input [31:0] mem_address,
    input [31:0] mem_store_data,
    input [1:0] mem_size,
    input mem_signed,
    input mem_load,
    input mem_store,
);

assign ext_valid = 1;
assign ext_instruction = !(mem_load || mem_store);
assign ext_address = ((mem_load || mem_store) ? mem_address : fetch_address) & 32'hffff_fffc;
assign ext_write_data = mem_store_data;

always @(*) begin
    if (!mem_store) begin
        ext_write_strobe = 0;
    end else if (mem_size == 0) begin
        ext_write_strobe = (4'b0001 << mem_address[1:0]);
    end else if (mem_size == 1) begin
        ext_write_strobe = (4'b0011 << mem_address[1:0]);
    end else if (mem_size == 2) begin
        ext_write_strobe = 4'b1111;
    end
end

assign fetch_data = ext_read_data;
assign fetch_ready = (ext_ready && ext_instruction);

assign mem_ready = (ext_ready && !ext_instruction);

wire [31:0] tmp_load_data = (ext_read_data >> (mem_address[1:0] * 8));

always @(*) begin
    if (mem_size == 0) begin
        if (mem_signed) begin
            mem_load_data = {{24{tmp_load_data[7]}}, tmp_load_data[7:0]};
        end else begin
            mem_load_data = {24'b0, tmp_load_data[7:0]};
        end
    end else if (mem_size == 1) begin
        if (mem_signed) begin
            mem_load_data = {{16{tmp_load_data[15]}}, tmp_load_data[15:0]};
        end else begin
            mem_load_data = {16'b0, tmp_load_data[15:0]};
        end
    end else if (mem_size == 2) begin
        mem_load_data = tmp_load_data;
    end
end

endmodule
