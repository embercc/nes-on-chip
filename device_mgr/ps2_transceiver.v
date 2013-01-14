module ps2_tranceiver(
    input           i_clk           ,
    input           i_rstn          ,
    input           i_ps2_clk       ,
    input           i_ps2_data      ,
    output          o_ps2_txclk     ,
    output          o_ps2_txclk_e   ,
    output          o_ps2_txdata    ,
    output          o_ps2_txdata_e  ,
    input           i_cmd_val       ,
    input   [7:0]   i_cmd           ,
    output          o_scan_val      ,
    output  [7:0]   o_scancode      ,
    output          o_ready         
);


reg [15:0] r_clk_smpl;
reg [15:0] r_data_smpl;
wire       c_data_smpl;
reg [9:0]  r_scancode;
reg [3:0]  r_scancnt;

wire        c_start_ok;
wire        c_stop_ok;
wire        c_parity_ok;
wire        c_scan_ok;
wire[7:0]   c_scancode;

reg         [3:0]   r_laststate;
reg         [3:0]   r_state;
reg         [3:0]   c_nextstate;
parameter   [3:0]   STATE_IDLE      = 4'h0;
parameter   [3:0]   STATE_TXLOWCLK  = 4'h1;
parameter   [3:0]   STATE_TXLOWDATA = 4'h2;
parameter   [3:0]   STATE_TXRLSCLK  = 4'h3;
parameter   [3:0]   STATE_TXTRAN    = 4'h4;
parameter   [3:0]   STATE_TXACK     = 4'h5;
parameter   [3:0]   STATE_RXTRAN    = 4'h8;
parameter   [3:0]   STATE_WAITCLK1  = 4'hf;

reg     [9:0] r_clklow_cnt;
reg     [3:0] r_txcnt;

reg     [9:0] r_txdata;

always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
    end
    else begin
    end
end

always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_clk_smpl <= 1'b1;
    end
    else begin
        r_clk_smpl[15:0] <= {r_clk_smpl[14:0], i_ps2_clk};
    end
end

always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_data_smpl <= 1'b1;
    end
    else begin
        r_data_smpl[15:0] <= {r_data_smpl[14:0], i_ps2_data};
    end
end
assign c_data_smpl = r_data_smpl[7];

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/*
sm
*/
always @ ( * ) begin
    case (r_state)
    STATE_IDLE:
        if(i_cmd_val)
            c_nextstate = STATE_TXLOWCLK;
        else if(r_clk_smpl==16'hff00)
            c_nextstate = STATE_RXTRAN;
        else
            c_nextstate = STATE_IDLE;
    STATE_TXLOWCLK:
        if(r_clklow_cnt==10'd240)
            c_nextstate = STATE_TXLOWDATA;
        else
            c_nextstate = STATE_TXLOWCLK;
    STATE_TXLOWDATA:
        c_nextstate = STATE_TXRLSCLK;
    STATE_TXRLSCLK:
        c_nextstate = STATE_TXTRAN;
    STATE_TXTRAN:
        if(r_txcnt==4'h9 && r_clk_smpl==16'hff00)
            c_nextstate = STATE_TXACK;
        else
            c_nextstate = STATE_TXTRAN;
    STATE_TXACK:
        if(r_clk_smpl==16'hff00 && c_data_smpl==1'b0)
            c_nextstate = STATE_WAITCLK1;
        else
            c_nextstate = STATE_TXACK;
    STATE_RXTRAN:
        if(r_clk_smpl==16'hff00 && r_scancnt==4'h9)
            c_nextstate = STATE_WAITCLK1;
        else
            c_nextstate = STATE_RXTRAN;
    STATE_WAITCLK1:
        if(r_clk_smpl==16'hffff)
            c_nextstate = STATE_IDLE;
        else
            c_nextstate = STATE_WAITCLK1;
    default:
        c_nextstate = STATE_IDLE;
    endcase
end

always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_state <= STATE_IDLE;
        r_laststate <= STATE_IDLE;
    end
    else begin
        r_state <= c_nextstate;
        r_laststate <= r_state;
    end
end

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/*
TX
*/
//clklow counter
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_clklow_cnt <= 10'h0;
    end
    else begin
        if(r_state==STATE_TXLOWCLK) begin
            if(r_laststate==STATE_IDLE) begin
                r_clklow_cnt <= 10'h0;
            end
            else if(r_clklow_cnt!=10'd240) begin
                r_clklow_cnt <= r_clklow_cnt + 10'h1;
            end
        end
    end
end

always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_txcnt <= 4'h0;
    end
    else begin
        if(r_state!=STATE_TXTRAN) begin
            r_txcnt <= 4'h0;
        end
        else begin
            if(r_clk_smpl==16'hff00) begin
                r_txcnt <= r_txcnt + 4'h1;
            end
        end
    end
end

always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_txdata <= 10'h0;
    end
    else begin
        if(r_state==STATE_IDLE && i_cmd_val) begin
            r_txdata <= {~(^i_cmd), i_cmd, 1'b0};
        end
        else if (r_state==STATE_TXTRAN && r_clk_smpl==16'hff00) begin
            r_txdata <= {1'b0, r_txdata[9:1]};
        end
    end
end


//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/*
rx
*/

always @ (posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_scancode <= 10'h0;
        r_scancnt <= 4'h0;
    end
    else begin
        if(r_state==STATE_RXTRAN) begin
            if(r_clk_smpl[15:0]==16'hff00) begin
                r_scancnt <= r_scancnt + 4'h1;
                r_scancode <= {c_data_smpl, r_scancode[9:1]};
            end
        end
        else begin
            r_scancnt <= 4'h0;
            r_scancode <= 10'h0;
        end
    end
end
//we can use r_scancode when r_scancnt == 11. the code is located in r_scancode[8:1]
//scancode verify:
assign c_stop_ok = r_scancnt==4'hA ? r_scancode[9] : 1'b0;
assign c_parity_ok = r_scancnt==4'hA ? ^r_scancode[8:0] : 1'b0;
assign c_scan_ok = c_stop_ok & c_parity_ok;
assign c_scancode = r_scancnt==4'hA ? r_scancode[7:0] : 8'h0;

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/*
output
*/
assign o_ps2_txdata_e = (r_state==STATE_TXLOWDATA || r_state==STATE_TXRLSCLK || r_state==STATE_TXTRAN);
assign o_ps2_txdata = o_ps2_txdata_e ? r_txdata[0] : 1'b1;

assign o_ps2_txclk_e = (r_state==STATE_TXLOWCLK || r_state==STATE_TXLOWDATA || r_state==STATE_TXRLSCLK);
assign o_ps2_txclk = o_ps2_txclk_e ? 1'b0 : 1'b1;

assign o_ready = r_state==STATE_IDLE;
assign o_scan_val = c_scan_ok;
assign o_scancode = c_scancode;

endmodule
