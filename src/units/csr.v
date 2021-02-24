module csr (
    input clk,
    // from decode (read port)
    input [11:0] read_address,
    // to decode (read port)
    output reg [31:0] read_data,
    output reg readable,
    output reg writeable,

    // from writeback (write port)
    input write_enable,
    input [11:0] write_address,
    input [31:0] write_data,
    
    // from writeback
    input retired,
    input traped,
    input mret,
    input [31:0] ecp,

    // to writeback
    output eip,
    output tip,
    output sip,

    // to fetch
    output [31:0] trap_vector,
    output [31:0] mret_vector,
);

reg [63:0] cycle;
reg [63:0] instret;
reg [31:0] mstatus;
reg pie;
reg ie;
reg [2:0] mie;
reg [2:0] mip;
reg [31:2] mtvec;
reg [31:0] mscratch;
reg [31:0] mecp;
reg [4:0] mcause;

assign eip = ie && mie[2] && mip[2];
assign tip = ie && mie[1] && mip[1];
assign sip = ie && mie[0] && mip[0];

assign trap_vector = mtvec;
assign mret_vector = mecp;

always @(*) begin
    casez (read_address)
        12'hc00, 12'hc01: begin // cycle, time
            read_data = cycle[31:0];
            readable = 1;
            writeable = 0;
        end
        12'hc02: begin // instret
            read_data = instret[31:0];
            readable = 1;
            writeable = 0;
        end
        12'hc80, 12'hc81: begin // cycleh, timeh
            read_data = cycle[63:32];
            readable = 1;
            writeable = 0;
        end
        12'hc82: begin // instreth
            read_data = instret[63:32];
            readable = 1;
            writeable = 0;
        end
        12'hc0?, 12'hc1?, 12'hc8?, 12'hc9?: begin // hpmcounterX, hpmcounterXh
            read_data = 0;
            readable = 1;
            writeable = 0;
        end
        12'hf11, 12'hf12, 12'hf13, 12'hf14: begin // mvendorid, marchid, mimpid, mhartid
            read_data = 0;
            readable = 1;
            writeable = 0;
        end
        12'h300: begin // mstatus
            //             SD  WPRI   TSR    TW   TVM   MXR   SUM  MPRV    XS    FS   MPP  WPRI   SPP MPIE  WPRI  SPIE  UPIE MIE  WPRI   SIE   UIE
            read_data = {1'b0, 8'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0, 2'b0, 2'b0, 2'b0, 1'b0, pie, 1'b0, 1'b0, 1'b0, ie, 1'b0, 1'b0, 1'b0};
            readable = 1;
            writeable = 1;
        end
        12'h301: begin // misa
            //            MXL  WLRL      ZYXWVUTSRQPONMLKJIHGFEDCBA
            read_data = {2'b0, 4'b0, 26'b00000000000000000100000000};
            readable = 1;
            writeable = 1;
        end
        12'h302: begin // medeleg
            read_data = ;
            readable = 1;
            writeable = 1;
        end
        12'h303: begin // mideleg
            read_data = ;
            readable = 1;
            writeable = 1;
        end
        12'h304: begin // mie
            read_data = ;
            readable = 1;
            writeable = 1;
        end
        12'h305: begin // mtvec
            read_data = ;
            readable = 1;
            writeable = 1;
        end
        12'h306: begin // mcounteren
            read_data = ;
            readable = 1;
            writeable = 1;
        end
        12'h340: begin // mscratch
            read_data = ;
            readable = 1;
            writeable = 1;
        end
        12'h341: begin // mepc
            read_data = ;
            readable = 1;
            writeable = 1;
        end
        12'h342: begin // mcause
            read_data = ;
            readable = 1;
            writeable = 1;
        end
        12'h343: begin // mtval
            read_data = ;
            readable = 1;
            writeable = 1;
        end
        12'h344: begin // mip
            read_data = ;
            readable = 1;
            writeable = 1;
        end
        12'hb00, 12'hb01: begin // mcycle, time
            read_data = cycle[31:0];
            readable = 1;
            writeable = 0;
        end
        12'hb02: begin // minstret
            read_data = instret[31:0];
            readable = 1;
            writeable = 0;
        end
        12'hb0?, 12'hb1?: begin // mhpmcounterX
            read_data = 0;
            readable = 1;
            writeable = 0;
        end
        12'hb80, 12'hb81: begin // mcycleh, mtimeh
            read_data = cycle[63:32];
            readable = 1;
            writeable = 0;
        end
        12'hb82: begin // minstreth
            read_data = instret[63:32];
            readable = 1;
            writeable = 0;
        end
        12'hb8?, 12'hb9?: begin // mhpmcounterXh
            read_data = 0;
            readable = 1;
            writeable = 0;
        end
        12'h320: begin // mcountinhibit
            read_data = ;
            readable = 1;
            writeable = 0;
        end
        12'h32?, 12'h33?: begin // mhpmeventX
            read_data = ;
            readable = 1;
            writeable = 0;
        end
        default: begin
            read_data = 0;
            readable = 0;
            writeable = 0;
        end
    endcase
end

always @(posedge clk) begin
    if (write_enable) begin
        
    end
end

always @(posedge clk) begin
    if (traped) begin
        pie = ie;
        ie = 0;
    end else if (mret) begin
        ie = pie;
        pie = 1;
    end
    cycle = cycle + 1;
    if (retired) begin
        instret = instret + 1;
    end
end

endmodule