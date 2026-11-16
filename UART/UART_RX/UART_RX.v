module UART_RX #(parameter DATA_WIDTH = 8)(
    input  wire                   CLK,          // RX_CLK = baud rate * Prescale
    input  wire                   RST,          // active low
    input  wire [5:0]             Prescale,     // supported: 8, 16, 32
    input  wire                   PAR_EN,
    input  wire                   PAR_TYP,
    input  wire                   RX_IN,
    output wire [DATA_WIDTH-1:0]  P_DATA,
    output wire                   data_valid,
    output wire                   par_err,
    output wire                   stp_err
);

// 2-FF synchronizer for the asynchronous serial input
reg rx_m, rx_s;
always @(posedge CLK or negedge RST) begin
    if (!RST) begin rx_m <= 1'b1; rx_s <= 1'b1; end
    else      begin rx_m <= RX_IN; rx_s <= rx_m; end
end

wire [3:0] bit_cnt;
wire [4:0] edge_cnt;
wire       edge_bit_en, dat_samp_en, par_chk_en, stp_chk_en, strt_chk_en, deser_en;
wire       strt_glitch, sampled_bit;

RX_FSM u_fsm (
    .CLK(CLK), .RST(RST), .RX_IN(rx_s), .PAR_EN(PAR_EN),
    .bit_cnt(bit_cnt), .edge_cnt(edge_cnt),
    .par_err(par_err), .stp_err(stp_err), .strt_glitch(strt_glitch),
    .prescale(Prescale),
    .edge_bit_en(edge_bit_en), .dat_samp_en(dat_samp_en),
    .par_check_en(par_chk_en), .stp_check_en(stp_chk_en),
    .strt_check_en(strt_chk_en), .deser_en(deser_en), .data_valid(data_valid)
);

edge_bit_counter u_cnt (
    .CLK(CLK), .RST(RST), .enable(edge_bit_en), .prescale(Prescale),
    .bit_cnt(bit_cnt), .edge_cnt(edge_cnt)
);

data_sampling u_samp (
    .CLK(CLK), .RST(RST), .RX_IN(rx_s), .dat_samp_en(dat_samp_en),
    .prescale(Prescale), .edge_cnt(edge_cnt), .sampled_bit(sampled_bit)
);

deserializer #(.DATA_WIDTH(DATA_WIDTH)) u_deser (
    .CLK(CLK), .RST(RST), .sampled_bit(sampled_bit), .Enable(deser_en),
    .edge_count(edge_cnt), .Prescale(Prescale), .P_DATA(P_DATA)
);

strt_check u_strt (
    .CLK(CLK), .RST(RST), .strt_chk_en(strt_chk_en), .sampled_bit(sampled_bit),
    .prescale(Prescale), .edge_cnt(edge_cnt), .strt_glitch(strt_glitch)
);

par_check #(.DATA_WIDTH(DATA_WIDTH)) u_par (
    .CLK(CLK), .RST(RST), .strt_chk_en(strt_chk_en), .par_chk_en(par_chk_en),
    .PAR_TYP(PAR_TYP), .sampled_bit(sampled_bit), .P_DATA(P_DATA),
    .prescale(Prescale), .edge_cnt(edge_cnt), .par_err(par_err)
);

stp_check u_stp (
    .CLK(CLK), .RST(RST), .strt_chk_en(strt_chk_en), .stp_chk_en(stp_chk_en),
    .sampled_bit(sampled_bit), .prescale(Prescale), .edge_cnt(edge_cnt),
    .stp_err(stp_err)
);

endmodule
