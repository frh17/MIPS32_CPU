`default_nettype wire

`define EQUAL       3'b001
// greater than zero
`define GTZ_A       3'b010
`define NOT_EQUAL   3'b011
`define NOT_ZERO_B  3'b100


module Compare(
    input [2:0] CompareOp,
    input [31:0] dataA,
    input [31:0] dataB,
    output reg success
    );

    always @(*) begin
        case(CompareOp)
            `EQUAL: success = (dataA == dataB) ? 1 : 0;
            `NOT_EQUAL: success = (dataA != dataB) ? 1 : 0;
            `GTZ_A: success = (dataA > 0) ? 1 : 0;
            `NOT_ZERO_B: success = (dataB != 0) ? 1 : 0;
            default: success = 0;
        endcase
    end
    
endmodule