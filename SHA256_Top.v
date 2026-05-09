module SHA256_Top (
    input clk,
    input reset,
    input start,
    input [31:0] block_word,
    input last_block,
    output busy,
    output done,
    output request_next_block,
    output [255:0] digest
);

    wire MS_LD;
    wire MS_ena;
    wire Ena_InterHash;
    wire Ena_WorkingVar;
    wire Sel_for_WVar;
    wire [3:0] load_index;
    wire [5:0] round_index;
    wire [5:0] K_index;

    wire [31:0] Kt;
    wire [31:0] WK_t;

    Control_Unit u_control (
        .clk(clk),
        .reset(reset),
        .start(start),
        .last_block(last_block),
        .busy(busy),
        .done(done),
        .MS_LD(MS_LD),
        .MS_ena(MS_ena),
        .Ena_InterHash(Ena_InterHash),
        .Ena_WorkingVar(Ena_WorkingVar),
        .Sel_for_WVar(Sel_for_WVar),
        .request_next_block(request_next_block),
        .load_index(load_index),
        .round_index(round_index),
        .K_index(K_index)
    );

    Message_Schedule u_MS (
        .Data_in(block_word),
        .LD(MS_LD),
        .clk(clk),
        .reset(reset),
        .ena(MS_ena),
        .Kt(Kt),
        .Out(WK_t)
    );

    CompressFunction u_CF (
        .clk(clk),
        .reset(reset),
        .Ena_InterHash(Ena_InterHash),
        .Ena_WorkingVar(Ena_WorkingVar),
        .Sel_for_WVar(Sel_for_WVar),
        .WK_t(WK_t),
        .DigestMessage(digest)
    );

    Kt u_Kt (
        .K_index(K_index),
        .Kt(Kt)
    );

endmodule
