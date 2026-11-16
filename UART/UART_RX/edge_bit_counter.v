// edge_cnt counts RX_CLK cycles inside a bit (0 .. prescale-1)
// bit_cnt counts finished bits of the frame; both clear while enable = 0
module edge_bit_counter (
    input  wire       CLK,
    input  wire       RST,
    input  wire       enable,
    input  wire [5:0] prescale,
    output reg  [3:0] bit_cnt,
    output reg  [4:0] edge_cnt
);

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        bit_cnt  <= 4'd0;
        edge_cnt <= 5'd0;
    end
    else if (enable) begin
        if (edge_cnt == prescale - 6'd1) begin
            edge_cnt <= 5'd0;
            bit_cnt  <= bit_cnt + 4'd1;
        end
        else
            edge_cnt <= edge_cnt + 5'd1;
    end
    else begin
        bit_cnt  <= 4'd0;
        edge_cnt <= 5'd0;
    end
end

endmodule
