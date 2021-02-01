module decode (
    input clk,
    input valid_in,
    input [31:0] instr,
    input [31:0] pc_in,
    input [31:0] next_pc_in,
    input stall,

    output [4:0] rs1_select,
    output [4:0] rs2_select,
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    
    output [11:0] csr_select,
    input [31:0] csr_data,
    input csr_readable,
    input csr_writeable,

    output reg [31:0] pc_out,
    output reg [31:0] next_pc_out,
    output reg [31:0] data_rs1,
    output reg [31:0] data_rs2,
    output reg [31:0] data_csr,
    output reg [31:0] data_imm,
    output reg [5:0] data_uimm,
    
    output reg [5:0] rd_addr,
    output reg [11:0] csr_addr,

    output reg [2:0] alu_func,
    output reg alu_func_sel,
    output reg [1:0] alu_a_select,
    output reg [1:0] alu_b_select,
    output reg [1:0] write_select,
    output reg cmp_less,
    output reg cmp_sign,
    output reg cmp_negate,
    output reg jump,
    output reg branch,
    output reg load,
    output reg [1:0] load_store_size,
    output reg load_signed,
    output reg store,
    output reg read_csr,
    output reg write_csr,
    output reg readable_csr,
    output reg writeable_csr,
    output reg valid_out,
    
    output reg [3:0] ecause,
    output reg exception,
);

localparam ALU_ADD_SUB = 3'b000;
localparam ALU_SLL     = 3'b001;
localparam ALU_SLT     = 3'b010;
localparam ALU_SLTU    = 3'b011;
localparam ALU_XOR     = 3'b100;
localparam ALU_SRL_SRA = 3'b101;
localparam ALU_OR      = 3'b110;
localparam ALU_AND_CLR = 3'b111;

localparam ALU_SEL_REG    = 2'b00;
localparam ALU_SEL_IMM    = 2'b01;
localparam ALU_SEL_PC_CSR = 2'b10;
localparam ALU_SEL_ZERO   = 2'b11;

localparam WRITE_SEL_ALU     = 2'b00;
localparam WRITE_SEL_CSR     = 2'b01;
localparam WRITE_SEL_LOAD    = 2'b10;
localparam WRITE_SEL_NEXT_PC = 2'b11;

assign rs1_select = instr[19:15];
assign rs2_select = instr[24:20];
assign csr_select = instr[31:20];

always @(posedge clk) begin
    if (!stall && valid_in) begin
        pc_out <= pc_in;
        next_pc_out <= next_pc_in;
        data_rs1 <= rs1_data;
        data_rs2 <= rs2_data;
        data_csr <= csr_data;
        data_uimm <= instr[19:15];
        case (instr[6:0])
            7'b0010111,
            7'b0110111 : data_imm <= {instr[31:12], 12'b0}; // U-type
            7'b1101111 : data_imm <= {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type
            7'b1100111,
            7'b0000011,
            7'b0010011 : data_imm <= {{20{instr[31]}}, instr[31:20]}; // I-type
            7'b0100011 : data_imm <= {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
            7'b0100011 : data_imm <= {{19{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
        endcase
        
        csr_addr <= instr[31:20];

        readable_csr <= csr_readable;
        writeable_csr <= csr_writeable;

        case (instr[6:0])
            7'b0110111 : begin // LUI
                alu_func <= ALU_OR;
                alu_a_select <= ALU_SEL_ZERO;
                alu_b_select <= ALU_SEL_IMM;
                write_select <= WRITE_SEL_ALU;
                branch <= 1'b0;
                load <= 1'b0;
                store <= 1'b0;
                rd_addr <= instr[11:7];
                read_csr <= 1'b0;
                write_csr <= 1'b0;
                exception <= 1'b0;
            end
            7'b0110111 : begin // AUIPC
                alu_func <= ALU_ADD_SUB;
                alu_func_sel <= 1'b0;
                alu_a_select <= ALU_SEL_PC_CSR;
                alu_b_select <= ALU_SEL_IMM;
                write_select <= WRITE_SEL_ALU;
                branch <= 1'b0;
                load <= 1'b0;
                store <= 1'b0;
                rd_addr <= instr[11:7];
                read_csr <= 1'b0;
                write_csr <= 1'b0;
                exception <= 1'b0;
            end
            7'b0110111 : begin // JAL
                alu_func <= ALU_ADD_SUB;
                alu_func_sel <= 1'b0;
                alu_a_select <= ALU_SEL_PC_CSR;
                alu_b_select <= ALU_SEL_IMM;
                write_select <= WRITE_SEL_NEXT_PC;
                branch <= 1'b1;
                jump <= 1'b1;
                load <= 1'b0;
                store <= 1'b0;
                rd_addr <= instr[11:7];
                read_csr <= 1'b0;
                write_csr <= 1'b0;
                exception <= 1'b0;
            end
            7'b1100111 : begin // JALR
                alu_func <= ALU_ADD_SUB;
                alu_func_sel <= 1'b0;
                alu_a_select <= ALU_SEL_REG;
                alu_b_select <= ALU_SEL_IMM;
                write_select <= WRITE_SEL_NEXT_PC;
                branch <= 1'b1;
                jump <= 1'b1;
                load <= 1'b0;
                store <= 1'b0;
                rd_addr <= instr[11:7];
                read_csr <= 1'b0;
                write_csr <= 1'b0;
                ecause <= 2;
                exception <= (instr[14:12] != 3'b000);
            end
            7'b1100011 : begin // Branch
                alu_func <= ALU_ADD_SUB;
                alu_func_sel <= 1'b0;
                alu_a_select <= ALU_SEL_PC_CSR;
                alu_b_select <= ALU_SEL_IMM;
                branch <= 1'b1;
                jump <= 1'b0;
                load <= 1'b0;
                store <= 1'b0;
                rd_addr <= 5'b00000;
                read_csr <= 1'b0;
                write_csr <= 1'b0;
                cmp_less <= instr[14];
                cmp_sign <= instr[13];
                cmp_negate <= instr[12];
                ecause <= 2;
                exception <= (instr[14:13] == 2'b01);
            end
            7'b0000011 : begin // LOAD
                alu_func <= ALU_ADD_SUB;
                alu_func_sel <= 1'b0;
                alu_a_select <= ALU_SEL_REG;
                alu_b_select <= ALU_SEL_IMM;
                write_select <= WRITE_SEL_LOAD;
                branch <= 1'b0;
                load <= 1'b1;
                store <= 1'b0;
                rd_addr <= instr[11:7];
                read_csr <= 1'b0;
                write_csr <= 1'b0;
                load_store_size <= instr[13:12];
                load_signed <= !instr[14];
                ecause <= 2;
                exception <= (instr[13:12] == 2'b11 || (instr[14] && instr[13:12] == 2'b10));
            end
            7'b0100011 : begin // STORE
                alu_func <= ALU_ADD_SUB;
                alu_func_sel <= 1'b0;
                alu_a_select <= ALU_SEL_REG;
                alu_b_select <= ALU_SEL_IMM;
                branch <= 1'b0;
                load <= 1'b0;
                store <= 1'b1;
                rd_addr <= 5'b00000;
                read_csr <= 1'b0;
                write_csr <= 1'b0;
                load_store_size <= instr[13:12];
                ecause <= 2;
                exception <= (instr[13:12] == 2'b11 || instr[14]);
            end
            7'b0010011 : begin // OP-IMM
                alu_func <= instr[14:12];
                alu_func_sel <= (instr[14:12] == 3'b101 && instr[30]);
                alu_a_select <= ALU_SEL_REG;
                alu_b_select <= ALU_SEL_IMM;
                write_select <= WRITE_SEL_ALU;
                branch <= 1'b0;
                load <= 1'b0;
                store <= 1'b0;
                rd_addr <= instr[11:7];
                read_csr <= 1'b0;
                write_csr <= 1'b0;
                exception <= 1'b0;
            end
            7'b0110011 : begin // OP
                alu_func <= instr[14:12];
                alu_func_sel <= instr[30];
                alu_a_select <= ALU_SEL_REG;
                alu_b_select <= ALU_SEL_REG;
                write_select <= WRITE_SEL_ALU;
                branch <= 1'b0;
                load <= 1'b0;
                store <= 1'b0;
                rd_addr <= instr[11:7];
                read_csr <= 1'b0;
                write_csr <= 1'b0;
                ecause <= 2;
                exception <= (instr[31:25] != 0 && (instr[31:25] != 7'b0100000 || (instr[14:12] != 3'b000 && instr[14:12] != 3'b101)));
            end
            7'b0001111 : begin // FENCE
                branch <= 1'b0;
                load <= 1'b0;
                store <= 1'b0;
                rd_addr <= 5'b00000;
                read_csr <= 1'b0;
                write_csr <= 1'b0;
                exception <= 1'b0;
                ecause <= 2;
                exception <= (instr[14:12] != 3'b000);
            end
            7'b1110011 : begin // SYSTEM
                case (instr[14:12])
                    3'b000: begin // ECALL / EBREAK
                        rd_addr <= 5'b00000;
                        read_csr <= 1'b0;
                        write_csr <= 1'b0;
                        ecause <= (instr[31:21] != 11'b00000000000 || instr[19:12] != 8'b00000000) ? 2 : (instr[20] ? 3 : 11);
                        exception <= 1'b1;
                    end
                    3'b001: begin // CSRRW
                        rd_addr <= instr[11:7];
                        alu_func <= ALU_OR;
                        alu_a_select <= ALU_SEL_REG;
                        alu_b_select <= ALU_SEL_ZERO;
                        read_csr <= (instr[11:7] != 0);
                        write_csr <= 1'b1;
                        exception <= 1'b0;
                    end
                    3'b001: begin // CSRRS
                        rd_addr <= instr[11:7];
                        alu_func <= ALU_OR;
                        alu_a_select <= ALU_SEL_REG;
                        alu_b_select <= ALU_SEL_PC_CSR;
                        read_csr <= 1'b1;
                        write_csr <= (instr[19:15] != 0);
                        exception <= 1'b0;
                    end
                    3'b001: begin // CSRRC
                        rd_addr <= instr[11:7];
                        alu_func <= ALU_AND_CLR;
                        alu_func_sel <= 1'b1;
                        alu_a_select <= ALU_SEL_REG;
                        alu_b_select <= ALU_SEL_PC_CSR;
                        read_csr <= 1'b1;
                        write_csr <= (instr[19:15] != 0);
                        exception <= 1'b0;
                    end
                    3'b001: begin // CSRRWI
                        rd_addr <= instr[11:7];
                        alu_func <= ALU_OR;
                        alu_a_select <= ALU_SEL_IMM;
                        alu_b_select <= ALU_SEL_ZERO;
                        read_csr <= (instr[11:7] != 0);
                        write_csr <= 1'b1;
                        exception <= 1'b0;
                    end
                    3'b001: begin // CSRRSI
                        rd_addr <= instr[11:7];
                        alu_func <= ALU_OR;
                        alu_a_select <= ALU_SEL_IMM;
                        alu_b_select <= ALU_SEL_PC_CSR;
                        read_csr <= 1'b1;
                        write_csr <= (instr[19:15] != 0);
                        exception <= 1'b0;
                    end
                    3'b001: begin // CSRRCI
                        rd_addr <= instr[11:7];
                        alu_func <= ALU_AND_CLR;
                        alu_func_sel <= 1'b1;
                        alu_a_select <= ALU_SEL_IMM;
                        alu_b_select <= ALU_SEL_PC_CSR;
                        read_csr <= 1'b1;
                        write_csr <= (instr[19:15] != 0);
                        exception <= 1'b0;
                    end
                    default: begin
                        ecause <= 2;
                        exception <= 1'b1;
                    end
                endcase
                branch <= 1'b0;
                load <= 1'b0;
                store <= 1'b0;
            end
            default : begin
                ecause <= 2;
                exception <= 1'b1;
            end
        endcase
        
        valid_out <= valid_in;
    end else begin
        valid_out <= 1'b0;
    end
end

endmodule