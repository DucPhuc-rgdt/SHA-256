module Maj_function(
    input  [31:0] x,
    input  [31:0] y,
    input  [31:0] z,
    output [31:0] f
);
    assign f = (x & y) ^ (x & z) ^ (y & z);
endmodule
