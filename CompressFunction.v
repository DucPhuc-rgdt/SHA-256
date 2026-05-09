module CompressFunction (
    input clk,
    input reset,            // reset bất đồng bộ
    input Ena_InterHash,
    input Ena_WorkingVar,
    input Sel_for_WVar,        // sel = 0 -> Hi-1; sel = 1 -> giá trị mới tính được
    input [31:0] WK_t,
    output [255:0] DigestMessage
);

    wire [31:0] H0_i;
    wire [31:0] H1_i;
    wire [31:0] H2_i;
    wire [31:0] H3_i;
    wire [31:0] H4_i;
    wire [31:0] H5_i;
    wire [31:0] H6_i;
    wire [31:0] H7_i;

    wire [31:0] a;
    wire [31:0] b;
    wire [31:0] c;
    wire [31:0] d;
    wire [31:0] e;
    wire [31:0] f;
    wire [31:0] g;
    wire [31:0] h;
    wire [31:0] a_in;
    wire [31:0] e_in;

    wire [31:0] E_o;
    wire [31:0] sigma1_e;
    wire [31:0] ch_efg;
    wire [31:0] maj_abc;
    wire [31:0] sigma0_a;

    Intermediate_Hash u_Intermediate_Hash (
        .A(a + H0_i),
        .B(b + H1_i),
        .C(c + H2_i),
        .D(d + H3_i),
        .E(e + H4_i),
        .F(f + H5_i),
        .G(g + H6_i),
        .H(h + H7_i),
        .clk(clk),
        .reset(reset),
        .ena(Ena_InterHash),
        .H0(H0_i),
        .H1(H1_i),
        .H2(H2_i),
        .H3(H3_i),
        .H4(H4_i),
        .H5(H5_i),
        .H6(H6_i),
        .H7(H7_i)
    );

    Working_Var u_Working_A (
        .H_old(H0_i),
        .New(a_in),
        .clk(clk),
        .reset(reset),
        .ena(Ena_WorkingVar),
        .Sel(Sel_for_WVar),
        .Out(a)
    );

    Working_Var u_Working_B (
        .H_old(H1_i),
        .New(a),
        .clk(clk),
        .reset(reset),
        .ena(Ena_WorkingVar),
        .Sel(Sel_for_WVar),
        .Out(b)
    );

    Working_Var u_Working_C (
        .H_old(H2_i),
        .New(b),
        .clk(clk),
        .reset(reset),
        .ena(Ena_WorkingVar),
        .Sel(Sel_for_WVar),
        .Out(c)
    );

    Working_Var u_Working_D (
        .H_old(H3_i),
        .New(c),                    // nối từ c -> d (chỉ cần điều khiển ena)
        .clk(clk),
        .reset(reset),
        .ena(Ena_WorkingVar),
        .Sel(Sel_for_WVar),
        .Out(d)
    );

    Working_Var u_Working_E (
        .H_old(H4_i),
        .New(e_in),
        .clk(clk),
        .reset(reset),
        .ena(Ena_WorkingVar),
        .Sel(Sel_for_WVar),
        .Out(e)
    );

    Working_Var u_Working_F (
        .H_old(H5_i),
        .New(e),
        .clk(clk),
        .reset(reset),
        .ena(Ena_WorkingVar),
        .Sel(Sel_for_WVar),
        .Out(f)
    );

    Working_Var u_Working_G (
        .H_old(H6_i),
        .New(f),
        .clk(clk),
        .reset(reset),
        .ena(Ena_WorkingVar),
        .Sel(Sel_for_WVar),
        .Out(g)
    );

    Working_Var u_Working_H (
        .H_old(H7_i),
        .New(g),
        .clk(clk),
        .reset(reset),
        .ena(Ena_WorkingVar),
        .Sel(Sel_for_WVar),
        .Out(h)
    );

    SIGMA1 u_SIGMA1 (
        .x(e),
        .f(sigma1_e)
    );

    Ch_function u_Ch (
        .x(e),
        .y(f),
        .z(g),
        .f(ch_efg)
    );

    Maj_function u_Maj (
        .x(a),
        .y(b),
        .z(c),
        .f(maj_abc)
    );

    SIGMA0 u_SIGMA0 (
        .x(a),
        .f(sigma0_a)
    );

    // Tầng 1
    reg [31:0] T1, T2, T3;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            T1 <= 32'd0;
            T2 <= 32'd0;
            T3 <= 32'd0;
        end
        else begin
            T1 <= sigma1_e + ch_efg;
            T2 <= h + WK_t;
            T3 <= maj_abc + sigma0_a;
        end
    end

    // Tầng 2
    reg [31:0] T4;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            T4 <= 32'd0;
        end
        else begin
            T4 <= T1 + T2;       
            // T4 = (sigma1_e + ch_efg) + (h + WK_t)
            // T4 chính là T1 trong lý thuyết
            // T3 chính là T2 trong lý thuyết
        end
    end

    assign a_in = T4 + T3;        //(sigma1_e + ch_efg) + (h + WK_t) + maj_abc + sigma0_a
    assign e_in = T4 + d;

    assign DigestMessage = {H0_i, H1_i, H2_i, H3_i, H4_i, H5_i, H6_i, H7_i};
    
endmodule
