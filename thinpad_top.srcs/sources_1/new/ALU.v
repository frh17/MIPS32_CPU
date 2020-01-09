`define ADDU_ALU    4'b0000
`define AND_ALU     4'b0001
`define OR_ALU      4'b0010
`define XOR_ALU     4'b0011
`define SLL_ALU     4'b0100
`define SRL_ALU     4'b0101
`define CLZ_ALU     4'b0110
`define LUI_ALU     4'b0111
// PC + 4
`define PCADD_ALU   4'b1000
// for movn out=op1
`define MOVN_ALU    4'b1001
// for null out=0
`define NULL_ALU    4'b1010
`define LWPC_ALU    4'b1111



module ALU(
    input wire [31:0] ALU_A,//ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿?????1
    input wire [31:0] ALU_B,//ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿?????2
    input wire [3:0] ALUop,//ï¿½ï¿½ï¿½ï¿½ï¿½Åºï¿½
    output reg [31:0] ALU_result//ï¿½ï¿½ï¿?????
    );
    wire [31:0] lwpc_offset;
    reg [5:0] clz_result;//ï¿½ï¿½Â¼clzÇ°ï¿½ï¿½0ï¿½ï¿½ï¿½ï¿½,ï¿½ï¿½ï¿?????6Î»
    assign lwpc_offset = {{11{ALU_B[18]}}, ALU_B[18:0], 2'b00};
    always @(*) begin
        case(ALUop)
            `ADDU_ALU: ALU_result = ALU_A + ALU_B; //0
            `AND_ALU: ALU_result = ALU_A & ALU_B; //1
            `OR_ALU: ALU_result = ALU_A | ALU_B; //2
            `XOR_ALU: ALU_result = ALU_A ^ ALU_B; //3
            `SLL_ALU: ALU_result = ALU_B << (ALU_A[4:0]); //4
            `SRL_ALU: ALU_result = ALU_B >> (ALU_A[4:0]); //5
            `CLZ_ALU: ALU_result = { 26'b0, clz_result }; //6
            `LUI_ALU: ALU_result = {ALU_B[15:0],16'b0}; //7
            `PCADD_ALU: ALU_result = ALU_A + 32'h00000004; //8
            `MOVN_ALU: ALU_result = ALU_A; //9
            `NULL_ALU: ALU_result = 0; //10
            `LWPC_ALU: ALU_result = (ALU_A + 32'hfffffffc) + lwpc_offset;
            default: ALU_result = 0;
        endcase
    end

    always @(*) begin
        if (ALU_A[31]) begin
            clz_result = 32'h0;
        end else if (ALU_A[30]) begin
            clz_result = 32'h1;
        end else if (ALU_A[29]) begin
            clz_result = 32'h2;
        end else if (ALU_A[28]) begin
            clz_result = 32'h3;
        end else if (ALU_A[27]) begin
            clz_result = 32'h4;
        end else if (ALU_A[26]) begin
            clz_result = 32'h5;
        end else if (ALU_A[25]) begin
            clz_result = 32'h6;
        end else if (ALU_A[24]) begin
            clz_result = 32'h7;
        end else if (ALU_A[23]) begin
            clz_result = 32'h8;
        end else if (ALU_A[22]) begin
            clz_result = 32'h9;
        end else if (ALU_A[21]) begin
            clz_result = 32'ha;
        end else if (ALU_A[20]) begin
            clz_result = 32'hb;
        end else if (ALU_A[19]) begin
            clz_result = 32'hc;
        end else if (ALU_A[18]) begin
            clz_result = 32'hd;
        end else if (ALU_A[17]) begin
            clz_result = 32'he;
        end else if (ALU_A[16]) begin
            clz_result = 32'hf;
        end else if (ALU_A[15]) begin
            clz_result = 32'h10;
        end else if (ALU_A[14]) begin
            clz_result = 32'h11;
        end else if (ALU_A[13]) begin
            clz_result = 32'h12;
        end else if (ALU_A[12]) begin
            clz_result = 32'h13;
        end else if (ALU_A[11]) begin
            clz_result = 32'h14;
        end else if (ALU_A[10]) begin
            clz_result = 32'h15;
        end else if (ALU_A[9]) begin
            clz_result = 32'h16;
        end else if (ALU_A[8]) begin
            clz_result = 32'h17;
        end else if (ALU_A[7]) begin
            clz_result = 32'h18;
        end else if (ALU_A[6]) begin
            clz_result = 32'h19;
        end else if (ALU_A[5]) begin
            clz_result = 32'h1a;
        end else if (ALU_A[4]) begin
            clz_result = 32'h1b;
        end else if (ALU_A[3]) begin
            clz_result = 32'h1c;
        end else if (ALU_A[2]) begin
            clz_result = 32'h1d;
        end else if (ALU_A[1]) begin
            clz_result = 32'h1e;
        end else if (ALU_A[0]) begin
            clz_result = 32'hf;
        end else begin
            clz_result = 32'h20;
        end
    end

endmodule