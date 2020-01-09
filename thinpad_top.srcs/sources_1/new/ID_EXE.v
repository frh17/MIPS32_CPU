`default_nettype wire

module ID_EXE(
    input reset,
    input clk,
    input keep,
    input clear,
    input [4:0] inRegWriteNode,
    input [31:0] inRegRt,
    input [31:0] inDataA,
    input [31:0] inDataB,
    input [3:0] inMemControl,
    input [3:0] inALUop,
    input inRegWrite,
    output reg [4:0] outRegWriteNode,
    output reg [31:0] outRegRt,
    output reg [31:0] outDataA,
    output reg [31:0] outDataB,
    output reg [3:0] outMemControl,
    output reg [3:0] outALUop,
    output reg outRegWrite
    );

    always @(posedge clk or posedge reset) begin
        if (reset == 1 || clear == 1) begin
            outRegWriteNode <= 0;
            outRegRt <= 0;
            outDataA <= 0;
            outDataB <= 0;
            outMemControl <= 0;
            outALUop <= 0;
            outRegWrite <= 0;
        end else if (keep == 1) begin
            outRegWriteNode <= outRegWriteNode;
            outRegRt <= outRegRt;
            outDataA <= outDataA;
            outDataB <= outDataB;
            outMemControl <= outMemControl;
            outALUop <= outALUop;
            outRegWrite <= outRegWrite;
        end else begin
            outRegWriteNode <= inRegWriteNode;
            outRegRt <= inRegRt;
            outDataA <= inDataA;
            outDataB <= inDataB;
            outMemControl <= inMemControl;
            outALUop <= inALUop;
            outRegWrite <= inRegWrite;
        end
    end
endmodule

