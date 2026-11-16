//==============================================================================
// FIFO_WR : write address, gray write pointer and FULL flag (W_CLK domain)
//==============================================================================
module FIFO_WR #(parameter ADDR_WIDTH = 3)(
    input  wire                   W_CLK,
    input  wire                   W_RST,        // active low, async
    input  wire                   W_INC,
    input  wire [ADDR_WIDTH:0]    wq2_rptr,     // read pointer (gray) synced to W_CLK
    output wire [ADDR_WIDTH-1:0]  waddr,
    output reg  [ADDR_WIDTH:0]    wptr,         // write pointer (gray)
    output reg                    wfull
);

reg  [ADDR_WIDTH:0] wbin;
wire [ADDR_WIDTH:0] wbin_next  = wbin + (W_INC & ~wfull);
wire [ADDR_WIDTH:0] wgray_next = (wbin_next >> 1) ^ wbin_next;

// full: MSBs differ, remaining bits equal (gray code)
wire wfull_val = (wgray_next == {~wq2_rptr[ADDR_WIDTH:ADDR_WIDTH-1],
                                  wq2_rptr[ADDR_WIDTH-2:0]});

assign waddr = wbin[ADDR_WIDTH-1:0];

always @(posedge W_CLK or negedge W_RST) begin
    if (!W_RST) begin
        wbin  <= {(ADDR_WIDTH+1){1'b0}};
        wptr  <= {(ADDR_WIDTH+1){1'b0}};
        wfull <= 1'b0;
    end
    else begin
        wbin  <= wbin_next;
        wptr  <= wgray_next;
        wfull <= wfull_val;
    end
end

endmodule
