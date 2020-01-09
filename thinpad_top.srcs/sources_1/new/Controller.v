`default_nettype wire

// Op
`define ADDIU 6'b001001
`define ANDI  6'b001100
`define ORI   6'b001101
`define XORI  6'b001110
`define LUI   6'b001111
`define CLZ_OP   6'b011100
`define BEQ   6'b000100
`define BGTZ  6'b000111
`define BNE   6'b000101
`define J     6'b000010
`define JAL   6'b000011
`define LB    6'b100000
`define LW    6'b100011
`define LH    6'b100001
`define SB    6'b101000
`define SW    6'b101011
`define LWPC  6'b111011

//func
`define OR    6'b100101
`define XOR   6'b100110
`define ADDU  6'b100001
`define AND   6'b100100
`define CLZ_FUNC  6'b100000
`define SLL   6'b000000
`define SRL   6'b000010
`define JR    6'b001000
`define MOVN  6'b001011


module Controller(
    input [31:0] Instruction,
    output reg isJump,
    output reg isBranch,
    output reg [2:0] CompareOp,
    output reg RegWrite,
    output reg [3:0] MemControl,
    output reg [3:0] ALUop,
    output reg isMOVN,
    output reg isJR,
    output reg isJAL,
    output reg isShift,
    output reg isImmi,
    output reg isWriteToRt,
    output reg ShiftLeft2,
    output reg isSignExtern,
    output reg isLWPC
    );

    wire [5:0] Op;
    wire [5:0] Func;
    wire [1:0] Op2;
    assign Op = Instruction[31:26];
    assign Func = Instruction[5:0];
    assign Op2 = Instruction[20:19];
    reg MemWrite, MemRead;
    reg [1:0] MemLength;

    always @(*) begin
        if (Op==`LWPC && Op2==2'b01) isLWPC = 1'b1;
        else isLWPC = 1'b0;
    end

    always @(*) begin
        if (Op == `J || Op==`JAL || (Op==0 && Func==`JR)) begin
            isJump = 1'b1;
        end else begin
            isJump = 1'b0;
        end
    end

    always @(*) begin
        if (Op==`BEQ || Op==`BGTZ || Op==`BNE) begin
            isBranch = 1'b1;
            ShiftLeft2 = 1'b1;
        end else begin
            isBranch = 1'b0;
            ShiftLeft2 = 1'b0;
        end
    end

    always @(*) begin
        if (Op==`BEQ) CompareOp = 3'b001;
        else if (Op==`BGTZ) CompareOp = 3'b010;
        else if (Op==`BNE) CompareOp = 3'b011;
        else if (Op==0 && Func==`MOVN) CompareOp = 3'b100;
        else CompareOp = 3'b000;
    end

    always @(*) begin
        if (Op==`BEQ || Op==`BGTZ || Op==`BNE || Op==`J || (Op==0 && Func==`JR) || Op==`SB || Op==`SW) begin
            RegWrite = 1'b0;
        end else RegWrite = 1'b1;
    end
    
    always @(*) begin
        if (Op==`SB || Op==`SW) MemWrite = 1'b1;
        else MemWrite = 1'b0;
    end

    always @(*) begin
        if (Op==`LB || Op==`LW || Op==`LH ||(Op==`LWPC && Op2==2'b01)) MemRead = 1'b1;
        else MemRead = 1'b0;
    end

    always @(*) begin
        if (Op==`LB || Op==`SB) MemLength = 2'b01;
        else if (Op==`LH) MemLength = 2'b10;
        else MemLength = 2'b00;
    end

    always @(*) begin
        MemControl[3:0] = { MemRead, MemWrite, MemLength[1:0] };
    end

    always @(*) begin
        if (Op==`ADDIU || (Op==0 && Func==`ADDU) || Op==`LB || Op==`LW || Op==`LH || Op==`SB || Op==`SW) begin
            ALUop = 4'b0000;
        end else if (Op==`ANDI || (Op==0 && Func==`AND)) begin
            ALUop = 4'b0001;
        end else if (Op==`ORI || (Op==0 && Func==`OR)) begin
            ALUop = 4'b0010;
        end else if (Op==`XORI || (Op==0 && Func==`XOR)) begin
            ALUop = 4'b0011;
        end else if (Op==0 && Func==`SLL) begin
            ALUop = 4'b0100;
        end else if (Op==0 && Func==`SRL) begin
            ALUop = 4'b0101;
        end else if (Op==`CLZ_OP && Func==`CLZ_FUNC) begin
            ALUop = 4'b0110;
        end else if (Op==`LUI) ALUop = 4'b0111;
        else if (Op==`JAL) ALUop = 4'b1000;
        else if (Op==0 && Func==`MOVN) ALUop = 4'b1001;
        else if ((Op==`LWPC && Op2==2'b01)) ALUop =4'b1111;
        else ALUop = 4'b1010;
    end
    
    always @(*) begin
        if (Op==0 && Func==`MOVN) isMOVN = 1'b1;
        else isMOVN = 1'b0;
    end

    always @(*) begin
        if (Op==0 && Func==`JR) isJR = 1'b1;
        else isJR = 1'b0;
    end

    always @(*) begin
        if (Op==`JAL) isJAL = 1'b1;
        else isJAL = 1'b0;
    end

    always @(*) begin
        if (Op==0 && (Func==`SLL || Func==`SRL)) isShift = 1'b1;
        else isShift = 1'b0;
    end

    always @(*) begin
        if (Op==`ADDIU || Op==`ANDI || Op==`ORI || Op==`XORI || Op==`LUI || Op==`LB || Op==`LW || Op==`LH || Op==`SB || Op==`SW) begin
            isImmi = 1'b1;
            isWriteToRt = 1'b1;
        end else begin
            isImmi = 1'b0;
            isWriteToRt = 1'b0;
        end
    end

    always @(*) begin
        if (Op==`ANDI || Op==`ORI || Op==`XORI) isSignExtern = 1'b0;
        else isSignExtern = 1'b1;
    end

endmodule