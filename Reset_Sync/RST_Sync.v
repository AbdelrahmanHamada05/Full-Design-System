// Reset synchronizer: asynchronous assertion, synchronous de-assertion
module RST_Sync #(parameter NUM_STAGES = 2)(
    input  wire RST,        // active low, asynchronous
    input  wire CLK,
    output wire SYNC_RST    // active low, synchronized
);

reg [NUM_STAGES-1:0] sync_reg;

always @(posedge CLK or negedge RST) begin
    if (!RST)
        sync_reg <= {NUM_STAGES{1'b0}};
    else
        sync_reg <= {sync_reg[NUM_STAGES-2:0], 1'b1};
end

assign SYNC_RST = sync_reg[NUM_STAGES-1];

endmodule
