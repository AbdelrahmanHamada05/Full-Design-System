module UART_TX #(parameter DATA_WIDTH = 8)(
    input  wire                  CLK,           // TX_CLK (one cycle per bit)
    input  wire                  RST,           // active low
    input  wire                  PAR_EN,
    input  wire                  PAR_TYP,
    input  wire [DATA_WIDTH-1:0] P_DATA,
    input  wire                  DATA_VALID,
    output reg                   TX_OUT,
    output wire                  Busy
);

wire        serial_en, serial_done, ser_out, par_bit;
wire [1:0]  MUX_sel;
wire [DATA_WIDTH-1:0] data_reg;
reg         mux_out;

TX_FSM u_fsm (
    .CLK(CLK), .RST(RST),
    .serial_done(serial_done), .PAR_EN(PAR_EN), .DATA_VALID(DATA_VALID),
    .serial_en(serial_en), .MUX_sel(MUX_sel), .BUSY(Busy)
);

serializer #(.DATA_WIDTH(DATA_WIDTH)) u_ser (
    .CLK(CLK), .RST(RST),
    .P_DATA(P_DATA), .load(DATA_VALID & ~Busy), .serial_en(serial_en),
    .ser_out(ser_out), .serial_done(serial_done), .data_reg(data_reg)
);

parity_calc #(.DATA_WIDTH(DATA_WIDTH)) u_par (
    .data(data_reg), .PAR_TYP(PAR_TYP), .par_bit(par_bit)
);

always @(*) begin
    case (MUX_sel)
        2'b00:   mux_out = 1'b0;        // start bit
        2'b01:   mux_out = ser_out;     // data bit
        2'b10:   mux_out = par_bit;     // parity bit
        default: mux_out = 1'b1;        // stop bit / idle
    endcase
end

// registered output: glitch free TX line
always @(posedge CLK or negedge RST) begin
    if (!RST) TX_OUT <= 1'b1;
    else      TX_OUT <= mux_out;
end

endmodule
