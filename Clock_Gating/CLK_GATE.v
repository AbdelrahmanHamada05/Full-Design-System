// Latch based clock gate (glitch free)
module CLK_GATE (
    input  wire CLK_EN,
    input  wire CLK,
    output wire GATED_CLK
);

reg en_latch;

// latch is transparent while CLK is low
always @(CLK or CLK_EN) begin
    if (!CLK) en_latch = CLK_EN;
end

assign GATED_CLK = CLK & en_latch;

endmodule
