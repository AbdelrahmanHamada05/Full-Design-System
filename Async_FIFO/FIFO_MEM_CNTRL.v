//==============================================================================
// FIFO_MEM_CNTRL : dual-port FIFO buffer (write on W_CLK, asynchronous read)
//==============================================================================
module FIFO_MEM_CNTRL #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3                    // depth = 2**ADDR_WIDTH
)(
    input  wire                   W_CLK,
    input  wire                   W_CLKEN,      // winc & ~wfull
    input  wire [ADDR_WIDTH-1:0]  waddr,
    input  wire [ADDR_WIDTH-1:0]  raddr,
    input  wire [DATA_WIDTH-1:0]  wdata,
    output wire [DATA_WIDTH-1:0]  rdata
);

localparam DEPTH = 1 << ADDR_WIDTH;

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

// the word at the read pointer is always visible on rdata
assign rdata = mem[raddr];

always @(posedge W_CLK) begin
    if (W_CLKEN)
        mem[waddr] <= wdata;
end

endmodule
