`default_nettype wire

`define FROM_WB  2'b11
`define FROM_MEM 2'b10
`define FROM_EXE 2'b01
`define FROM_NUL 2'b00

module ForwardUnit(
    input RegWrite_exe,
    input RegWrite_mem,
    input RegWrite_wb,
    input [4:0] RegNode_exe,
    input [4:0] RegNode_mem,
    input [4:0] RegNode_wb,
    input [4:0] Rs,
    input [4:0] Rt,
    output reg [1:0] ForwardRt,
    output reg [1:0] ForwardRs
    );


    // deal with forwardRs
    always @(*) begin
        if (Rs != 0) begin
            if ((RegWrite_exe == 1) && (RegNode_exe == Rs)) begin
                ForwardRs = `FROM_EXE;
            end else if ((RegWrite_mem == 1) && (RegNode_mem == Rs)) begin
                ForwardRs = `FROM_MEM;
            end else if ((RegWrite_wb == 1) && (RegNode_wb == Rs)) begin
                ForwardRs = `FROM_WB;
            end else begin
                ForwardRs = `FROM_NUL;
            end
        end else begin
            ForwardRs = `FROM_NUL;
        end
    end

    // deal with forwardRt
    always @(*) begin
        if (Rt != 0) begin
            if ((RegWrite_exe == 1) && (RegNode_exe == Rt)) begin
                ForwardRt = `FROM_EXE;
            end else if ((RegWrite_mem == 1) && (RegNode_mem == Rt)) begin
                ForwardRt = `FROM_MEM;
            end else if ((RegWrite_wb == 1) && (RegNode_wb == Rt)) begin
                ForwardRt = `FROM_WB;
            end else begin
                ForwardRt = `FROM_NUL;
            end
        end else begin
            ForwardRt = `FROM_NUL;
        end
    end

endmodule