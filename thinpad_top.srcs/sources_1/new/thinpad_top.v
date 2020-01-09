`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入

    input wire clock_btn,         //BTN5手动时钟按钮��????????关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮��????????关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到"ON"时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信��????????
    output wire uart_rdn,         //读串口信号，低有��????????
    output wire uart_wrn,         //写串口信号，低有��????????
    input wire uart_dataready,    //串口数据准备��????????
    input wire uart_tbre,         //发�?�数据标��????????
    input wire uart_tsre,         //数据发�?�完毕标��????????

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共��????????
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持��????????0
    output wire base_ram_ce_n,       //BaseRAM片�?�，低有��????????
    output wire base_ram_oe_n,       //BaseRAM读使能，低有��????????
    output wire base_ram_we_n,       //BaseRAM写使能，低有��????????

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持��????????0
    output wire ext_ram_ce_n,       //ExtRAM片�?�，低有��????????
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有��????????
    output wire ext_ram_we_n,       //ExtRAM写使能，低有��????????

    //直连串口信号
    output wire txd,  //直连串口发�?�端
    input  wire rxd,  //直连串口接收��????????

    //Flash存储器信号，参�?? JS28F640 芯片手册
    output reg [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效��????????16bit模式无意��????????
    inout  wire [15:0]flash_d,      //Flash数据
    output reg flash_rp_n,         //Flash复位信号，低有效
    output reg flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧��????????
    output reg flash_ce_n,         //Flash片�?�信号，低有��????????
    output reg flash_oe_n,         //Flash读使能信号，低有��????????
    output reg flash_we_n,         //Flash写使能信号，低有��????????
    output reg flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash��????????16位模式时请设��????????1

    //USB 控制器信号，参�?? SL811 芯片手册
    output wire sl811_a0,
    //inout  wire[7:0] sl811_d,     //USB数据线与网络控制器的dm9k_sd[7:0]共享
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    //网络控制器信号，参�?? DM9000A 芯片手册
    output wire dm9k_cmd,
    inout  wire[15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input  wire dm9k_int,

    //图像输出信号
    output wire[2:0] video_red,    //红色像素��????????3��????????
    output wire[2:0] video_green,  //绿色像素��????????3��????????
    output wire[1:0] video_blue,   //蓝色像素��????????2��????????
    output wire video_hsync,       //行同步（水平同步）信��????????
    output wire video_vsync,       //场同步（垂直同步）信��????????
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐��????????
    //for simulation
    // output wire [31:0] ALUOUT_EXE,
    // output wire [31:0] INSTRU_IF,
    // output wire [31:0] DATAA,
    // output wire [31:0] DATAB,
    // output wire [1:0] FORWARDRS,
    // output wire [1:0] FORWARDRT
    //input wire[31:0] inst
);

wire myclk;
//assign myclk = clk_11M0592;
integer count;
always @(posedge clk_50M or posedge reset_btn) begin
    if (reset_btn == 1) begin
        count <= 0;
        myclk <= 0;
    end else if (count == 1) begin
        myclk <= 1;
        count <= 0;
    end else begin
        myclk <= 0;
        count <= 1;
    end
end
//wires between modules
wire isJump_ID_PC, isTrueBranch_ID_PC;
wire [31:0] JumpAddr_ID_PC, BranchAddr_ID_PC; 
wire [4:0] keep, clear;
wire [31:0] pc_PC_IM;
wire [31:0] pc_ID;
wire [31:0] instruction_IM;
wire [31:0] instruction_ID;
wire [1:0] ForwardRt_FU_ID, ForwardRs_FU_ID;
wire [4:0] RegWriteNode_ID, RegWriteNode_EXE, RegWriteNode_MEM, RegWriteNode_WB;
wire [31:0] RegRt_ID, RegRt_EXE, RegRt_MEM;
wire [31:0] DataA_ID, DataB_ID, DataA_EXE, DataB_EXE;
//memread memwrite memlength
wire [3:0] MemControl_ID, MemControl_EXE, MemControl_MEM;
wire [3:0] ALUOp_ID, ALUOp_EXE;
wire isRegWrite_ID, isRegWrite_EXE, isRegWrite_MEM, isRegWrite_WB;
wire [31:0] ALUOut_EXE, ALUOut_MEM;
wire [31:0] data_DM;
wire [31:0] DataOut_MEM, DataOut_WB;

//for simulation
// assign ALUOUT_EXE = ALUOut_EXE;
// assign INSTRU_IF = instruction_IM;
// assign DATAA = DataA_ID;
// assign DATAB = DataB_ID;
// assign FORWARDRS = ForwardRs_FU_ID;
// assign FORWARDRT = ForwardRt_FU_ID;
assign leds[15:8] = ALUOut_EXE[7:0];
assign leds[7:0] = instruction_ID[7:0];
assign dpy0 = pc_PC_IM[7:0];

Bubble bubble(
    .MemRead_MEM(MemControl_MEM[3]),
    .MemWrite_MEM(MemControl_MEM[2]),
    .Bub_keep(keep),
    .Bub_clear(clear),
    .MemRead_EXE(MemControl_EXE[3]),
    .ForwardRs(ForwardRs_FU_ID),
    .ForwardRt(ForwardRt_FU_ID)
);

ForwardUnit forwardunit(
    .RegWrite_exe(isRegWrite_EXE),
    .RegWrite_mem(isRegWrite_MEM),
    .RegWrite_wb(isRegWrite_WB),
    .RegNode_exe(RegWriteNode_EXE),
    .RegNode_mem(RegWriteNode_MEM),
    .RegNode_wb(RegWriteNode_WB),
    .Rs(instruction_ID[25:21]),
    .Rt(instruction_ID[20:16]),
    .ForwardRt(ForwardRt_FU_ID),
    .ForwardRs(ForwardRs_FU_ID)
);

MEM_WB mem_wb(
    .clk(myclk),
    .reset(reset_btn),
    .keep(keep[0]),
    .clear(clear[0]),
    .inResult(DataOut_MEM),
    .inRegWriteNode(RegWriteNode_MEM),
    .inRegWrite(isRegWrite_MEM),
    .outResult(DataOut_WB),
    .outRegWriteNode(RegWriteNode_WB),
    .outRegWrite(isRegWrite_WB)
);

MemCtrl memctrl(
    .inIMAddr(pc_PC_IM),
    .inDMAddr(ALUOut_MEM),
    .outData(data_DM),
    .outInst(instruction_IM),
    .inDMData(RegRt_MEM),
    .MemControl(MemControl_MEM),
    .BaseRamData(base_ram_data),
    .BaseRamAddr(base_ram_addr),
    .BaseRamByteEnable(base_ram_be_n),
    .BaseRamEnable(base_ram_ce_n),
    .BaseRamReadEnable(base_ram_oe_n),
    .BaseRamWriteEnable(base_ram_we_n),
    .ExtRamData(ext_ram_data),
    .ExtRamAddr(ext_ram_addr),
    .ExtRamByteEnable(ext_ram_be_n),
    .ExtRamEnable(ext_ram_ce_n),
    .ExtRamReadEnable(ext_ram_oe_n),
    .ExtRamWriteEnable(ext_ram_we_n),
    .SerialReadEnable(uart_rdn),
    .SerialWriteEnable(uart_wrn),
    .SerialDataReady(uart_dataready),
    .SerialTbre(uart_tbre),
    .SerialTsre(uart_tsre)
);

MUX_MEM mux_mem(
    .MemRead(MemControl_MEM[3]),
    .ALUout(ALUOut_MEM),
    .DMout(data_DM),
    .data(DataOut_MEM)
);

EXE_MEM exe_mem(
    .clk(myclk),
    .reset(reset_btn),
    .clear(clear[1]),
    .keep(keep[1]),
    .inResult(ALUOut_EXE),
    .inRegRt(RegRt_EXE),
    .inRegWriteNode(RegWriteNode_EXE),
    .inMemControl(MemControl_EXE),
    .inRegWrite(isRegWrite_EXE),
    .outResult(ALUOut_MEM),
    .outRegRt(RegRt_MEM),
    .outRegWriteNode(RegWriteNode_MEM),
    .outMemControl(MemControl_MEM),
    .outRegWrite(isRegWrite_MEM)
);

ALU myALU(
    .ALU_A(DataA_EXE),
    .ALU_B(DataB_EXE),
    .ALUop(ALUOp_EXE),
    .ALU_result(ALUOut_EXE)
);

ID_EXE id_exe(
    .reset(reset_btn),
    .clk(myclk),
    .keep(keep[2]),
    .clear(clear[2]),
    .inRegWriteNode(RegWriteNode_ID),
    .inRegRt(RegRt_ID),
    .inDataA(DataA_ID),
    .inDataB(DataB_ID),
    .inMemControl(MemControl_ID),
    .inALUop(ALUOp_ID),
    .inRegWrite(isRegWrite_ID),
    .outRegWriteNode(RegWriteNode_EXE),
    .outRegRt(RegRt_EXE),
    .outDataA(DataA_EXE),
    .outDataB(DataB_EXE),
    .outMemControl(MemControl_EXE),
    .outALUop(ALUOp_EXE),
    .outRegWrite(isRegWrite_EXE)
);

ID id(
    .clk(myclk),
    .reset(reset_btn),
    .instruction(instruction_ID),
    .newPC(pc_ID),
    .ForwardRt(ForwardRt_FU_ID),
    .ForwardRs(ForwardRs_FU_ID),
    .RegWriteNode_WB(RegWriteNode_WB),
    .RegWriteData_WB(DataOut_WB),
    .RegWriteEnable_WB(isRegWrite_WB),
    .DataForward_EXE(ALUOut_EXE),
    .DataForward_MEM(DataOut_MEM),
    .DataForward_WB(DataOut_WB),
    .RegWriteNode(RegWriteNode_ID),
    .RegRt(RegRt_ID),
    .DataA(DataA_ID),
    .DataB(DataB_ID),
    .MemControl(MemControl_ID),
    .ALUOp(ALUOp_ID),
    .isRegWrite(isRegWrite_ID),
    .isTrueBranch_IF(isTrueBranch_ID_PC),
    .isJump_IF(isJump_ID_PC),
    .JumpAddr(JumpAddr_ID_PC),
    .BranchAddr(BranchAddr_ID_PC)
);

IF_ID if_id(
    .clk(myclk),
    .reset(reset_btn),
    .inPC(pc_PC_IM),
    //.inInstruction(inst),
    .inInstruction(instruction_IM),
    .keep(keep[3]),
    .clear(clear[3]),
    .outInstruction(instruction_ID),
    .outPC(pc_ID)
);

PC mypc(
    .clk(myclk),
    .reset(reset_btn),
    .isJump(isJump_ID_PC),
    .isTrueBranch(isTrueBranch_ID_PC),
    .AddrJump(JumpAddr_ID_PC),
    .AddrBranch(BranchAddr_ID_PC),
    .keep(keep[4]),
    .clear(clear[4]),
    .outPC(pc_PC_IM)
);

//�ֱ���800x600@75Hz������ʱ��Ϊ50MHz
  wire [11:0] hdata;
  wire [11:0] vdata;
  reg[15:0] color = 16'h0;
  assign video_red = color[2:0]; 
  assign video_green = color[5:3]; 
  assign video_blue =color[7:6];
  assign video_clk = clk_50M;
  
  reg wait_read_data_time = 0;
  always @(posedge clk_50M) begin
    flash_a <= vdata*800 + hdata;
    flash_vpen <= 1'b1;
    flash_rp_n <= 1'b1;
    flash_oe_n <= 1'b0;
    flash_ce_n <= 1'b0;
    flash_byte_n <= 1'b1;
    flash_we_n <= 1'b1;
    color <= flash_d;
  end
  
  vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(clk_50M),
    .hdata(hdata),
    .vdata(vdata),
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de)
  );
  
endmodule
