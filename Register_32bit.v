module Register_32bit (
    input [31:0] In,
    input clk, 
    input reset,
    input ena,
    output reg [31:0] Out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Out <= 32'b0;
        end else if (ena)
            Out <= In;
    end
    
endmodule
// Tạm thời để đó, sau có nên đổi tên hay dùng chung với file .v trong Message Schedule
