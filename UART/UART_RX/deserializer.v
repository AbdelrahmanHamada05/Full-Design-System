module deserializer #(parameter DATA_WIDTH = 8)(
    input  wire                    CLK,
    input  wire                    RST,
    input  wire                    sampled_bit,
    input  wire                    Enable,
    input  wire [4:0]              edge_count,
    input  wire [5:0]              Prescale,

    output reg  [DATA_WIDTH-1:0]   P_DATA
);

// one-cycle strobe at the end of each bit period
wire sample_point = (edge_count == Prescale - 6'd1);

// Shift register: first bit received (LSB) ends up in P_DATA[0]
// after DATA_WIDTH shifts.
always @(posedge CLK or negedge RST) begin
    if (!RST)
        P_DATA <= {DATA_WIDTH{1'b0}};
    else if (Enable && sample_point)
        P_DATA <= {sampled_bit, P_DATA[DATA_WIDTH-1:1]};
end

endmodule
