module Intermediate_Hash(
    input [31:0] A,
    input [31:0] B,
    input [31:0] C,
    input [31:0] D,
    input [31:0] E,
    input [31:0] F,
    input [31:0] G,
    input [31:0] H,
    input clk, 
    input reset,
    input ena,              // ena cho phép cập nhật giá trị trung gian.
    output reg [31:0] H0,
    output reg [31:0] H1,
    output reg [31:0] H2,
    output reg [31:0] H3,
    output reg [31:0] H4,
    output reg [31:0] H5,
    output reg [31:0] H6,
    output reg [31:0] H7
);
    always@(posedge clk or posedge reset) begin
        if (reset) begin
            H0 <= 32'h6a09e667;
            H1 <= 32'hbb67ae85;
            H2 <= 32'h3c6ef372;
            H3 <= 32'ha54ff53a;
            H4 <= 32'h510e527f;
            H5 <= 32'h9b05688c;
            H6 <= 32'h1f83d9ab;
            H7 <= 32'h5be0cd19;
        end else if (ena) begin
            H0 <= A;
            H1 <= B;
            H2 <= C;
            H3 <= D;
            H4 <= E;
            H5 <= F;
            H6 <= G;
            H7 <= H;
        end
    end

endmodule