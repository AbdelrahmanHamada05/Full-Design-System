// Rising-edge pulse generator
module Pulse_Gen (
    input  wire CLK,
    input  wire RST,            // active low
    input  wire lvl_sig,
    output wire pulse_sig
);

reg lvl_q;

always @(posedge CLK or negedge RST) begin
    if (!RST) lvl_q <= 1'b0;
    else      lvl_q <= lvl_sig;
end

assign pulse_sig = lvl_sig & ~lvl_q;

endmodule
