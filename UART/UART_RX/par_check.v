// parity error flag: set at the end of the parity bit, held until the next frame starts
module par_check #(parameter DATA_WIDTH = 8)(
    input  wire                  CLK,
    input  wire                  RST,
    input  wire                  strt_chk_en,    // high at the start of every frame (clears the flag)
    input  wire                  par_chk_en,
    input  wire                  PAR_TYP,
    input  wire                  sampled_bit,
    input  wire [DATA_WIDTH-1:0] P_DATA,
    input  wire [5:0]            prescale,
    input  wire [4:0]            edge_cnt,
    output reg                   par_err
);

wire expected = PAR_TYP ? ~(^P_DATA) : (^P_DATA);

always @(posedge CLK or negedge RST) begin
    if (!RST)
        par_err <= 1'b0;
    else if (strt_chk_en)
        par_err <= 1'b0;
    else if (par_chk_en && (edge_cnt == prescale - 6'd2))
        par_err <= (expected != sampled_bit);
end

endmodule
