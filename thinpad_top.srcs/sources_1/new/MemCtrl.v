`default_nettype wire

module MemCtrl(
    input [31:0] inIMAddr,
    input [31:0] inDMAddr,
    output [31:0] outData,//
    output [31:0] outInst,
    input [31:0] inDMData,
    input [3:0] MemControl,

    inout [31:0] BaseRamData,
    output [19:0] BaseRamAddr,//
    output [3:0] BaseRamByteEnable,//
    output BaseRamEnable,//
    output BaseRamReadEnable,
    output BaseRamWriteEnable,

    inout [31:0] ExtRamData,
    output [19:0] ExtRamAddr,//
    output [3:0] ExtRamByteEnable,//
    output ExtRamEnable,//
    output ExtRamReadEnable,//
    output ExtRamWriteEnable,//

    output SerialReadEnable,
    output SerialWriteEnable,
    input SerialDataReady,
    input SerialTbre,
    input wire SerialTsre
);

wire MemRead, MemWrite, useDataMem;
wire [1:0] MemLength;
assign MemRead = MemControl[3];
assign MemWrite = MemControl[2];
assign MemLength = MemControl[1:0];
assign useDataMem = MemRead | MemWrite;

//确定输入地址
wire [31:0] inAddr;
wire [1:0] offset;
assign inAddr = useDataMem ? inDMAddr : inIMAddr;
assign BaseRamAddr = inAddr[21:2];
assign ExtRamAddr = inAddr[21:2];
assign offset = inAddr[1:0];

//串口使能
wire isSerialControl, isSerialData;
assign isSerialControl = (inDMAddr == 32'hBFD003FC) ? 1 : 0;
assign isSerialData = (inDMAddr == 32'hBFD003F8) ? 1 : 0;
assign SerialReadEnable = (MemRead & isSerialData) ? 0 : 1;
assign SerialWriteEnable = (MemWrite & isSerialData) ? 0 : 1;

//使用ExtRam
wire isExtRam;
assign isExtRam = (isSerialControl | isSerialData) ? 0 : inAddr[22];

//读出�??32位数
wire [31:0] dataRead;
assign dataRead = isSerialControl ? {30'b0, SerialDataReady, SerialTbre &SerialTsre} :
                (isExtRam ? ExtRamData : BaseRamData); 
// always @(*) begin
//     if (isSerialControl) dataRead = {30'b0, SerialDataReady, SeiralTbre &SeiralTsre};
//     else if (isSerialData) dataRead = BaseRamAddr;
//     else if (isExtRam) dataRead = ExtRamData;
//     else dataRead = BaseRamAddr;
// end
reg [31:0] DataToWrite;

//读或写的高阻�??
assign ExtRamData = (MemWrite & isExtRam) ? DataToWrite : 32'bz;
assign BaseRamData = (MemWrite & ~isExtRam) ? DataToWrite : 32'bz;

//读写使能，低有效
assign BaseRamWriteEnable = (isSerialControl | isSerialData ) ? 1 : ~(MemWrite & ~isExtRam);
assign ExtRamWriteEnable =  (isSerialControl | isSerialData ) ? 1 : ~(MemWrite & isExtRam);
assign BaseRamReadEnable =  (isSerialControl | isSerialData ) ? 1 : ~(~MemWrite & ~isExtRam);
assign ExtRamReadEnable =  (isSerialControl | isSerialData ) ? 1 : ~(~MemWrite & isExtRam);

//选片使能，低有效
assign BaseRamEnable = 0;
assign ExtRamEnable = 0;

// 读到的指�??
assign outInst = (~useDataMem) ? dataRead : 32'b0;

// 读到的数据和字节使能
reg [31:0] dataTmp;
reg [3:0] baseByteEnableTmp, extByteEnableTmp;
assign outData = dataTmp;
assign BaseRamByteEnable = baseByteEnableTmp;
assign ExtRamByteEnable = extByteEnableTmp;

always @(*) begin
    if (MemRead | MemWrite == 1) begin
        if (MemLength == 1) begin  //byte
            case (offset)
                2'b00 : begin
                    baseByteEnableTmp = 4'b1110;
                    extByteEnableTmp = 4'b1110;
                    dataTmp = {{24{dataRead[7]}}, dataRead[7:0]};
                    DataToWrite = {24'b0, inDMData[7:0]};
                end
                2'b01 : begin
                    baseByteEnableTmp = 4'b1101;
                    extByteEnableTmp = 4'b1101;
                    dataTmp = {{24{dataRead[15]}}, dataRead[15:8]};
                    DataToWrite = {16'b0, inDMData[7:0], 8'b0};
                end
                2'b10 : begin
                    baseByteEnableTmp = 4'b1011;
                    extByteEnableTmp = 4'b1011;
                    dataTmp = {{24{dataRead[23]}}, dataRead[23:16]};
                    DataToWrite = {8'b0, inDMData[7:0], 16'b0};
                end
                2'b11 : begin
                    baseByteEnableTmp = 4'b0111;
                    extByteEnableTmp = 4'b0111;
                    dataTmp = {{24{dataRead[31]}}, dataRead[31:24]};
                    DataToWrite = {inDMData[7:0], 24'b0};
                end
                default: begin
                    baseByteEnableTmp = 4'b1110;
                    extByteEnableTmp = 4'b1110;
                    dataTmp = {{24{dataRead[7]}}, dataRead[7:0]};
                    DataToWrite = {24'b0, inDMData[7:0]};
                end
            endcase
        end else if (MemLength == 2) begin
            if (offset[1] == 0) begin
                baseByteEnableTmp = 4'b1100;
                extByteEnableTmp = 4'b1100;
                dataTmp = {{16{dataRead[15]}}, dataRead[15:0]};
                DataToWrite = {16'b0, inDMData[15:0]};
            end else begin
                baseByteEnableTmp = 4'b0011;
                extByteEnableTmp = 4'b0011;
                dataTmp = {{16{dataRead[31]}}, dataRead[31:16]};
                DataToWrite = {inDMData[15:0], 16'b0};
            end
        end else begin
            baseByteEnableTmp = 4'b0000;
            extByteEnableTmp = 4'b0000;
            dataTmp = dataRead;
            DataToWrite = inDMData;
        end
    end else begin
        baseByteEnableTmp = 4'b0000;
        extByteEnableTmp = 4'b0000;
        dataTmp = dataRead;
        DataToWrite = inDMData;
    end
end


endmodule