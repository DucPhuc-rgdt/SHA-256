module sigma0 (
    input [31:0] In,
    output [31:0] Out
);
    wire [31:0] r7, r18, sr3;
    assign r7 = {In[6:0], In[31:7]};
    assign r18 = {In[17:0], In[31:18]};
    assign sr3 = In >> 3;
    assign Out = r7 ^ r18 ^ sr3;
endmodule