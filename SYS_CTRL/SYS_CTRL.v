//==============================================================================
// SYS_CTRL  (REF_CLK domain)
//   Decodes the command frames coming from UART_RX (through Data_Sync) and
//   drives the RegFile, the ALU (with its clock gate) and the TX ASYNC_FIFO.
//
//   Command frames (Frame 0 first):
//     RF write          : 0xAA, Address, Data                  -> no response
//     RF read           : 0xBB, Address                        -> 1 frame
//     ALU with operands : 0xCC, Operand A, Operand B, ALU_FUN  -> 2 frames
//     ALU no operands   : 0xDD, ALU_FUN                        -> 2 frames
//   ALU result is sent LSB first (ALU_OUT[7:0], then ALU_OUT[15:8]).
//   Operand A / B are written to RegFile addresses 0x0 / 0x1.
//==============================================================================
module SYS_CTRL (
    input  wire        CLK,
    input  wire        RST,             // active low (RST_SYNC_1)

    // ALU
    input  wire [15:0] ALU_OUT,
    input  wire        ALU_OUT_Valid,
    output reg  [3:0]  ALU_FUN,
    output reg         ALU_EN,
    output reg         CLKG_EN,          // clock gate enable

    // RegFile
    output reg  [3:0]  Address,
    output reg         WrEn,
    output reg         RdEn,
    output reg  [7:0]  WrData,
    input  wire [7:0]  RdData,
    input  wire        RdData_Valid,

    // UART_RX (through Data_Sync)
    input  wire [7:0]  RX_P_DATA,
    input  wire        RX_D_VLD,

    // UART_TX (through ASYNC_FIFO)
    output reg  [7:0]  TX_P_DATA,       // -> FIFO WR_DATA
    output reg         TX_D_VLD,        // -> FIFO W_INC
    input  wire        FIFO_FULL,

    // Clock divider (always on)
    output wire        clk_div_en
);

assign clk_div_en = 1'b1;

/* Command codes */
localparam [7:0] RF_WR_CMD      = 8'hAA,
                 RF_RD_CMD      = 8'hBB,
                 ALU_W_OP_CMD   = 8'hCC,
                 ALU_W_NOP_CMD  = 8'hDD;

/* States */
localparam [3:0] IDLE      = 4'd0,
                 WR_ADDR   = 4'd1,    // wait for RF write address
                 WR_DATA   = 4'd2,    // wait for RF write data, then write
                 RD_ADDR   = 4'd3,    // wait for RF read address, then read
                 RD_WAIT   = 4'd4,    // wait for RdData_Valid
                 RD_PUSH   = 4'd5,    // push the read byte to the FIFO
                 ALU_A     = 4'd6,    // operand A -> REG0
                 ALU_B     = 4'd7,    // operand B -> REG1
                 ALU_FUNC  = 4'd8,    // wait for ALU function frame
                 ALU_EXEC  = 4'd9,    // run the ALU, wait for ALU_OUT_Valid
                 ALU_PUSH0 = 4'd10,   // push ALU_OUT[7:0]
                 ALU_PUSH1 = 4'd11;   // push ALU_OUT[15:8]

reg [3:0]  current_state, next_state;

reg [3:0]  addr_reg;
reg [3:0]  fun_reg;
reg [7:0]  rd_reg;
reg [15:0] alu_res;

/* State + data registers */
always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        current_state <= IDLE;
        addr_reg      <= 4'd0;
        fun_reg       <= 4'd0;
        rd_reg        <= 8'd0;
        alu_res       <= 16'd0;
    end
    else begin
        current_state <= next_state;

        case (current_state)
            WR_ADDR:  if (RX_D_VLD)      addr_reg <= RX_P_DATA[3:0];
            ALU_FUNC: if (RX_D_VLD)      fun_reg  <= RX_P_DATA[3:0];
            RD_WAIT:  if (RdData_Valid)  rd_reg   <= RdData;
            ALU_EXEC: if (ALU_OUT_Valid)     alu_res  <= ALU_OUT;
            default: ;
        endcase
    end
end

/* Next state + outputs */
always @(*) begin
    next_state = current_state;
    ALU_FUN    = fun_reg;
    ALU_EN      = 1'b0;
    CLKG_EN     = 1'b0;
    Address    = addr_reg;
    WrEn       = 1'b0;
    RdEn       = 1'b0;
    WrData     = RX_P_DATA;
    TX_P_DATA  = 8'd0;
    TX_D_VLD   = 1'b0;

    case (current_state)
        IDLE: begin
            if (RX_D_VLD) begin
                case (RX_P_DATA)
                    RF_WR_CMD:     next_state = WR_ADDR;
                    RF_RD_CMD:     next_state = RD_ADDR;
                    ALU_W_OP_CMD:  next_state = ALU_A;
                    ALU_W_NOP_CMD: next_state = ALU_FUNC;
                    default:       next_state = IDLE;     // unknown command: ignore
                endcase
            end
        end

        /* ---------------- Register file write ---------------- */
        WR_ADDR: begin
            if (RX_D_VLD) next_state = WR_DATA;
        end
        WR_DATA: begin
            Address = addr_reg;
            WrData  = RX_P_DATA;
            if (RX_D_VLD) begin
                WrEn       = 1'b1;
                next_state = IDLE;
            end
        end

        /* ---------------- Register file read ---------------- */
        RD_ADDR: begin
            Address = RX_P_DATA[3:0];
            if (RX_D_VLD) begin
                RdEn       = 1'b1;
                next_state = RD_WAIT;
            end
        end
        RD_WAIT: begin
            if (RdData_Valid) next_state = RD_PUSH;
        end
        RD_PUSH: begin
            TX_P_DATA = rd_reg;
            if (!FIFO_FULL) begin
                TX_D_VLD   = 1'b1;
                next_state = IDLE;
            end
        end

        /* ---------------- ALU operation ---------------- */
        // CLKG_EN stays high from the first operand frame until the result has
        // been pushed, so the gated clock is running before EN rises and
        // keeps running while EN is low (the ALU clears OUT_VALID).
        ALU_A: begin
            CLKG_EN  = 1'b1;
            Address = 4'd0;
            WrData  = RX_P_DATA;
            if (RX_D_VLD) begin
                WrEn       = 1'b1;
                next_state = ALU_B;
            end
        end
        ALU_B: begin
            CLKG_EN  = 1'b1;
            Address = 4'd1;
            WrData  = RX_P_DATA;
            if (RX_D_VLD) begin
                WrEn       = 1'b1;
                next_state = ALU_FUNC;
            end
        end
        ALU_FUNC: begin
            CLKG_EN = 1'b1;
            if (RX_D_VLD) next_state = ALU_EXEC;
        end
        ALU_EXEC: begin
            CLKG_EN = 1'b1;
            ALU_EN = 1'b1;
            if (ALU_OUT_Valid) next_state = ALU_PUSH0;
        end
        ALU_PUSH0: begin
            CLKG_EN    = 1'b1;
            TX_P_DATA = alu_res[7:0];
            if (!FIFO_FULL) begin
                TX_D_VLD   = 1'b1;
                next_state = ALU_PUSH1;
            end
        end
        ALU_PUSH1: begin
            CLKG_EN    = 1'b1;
            TX_P_DATA = alu_res[15:8];
            if (!FIFO_FULL) begin
                TX_D_VLD   = 1'b1;
                next_state = IDLE;
            end
        end

        default: next_state = IDLE;
    endcase
end

endmodule