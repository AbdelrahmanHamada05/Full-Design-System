module CLKDIV_MUX #(
    parameter WIDTH = 8
) (
    input  wire [5:0]       IN,
    output reg  [WIDTH-1:0] OUT
);

always @(*) begin
    case (IN)
        6'd8:    OUT = 8'd4;
        6'd16:   OUT = 8'd2;
        6'd32:   OUT = 8'd1;
        default: OUT = 8'd1;
    endcase
end

endmodule