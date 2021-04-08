module decode (
    input clk,

    // from fetch
    input [31:0] pc_in,
    input [31:0] next_pc_in,
    input [31:0] instruction_in,
    input valid_in,

    // from hazard
    input stall,
    input invalidate,

    // to regfile
    output [4:0] rs1_address,
    output [4:0] rs2_address,
    // from regfile
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    
    // to csr
    output [11:0] csr_address,
    input [31:0] csr_data,
    // from csr
    input csr_readable,
    input csr_writeable,

    // to execute
    output reg [31:0] pc_out,
    output reg [31:0] next_pc_out,
    // to execute (control EX)
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] csr_data_out,
    output reg [31:0] imm_data_out,
    output reg [2:0] alu_function_out,
    output reg alu_function_modifier_out,
    output reg [1:0] alu_select_a_out,
    output reg [1:0] alu_select_b_out,
    output reg [2:0] cmp_function_out,
    output reg jump_out,
    output reg branch_out,
    output reg csr_read_out,
    output reg csr_write_out,
    output reg csr_readable_out,
    output reg csr_writeable_out,
    // to execute (control MEM)
    output reg load_out,
    output reg store_out,
    output reg [1:0] load_store_size_out,
    output reg load_signed_out,
    // to execute (control WB)
    output reg [1:0] write_select_out,
    output reg [4:0] rd_address_out,
    output reg [11:0] csr_address_out,
    output reg mret_out,
    output reg wfi_out,
    // to execute
    output reg valid_out,
    output reg [3:0] ecause_out,
    output reg exception_out
);

localparam ALU_ADD_SUB = 3'b000;
localparam ALU_OR      = 3'b110;
localparam ALU_AND_CLR = 3'b111;

localparam ALU_SEL_REG = 2'b00;
localparam ALU_SEL_IMM = 2'b01;
localparam ALU_SEL_PC  = 2'b10;
localparam ALU_SEL_CSR = 2'b11;

localparam WRITE_SEL_ALU     = 2'b00;
localparam WRITE_SEL_CSR     = 2'b01;
localparam WRITE_SEL_LOAD    = 2'b10;
localparam WRITE_SEL_NEXT_PC = 2'b11;

wire [31:0] instr = instruction_in;

assign rs1_address = instr[19:15];
assign rs2_address = instr[24:20];
assign csr_address = instr[31:20];
                
wire [4:0] rd_address = instr[11:7];

// possible immediate values
wire [31:0] u_type_imm_data = {instr[31:12], 12'b0};
wire [31:0] j_type_imm_data = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
wire [31:0] i_type_imm_data = {{20{instr[31]}}, instr[31:20]};
wire [31:0] s_type_imm_data = {{20{instr[31]}}, instr[31:25], instr[11:7]};
wire [31:0] b_type_imm_data = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
wire [31:0] csr_type_imm_data = {27'b0, rs1_address};

always @(posedge clk) begin
    if (!stall) begin
        valid_out <= 0;
        if (valid_in && !invalidate) begin
            pc_out <= pc_in;
            next_pc_out <= next_pc_in;
            rs1_data_out <= rs1_data;
            rs2_data_out <= rs2_data;
            csr_data_out <= csr_data;
            imm_data_out <= 0;
            csr_address_out <= csr_address;
            csr_readable_out <= csr_readable;
            csr_writeable_out <= csr_writeable;
            alu_function_out <= ALU_OR;
            alu_function_modifier_out <= 0;
            alu_select_a_out <= ALU_SEL_IMM;
            alu_select_b_out <= ALU_SEL_IMM;
            write_select_out <= WRITE_SEL_ALU;
            branch_out <= 0;
            load_out <= 0;
            store_out <= 0;
            rd_address_out <= 0;
            csr_read_out <= 0;
            csr_write_out <= 0;
            mret_out <= 0;
            wfi_out <= 0;
            ecause_out <= 0;
            exception_out <= 0;
            valid_out <= 1;
            case (instr[6:0])
                7'b0110111 : begin // LUI
                    imm_data_out <= u_type_imm_data;
                    rd_address_out <= rd_address;
                end
                7'b0010111 : begin // AUIPC
                    alu_function_out <= ALU_ADD_SUB;
                    alu_select_a_out <= ALU_SEL_PC;
                    imm_data_out <= u_type_imm_data;
                    rd_address_out <= rd_address;
                end
                7'b1101111 : begin // JAL
                    alu_function_out <= ALU_ADD_SUB;
                    alu_select_a_out <= ALU_SEL_PC;
                    imm_data_out <= j_type_imm_data;
                    write_select_out <= WRITE_SEL_NEXT_PC;
                    branch_out <= 1;
                    jump_out <= 1;
                    rd_address_out <= rd_address;
                end
                7'b1100111 : begin // JALR
                    alu_function_out <= ALU_ADD_SUB;
                    alu_select_a_out <= ALU_SEL_REG;
                    imm_data_out <= i_type_imm_data;
                    write_select_out <= WRITE_SEL_NEXT_PC;
                    branch_out <= 1;
                    jump_out <= 1;
                    rd_address_out <= rd_address;
                    if (instr[14:12] != 0) begin
                        ecause_out <= 2;
                        exception_out <= 1;
                    end
                end
                7'b1100011 : begin // Branch
                    alu_function_out <= ALU_ADD_SUB;
                    alu_select_a_out <= ALU_SEL_PC;
                    imm_data_out <= b_type_imm_data;
                    branch_out <= 1;
                    cmp_function_out <= instr[14:12];
                    if (instr[14:13] == 2'b01) begin
                        ecause_out <= 2;
                        exception_out <= 1;
                    end
                end
                7'b0000011 : begin // LOAD
                    alu_function_out <= ALU_ADD_SUB;
                    alu_select_a_out <= ALU_SEL_REG;
                    imm_data_out <= i_type_imm_data;
                    write_select_out <= WRITE_SEL_LOAD;
                    load_out <= 1;
                    rd_address_out <= rd_address;
                    load_store_size_out <= instr[13:12];
                    load_signed_out <= !instr[14];
                    if (instr[13:12] == 2'b11 || (instr[14] && instr[13:12] == 2'b10)) begin
                        ecause_out <= 2;
                        exception_out <= 1;
                    end
                end
                7'b0100011 : begin // STORE
                    alu_function_out <= ALU_ADD_SUB;
                    alu_select_a_out <= ALU_SEL_REG;
                    imm_data_out <= s_type_imm_data;
                    store_out <= 1;
                    load_store_size_out <= instr[13:12];
                    if (instr[13:12] == 2'b11 || instr[14]) begin
                        ecause_out <= 2;
                        exception_out <= 1;
                    end
                end
                7'b0010011 : begin // OP-IMM
                    alu_function_out <= instr[14:12];
                    alu_function_modifier_out <= (instr[14:12] == 3'b101 && instr[30]);
                    alu_select_a_out <= ALU_SEL_REG;
                    imm_data_out <= i_type_imm_data;
                    write_select_out <= WRITE_SEL_ALU;
                    rd_address_out <= rd_address;
                end
                7'b0110011 : begin // OP
                    alu_function_out <= instr[14:12];
                    alu_function_modifier_out <= instr[30];
                    alu_select_a_out <= ALU_SEL_REG;
                    alu_select_b_out <= ALU_SEL_REG;
                    write_select_out <= WRITE_SEL_ALU;
                    rd_address_out <= rd_address;
                    if (instr[31:25] != 0 && (instr[31:25] != 7'b0100000 || (instr[14:12] != 0 && instr[14:12] != 3'b101))) begin
                        ecause_out <= 2;
                        exception_out <= 1;
                    end
                end
                7'b0001111 : begin // FENCE
                    if (instr[14:12] != 0) begin
                        ecause_out <= 2;
                        exception_out <= 1;
                    end
                end
                7'b1110011 : begin // SYSTEM
                    case (instr[14:12])
                        3'b000: begin // PRIV
                            case (instr[24:20])
                                5'b00000: begin // ECALL
                                    ecause_out <= 11;
                                    exception_out <= 1;
                                    if (instr[31:25] != 0 || instr[19:15] != 0 || instr[11:7] != 0) begin
                                        ecause_out <= 2;
                                    end
                                end
                                5'b00001: begin // EBREAK
                                    ecause_out <= 3;
                                    exception_out <= 1;
                                    if (instr[31:25] != 0 || instr[19:15] != 0 || instr[11:7] != 0) begin
                                        ecause_out <= 2;
                                    end
                                end
                                5'b00010: begin // MRET
                                    mret_out <= 1;
                                    if (instr[31:25] != 7'b0011000 || instr[19:15] != 0 || instr[11:7] != 0) begin
                                        ecause_out <= 2;
                                        exception_out <= 1;
                                    end
                                end
                                5'b00101: begin // WFI
                                    wfi_out <= 1;
                                    if (instr[31:25] != 7'b0001000 || instr[19:15] != 0 || instr[11:7] != 0) begin
                                        ecause_out <= 2;
                                        exception_out <= 1;
                                    end
                                end
                                default: begin
                                    ecause_out <= 2;
                                    exception_out <= 1;
                                end
                            endcase
                        end
                        3'b001: begin // CSRRW
                            rd_address_out <= rd_address;
                            alu_select_a_out <= ALU_SEL_REG;
                            csr_read_out <= (rd_address != 0);
                            csr_write_out <= 1;
                            write_select_out <= WRITE_SEL_CSR;
                        end
                        3'b010: begin // CSRRS
                            rd_address_out <= rd_address;
                            alu_select_a_out <= ALU_SEL_REG;
                            alu_select_b_out <= ALU_SEL_CSR;
                            csr_read_out <= 1;
                            csr_write_out <= (rs1_address != 0);
                            write_select_out <= WRITE_SEL_CSR;
                        end
                        3'b011: begin // CSRRC
                            rd_address_out <= rd_address;
                            alu_function_out <= ALU_AND_CLR;
                            alu_function_modifier_out <= 1;
                            alu_select_a_out <= ALU_SEL_REG;
                            alu_select_b_out <= ALU_SEL_CSR;
                            csr_read_out <= 1;
                            csr_write_out <= (rs1_address != 0);
                            write_select_out <= WRITE_SEL_CSR;
                        end
                        3'b101: begin // CSRRWI
                            rd_address_out <= rd_address;
                            imm_data_out <= csr_type_imm_data;
                            csr_read_out <= (rd_address != 0);
                            csr_write_out <= 1;
                            write_select_out <= WRITE_SEL_CSR;
                        end
                        3'b110: begin // CSRRSI
                            rd_address_out <= rd_address;
                            alu_select_b_out <= ALU_SEL_CSR;
                            imm_data_out <= csr_type_imm_data;
                            csr_read_out <= 1;
                            csr_write_out <= (rs1_address != 0);
                            write_select_out <= WRITE_SEL_CSR;
                        end
                        3'b111: begin // CSRRCI
                            rd_address_out <= rd_address;
                            alu_function_out <= ALU_AND_CLR;
                            alu_function_modifier_out <= 1;
                            alu_select_b_out <= ALU_SEL_CSR;
                            imm_data_out <= csr_type_imm_data;
                            csr_read_out <= 1;
                            csr_write_out <= (rs1_address != 0);
                            write_select_out <= WRITE_SEL_CSR;
                        end
                        default: begin
                            ecause_out <= 2;
                            exception_out <= 1;
                        end
                    endcase
                end
                default : begin
                    ecause_out <= 2;
                    exception_out <= 1;
                end
            endcase
        end
    end
end

endmodule

