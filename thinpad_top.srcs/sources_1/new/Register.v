`default_nettype wire

module Register(
    input clk,
    input reset,
    input [4:0] RegRead1,
    input [4:0] RegRead2,
    input [4:0] RegWrite,
    input [31:0] DataWrite,
    input WriteEnable,
    output [31:0] DataRead1,
    output [31:0] DataRead2
    );

    reg [31:0] register[31:0];
    integer i;

    always @(posedge reset or posedge clk)
    begin
        if (reset) begin
            for (i = 0; i < 32; i=i+1) begin
                register[i] = 0;
            end
        end
        else if (WriteEnable && (RegWrite != 0)) begin
            register[RegWrite] = DataWrite;
        end
    end

    assign DataRead1 = (RegRead1 == 0) ? 32'b0 : register[RegRead1];
    assign DataRead2 = (RegRead2 == 0) ? 32'b0 : register[RegRead2];

endmodule
