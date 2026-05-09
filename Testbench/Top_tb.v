`timescale 1ns/100ps

module Top_tb;
    localparam integer NUM_TESTS = 132;

    reg clk;
    reg reset;
    reg start;
    reg [31:0] block_word;
    reg last_block;

    wire busy;
    wire done;
    wire request_next_block;
    wire [255:0] digest;

    reg [511:0] mes_blocks [0:3400]; // tổng số block = 4001 của 132 testcase
    reg [255:0] expected_digest [0:NUM_TESTS-1];
    reg [54:0] block_counts [0:NUM_TESTS-1];

    integer test;
    integer pass;
    integer block_base;
    integer current_block;

    SHA256_Top dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .last_block(last_block),
        .block_word(block_word),
        .busy(busy),
        .done(done),
        .digest(digest),
        .request_next_block(request_next_block)
    );

    function [31:0] get_block_word;
        input [511:0] mes_block;
        input [3:0] idx;
        begin
            case (idx)
                4'd0:  get_block_word = mes_block[511:480];
                4'd1:  get_block_word = mes_block[479:448];
                4'd2:  get_block_word = mes_block[447:416];
                4'd3:  get_block_word = mes_block[415:384];
                4'd4:  get_block_word = mes_block[383:352];
                4'd5:  get_block_word = mes_block[351:320];
                4'd6:  get_block_word = mes_block[319:288];
                4'd7:  get_block_word = mes_block[287:256];
                4'd8:  get_block_word = mes_block[255:224];
                4'd9:  get_block_word = mes_block[223:192];
                4'd10: get_block_word = mes_block[191:160];
                4'd11: get_block_word = mes_block[159:128];
                4'd12: get_block_word = mes_block[127:96];
                4'd13: get_block_word = mes_block[95:64];
                4'd14: get_block_word = mes_block[63:32];
                4'd15: get_block_word = mes_block[31:0];
                default: get_block_word = 32'd0;
            endcase
        end
    endfunction

    always @(*) begin
        if (busy && dut.u_control.MS_LD && dut.u_control.MS_ena) begin
            block_word = get_block_word(mes_blocks[block_base + current_block], dut.u_control.load_index);
        end else begin
            block_word = 32'd0;
        end
    end

    always @(*) begin
        last_block = (current_block == block_counts[test] - 1);
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_block <= 0;
        end else if (start) begin
            current_block <= 0;
        end else if (request_next_block) begin
            current_block <= current_block + 1;
        end
    end

    initial begin
        $dumpfile("Top_tb.vcd");
        $dumpvars(0, Top_tb);

        $readmemh("Block.txt", mes_blocks);
        $readmemh("Num_block.txt", block_counts);
        $readmemh("ExpectedDigests.txt", expected_digest);

        clk = 1'b0;
        reset = 1'b1;
        start = 1'b0;
        last_block = 1'b0;
        pass = 0;
        block_base = 0;
        current_block = 0;

        #20;
        reset = 1'b0;

        for (test = 0; test < NUM_TESTS; test = test + 1) begin
            @(negedge clk);
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;

            wait(done == 1'b1);
            #1;

            if (digest === expected_digest[test]) begin
                pass = pass + 1;
                $display("PASS testcase %0d", test + 1);
            end else begin
                $display("FAIL testcase %0d", test + 1);
                $display("  expected = %064h", expected_digest[test]);
                $display("  actual   = %064h", digest);
            end

            block_base = block_base + block_counts[test];

            if (test != NUM_TESTS - 1) begin
                @(negedge clk);
                reset = 1'b1;
                start = 1'b0;
                @(negedge clk);
                reset = 1'b0;
            end
        end

        $display("Summary: %0d/%0d testcase passed.", pass, NUM_TESTS);
        #20;
        $finish;
    end

    always #5 clk = ~clk;

endmodule
