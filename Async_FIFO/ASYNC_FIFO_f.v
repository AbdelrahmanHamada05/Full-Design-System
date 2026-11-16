//==============================================================================
// ASYNC_FIFO : top module
//   depth = 2**ADDR_WIDTH (default 8, see the depth calculation in the TB)
//==============================================================================
module ASYNC_FIFO_f #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
)(
    input  wire                   W_CLK,
    input  wire                   W_RST,        // active low, async
    input  wire                   W_INC,
    input  wire                   R_CLK,
    input  wire                   R_RST,        // active low, async
    input  wire                   R_INC,
    input  wire [DATA_WIDTH-1:0]  WR_DATA,
    output wire [DATA_WIDTH-1:0]  RD_DATA,
    output wire                   FULL,
    output wire                   EMPTY
);

wire [ADDR_WIDTH-1:0] waddr, raddr;
wire [ADDR_WIDTH:0]   wptr, rptr, wq2_rptr, rq2_wptr;

FIFO_MEM_CNTRL #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) u_mem (
    .W_CLK   (W_CLK),
    .W_CLKEN (W_INC & ~FULL),
    .waddr   (waddr),
    .raddr   (raddr),
    .wdata   (WR_DATA),
    .rdata   (RD_DATA)
);

FIFO_WR #(.ADDR_WIDTH(ADDR_WIDTH)) u_wr (
    .W_CLK    (W_CLK),
    .W_RST    (W_RST),
    .W_INC    (W_INC),
    .wq2_rptr (wq2_rptr),
    .waddr    (waddr),
    .wptr     (wptr),
    .wfull    (FULL)
);

FIFO_RD #(.ADDR_WIDTH(ADDR_WIDTH)) u_rd (
    .R_CLK    (R_CLK),
    .R_RST    (R_RST),
    .R_INC    (R_INC),
    .rq2_wptr (rq2_wptr),
    .raddr    (raddr),
    .rptr     (rptr),
    .rempty   (EMPTY)
);

// read pointer -> write domain
DF_SYNC #(.WIDTH(ADDR_WIDTH+1)) sync_r2w (
    .CLK (W_CLK), .RST (W_RST), .D (rptr), .Q (wq2_rptr)
);

// write pointer -> read domain
DF_SYNC #(.WIDTH(ADDR_WIDTH+1)) sync_w2r (
    .CLK (R_CLK), .RST (R_RST), .D (wptr), .Q (rq2_wptr)
);

endmodule
