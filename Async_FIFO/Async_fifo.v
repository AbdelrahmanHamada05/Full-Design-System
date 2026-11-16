// Wrapper with the port names used by SYS_TOP (pointer width P_SIZE = address bits + 1)
module Async_fifo #(
    parameter D_SIZE  = 8,
    parameter P_SIZE  = 4,          // pointer width
    parameter F_DEPTH = 8           // depth = 2**(P_SIZE-1)
)(
    input  wire              i_w_clk,
    input  wire              i_w_rstn,
    input  wire              i_w_inc,
    input  wire [D_SIZE-1:0] i_w_data,
    input  wire              i_r_clk,
    input  wire              i_r_rstn,
    input  wire              i_r_inc,
    output wire [D_SIZE-1:0] o_r_data,
    output wire              o_full,
    output wire              o_empty
);

ASYNC_FIFO_f #(.DATA_WIDTH(D_SIZE), .ADDR_WIDTH(P_SIZE-1)) u_fifo (
    .W_CLK   (i_w_clk),
    .W_RST   (i_w_rstn),
    .W_INC   (i_w_inc),
    .R_CLK   (i_r_clk),
    .R_RST   (i_r_rstn),
    .R_INC   (i_r_inc),
    .WR_DATA (i_w_data),
    .RD_DATA (o_r_data),
    .FULL    (o_full),
    .EMPTY   (o_empty)
);

endmodule
