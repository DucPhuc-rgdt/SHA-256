module sigma1 (
    input [31:0] In,
    output [31:0] Out
);
    wire [31:0] r17, r19, sr10;
    assign r17 = {In[16:0], In[31:17]};
    assign r19 = {In[18:0], In[31:19]};
    assign sr10 = In >> 10;
    assign Out = r17 ^ r19 ^ sr10;
endmodule