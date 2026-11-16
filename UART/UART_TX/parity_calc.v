// PAR_TYP = 0 : even parity, PAR_TYP = 1 : odd parity
module parity_calc #(parameter DATA_WIDTH = 8)(
    input  wire [DATA_WIDTH-1:0] data,
    input  wire                  PAR_TYP,
    output wire                  par_bit
);

assign par_bit = PAR_TYP ? ~(^data) : (^data);

endmodule
