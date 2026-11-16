module TX_FSM (
    input  wire       CLK,
    input  wire       RST,
    input  wire       serial_done,
    input  wire       PAR_EN,
    input  wire       DATA_VALID,

    output reg        serial_en,
    output reg  [1:0] MUX_sel,
    output reg        BUSY
);

/* State Encoding */
localparam  IDLE   = 3'd0,
            START  = 3'd1,
            DATA   = 3'd2,
            PARITY = 3'd3,
            STOP   = 3'd4;

reg [2:0] current_state, next_state;

/* State Transition */
always @(posedge CLK or negedge RST) begin
    if (!RST) current_state <= IDLE;
    else      current_state <= next_state;
end

/* Next State Logic & Output Logic */
always @(*) begin
    case (current_state)
        IDLE: begin
            serial_en = 0;
            BUSY      = 0;
            MUX_sel   = 2'b11;
            if (DATA_VALID) next_state = START;
            else            next_state = IDLE;
        end
        START: begin
            serial_en  = 0;
            BUSY       = 1;
            MUX_sel    = 2'b00;
            next_state = DATA;
        end
        DATA: begin
            serial_en = 1;
            BUSY      = 1;
            MUX_sel   = 2'b01;
            if (serial_done) begin
                if (PAR_EN) next_state = PARITY;
                else        next_state = STOP;
            end
            else next_state = DATA;
        end
        PARITY: begin
            serial_en  = 0;
            BUSY       = 1;
            MUX_sel    = 2'b10;
            next_state = STOP;
        end
        STOP: begin
            serial_en  = 0;
            BUSY       = 1;
            MUX_sel    = 2'b11;
            next_state = IDLE;
        end
        default: begin
            serial_en  = 0;
            BUSY       = 0;
            MUX_sel    = 2'b11;
            next_state = IDLE;
        end
    endcase
end

endmodule
