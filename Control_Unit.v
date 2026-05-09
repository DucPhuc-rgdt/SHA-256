module Control_Unit (
    input clk,
    input reset,
    input start,
    input last_block,
    output busy,
    output done,
    output MS_LD,
    output MS_ena,
    output Ena_InterHash,
    output Ena_WorkingVar,
    output Sel_for_WVar,
    output request_next_block,
    output [3:0] load_index,
    output [5:0] round_index,
    output [5:0] K_index
);

    localparam [2:0] Idle      = 3'd0;
    localparam [2:0] Load      = 3'd1;
    localparam [2:0] Init_WV   = 3'd2;
    localparam [2:0] Wait1     = 3'd3;
    localparam [2:0] Wait2     = 3'd4;
    localparam [2:0] Update_WV = 3'd5;
    localparam [2:0] Writeback = 3'd6;
    localparam [2:0] Done      = 3'd7;

    reg [2:0] state, next_state;
    reg [3:0] load_count;
    reg [5:0] round_count;

    always @(*) begin
        case (state)
            Idle:       next_state = start ? Load : Idle;
            Load:       next_state = (load_count == 4'd15) ? Init_WV : Load;
            Init_WV:    next_state = Wait1;
            Wait1:      next_state = Wait2;
            Wait2:      next_state = Update_WV;
            Update_WV:  next_state = (round_count == 6'd63) ? Writeback : Wait1;
            Writeback:  next_state = last_block ? Done : Load;
            Done:       next_state = Idle;
            default:    next_state = Idle;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= Idle;
            load_count <= 4'd0;
            round_count <= 6'd0;
        end else begin
            state <= next_state;

            if (state == Load && load_count < 4'd15) begin
                load_count <= load_count + 4'd1;
            end else begin
                load_count <= 4'd0;
            end

            if (state == Update_WV && round_count <= 6'd63) begin
                round_count <= round_count + 6'd1;
            end else if (state == Load) begin
                round_count <= 6'd0;
            end
        end
    end

    assign busy = (state != Idle);
    assign done = (state == Done);
    assign MS_LD = (state == Load);
    assign MS_ena = (state == Load || (state == Update_WV && round_count < 6'd63));
    assign Ena_InterHash = (state == Writeback);
    assign Ena_WorkingVar = (state == Init_WV || state == Update_WV);
    assign Sel_for_WVar = (state == Update_WV);
    assign request_next_block = (state == Writeback) && !last_block;
    assign load_index = load_count;
    assign round_index = round_count;
    assign K_index = round_count;

endmodule
