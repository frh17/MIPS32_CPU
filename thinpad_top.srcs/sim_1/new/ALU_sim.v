`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/22 11:03:43
// Design Name: 
// Module Name: ALU_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ALU_sim;

reg [31:0] simALU_A;//输入操作�???1
reg [31:0] simALU_B;//输入操作�???2
reg [3:0] simALUop;//控制信号
wire [31:0] simALU_result;//输出
integer i;

ALU alu(.ALU_A(simALU_A), .ALU_B(simALU_A), .ALUop(simALUop), .ALU_result(simALU_result));

initial begin
    simALU_A = 32'b00000000111111110000111100110101;
    simALU_B = 32'b00000000111111110000111100110101;
    simALUop = 4'b1111;

end
//00ff0f31
//fffc3cd4
//00fb4c05
//1 1100 0011 1100 1101 0100

endmodule
