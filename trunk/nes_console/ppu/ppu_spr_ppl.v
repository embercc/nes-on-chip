`timescale 10ns/1ns

module ppu_spr_ppl(
    input           i_clk       ,
    input           i_rstn      ,
    input [7:0]     i_xcnt      ,
    input           i_xcnt_wr   ,
    input [7:0]     i_attr      ,
    input           i_attr_we   ,
    input [15:0]    i_patt      ,
    input           i_patt_we   ,
    input           i_run       ,
    output          o_priority  ,//0 in front of background, 1 behind
    output[3:0]     o_pattern   ,
    output          o_show
);

reg [7:0]  r_xcnt;
reg [1:0]  r_paletteH;
reg        r_priority;
reg        r_mirrorX;
reg [7:0]  r_pt_H;
reg [7:0]  r_pt_L;
reg [8:0]  r_show_cnt;

// attribute
always @ (posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_paletteH <= 2'h0;
        r_priority <= 1'b0;
        r_mirrorX <= 1'b0;
    end
    else begin
        if(i_attr_we) begin
            r_paletteH <= i_attr[1:0];
            r_priority <= i_attr[5];
            r_mirrorX <= i_attr[6];
        end
    end
end

//xcounter
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_xcnt <= 8'h0;
    end
    else begin
        if(i_xcnt_wr)
            r_xcnt <= i_xcnt;
        else if (i_run & (r_xcnt!=0))
            r_xcnt <= r_xcnt - 8'h1;
    end
end

//output counter
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_show_cnt <= 9'h0;
    end
    else begin
        if((r_xcnt==8'h0) & i_run & ~r_show_cnt[8]) begin
            r_show_cnt <= r_show_cnt + 9'h1;
        end
    end
end

//pattern table
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        {r_pt_H, r_pt_L} <= 16'h0;
    end
    else begin
        if(i_patt_we) begin
            if(r_mirrorX) begin
                r_pt_H <= {i_patt[8], i_patt[9], i_patt[10], i_patt[11], i_patt[12], i_patt[13], i_patt[14], i_patt[15]};
                r_pt_L <= {i_patt[0], i_patt[1], i_patt[2], i_patt[3], i_patt[4], i_patt[5], i_patt[6], i_patt[7]};
            end
            else begin
                r_pt_H <= i_patt[15:8];
                r_pt_L <= i_patt[7:0];
            end
        end
        else if(i_run & (r_xcnt==8'h0)) begin
            r_pt_H <= {r_pt_H[6:0], 1'b0};
            r_pt_L <= {r_pt_L[6:0], 1'b0};
        end
    end
end

//output
assign o_priority  = r_priority;
assign o_pattern = {r_paletteH, r_pt_H[7], r_pt_L[7]};
assign o_show = (r_xcnt==8'h0) & ~r_show_cnt[8];


endmodule
