`default_nettype wire

module Extend(
    input wire[15:0] Ext_immi,//要拓展的立即数
    input wire Ext_left,//左移信号
    input wire Ext_type,//扩展方式
    output reg[31:0] Ext_data//扩展后的结果
    );

    always @(*) begin
        case({Ext_left, Ext_type})
            2'b00: Ext_data = {{16'b0}, Ext_immi};
            2'b01: Ext_data = {{16{Ext_immi[15]}}, Ext_immi};
            2'b10: Ext_data = {14'b0, Ext_immi, 2'b00};
            2'b11: Ext_data = {{14{Ext_immi[15]}}, Ext_immi, 2'b00};
        endcase
    end
    
endmodule