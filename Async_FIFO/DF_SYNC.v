//==============================================================================
// DF_SYNC : double flop synchronizer (bus of gray-coded pointers)
//==============================================================================
module DF_SYNC #(parameter WIDTH = 4)(
    input  wire             CLK,        // destination clock
    input  wire             RST,        // active low, async
    input  wire [WIDTH-1:0] D,          // asynchronous input
    output reg  [WIDTH-1:0] Q           // synchronized output
);

reg [WIDTH-1:0] meta;

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        meta <= {WIDTH{1'b0}};
        Q    <= {WIDTH{1'b0}};
    end
    else begin
        meta <= D;
        Q    <= meta;
    end
end

endmodule
