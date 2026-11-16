module Data_Sync #(
    parameter NUM_STAGES = 2,
    parameter BUS_WIDTH = 8
)(
    input wire CLK,
    input wire RST,
    input wire [BUS_WIDTH-1:0] unsync_bus,
    input wire bus_enable,

    output wire enable_pulse,
    output wire [BUS_WIDTH-1:0] sync_bus
);

wire MFF_OUT;
wire pulse_sig;

Multi_FF #(.NUM_STAGES(NUM_STAGES)) u_Multi_FF (
    .CLK(CLK),
    .RST(RST),
    .async_data(bus_enable),
    .sync_data(MFF_OUT)
);

Pulse_Gen_Pos u_Pulse_Gen (
    .CLK(CLK),
    .RST(RST),
    .lvl_sig(MFF_OUT),
    .pulse_sig(pulse_sig)
);

FF u_FF(
    .CLK(CLK),
    .RST(RST),
    .IN_FF(pulse_sig),
    .OUT(enable_pulse)    
);

MUX_21_REG #(.BUS_WIDTH(BUS_WIDTH)) u_MUX_21_REG (
    .CLK(CLK),
    .RST(RST),
    .MUX_IN(unsync_bus),
    .sel(pulse_sig),
    .REG_OUT(sync_bus)
);

endmodule