module RegFile #(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR  = 4
) (
    input  wire             CLK,
    input  wire             RST,
    input  wire             WrEn,
    input  wire             RdEn,
    input  wire [ADDR-1:0]  Address,
    input  wire [WIDTH-1:0] WrData, 
    output reg  [WIDTH-1:0] RdData,
    output reg              RdData_Valid,
    output wire [WIDTH-1:0] REG0,
    output wire [WIDTH-1:0] REG1,
    output wire [WIDTH-1:0] REG2,
    output wire [WIDTH-1:0] REG3
);

    reg [WIDTH-1:0] regArr [DEPTH-1:0];
    integer i;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            // Single clean assignment loop for all registers
            for (i = 0; i < DEPTH; i = i + 1) begin
                if (i == 2)
                    regArr[2] <= 8'b1000_0001; // Default UART Config
                else if (i == 3)
                    regArr[3] <= 8'b0010_0000; // Default Div Ratio
                else
                    regArr[i] <= {WIDTH{1'b0}};
            end

            RdData       <= {WIDTH{1'b0}};
            RdData_Valid <= 1'b0;
        end
        else if (RdEn && !WrEn) begin
            RdData       <= regArr[Address];
            RdData_Valid <= 1'b1;
        end
        else if (!RdEn && WrEn) begin
            regArr[Address] <= WrData;
            RdData_Valid    <= 1'b0; // FIX: Explicitly deassert valid on write
        end
        else begin
            RdData_Valid    <= 1'b0; // Clear valid when idle or during collision
        end
    end

    // Continuous assignment for configuration registers
    assign REG0 = regArr[0];
    assign REG1 = regArr[1];
    assign REG2 = regArr[2];
    assign REG3 = regArr[3];

endmodule