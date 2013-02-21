module ppu_lcd_vout(
    input               i_lcd_rstn  ,
    input               i_lcd_clk   ,
    output      [16:0]  o_vbuf_addr ,
    input       [7:0]   i_vbuf_hsv  ,
    output reg  [7:0]   o_lcd_r     ,
    output reg  [7:0]   o_lcd_g     ,
    output reg  [7:0]   o_lcd_b     ,
    output reg          o_lcd_hsd   ,
    output reg          o_lcd_vsd   ,
    output              o_vblank    ,
    input       [9:0]   i_jp_vec_1p ,
    input       [9:0]   i_jp_vec_2p ,
    input       [2:0]   i_high_bgr
);

/*
lcd out started in odd frame. vbuf_addr[16]==1
*/


wire[16:0]  c_vbuf_addr;
wire[7:0]   c_vbuf_addr_x;
wire[7:0]   c_vbuf_addr_y;

wire[9:0]   c_lcd_xx;
wire[8:0]   c_lcd_yy;
reg [9:0]   r_lcd_xx;
reg [8:0]   r_lcd_yy;

reg [10:0]  r_xcnt;
reg [9:0]   r_line;
reg         r_hsd;
reg         r_vsd;

wire[23:0]   c_hsv2rgb;
wire[23:0]   c_hsv2rgb_masked;

reg         r_vbuf_page;
wire        c_game_area;
wire        c_jp_mon_box_1p     ;
wire        c_jp_mon_up_1p      ;
wire        c_jp_mon_down_1p    ;
wire        c_jp_mon_left_1p    ;
wire        c_jp_mon_right_1p   ;
wire        c_jp_mon_b_1p       ;
wire        c_jp_mon_a_1p       ;
wire        c_jp_mon_tb_1p      ;
wire        c_jp_mon_ta_1p      ;
wire        c_jp_mon_select_1p  ;
wire        c_jp_mon_start_1p   ;
wire        c_jp_mon_box_2p     ;
wire        c_jp_mon_up_2p      ;
wire        c_jp_mon_down_2p    ;
wire        c_jp_mon_left_2p    ;
wire        c_jp_mon_right_2p   ;
wire        c_jp_mon_b_2p       ;
wire        c_jp_mon_a_2p       ;
wire        c_jp_mon_tb_2p      ;
wire        c_jp_mon_ta_2p      ;
wire        c_spliter           ;
//wire        c_jp_mon_select_2p  ;
//wire        c_jp_mon_start_2p   ;


always @ ( posedge i_lcd_clk or negedge i_lcd_rstn) begin
    if(~i_lcd_rstn) begin
        r_vbuf_page <= 1'b1;
    end
    else begin
        if(r_xcnt==11'd1055 && r_line==10'd524) begin
            r_vbuf_page <= ~r_vbuf_page;
        end
    end
end

always @ ( posedge i_lcd_clk or negedge i_lcd_rstn) begin
    if(~i_lcd_rstn) begin
        r_xcnt <= 11'h0;
    end
    else begin
        if(r_xcnt == 11'd1055) begin
            r_xcnt <= 11'h0;
        end
        else begin
            r_xcnt <= r_xcnt + 11'h1;
        end
    end
end

always @ ( posedge i_lcd_clk or negedge i_lcd_rstn) begin
    if(~i_lcd_rstn) begin
        r_line <= 10'h0;
    end
    else begin
        if(r_xcnt == 11'd1055) begin
            if(r_line==10'd524) begin
                r_line <= 10'h0;
            end
            else begin    
                r_line <= r_line + 10'h1;
            end
        end
    end
end

always @ ( posedge i_lcd_clk or negedge i_lcd_rstn) begin
    if(~i_lcd_rstn) begin
        r_hsd <= 1'b0;
    end
    else begin
        if(r_xcnt<11'd30) begin
            r_hsd <= 1'b0;
        end
        else begin
            r_hsd <= 1'b1;
        end
    end
end

always @ ( posedge i_lcd_clk or negedge i_lcd_rstn) begin
    if(~i_lcd_rstn) begin
        r_vsd <= 1'b0;
    end
    else begin
        if(r_line<10'd13) begin
            r_vsd <= 1'b0;
        end
        else begin
            r_vsd <= 1'b1;
        end
    end    
end

/*
LCD SCREEN coordinate
*/
assign c_lcd_xx = 11'd799 - (r_xcnt - 11'd46);
assign c_lcd_yy = 10'd479 - (r_line - 10'd23);

always @ ( posedge i_lcd_clk or negedge i_lcd_rstn) begin
    if(~i_lcd_rstn) begin
        r_lcd_xx <= 10'h0;
        r_lcd_yy <= 9'h0;
    end
    else begin
        r_lcd_xx <= c_lcd_xx;
        r_lcd_yy <= c_lcd_yy;
    end    
end

/*
LCD SCREEN layout
*/
assign c_vbuf_addr_x = c_lcd_xx[8:1];
assign c_vbuf_addr_y = c_lcd_yy[8:1];
assign c_game_area = r_lcd_xx<10'd512;
assign c_jp_mon_box_1p = (((r_lcd_yy==9'd440) | (r_lcd_yy==9'd441) | (r_lcd_yy==9'd458) | (r_lcd_yy==9'd459)) & (r_lcd_xx>=10'd750) & (r_lcd_xx<=10'd797))
                        |((r_lcd_yy>=9'd442) & (r_lcd_yy<=9'd457) & ((r_lcd_xx==10'd748) | (r_lcd_xx==10'd749) | (r_lcd_xx==10'd798) | (r_lcd_xx==10'd799)));
assign c_jp_mon_box_2p = (((r_lcd_yy==9'd460) | (r_lcd_yy==9'd461) | (r_lcd_yy==9'd478) | (r_lcd_yy==9'd479)) & (r_lcd_xx>=10'd750) & (r_lcd_xx<=10'd797))
                        |((r_lcd_yy>=9'd462) & (r_lcd_yy<=9'd477) & ((r_lcd_xx==10'd748) | (r_lcd_xx==10'd749) | (r_lcd_xx==10'd798) | (r_lcd_xx==10'd799)));

assign c_jp_mon_up_1p       = (r_lcd_xx[9:2]==8'd189) & (r_lcd_yy[8:2]==7'd111);
assign c_jp_mon_down_1p     = (r_lcd_xx[9:2]==8'd189) & (r_lcd_yy[8:2]==7'd113);
assign c_jp_mon_left_1p     = (r_lcd_xx[9:2]==8'd188) & (r_lcd_yy[8:2]==7'd112);
assign c_jp_mon_right_1p    = (r_lcd_xx[9:2]==8'd190) & (r_lcd_yy[8:2]==7'd112);
assign c_jp_mon_b_1p        = (r_lcd_xx[9:2]==8'd196) & (r_lcd_yy[8:2]==7'd113);
assign c_jp_mon_a_1p        = (r_lcd_xx[9:2]==8'd198) & (r_lcd_yy[8:2]==7'd113);
assign c_jp_mon_tb_1p       = (r_lcd_xx[9:2]==8'd196) & (r_lcd_yy[8:2]==7'd111);
assign c_jp_mon_ta_1p       = (r_lcd_xx[9:2]==8'd198) & (r_lcd_yy[8:2]==7'd111);
assign c_jp_mon_select_1p   = (r_lcd_xx[9:2]==8'd192) & (r_lcd_yy[8:2]==7'd113);
assign c_jp_mon_start_1p    = (r_lcd_xx[9:2]==8'd194) & (r_lcd_yy[8:2]==7'd113);

assign c_jp_mon_up_2p       = (r_lcd_xx[9:2]==8'd189) & (r_lcd_yy[8:2]==7'd116);
assign c_jp_mon_down_2p     = (r_lcd_xx[9:2]==8'd189) & (r_lcd_yy[8:2]==7'd118);
assign c_jp_mon_left_2p     = (r_lcd_xx[9:2]==8'd188) & (r_lcd_yy[8:2]==7'd117);
assign c_jp_mon_right_2p    = (r_lcd_xx[9:2]==8'd190) & (r_lcd_yy[8:2]==7'd117);
assign c_jp_mon_b_2p        = (r_lcd_xx[9:2]==8'd196) & (r_lcd_yy[8:2]==7'd118);
assign c_jp_mon_a_2p        = (r_lcd_xx[9:2]==8'd198) & (r_lcd_yy[8:2]==7'd118);
assign c_jp_mon_tb_2p       = (r_lcd_xx[9:2]==8'd196) & (r_lcd_yy[8:2]==7'd116);
assign c_jp_mon_ta_2p       = (r_lcd_xx[9:2]==8'd198) & (r_lcd_yy[8:2]==7'd116);

assign c_spliter            = (r_lcd_xx[9:0]==10'd513);
//assign c_jp_mon_select_1p   = (r_lcd_xx[9:2]==8'd192) & (r_lcd_yy[8:2]==7'd113);
//assign c_jp_mon_start_1p    = (r_lcd_xx[9:2]==8'd194) & (r_lcd_yy[8:2]==7'd113);
/*
LCD OUTPUT
*/
assign c_hsv2rgb_masked[7:0]   = i_high_bgr[2] ? 8'hff : c_hsv2rgb[7:0];//blue
assign c_hsv2rgb_masked[15:8]  = i_high_bgr[1] ? 8'hff : c_hsv2rgb[15:8];//green
assign c_hsv2rgb_masked[23:16] = i_high_bgr[0] ? 8'hff : c_hsv2rgb[23:16];//red

always @ (posedge i_lcd_clk) begin
    o_lcd_hsd   <= r_hsd;
    o_lcd_vsd   <= r_vsd;
    if(r_hsd & r_vsd) begin
        case(1)
        c_game_area         :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= c_hsv2rgb_masked     ;            end
        c_jp_mon_box_1p     :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {8'h00, 8'hff, 8'h7f};            end
        c_jp_mon_box_2p     :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {8'h00, 8'h7f, 8'hff};            end
        c_jp_mon_up_1p      :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_1p[9]}}, ~{8{i_jp_vec_1p[9]}}, 8'h00};            end
        c_jp_mon_down_1p    :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_1p[8]}}, ~{8{i_jp_vec_1p[8]}}, 8'h00};            end
        c_jp_mon_left_1p    :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_1p[7]}}, ~{8{i_jp_vec_1p[7]}}, 8'h00};            end
        c_jp_mon_right_1p   :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_1p[6]}}, ~{8{i_jp_vec_1p[6]}}, 8'h00};            end
        c_jp_mon_b_1p       :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_1p[5]}}, ~{8{i_jp_vec_1p[5]}}, 8'h00};            end
        c_jp_mon_a_1p       :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_1p[4]}}, ~{8{i_jp_vec_1p[4]}}, 8'h00};            end
        c_jp_mon_tb_1p      :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_1p[3]}}, ~{8{i_jp_vec_1p[3]}}, 8'h00};            end
        c_jp_mon_ta_1p      :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_1p[2]}}, ~{8{i_jp_vec_1p[2]}}, 8'h00};            end
        c_jp_mon_select_1p  :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_1p[1]}}, ~{8{i_jp_vec_1p[1]}}, 8'h00};            end
        c_jp_mon_start_1p   :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_1p[0]}}, ~{8{i_jp_vec_1p[0]}}, 8'h00};            end
        c_jp_mon_up_2p      :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_2p[9]}}, 8'h00, ~{8{i_jp_vec_2p[9]}}};            end
        c_jp_mon_down_2p    :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_2p[8]}}, 8'h00, ~{8{i_jp_vec_2p[8]}}};            end
        c_jp_mon_left_2p    :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_2p[7]}}, 8'h00, ~{8{i_jp_vec_2p[7]}}};            end
        c_jp_mon_right_2p   :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_2p[6]}}, 8'h00, ~{8{i_jp_vec_2p[6]}}};            end
        c_jp_mon_b_2p       :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_2p[5]}}, 8'h00, ~{8{i_jp_vec_2p[5]}}};            end
        c_jp_mon_a_2p       :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_2p[4]}}, 8'h00, ~{8{i_jp_vec_2p[4]}}};            end
        c_jp_mon_tb_2p      :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_2p[3]}}, 8'h00, ~{8{i_jp_vec_2p[3]}}};            end
        c_jp_mon_ta_2p      :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {{8{i_jp_vec_2p[2]}}, 8'h00, ~{8{i_jp_vec_2p[2]}}};            end
        c_spliter           :            begin                {o_lcd_r, o_lcd_g, o_lcd_b} <= {8'h00, {8{r_lcd_yy[4]}}, ~{8{r_lcd_yy[4]}}};            end
        default:
            {o_lcd_r, o_lcd_g, o_lcd_b} <= {8'h00, 8'h00, 8'h00};
        endcase
    end
end
assign o_vbuf_addr = {r_vbuf_page, c_vbuf_addr_y, c_vbuf_addr_x};

/*
game control output
*/
assign o_vblank = (r_line >= 10'd480);



hsv2rgb hsv2rgb_wapper(
    .i_hsv      (i_vbuf_hsv[6:0]), //input      [6:0]     
    .o_rgb      (c_hsv2rgb)  //output reg [23:0]    
);

endmodule
