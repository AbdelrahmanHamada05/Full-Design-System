// Latches the parallel word when a frame starts and shifts it out LSB first
module serializer #(parameter DATA_WIDTH = 8)(
    input  wire                  CLK,
    input  wire                  RST,
    input  wire [DATA_WIDTH-1:0] P_DATA,
    input  wire                  load,          // DATA_VALID & ~BUSY
    input  wire                  serial_en,
    output wire                  ser_out,
    output wire                  serial_done,
    output reg  [DATA_WIDTH-1:0] data_reg
);

reg [2:0] count;

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        data_reg <= {DATA_WIDTH{1'b0}};
        count    <= 3'd0;
    end
    else begin
        if (load) data_reg <= P_DATA;

        if (serial_en) count <= count + 3'd1;
        else           count <= 3'd0;
    end
end

assign ser_out     = data_reg[count];
assign serial_done = serial_en && (count == DATA_WIDTH-1);

endmodule
