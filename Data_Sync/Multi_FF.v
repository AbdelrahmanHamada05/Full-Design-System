module Multi_FF #(
    parameter NUM_STAGES = 2
)(
    input wire CLK, RST,
    input wire async_data,
    output wire sync_data
);

reg [NUM_STAGES-1:0] sync_reg;
integer i;

always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        sync_reg <= {NUM_STAGES{1'b0}};
    end
    else begin
        sync_reg[0] <= async_data;
        for(i = 1; i < NUM_STAGES; i = i + 1) begin
            sync_reg[i] <= sync_reg[i - 1];
        end
    end
end

assign sync_data = sync_reg[NUM_STAGES - 1];

endmodule