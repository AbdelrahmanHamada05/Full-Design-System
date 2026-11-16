module FF(
    input wire CLK,
    input wire RST,
    input wire IN_FF,
    output reg OUT
);

always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        OUT <= 1'b0;
    end
    else begin
        OUT <= IN_FF;
    end
end

endmodule