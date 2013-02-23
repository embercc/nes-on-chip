module ppu_rde(
    input           i_clk           ,
    input           i_rstn          ,
    //cfg port                      
    input   [5:0]   i_ppuctrl       ,    
    input   [7:0]   i_ppumask       ,
    input   [7:0]   i_ppuscrollX    ,
    input   [7:0]   i_ppuscrollY    ,
    input           i_force_rld     ,
    input           i_vblank        ,
    output          o_spr_ovfl      ,
    output          o_spr_0hit      ,
    output          o_rde_run       ,
    //vram port                     
    output  reg [11:0]  o_pt_addr       ,
    input       [15:0]  i_pt_rdata      ,
    output      [11:0]  o_nt_addr       ,
    input       [7:0]   i_nt_rdata      ,
    output      [4:0]   o_plt_addr      ,
    input       [7:0]   i_plt_rdata     ,
    output      [5:0]   o_oam_addr  ,
    input       [31:0]  i_oam_rdata ,
    output      [2:0]   o_oam2_addr ,
    output      [31:0]  o_oam2_wdata,
    output              o_oam2_we   ,
    input       [31:0]  i_oam2_rdata,
    //vout port                     
    output  [16:0]  o_vbuf_addr     ,
    output          o_vbuf_we       ,
    output  [7:0]   o_vbuf_wdata    
);

parameter [8:0] SCAN_X_MAX = 9'd319;

wire[1:0]   c_nt_base   ;
wire        c_spr_pt_sel;
wire        c_bg_pt_sel ;
wire        c_patt_sz   ;//sprite only
//wire        c_high_b    ;
//wire        c_high_g    ;
//wire        c_high_r    ;
wire        c_spr_ena   ;
wire        c_bg_ena    ;
wire        c_spr_clip  ;
wire        c_bg_clip   ;
//wire        c_gray    ;
wire[4:0]   c_scrollX   ;
wire[2:0]   c_fineX     ;
wire[4:0]   c_scrollY   ;
wire[2:0]   c_fineY     ;
reg         r_vblank    ;
reg         rr_vblank   ;
//scanline counters.
reg [8:0] r_scan_x; //0-255 is renderring period, 255- is spr preprocessing period.
reg [8:0] rr_scan_x;
reg [8:0] r_scan_y; //0-239 is renderring period, 240- is idle and vblank period.
reg [8:0] rr_scan_y;

reg r_rde_run;
reg [4:0] r_ntX;
reg [2:0] r_fineX;
reg [4:0] r_ntY;
reg [2:0] r_fineY;
reg [1:0] r_nt_base;
reg [9:0] r_attr_addr;
wire      c_pixel_calc;
reg [3:0]  c_bg_pixel;
reg [11:0] c_spr_pt_addr;

reg [15:0] r_patt_shft_H;
reg [15:0] r_patt_shft_L;
reg [15:0] r_attr_shft_H;
reg [15:0] r_attr_shft_L;

reg [3:0]  r_oam2_eaddr;

wire [8:0]c_oam_deltaY;
wire c_oam_in_range;
wire c_oam_good;
//reg [8:0] r_scan_y_next;
reg       r_spr_ovfl;
reg       r_spr_0hit;
reg       r_spr_eva_period;
wire      c_sprt_run;
reg [7:0] c_sprt_xcnt_we;
reg [7:0] r_sprt_xcnt_we;
reg [7:0] r_sprt_pt_we;
wire      c_spr_0hit;
wire        c_sprt_0priority    ;
wire[3:0]   c_sprt_0pattern     ;
wire        c_sprt_0show        ;
wire        c_sprt_1priority    ;
wire[3:0]   c_sprt_1pattern     ;
wire        c_sprt_1show        ;
wire        c_sprt_2priority    ;
wire[3:0]   c_sprt_2pattern     ;
wire        c_sprt_2show        ;
wire        c_sprt_3priority    ;
wire[3:0]   c_sprt_3pattern     ;
wire        c_sprt_3show        ;
wire        c_sprt_4priority    ;
wire[3:0]   c_sprt_4pattern     ;
wire        c_sprt_4show        ;
wire        c_sprt_5priority    ;
wire[3:0]   c_sprt_5pattern     ;
wire        c_sprt_5show        ;
wire        c_sprt_6priority    ;
wire[3:0]   c_sprt_6pattern     ;
wire        c_sprt_6show        ;
wire        c_sprt_7priority    ;
wire[3:0]   c_sprt_7pattern     ;
wire        c_sprt_7show        ;
wire[15:0]  c_sprt_pt_in       ;
reg [31:0]  r_oam2_rdata         ;

reg         r_oam_primary   ;
reg         r_sprt_0in0     ;
wire        c_sprt_0primary ;

wire [8:0]  c_oam2_deltaY;
wire [3:0]  c_sprt_pattern;
wire        c_sprt_priority;
wire [3:0]  c_sprt_pattclip;
wire        c_sprt_prioclip;
wire [4:0]  c_mixed_pattern;

reg    r_vbuf_page;
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

assign c_patt_sz    = i_ppuctrl[5];
assign c_bg_pt_sel  = i_ppuctrl[4];
assign c_spr_pt_sel = i_ppuctrl[3];
assign c_nt_base    = i_ppuctrl[1:0];
//assign c_high_b     = i_ppumask[7];
//assign c_high_g     = i_ppumask[6];
//assign c_high_r     = i_ppumask[5];
assign c_spr_ena    = i_ppumask[4];
assign c_bg_ena     = i_ppumask[3];
assign c_spr_clip   = i_ppumask[2];
assign c_bg_clip    = i_ppumask[1];
//assign c_gray       = i_ppumask[0];
assign c_scrollX    = i_ppuscrollX[7:3];
assign c_fineX      = i_ppuscrollX[2:0];
assign c_scrollY    = i_ppuscrollY[7:3];
assign c_fineY      = i_ppuscrollY[2:0];



//vblank start
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_vblank <= 1'b0;
        rr_vblank <= 1'b0;
    end
    else begin
        r_vblank <= i_vblank;
        rr_vblank <= r_vblank;
    end
end

//rde ena
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_rde_run <= 1'b0;
    end
    else begin
        if(~rr_vblank & r_vblank)
            r_rde_run <= 1'b1;
        else if(r_scan_y==9'd239 && r_scan_x==SCAN_X_MAX)
            r_rde_run <= 1'b0;
    end
end


//scanline counters
//scanline x
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_scan_x <= 9'h0;
    end
    else begin
        if (~rr_vblank & r_vblank)
            r_scan_x <= 9'h0;
        else if (r_rde_run) begin
            if (r_scan_x==SCAN_X_MAX)
                r_scan_x <= 9'h0;
            else
                r_scan_x <= r_scan_x + 9'h1;
        end
    end
end
//scanline y
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_scan_y <= 9'h0;
    end
    else begin
        if(~rr_vblank & r_vblank)
            r_scan_y <= 9'd240;
        else if(r_rde_run) begin
            if(r_scan_x==SCAN_X_MAX) begin
                if (r_scan_y==9'd261)
                    r_scan_y <= 9'h0;
                else
                    r_scan_y <= r_scan_y + 9'h1;
            end
        end
    end
end

/*
 scanlines 9'h105, 9'h000 - 9'h0EF are renderred scanlines.
 scan_x 9'h0 - 9'hff are pixel calculation cycles in a scanline.
*/

/*******************************************************

                background render
                
********************************************************/
assign c_pixel_calc = (r_scan_y<9'd240 | (r_scan_y[8:0]==9'd261)) & (~r_scan_x[8] | (r_scan_x[8:4]==5'b10001)) ;
//PatternTable shifter
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_patt_shft_H <= 16'h0;
        r_patt_shft_L <= 16'h0;
    end
    else begin
        if( c_pixel_calc ) begin
            if((r_scan_x[2:0]==3'h7)) begin
                r_patt_shft_H[7:0] <= i_pt_rdata[15:8];
                r_patt_shft_L[7:0] <= i_pt_rdata[7:0];
                r_patt_shft_H[15:8] <= r_patt_shft_H[14:7];
                r_patt_shft_L[15:8] <= r_patt_shft_L[14:7];
            end
            else begin
                r_patt_shft_H <= {r_patt_shft_H[14:0], 1'b0};
                r_patt_shft_L <= {r_patt_shft_L[14:0], 1'b0};
            end
        end
    end
end
//AttrTable shifter
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_attr_shft_H <= 16'h0;
        r_attr_shft_L <= 16'h0;
    end
    else begin
        if( c_pixel_calc ) begin
            if( (r_scan_x[2:0]==3'h7)) begin
                r_attr_shft_H[7:0] <= {r_ntY[1], r_ntX[1]}==2'b00 ? {8{i_nt_rdata[1]}}:
                                      {r_ntY[1], r_ntX[1]}==2'b01 ? {8{i_nt_rdata[3]}}:
                                      {r_ntY[1], r_ntX[1]}==2'b10 ? {8{i_nt_rdata[5]}}:
                                      {8{i_nt_rdata[7]}};
                r_attr_shft_L[7:0] <= {r_ntY[1], r_ntX[1]}==2'b00 ? {8{i_nt_rdata[0]}}:
                                      {r_ntY[1], r_ntX[1]}==2'b01 ? {8{i_nt_rdata[2]}}:
                                      {r_ntY[1], r_ntX[1]}==2'b10 ? {8{i_nt_rdata[4]}}:
                                      {8{i_nt_rdata[6]}};
                r_attr_shft_H[15:8] <= r_attr_shft_H[14:7];
                r_attr_shft_L[15:8] <= r_attr_shft_L[14:7];
            end
            else begin
                r_attr_shft_H <= {r_attr_shft_H[14:0], 1'b0};
                r_attr_shft_L <= {r_attr_shft_L[14:0], 1'b0};
            end
        end
    end
end

//pipeline ntX and ntY and nt_base// that's part of loopyV
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_ntX <= 5'h0;
        r_fineX <= 3'h0;
        r_ntY <= 5'h0;
        r_fineY <= 3'h0;
        r_nt_base <= 2'b00;
    end
    else begin
        /*
        if ((r_scan_y[8:0]==9'd260) & (r_scan_x==SCAN_X_MAX)) begin
            r_ntX <= c_scrollX + 5'h1;
            r_fineX <= c_fineX;
            {r_ntY, r_fineY} <= {c_scrollY, c_fineY} - 8'h1;
        end
        else if (~r_scan_x[8]) begin
            if((r_scan_x[2:0]==3'h4)) begin
                r_ntX <= r_ntX + 5'h1;
            end
            
            if((r_scan_x[8:0]==8'hF4)) begin
                r_fineY <= r_fineY + 3'h1;
                if (r_fineY==3'h7) begin
                    if (r_ntY==5'd29)
                        r_ntY <= 5'h0;
                    else
                        r_ntY <= r_ntY + 5'h1;
                end
            end
        end
        */
        if((r_scan_y[8:0]==9'd261 && r_scan_x[8:0]==9'h10F) | i_force_rld) begin
            {r_ntY, r_fineY} <= {c_scrollY, c_fineY};
            r_nt_base[1] <= c_nt_base[1];
        end
        else if(r_scan_x[8:0]==9'h100) begin
            r_fineY <= r_fineY + 3'h1;
            if (r_fineY==3'h7) begin
                if (r_ntY==5'd29) begin
                    r_ntY <= 5'h0;
                    r_nt_base[1] <= ~r_nt_base[1];
                end
                else begin
                    r_ntY <= r_ntY + 5'h1;
                end
            end
        end
        
        if((r_scan_x[8:0]==9'h101) | i_force_rld) begin
            r_ntX <= c_scrollX;
            r_fineX <= c_fineX;
            r_nt_base[0] <= c_nt_base[0];
        end
        else if(~r_scan_x[8] | (r_scan_x[8:4]==5'b10001)) begin
            if(r_scan_x[2:0]==3'h7) begin
                r_ntX <= r_ntX + 5'h1;
                if(r_ntX==5'd31) begin
                    r_nt_base[0] <= ~r_nt_base[0];
                end
            end
        end
    end
end

//NameTable base
/*
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_nt_base <= 2'b00;
    end
    else begin
        if ((r_scan_y[8:0]==9'd260) & (r_scan_x==SCAN_X_MAX)) begin
            r_nt_base <= c_nt_base;
        end
        else if(~r_scan_x[8] & r_scan_y<9'd240)begin
            if((r_scan_x[2:0]==3'h4) & (r_ntX==5'd31)) begin
                if(r_scan_x[7:3]==5'b11110)
                    r_nt_base[0] <= c_nt_base[0];
                else
                    r_nt_base[0] <= ~r_nt_base[0];
            end
            
            if((r_scan_x[7:0]==8'hF4) & (r_fineY==3'h7) & (r_ntY==5'd29)) begin
                r_nt_base[1] <= ~r_nt_base[1];
            end
        end
    end
end
*/

//AttrTable address, ready after step5
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_attr_addr <= 10'h0;
    end
    else begin
        if( c_pixel_calc ) begin
            if (r_scan_x[2:0]==3'h5) begin
                r_attr_addr = {4'b1111, r_ntY[4:2], r_ntX[4:2]};
            end
        end
    end
end

//NameTable and AttrTable access
assign o_nt_addr[11:10] = r_nt_base;
assign o_nt_addr[9:0] = ~c_pixel_calc ? 10'h0 :
                        r_scan_x[2:0]==3'h5 ? {r_ntY, r_ntX} :
                        r_scan_x[2:0]==3'h6 ? r_attr_addr :
                        10'h0;


//pattern table access
//r_scan_x 00-FF is background period.
always @ ( * ) begin
    if ( c_pixel_calc ) begin
        if (r_scan_x[2:0]==3'h6) begin
            //if(c_patt_sz) begin //8x16
            //    o_pt_addr = {i_nt_rdata[0], i_nt_rdata[7:1], r_ntY[0], r_fineY};
            //end
            //else begin //8x8
                o_pt_addr = {c_bg_pt_sel, i_nt_rdata[7:0], r_fineY};
            //end
        end
        else begin
            o_pt_addr = 12'h0;
        end
    end
    else begin
        o_pt_addr = c_spr_pt_addr;
    end
end

//////////////////////////////////background pixel result///////////////////////////////////////////////////
always @ ( * ) begin
    case (r_fineX)
        3'h0:   c_bg_pixel = ~c_bg_clip & (r_scan_x<8) ? 4'h0 : {r_attr_shft_H[15], r_attr_shft_L[15], r_patt_shft_H[15], r_patt_shft_L[15]};
        3'h1:   c_bg_pixel = ~c_bg_clip & (r_scan_x<8) ? 4'h0 : {r_attr_shft_H[14], r_attr_shft_L[14], r_patt_shft_H[14], r_patt_shft_L[14]};
        3'h2:   c_bg_pixel = ~c_bg_clip & (r_scan_x<8) ? 4'h0 : {r_attr_shft_H[13], r_attr_shft_L[13], r_patt_shft_H[13], r_patt_shft_L[13]};
        3'h3:   c_bg_pixel = ~c_bg_clip & (r_scan_x<8) ? 4'h0 : {r_attr_shft_H[12], r_attr_shft_L[12], r_patt_shft_H[12], r_patt_shft_L[12]};
        3'h4:   c_bg_pixel = ~c_bg_clip & (r_scan_x<8) ? 4'h0 : {r_attr_shft_H[11], r_attr_shft_L[11], r_patt_shft_H[11], r_patt_shft_L[11]};
        3'h5:   c_bg_pixel = ~c_bg_clip & (r_scan_x<8) ? 4'h0 : {r_attr_shft_H[10], r_attr_shft_L[10], r_patt_shft_H[10], r_patt_shft_L[10]};
        3'h6:   c_bg_pixel = ~c_bg_clip & (r_scan_x<8) ? 4'h0 : {r_attr_shft_H[ 9], r_attr_shft_L[ 9], r_patt_shft_H[ 9], r_patt_shft_L[ 9]};
     default:   c_bg_pixel = ~c_bg_clip & (r_scan_x<8) ? 4'h0 : {r_attr_shft_H[ 8], r_attr_shft_L[ 8], r_patt_shft_H[ 8], r_patt_shft_L[ 8]};
    endcase
end
///////////////////////////////////////////////////////////////////////////////////////////////////////////
/*******************************************************

                sprites render
                
********************************************************/
//spr evaluation

//the next scanline, used for sprite evaluation.
//always @ ( posedge i_clk or negedge i_rstn) begin
//    if(~i_rstn) begin
//        r_scan_y_next <= 9'h0;
//    end
//    else begin
//        if(r_scan_y==9'd261)
//            r_scan_y_next <= 9'h0;
//        else
//            r_scan_y_next <= r_scan_y + 9'h1;
//    end
//end

assign  o_oam_addr = r_scan_x[8:6] == 3'b001 ? r_scan_x[5:0] : 6'h0;
//assign  c_oam_deltaY = r_scan_y_next - {1'b0, i_oam_rdata[7:0]};
assign  c_oam_deltaY = r_scan_y - {1'b0, i_oam_rdata[7:0]};
assign  c_oam_in_range = (i_oam_rdata[7:4]==4'hF) | (i_oam_rdata[7:0]==8'h0)? 1'b0:
                         c_patt_sz ? c_oam_deltaY[8:4] == 5'h0 :
                         c_oam_deltaY[8:3]==6'h0;
//assign  c_oam_good = c_oam_in_range & ~r_oam2_eaddr[3] & (r_scan_y_next<9'd240);
assign  c_oam_good = c_oam_in_range & ~r_oam2_eaddr[3] & (r_scan_y<9'd240);

//spr evaluation period,  valid time  of  c_oam_in_range and c_oam_good 
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_spr_eva_period <= 1'b0;
    end
    else begin
        r_spr_eva_period <= (r_scan_x[8:6]==3'b001) & ((r_scan_y<9'd240));
    end
end

//second oam eva addr
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_oam2_eaddr <= 4'h0;
    end
    else begin
        if(r_scan_x==SCAN_X_MAX)
            r_oam2_eaddr <= 4'h0;
        else if(c_oam_good & r_spr_eva_period)
            r_oam2_eaddr <= r_oam2_eaddr + 4'h1;
    end
end

//spr overflow flag
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_spr_ovfl <= 1'b0;
    end
    else begin
        if((r_scan_y[8:0]==9'd260) & (r_scan_x==SCAN_X_MAX))
            r_spr_ovfl <= 1'b0;
        else if(r_oam2_eaddr[3] & c_oam_in_range & r_spr_eva_period & r_scan_y[8:0]<9'd240)
            r_spr_ovfl <= 1'b1;
    end
end

assign o_oam2_addr = r_scan_x[7:3] == 5'h0 ? r_scan_x[2:0] : r_oam2_eaddr[2:0];
assign o_oam2_wdata = r_scan_x[8:3] ==6'h0 ? 32'hffffffff : i_oam_rdata;
assign o_oam2_we = r_scan_x[8:3]==6'h0 ? 1'b1 : 
                   r_spr_eva_period ? c_oam_good :
                   1'b0 ;

//primary sprite flag. the first sprite in OAM
always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_oam_primary <= 1'b0;
    end
    else begin
        if(o_oam_addr==6'h0)
            r_oam_primary <= 1'b1;
        else 
            r_oam_primary <= 1'b0;
    end
end
//primary sprite in range: indicate that the first sprite in oam2 is primary.
always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_sprt_0in0 <= 1'b0;
    end
    else begin
        if((o_oam2_addr==3'h0) & o_oam2_we) begin
            if(r_oam_primary)
                r_sprt_0in0 <= 1'b1;
            else 
                r_sprt_0in0 <= 1'b0;
        end
    end
end

//pipeline spr
assign c_sprt_run = ~r_scan_x[8];
always @ ( * ) begin
    if(r_scan_x[8:3]==6'b100000) begin
        case(r_scan_x[2:0])
            3'h0:   c_sprt_xcnt_we = 8'b00000001;
            3'h1:   c_sprt_xcnt_we = 8'b00000010;
            3'h2:   c_sprt_xcnt_we = 8'b00000100;
            3'h3:   c_sprt_xcnt_we = 8'b00001000;
            3'h4:   c_sprt_xcnt_we = 8'b00010000;
            3'h5:   c_sprt_xcnt_we = 8'b00100000;
            3'h6:   c_sprt_xcnt_we = 8'b01000000;
         default:   c_sprt_xcnt_we = 8'b10000000;
        endcase
    end
    else begin
        c_sprt_xcnt_we = 8'b00000000;
    end
end

//assign  c_oam2_deltaY = r_scan_y_next - {1'b0, i_oam2_rdata[7:0]};
assign  c_oam2_deltaY = r_scan_y - {1'b0, i_oam2_rdata[7:0]};

always @ ( * ) begin
    if(c_patt_sz) begin //8x16
        if(i_oam2_rdata[23]) //flip Y
            c_spr_pt_addr = {i_oam2_rdata[8], i_oam2_rdata[15:9], 4'b1111 - c_oam2_deltaY[3:0]};
        else //normal
            c_spr_pt_addr = {i_oam2_rdata[8], i_oam2_rdata[15:9], c_oam2_deltaY[3:0]};
    end
    else begin  //8x8
        if(i_oam2_rdata[23]) //flip Y
            c_spr_pt_addr = {c_spr_pt_sel, i_oam2_rdata[15:8], 3'b111 - c_oam2_deltaY[2:0]};
        else //normal
            c_spr_pt_addr = {c_spr_pt_sel, i_oam2_rdata[15:8], c_oam2_deltaY[2:0]};
    end
end

always @(posedge i_clk) begin
    r_oam2_rdata <= i_oam2_rdata;
end

always @(posedge i_clk) begin
    r_sprt_xcnt_we <= c_sprt_xcnt_we;
    r_sprt_pt_we <= r_sprt_xcnt_we;
end

assign c_sprt_pt_in = r_oam2_rdata[31:0]==32'hffffffff ? 16'h0 : i_pt_rdata;
/////////////////////////////sprites pixel result/////////////////////////////////
assign c_sprt_pattern = c_sprt_0show & (c_sprt_0pattern[1:0]!=2'h0) ? c_sprt_0pattern :
                        c_sprt_1show & (c_sprt_1pattern[1:0]!=2'h0) ? c_sprt_1pattern :
                        c_sprt_2show & (c_sprt_2pattern[1:0]!=2'h0) ? c_sprt_2pattern :
                        c_sprt_3show & (c_sprt_3pattern[1:0]!=2'h0) ? c_sprt_3pattern :
                        c_sprt_4show & (c_sprt_4pattern[1:0]!=2'h0) ? c_sprt_4pattern :
                        c_sprt_5show & (c_sprt_5pattern[1:0]!=2'h0) ? c_sprt_5pattern :
                        c_sprt_6show & (c_sprt_6pattern[1:0]!=2'h0) ? c_sprt_6pattern :
                        c_sprt_7show & (c_sprt_7pattern[1:0]!=2'h0) ? c_sprt_7pattern :
                        4'h0;

assign c_sprt_priority= c_sprt_0show & (c_sprt_0pattern[1:0]!=2'h0) ? c_sprt_0priority :
                        c_sprt_1show & (c_sprt_1pattern[1:0]!=2'h0) ? c_sprt_1priority :
                        c_sprt_2show & (c_sprt_2pattern[1:0]!=2'h0) ? c_sprt_2priority :
                        c_sprt_3show & (c_sprt_3pattern[1:0]!=2'h0) ? c_sprt_3priority :
                        c_sprt_4show & (c_sprt_4pattern[1:0]!=2'h0) ? c_sprt_4priority :
                        c_sprt_5show & (c_sprt_5pattern[1:0]!=2'h0) ? c_sprt_5priority :
                        c_sprt_6show & (c_sprt_6pattern[1:0]!=2'h0) ? c_sprt_6priority :
                        c_sprt_7show & (c_sprt_7pattern[1:0]!=2'h0) ? c_sprt_7priority :
                        1'b1;
                        
assign c_sprt_pattclip = c_spr_clip ? c_sprt_pattern :
                         r_scan_x<8 ? 4'h0 :
                         c_sprt_pattern;

assign c_sprt_prioclip = c_spr_clip ? c_sprt_priority :
                         r_scan_x<8 ? 1'b1 :
                         c_sprt_priority;
                         
//////////////////////////////////////////////////////////////////////////////////

/*******************************************************

                mixer
                
********************************************************/
//sprite 0hit flag
/*
For sprite 0 hit to happen at a particular pixel (x, y), the following must be true:
The background must be enabled.
Sprites must be enabled.
The pixel must be in range of sprite 0. This allows the CPU to run ahead from the top
 of the picture to the top of sprite 0 and from the bottom of sprite 0 to the bottom of the picture.
The pixel in the background must be opaque.
The pixel in sprite 0, as flipped, must be opaque.
x must be less than or equal to 254 (no sprite 0 hit on last pixel).
If background or sprite clipping is enabled, x must be greater than or equal to 8.
*/
assign c_spr_0hit = c_bg_ena &
                    c_spr_ena &
                    c_sprt_0primary & 
                    c_sprt_0show &
                    (c_sprt_0pattern[1:0]!=2'h0) &
                    (c_bg_pixel[1:0]!=2'h0) &
                    (r_scan_x<9'd255) &
                    (r_scan_y<9'd240) &
                    (~c_spr_clip | (r_scan_x>=9'd8))
                    ;

always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_spr_0hit <= 1'b0;
    end
    else begin
        if((r_scan_y[8:0]==9'd260) & (r_scan_x==SCAN_X_MAX))
            r_spr_0hit <= 1'b0;
        else if(c_spr_0hit)
            r_spr_0hit <= 1'b1;
    end
end

assign c_mixed_pattern = (~c_spr_ena & ~c_bg_ena) ? 5'h0:
                         (c_spr_ena & ~c_bg_ena) ? {1'b1, c_sprt_pattclip} :
                         (~c_spr_ena & c_bg_ena) ? {1'b0, c_bg_pixel} :
                        ~c_sprt_prioclip ? {1'b1, c_sprt_pattclip}:
                         c_bg_pixel[1:0]==2'h0 ? {1'b1, c_sprt_pattclip}:
                         {1'b0, c_bg_pixel};

assign o_plt_addr = c_mixed_pattern;


/*******************************************************

                send to vbuf
                
********************************************************/

always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        rr_scan_x <= 9'h0;
        rr_scan_y <= 9'h0;
    end
    else begin
        rr_scan_x <= r_scan_x;
        rr_scan_y <= r_scan_y;
    end
end

//vbuf page, starts at even frame, lcd part starts at odd frame
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_vbuf_page <= 1'b0;
    end
    else begin
        if(~rr_vblank & r_vblank)
            r_vbuf_page <= ~r_vbuf_page;
    end
end

assign o_vbuf_addr = {r_vbuf_page, rr_scan_y[7:0], rr_scan_x[7:0]};
assign o_vbuf_wdata = i_plt_rdata;
assign o_vbuf_we  = (rr_scan_y<9'd240) & ~rr_scan_x[8];

//status outputs
assign o_spr_ovfl = r_spr_ovfl;
assign o_spr_0hit = r_spr_0hit;

assign o_rde_run = r_rde_run;



ppu_spr_ppl spr_ppl_0(
    .i_clk          (i_clk),//input           
    .i_rstn         (i_rstn),//input           
    .i_primary      (r_sprt_0in0),
    .i_xcnt         (i_oam2_rdata[31:24]),//input [7:0]     
    .i_xcnt_wr      (r_sprt_xcnt_we[0]),//input           
    .i_attr         (i_oam2_rdata[23:16]),//input [7:0]     
    .i_attr_we      (r_sprt_xcnt_we[0]),//input           
    .i_patt         (c_sprt_pt_in),//input [15:0]    
    .i_patt_we      (r_sprt_pt_we[0]),//input           
    .i_run          (c_sprt_run),//input           
    .o_primary      (c_sprt_0primary),
    .o_priority     (c_sprt_0priority),//output          
    .o_pattern      (c_sprt_0pattern ),//output[3:0]     
    .o_show         (c_sprt_0show    ) //output          
);

ppu_spr_ppl spr_ppl_1(
    .i_clk          (i_clk),//input           
    .i_rstn         (i_rstn),//input           
    .i_primary      (1'b0),
    .i_xcnt         (i_oam2_rdata[31:24]),//input [7:0]     
    .i_xcnt_wr      (r_sprt_xcnt_we[1]),//input           
    .i_attr         (i_oam2_rdata[23:16]),//input [7:0]     
    .i_attr_we      (r_sprt_xcnt_we[1]),//input           
    .i_patt         (c_sprt_pt_in),//input [15:0]    
    .i_patt_we      (r_sprt_pt_we[1]),//input           
    .i_run          (c_sprt_run),//input           
    .o_primary      (),
    .o_priority     (c_sprt_1priority),//output          
    .o_pattern      (c_sprt_1pattern ),//output[3:0]     
    .o_show         (c_sprt_1show    ) //output  
);

ppu_spr_ppl spr_ppl_2(
    .i_clk          (i_clk),//input           
    .i_rstn         (i_rstn),//input           
    .i_primary      (1'b0),
    .i_xcnt         (i_oam2_rdata[31:24]),//input [7:0]     
    .i_xcnt_wr      (r_sprt_xcnt_we[2]),//input           
    .i_attr         (i_oam2_rdata[23:16]),//input [7:0]     
    .i_attr_we      (r_sprt_xcnt_we[2]),//input           
    .i_patt         (c_sprt_pt_in),//input [15:0]    
    .i_patt_we      (r_sprt_pt_we[2]),//input           
    .i_run          (c_sprt_run),//input           
    .o_primary      (),
    .o_priority     (c_sprt_2priority),//output          
    .o_pattern      (c_sprt_2pattern ),//output[3:0]     
    .o_show         (c_sprt_2show    ) //output   
);

ppu_spr_ppl spr_ppl_3(
    .i_clk          (i_clk),//input           
    .i_rstn         (i_rstn),//input           
    .i_primary      (1'b0),
    .i_xcnt         (i_oam2_rdata[31:24]),//input [7:0]     
    .i_xcnt_wr      (r_sprt_xcnt_we[3]),//input           
    .i_attr         (i_oam2_rdata[23:16]),//input [7:0]     
    .i_attr_we      (r_sprt_xcnt_we[3]),//input           
    .i_patt         (c_sprt_pt_in),//input [15:0]    
    .i_patt_we      (r_sprt_pt_we[3]),//input           
    .i_run          (c_sprt_run),//input           
    .o_primary      (),
    .o_priority     (c_sprt_3priority),//output          
    .o_pattern      (c_sprt_3pattern ),//output[3:0]     
    .o_show         (c_sprt_3show    ) //output  
);

ppu_spr_ppl spr_ppl_4(
    .i_clk          (i_clk),//input           
    .i_rstn         (i_rstn),//input           
    .i_primary      (1'b0),
    .i_xcnt         (i_oam2_rdata[31:24]),//input [7:0]     
    .i_xcnt_wr      (r_sprt_xcnt_we[4]),//input           
    .i_attr         (i_oam2_rdata[23:16]),//input [7:0]     
    .i_attr_we      (r_sprt_xcnt_we[4]),//input           
    .i_patt         (c_sprt_pt_in),//input [15:0]    
    .i_patt_we      (r_sprt_pt_we[4]),//input           
    .i_run          (c_sprt_run),//input           
    .o_primary      (),
    .o_priority     (c_sprt_4priority),//output          
    .o_pattern      (c_sprt_4pattern ),//output[3:0]     
    .o_show         (c_sprt_4show    ) //output  
);

ppu_spr_ppl spr_ppl_5(
    .i_clk          (i_clk),//input           
    .i_rstn         (i_rstn),//input           
    .i_primary      (1'b0),
    .i_xcnt         (i_oam2_rdata[31:24]),//input [7:0]     
    .i_xcnt_wr      (r_sprt_xcnt_we[5]),//input           
    .i_attr         (i_oam2_rdata[23:16]),//input [7:0]     
    .i_attr_we      (r_sprt_xcnt_we[5]),//input           
    .i_patt         (c_sprt_pt_in),//input [15:0]    
    .i_patt_we      (r_sprt_pt_we[5]),//input           
    .i_run          (c_sprt_run),//input           
    .o_primary      (),
    .o_priority     (c_sprt_5priority),//output          
    .o_pattern      (c_sprt_5pattern ),//output[3:0]     
    .o_show         (c_sprt_5show    ) //output  
);

ppu_spr_ppl spr_ppl_6(
    .i_clk          (i_clk),//input           
    .i_rstn         (i_rstn),//input           
    .i_primary      (1'b0),
    .i_xcnt         (i_oam2_rdata[31:24]),//input [7:0]     
    .i_xcnt_wr      (r_sprt_xcnt_we[6]),//input           
    .i_attr         (i_oam2_rdata[23:16]),//input [7:0]     
    .i_attr_we      (r_sprt_xcnt_we[6]),//input           
    .i_patt         (c_sprt_pt_in),//input [15:0]    
    .i_patt_we      (r_sprt_pt_we[6]),//input           
    .i_run          (c_sprt_run),//input           
    .o_primary      (),
    .o_priority     (c_sprt_6priority),//output          
    .o_pattern      (c_sprt_6pattern ),//output[3:0]     
    .o_show         (c_sprt_6show    ) //output  
);

ppu_spr_ppl spr_ppl_7(
    .i_clk          (i_clk),//input           
    .i_rstn         (i_rstn),//input           
    .i_primary      (1'b0),
    .i_xcnt         (i_oam2_rdata[31:24]),//input [7:0]     
    .i_xcnt_wr      (r_sprt_xcnt_we[7]),//input           
    .i_attr         (i_oam2_rdata[23:16]),//input [7:0]     
    .i_attr_we      (r_sprt_xcnt_we[7]),//input           
    .i_patt         (c_sprt_pt_in),//input [15:0]    
    .i_patt_we      (r_sprt_pt_we[7]),//input           
    .i_run          (c_sprt_run),//input           
    .o_primary      (),
    .o_priority     (c_sprt_7priority),//output          
    .o_pattern      (c_sprt_7pattern ),//output[3:0]     
    .o_show         (c_sprt_7show    ) //output  
);
























endmodule
