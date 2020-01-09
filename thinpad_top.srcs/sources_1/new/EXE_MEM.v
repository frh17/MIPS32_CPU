`default_nettype wire

module EXE_MEM(
    input clk,
    input reset,
    input clear,
    input keep,
    input [31:0] inResult,
    input [31:0] inRegRt,
    input [4:0] inRegWriteNode,
    input [3:0] inMemControl,
    input inRegWrite,
    output reg [31:0] outResult,
    output reg [31:0] outRegRt,
    output reg [4:0] outRegWriteNode,
    output reg [3:0] outMemControl,
    output reg outRegWrite
    );

    always @(posedge clk or posedge reset) begin
        if (reset == 1 || clear == 1) begin
            outResult <= 0;
            outRegRt <= 0;
            outRegWriteNode <= 0;
            outMemControl <= 0;
            outRegWrite <= 0;
        end else if (keep == 1) begin
            outResult <= outResult;
            outRegRt <= outRegRt;
            outRegWriteNode <= outRegWriteNode;
            outMemControl <= outMemControl;
            outRegWrite <= outRegWrite;
        end else begin
            outResult <= inResult;
            outRegRt <= inRegRt;
            outRegWriteNode <= inRegWriteNode;
            outMemControl <= inMemControl;
            outRegWrite <= inRegWrite;
        end
    end
endmodule


