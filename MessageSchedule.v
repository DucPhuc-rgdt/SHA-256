module Message_Schedule (
    input [31:0] Data_in,
    input LD,
    input clk, 
    input reset,
    input ena,
    input [31:0] Kt,
    output [31:0] Out);
    
    wire [31:0] In_regis15;
    wire [31:0] Out_regis15, Out_regis14, Out_regis13, Out_regis12;
    wire [31:0] Out_regis11, Out_regis10, Out_regis9;
    wire [31:0] Out_regis8, Out_regis7, Out_regis6;
    wire [31:0] Out_regis5, Out_regis4, Out_regis3;
    wire [31:0] Out_regis2, Out_regis1, Out_regis0;

    Register_32bit regis15 (.In(In_regis15), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis15));
    Register_32bit regis14 (.In(Out_regis15), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis14));
    Register_32bit regis13 (.In(Out_regis14), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis13));
    Register_32bit regis12 (.In(Out_regis13), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis12));
    Register_32bit regis11 (.In(Out_regis12), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis11));
    Register_32bit regis10 (.In(Out_regis11), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis10));
    Register_32bit regis9 (.In(Out_regis10), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis9));
    Register_32bit regis8 (.In(Out_regis9), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis8));
    Register_32bit regis7 (.In(Out_regis8), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis7));
    Register_32bit regis6 (.In(Out_regis7), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis6));
    Register_32bit regis5 (.In(Out_regis6), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis5));
    Register_32bit regis4 (.In(Out_regis5), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis4));
    Register_32bit regis3 (.In(Out_regis4), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis3));
    Register_32bit regis2 (.In(Out_regis3), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis2));
    Register_32bit regis1 (.In(Out_regis2), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis1));
    Register_32bit regis0 (.In(Out_regis1), .clk(clk), .ena(ena), .reset(reset), .Out(Out_regis0));

    wire [31:0] sigma1_out, sigma0_out;
    sigma1 sigma1_inst (.In(Out_regis15), .Out(sigma1_out));
    sigma0 sigma0_inst (.In(Out_regis2), .Out(sigma0_out));

    wire [31:0] t1, t2;
    Register_32bit tmp1 (.In(sigma1_out + Out_regis10), .clk(clk), .ena(ena), .reset(reset), .Out(t1));
    Register_32bit tmp2 (.In(sigma0_out + Out_regis1), .clk(clk), .ena(ena), .reset(reset), .Out(t2));

    assign In_regis15 = LD ? Data_in : (t1 + t2);
    assign Out = Kt + Out_regis0;
    
endmodule