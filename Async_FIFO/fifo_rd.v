//==============================================================================
// FIFO_RD : read address, gray read pointer and EMPTY flag (R_CLK domain)
//==============================================================================
module FIFO_RD #(parameter ADDR_WIDTH = 3)(
    input  wire                   R_CLK,
    input  wire                   R_RST,        // active low, async
    input  wire                   R_INC,
    input  wire [ADDR_WIDTH:0]    rq2_wptr,     // write pointer (gray) synced to R_CLK
    output wire [ADDR_WIDTH-1:0]  raddr,
    output reg  [ADDR_WIDTH:0]    rptr,         // read pointer (gray)
    output reg                    rempty
);

reg  [ADDR_WIDTH:0] rbin;
wire [ADDR_WIDTH:0] rbin_next  = rbin + (R_INC & ~rempty);
wire [ADDR_WIDTH:0] rgray_next = (rbin_next >> 1) ^ rbin_next;

// empty: next read pointer equals the synchronized write pointer
wire rempty_val = (rgray_next == rq2_wptr);

assign raddr = rbin[ADDR_WIDTH-1:0];

always @(posedge R_CLK or negedge R_RST) begin
    if (!R_RST) begin
        rbin   <= {(ADDR_WIDTH+1){1'b0}};
        rptr   <= {(ADDR_WIDTH+1){1'b0}};
        rempty <= 1'b1;
    end
    else begin
        rbin   <= rbin_next;
        rptr   <= rgray_next;
        rempty <= rempty_val;
    end
end

endmodule
