`default_nettype wire


module IF_ID(
    input clk,
    input reset,
    input [31:0] inPC,
    input [31:0] inInstruction,
    input keep,
    input clear,
    output reg [31:0] outInstruction,
    output reg [31:0] outPC
    );

    always @(posedge clk or posedge reset) begin
        if (reset == 1 || clear == 1) begin
            outPC <= 0;
            outInstruction <= 0;
        end else if (keep == 1) begin
            outPC <= outPC;
            outInstruction <= outInstruction;
        end else begin
            outInstruction <= inInstruction;
            outPC <= inPC + 4;
        end
    end
endmodule