module MUX_21_REG #(
    parameter BUS_WIDTH = 8
)(
    input wire CLK,
    input wire RST,
    input wire [BUS_WIDTH-1:0] MUX_IN,
    input wire sel,
    output reg [BUS_WIDTH-1:0] REG_OUT
);

always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        REG_OUT <= {BUS_WIDTH{1'b0}};
    end
    else begin
        REG_OUT <= sel? MUX_IN : REG_OUT;
    end
end

endmodule