// Integer clock divider (even and odd ratios). Ratio 0 or 1 passes the clock through.
module Clock_Divider #(parameter RATIO_WIDTH = 8)(
    input  wire                   i_ref_clk,
    input  wire                   i_rst_n,       // active low, async
    input  wire                   i_clk_en,
    input  wire [RATIO_WIDTH-1:0] i_div_ratio,
    output wire                   o_div_clk
);

reg  [RATIO_WIDTH-1:0] count;
reg                    div_clk;

wire                     bypass = (i_div_ratio == {RATIO_WIDTH{1'b0}}) ||
                                  (i_div_ratio == {{(RATIO_WIDTH-1){1'b0}}, 1'b1});
wire                     is_odd = i_div_ratio[0];
wire [RATIO_WIDTH-1:0]   half   = i_div_ratio >> 1;        // floor(N/2)

// even N : toggle every N/2 cycles
// odd  N : high for (N-1)/2 cycles, low for (N+1)/2 cycles
wire toggle = is_odd ? (div_clk ? (count == half - 1) : (count == half))
                     : (count == half - 1);

always @(posedge i_ref_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        count   <= {RATIO_WIDTH{1'b0}};
        div_clk <= 1'b0;
    end
    else if (!i_clk_en || bypass) begin
        count   <= {RATIO_WIDTH{1'b0}};
        div_clk <= 1'b0;
    end
    else if (toggle) begin
        count   <= {RATIO_WIDTH{1'b0}};
        div_clk <= ~div_clk;
    end
    else
        count   <= count + 1'b1;
end

assign o_div_clk = !i_clk_en ? 1'b0 : (bypass ? i_ref_clk : div_clk);

endmodule
