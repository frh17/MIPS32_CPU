`default_nettype wire

module MEM_WB(
    input clk,
    input reset,
    input keep,
    input clear,
    input [31:0] inResult,
    input [4:0] inRegWriteNode,
    input inRegWrite,
    output reg [31:0] outResult,
    output reg [4:0] outRegWriteNode,
    output reg outRegWrite
    );

    always @(posedge clk or posedge reset) begin
        if (reset == 1 || clear == 1) begin
            outResult <= 0;
            outRegWriteNode <= 0;
            outRegWrite <= 0;
        end else if (keep == 1) begin
            outResult <= outResult;
            outRegWrite <= outRegWrite;
            outRegWriteNode <= outRegWriteNode;
        end else begin
            outResult <= inResult;
            outRegWrite <= inRegWrite;
            outRegWriteNode <= inRegWriteNode;
        end
    end
endmodule
