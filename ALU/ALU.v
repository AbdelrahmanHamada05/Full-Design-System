// ALU: registered result, OUT_VALID is high while EN is high
module ALU #(
    parameter OPER_WIDTH = 8,
    parameter OUT_WIDTH  = 16
)(
    input  wire                   CLK,
    input  wire                   RST,          // active low
    input  wire [OPER_WIDTH-1:0]  A,
    input  wire [OPER_WIDTH-1:0]  B,
    input  wire [3:0]             ALU_FUN,
    input  wire                   EN,
    output reg  [OUT_WIDTH-1:0]   ALU_OUT,
    output reg                    OUT_VALID
);

wire [OPER_WIDTH-1:0] and_r  = A & B;
wire [OPER_WIDTH-1:0] or_r   = A | B;
wire [OPER_WIDTH-1:0] nand_r = ~(A & B);
wire [OPER_WIDTH-1:0] nor_r  = ~(A | B);
wire [OPER_WIDTH-1:0] xor_r  = A ^ B;
wire [OPER_WIDTH-1:0] xnor_r = ~(A ^ B);

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        ALU_OUT   <= {OUT_WIDTH{1'b0}};
        OUT_VALID <= 1'b0;
    end
    else if (EN) begin
        OUT_VALID <= 1'b1;
        case (ALU_FUN)
            4'b0000: ALU_OUT <= A + B;
            4'b0001: ALU_OUT <= A - B;
            4'b0010: ALU_OUT <= A * B;
            4'b0011: ALU_OUT <= (B == 0) ? {OUT_WIDTH{1'b0}} : A / B;
            4'b0100: ALU_OUT <= and_r;
            4'b0101: ALU_OUT <= or_r;
            4'b0110: ALU_OUT <= nand_r;
            4'b0111: ALU_OUT <= nor_r;
            4'b1000: ALU_OUT <= xor_r;
            4'b1001: ALU_OUT <= xnor_r;
            4'b1010: ALU_OUT <= (A == B) ? 16'd1 : 16'd0;     // CMP: A = B
            4'b1011: ALU_OUT <= (A >  B) ? 16'd2 : 16'd0;     // CMP: A > B
            4'b1100: ALU_OUT <= A >> 1;                       // SHIFT: A >> 1
            4'b1101: ALU_OUT <= {{(OUT_WIDTH-OPER_WIDTH){1'b0}}, A} << 1;  // SHIFT: A << 1
            default: ALU_OUT <= {OUT_WIDTH{1'b0}};
        endcase
    end
    else begin
        ALU_OUT   <= {OUT_WIDTH{1'b0}};
        OUT_VALID <= 1'b0;
    end
end

endmodule
