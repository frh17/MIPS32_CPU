`default_nettype wire

`define FROM_WB  2'b11
`define FROM_MEM 2'b10
`define FROM_EXE 2'b01
`define FROM_NUL 2'b00

module ID(
    input clk,
    input reset,
    input [31:0] instruction,
    input [31:0] newPC,
    input [1:0] ForwardRt,
    input [1:0] ForwardRs,
    input [4:0] RegWriteNode_WB,
    input [31:0] RegWriteData_WB,
    input RegWriteEnable_WB,
    input [31:0] DataForward_EXE,
    input [31:0] DataForward_MEM,
    input [31:0] DataForward_WB,
    output reg[4:0] RegWriteNode,
    output [31:0] RegRt,
    output reg[31:0] DataA,
    output reg[31:0] DataB,
    output [3:0] MemControl,
    output [3:0] ALUOp,
    output isRegWrite,
    output isTrueBranch_IF,
    output isJump_IF,
    output [31:0] JumpAddr,
    output [31:0] BranchAddr
);

wire [4:0] rt, rs, rd, sa;
assign rt = instruction[20:16];
assign rs = instruction[25:21];
assign rd = instruction[15:11];
assign sa = instruction[10:6];
//data directly out from registers
wire [31:0] RegData1, RegData2;
//data after mux2 and mux3
reg [31:0] TrulyRegData1, TrulyRegData2;
//control signals
wire isJump;
wire isBranch;
wire [2:0] CompareOp;
wire RegWrite;
wire isMOVN;
wire isJR;
wire isJAL;
wire isShift;
wire isImmi;
wire isWriteToRt;
wire ShiftLeft2;
wire isSignExtern;
wire CompareTrue;
wire isLWPC;
// extended immi
wire [31:0] immidiate;

assign isTrueBranch_IF = isBranch & CompareTrue;
assign isJump_IF = isJump;
assign BranchAddr = immidiate + newPC;
assign RegRt = TrulyRegData2;
//mux8
assign isRegWrite = (isMOVN == 1) ? CompareTrue : RegWrite;
//mux4
assign JumpAddr = (isJR == 1) ? TrulyRegData1 : {newPC[31:28], instruction[25:0], 2'b0};

//mux2
always @(*) begin
    case (ForwardRs)
        `FROM_NUL: TrulyRegData1 = RegData1;
        `FROM_EXE: TrulyRegData1 = DataForward_EXE;
        `FROM_MEM: TrulyRegData1 = DataForward_MEM;
        `FROM_WB: TrulyRegData1 = DataForward_WB;
        default: TrulyRegData1 = RegData1;
    endcase
end

//mux3
always @(*) begin
    case (ForwardRt)
        `FROM_NUL: TrulyRegData2 = RegData2;
        `FROM_EXE: TrulyRegData2 = DataForward_EXE;
        `FROM_MEM: TrulyRegData2 = DataForward_MEM;
        `FROM_WB: TrulyRegData2 = DataForward_WB;
        default: TrulyRegData2 = RegData2;
    endcase
end

//mux5
always @(*) begin
    if (isLWPC) DataB = instruction;
    else if (isImmi) DataB = immidiate;
    else DataB = TrulyRegData2;
end

//mux6
always @(*) begin
    if (isLWPC == 1) RegWriteNode = rs;
    else if (isJAL  == 1) RegWriteNode = 5'b11111;
    else if (isWriteToRt) RegWriteNode = rt;
    else RegWriteNode = rd;
end

//mux7
always @(*) begin
    if (isJAL == 1 || isLWPC == 1) DataA = newPC;
    else if (isShift == 1) DataA = {27'b0, sa};
    else DataA = TrulyRegData1;
end



Compare compare(
    .CompareOp(CompareOp),
    .dataA(TrulyRegData1),
    .dataB(TrulyRegData2),
    .success(CompareTrue)
);

Extend extend(
    .Ext_immi(instruction[15:0]),
    .Ext_left(ShiftLeft2),
    .Ext_type(isSignExtern),
    .Ext_data(immidiate)
);

Controller controller(
    .Instruction(instruction),
    .isJump(isJump),
    .isBranch(isBranch),
    .CompareOp(CompareOp),
    .RegWrite(RegWrite),
    .MemControl(MemControl),
    .ALUop(ALUOp),
    .isMOVN(isMOVN),
    .isJR(isJR),
    .isJAL(isJAL),
    .isShift(isShift),
    .isImmi(isImmi),
    .isWriteToRt(isWriteToRt),
    .ShiftLeft2(ShiftLeft2),
    .isSignExtern(isSignExtern),
    .isLWPC(isLWPC)
);

Register registers(
    .clk(clk),
    .reset(reset),
    .RegRead1(rs),
    .RegRead2(rt),
    .RegWrite(RegWriteNode_WB),
    .DataWrite(RegWriteData_WB),
    .WriteEnable(RegWriteEnable_WB),
    .DataRead1(RegData1),
    .DataRead2(RegData2)
);



endmodule