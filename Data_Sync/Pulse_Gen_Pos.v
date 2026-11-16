module Pulse_Gen_Pos(
    input wire CLK, 
    input wire RST,
    input wire lvl_sig,
    output wire pulse_sig
);

reg rcv_sig;

always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        rcv_sig <= 0;
    end
    else begin
        rcv_sig <= lvl_sig;
    end
end

assign pulse_sig = lvl_sig & ~rcv_sig;

endmodule