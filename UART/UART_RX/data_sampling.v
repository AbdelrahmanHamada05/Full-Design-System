// Majority vote of three samples taken around the middle of the bit
module data_sampling (
    input  wire       CLK,
    input  wire       RST,
    input  wire       RX_IN,            // already synchronized
    input  wire       dat_samp_en,
    input  wire [5:0] prescale,
    input  wire [4:0] edge_cnt,
    output reg        sampled_bit
);

reg s0, s1, s2;
wire [5:0] half = prescale >> 1;

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        s0 <= 1'b1; s1 <= 1'b1; s2 <= 1'b1;
        sampled_bit <= 1'b1;
    end
    else if (dat_samp_en) begin
        if      (edge_cnt == half - 6'd2) s0 <= RX_IN;
        else if (edge_cnt == half - 6'd1) s1 <= RX_IN;
        else if (edge_cnt == half)        s2 <= RX_IN;

        sampled_bit <= (s0 & s1) | (s1 & s2) | (s0 & s2);
    end
end

endmodule
