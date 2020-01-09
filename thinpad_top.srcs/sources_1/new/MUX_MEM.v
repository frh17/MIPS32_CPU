`default_nettype wire

module MUX_MEM(
    input MemRead,
    input [31:0] ALUout,
    input [31:0] DMout,
    output reg [31:0] data
    );

    always @(*) begin
        if (MemRead == 1) data = DMout;
        else data = ALUout;
    end

endmodule