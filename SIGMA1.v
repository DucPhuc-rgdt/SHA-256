module SIGMA1(
    input  [31:0] x,
    output [31:0] f
);
    assign f = {x[5:0], x[31:6]} ^ {x[10:0], x[31:11]} ^ {x[24:0], x[31:25]};
endmodule
