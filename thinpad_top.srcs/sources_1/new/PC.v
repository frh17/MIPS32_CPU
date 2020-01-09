`default_nettype wire

`define START 32'h80000000

module PC(
    input clk,
    input reset,
    input isJump,
    input isTrueBranch,
    input [31:0] AddrJump,
    input [31:0] AddrBranch,
    input keep,
    input clear,
    output reg [31:0] outPC
    );

    reg [31:0] prePC;

    always @(*) begin
        if (isTrueBranch == 1) begin
            prePC = AddrBranch;
        end else if (isJump == 1) begin
            prePC = AddrJump;
        end else begin
            prePC = outPC + 4;
        end
    end

    always @(posedge reset or posedge clk) begin
        if (reset == 1) begin
            outPC = `START;
        end else if (keep == 1) begin
            outPC = outPC;
        end else begin
            outPC = prePC;
        end
    end
endmodule
