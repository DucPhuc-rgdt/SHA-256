module Working_Var (
    input [31:0] H_old,        // H(i-1)
    input [31:0] New,          // Giá trị mới từ hàm.
    input clk, 
    input reset,
    input ena,
    input Sel,          // Chọn giữa H(i-1) và giá trị mới.
    output reg [31:0] Out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Out <= 32'b0;
        end else if (ena) begin
            Out <= (Sel) ? New : H_old;     // Nếu Sel = 1: chọn giá trị mới; Sel=0: chọn H(i-1).
        end
    end
    
endmodule