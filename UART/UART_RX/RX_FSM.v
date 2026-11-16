module RX_FSM (
    input  wire        CLK,
    input  wire        RST,
    input  wire        RX_IN,          // should already be synchronized (2-FF)
    input  wire        PAR_EN,
    input  wire [3:0]  bit_cnt,
    input  wire [4:0]  edge_cnt,
    input  wire        par_err,
    input  wire        stp_err,
    input  wire        strt_glitch,
    input  wire [5:0]  prescale,

    output reg         edge_bit_en,
    output reg         dat_samp_en,
    output reg         par_check_en,
    output reg         stp_check_en,
    output reg         strt_check_en,
    output reg         deser_en,
    output reg         data_valid
);

/* State Encoding (5 states) */
localparam  IDLE   = 3'd0,
            START  = 3'd1,
            DATA   = 3'd2,
            PARITY = 3'd3,
            STOP   = 3'd4;

reg [2:0] current_state, next_state;

/* End of the current bit period, and one cycle before it */
wire last_edge = (edge_cnt == prescale - 6'd1);
wire pre_edge  = (edge_cnt == prescale - 6'd2);

/* Stop bit is finished one cycle early (bit_cnt 9 without parity, 10 with) */
wire stop_exit = pre_edge && (PAR_EN ? (bit_cnt == 4'd10) : (bit_cnt == 4'd9));

/* State Transition */
always @(posedge CLK or negedge RST) begin
    if (!RST)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

/* Next State Logic */
always @(*) begin
    case (current_state)
        IDLE: begin
            if (!RX_IN) next_state = START;
            else        next_state = IDLE;
        end
        START: begin
            if (last_edge && bit_cnt == 4'd0) begin
                if (strt_glitch) next_state = IDLE;   // false start bit
                else             next_state = DATA;
            end
            else next_state = START;
        end
        DATA: begin
            if (last_edge && bit_cnt == 4'd8)
                next_state = PAR_EN ? PARITY : STOP;
            else
                next_state = DATA;
        end
        PARITY: begin
            if (last_edge && bit_cnt == 4'd9) next_state = STOP;
            else                              next_state = PARITY;
        end
        STOP: begin
            // Leave one cycle before the stop bit ends. IDLE then spends the
            // last cycle of the stop bit with edge_bit_en = 0, which clears the
            // counters, and moves to START as soon as RX_IN is low.
            if (stop_exit) next_state = IDLE;
            else           next_state = STOP;
        end
        default: next_state = IDLE;
    endcase
end

/* Output Logic (Moore) */
always @(*) begin
    strt_check_en = 1'b0;
    par_check_en  = 1'b0;
    stp_check_en  = 1'b0;
    dat_samp_en   = 1'b0;
    edge_bit_en   = 1'b0;
    deser_en      = 1'b0;

    case (current_state)
        IDLE: begin
        end
        START: begin
            strt_check_en = 1'b1;
            dat_samp_en   = 1'b1;
            edge_bit_en   = 1'b1;
        end
        DATA: begin
            dat_samp_en   = 1'b1;
            edge_bit_en   = 1'b1;
            deser_en      = 1'b1;   // deserializer shifts at edge_cnt == prescale-1
        end
        PARITY: begin
            par_check_en  = 1'b1;
            dat_samp_en   = 1'b1;
            edge_bit_en   = 1'b1;
        end
        STOP: begin
            stp_check_en  = 1'b1;
            dat_samp_en   = 1'b1;
            edge_bit_en   = 1'b1;
        end
        default: begin
        end
    endcase
end

/* data_valid: one-cycle registered pulse.
   stop_done_d is high in the cycle after STOP is left (the error flags are
   read then); data_valid follows one cycle later. */
reg stop_done_d;

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        stop_done_d <= 1'b0;
        data_valid  <= 1'b0;
    end
    else begin
        stop_done_d <= (current_state == STOP) && stop_exit;
        data_valid  <= stop_done_d && (!PAR_EN || !par_err) && !stp_err;
    end
end

endmodule
