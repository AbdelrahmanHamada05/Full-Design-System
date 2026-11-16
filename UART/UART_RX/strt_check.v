// start bit must be 0; strt_glitch = 1 when the sampled start bit is not 0
module strt_check (
    input  wire       CLK,
    input  wire       RST,
    input  wire       strt_chk_en,
    input  wire       sampled_bit,
    input  wire [5:0] prescale,
    input  wire [4:0] edge_cnt,
    output reg        strt_glitch
);

always @(posedge CLK or negedge RST) begin
    if (!RST)
        strt_glitch <= 1'b0;
    else if (strt_chk_en) begin
        if (edge_cnt == prescale - 6'd2) strt_glitch <= sampled_bit;
    end
    else
        strt_glitch <= 1'b0;
end

endmodule
