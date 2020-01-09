`define FROM_EXE 2'b01

module Bubble(
    input wire MemRead_MEM,//mem段的MemRead信号
    input wire MemWrite_MEM,//mem段的MemWrite信号
    output reg [4:0] Bub_keep,//要保存的信号�?5位对�?5个流水线寄存�?
    output reg [4:0] Bub_clear,//要清理的信号
    input wire MemRead_EXE,
    input wire [1:0] ForwardRs,
    input wire [1:0] ForwardRt
    );

    always @(*) begin
        if (MemRead_EXE==1 && (ForwardRs==`FROM_EXE || ForwardRt==`FROM_EXE)) begin
            Bub_keep = 5'b11000;
            Bub_clear = 5'b00100;
        end else if((MemRead_MEM | MemWrite_MEM ) == 1'b1) begin
            Bub_keep = 5'b11000;
            Bub_clear = 5'b00100;
        end else begin
            Bub_keep = 5'b00000;
            Bub_clear = 5'b00000;
        end
    end
endmodule