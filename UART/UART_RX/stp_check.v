// stop error flag: stop bit must be 1
module stp_check (
    input  wire       CLK,
    input  wire       RST,
    input  wire       strt_chk_en,
    input  wire       stp_chk_en,
    input  wire       sampled_bit,
    input  wire [5:0] prescale,
    input  wire [4:0] edge_cnt,
    output reg        stp_err
);

always @(posedge CLK or negedge RST) begin
    if (!RST)
        stp_err <= 1'b0;
    else if (strt_chk_en)
        stp_err <= 1'b0;
    else if (stp_chk_en && (edge_cnt == prescale - 6'd2))
        stp_err <= ~sampled_bit;
end

endmodule
