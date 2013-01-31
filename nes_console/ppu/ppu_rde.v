module ppu_rde(
    input           i_clk           ,
    input           i_rstn          ,
    //cfg port                      
    input   [5:0]   i_ppuctrl       ,    
    input   [7:0]   i_ppumask       ,
    input   [7:0]   i_ppuscrollX    ,
    input   [7:0]   i_ppuscrollY    ,
    input           i_vblank        ,
    output          o_spr_ovfl      ,
    output          o_spr_0hit      ,
    //vram port                     
    output  reg [11:0]  o_pt_addr       ,
    input       [15:0]  i_pt_rdata      ,
    output      [11:0]  o_nt_addr       ,
    input       [7:0]   i_nt_rdata      ,
    output      [4:0]   o_plt_addr      ,
    input       [7:0]   i_plt_rdata     ,
    //vout port                     
    output  [16:0]  o_vbuf_addr     ,
    output          o_vbuf_we       ,
    output  [7:0]   o_vbuf_wdata    
);

parameter [8:0] SCAN_X_MAX = 9'd339;

wire[1:0]   c_nt_base   ;
wire        c_spr_pt_sel;
wire        c_bg_pt_sel ;
wire        c_patt_sz   ;
wire        c_high_b    ;
wire        c_high_g    ;
wire        c_high_r    ;
wire        c_spr_ena   ;
wire        c_bg_ena    ;
wire        c_spr_clip  ;
wire        c_bg_clip   ;
wire        c_gray      ;
wire[4:0]   c_scrollX   ;
wire[2:0]   c_fineX     ;
wire[4:0]   c_scrollY   ;
wire[2:0]   c_fineY     ;
reg         r_vblank    ;
reg         rr_vblank   ;
//scanline counters.
reg [8:0] r_scan_x; //0-255 is renderring period, 255- is spr preprocessing period.
reg [8:0] r_scan_y; //0-239 is renderring period, 240- is idle and vblank period.

reg r_rde_run;
reg [4:0] r_ntX;
reg [2:0] r_fineX;
reg [4:0] r_ntY;
reg [2:0] r_fineY;
reg [1:0] r_nt_base;
reg [9:0] r_attr_addr;
wire      c_pixel_calc;
reg [3:0]  c_bg_pixel;
wire[11:0] c_spr_pt_addr;

reg [15:0] r_patt_shft_H;
reg [15:0] r_patt_shft_L;
reg [15:0] r_attr_shft_H;
reg [15:0] r_attr_shft_L;

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

assign c_patt_sz    = i_ppuctrl[5];
assign c_bg_pt_sel  = i_ppuctrl[4];
assign c_spr_pt_sel = i_ppuctrl[3];
assign c_nt_base    = i_ppuctrl[1:0];
assign c_high_b     = i_ppumask[7];
assign c_high_g     = i_ppumask[6];
assign c_high_r     = i_ppumask[5];
assign c_spr_ena    = i_ppumask[4];
assign c_bg_ena     = i_ppumask[3];
assign c_spr_clip   = i_ppumask[2];
assign c_bg_clip    = i_ppumask[1];
assign c_gray       = i_ppumask[0];
assign c_scrollX    = i_ppuscrollX[7:3];
assign c_fineX      = i_ppuscrollX[2:0];
assign c_scrollY    = i_ppuscrollY[7:3];
assign c_fineY      = i_ppuscrollY[2:0];

//tamplate
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
    end
    else begin
    end
end

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
assign c_pixel_calc = (r_scan_y<9'd240 | (r_scan_y[8:0]==9'd261)) & ~r_scan_x[8] ;
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
            end
            else begin
                r_attr_shft_H <= {r_attr_shft_H[14:0], 1'b0};
                r_attr_shft_L <= {r_attr_shft_L[14:0], 1'b0};
            end
        end
    end
end

//pipeline ntX and ntY
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_ntX <= 5'h0;
        r_fineX <= 3'h0;
        r_ntY <= 5'h0;
        r_fineY <= 3'h0;
    end
    else begin
        if ((r_scan_y[8:0]==9'd260) & (r_scan_x==SCAN_X_MAX)) begin
            r_ntX <= c_scrollX + 5'h1;
            r_fineX <= c_fineX;
            {r_ntY, r_fineY} <= {c_scrollY, c_fineY} - 8'h1;
        end
        else if (~r_scan_x[8]) begin
            if((r_scan_x[2:0]==3'h4)) begin
                r_ntX <= r_ntX + 5'h1;
            end
            
            if((r_scan_x[7:0]==8'hF4)) begin
                r_fineY <= r_fineY + 3'h1;
                if((r_fineY==3'h7) & (r_ntY==5'd29))
                    r_ntY <= 5'h0;
                else
                    r_ntY <= r_ntY + 5'h1;
            end
        end
    end
end

//NameTable base
always @ ( posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_nt_base <= 2'b00;
    end
    else begin
        if ((r_scan_y[8:0]==9'd260) & (r_scan_x==SCAN_X_MAX)) begin
            r_nt_base<=c_nt_base;
        end
        else if(~r_scan_x[8] & r_scan_y<9'd240)begin
            if((r_scan_x[2:0]==3'h4) & (r_ntX==5'd31)) begin
                r_nt_base[0] <= ~r_nt_base[0];
            end
            
            if((r_scan_x[7:0]==8'hF4) & (r_fineY==3'h7) & (r_ntY==5'd29)) begin
                r_nt_base[1] <= ~r_nt_base[1];
            end
        end
    end
end

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
        if (r_scan_x[2:0]==3'h6)) begin
            if(c_patt_sz) begin //8x16
                o_pt_addr = {i_nt_rdata[0], i_nt_rdata[7:1], r_ntY[0], r_fineY};
            end
            else begin //8x8
                o_pt_addr = {c_bg_pt_sel, i_nt_rdata[7:0], r_fineY};
            end
        end
        else begin
            o_pt_addr = 12'h0;
        end
    end
    else begin
        o_pt_addr = c_spr_pt_addr;
    end
    //TODO : add sprites pt_addr compute here.
end

//background pixel result
always @ ( * ) begin
    case (r_fineX)
        3'h0:   c_bg_pixel = {r_attr_shft_H[15], r_attr_shft_L[15], r_patt_shft_H[15], r_patt_shft_L[15]};
        3'h1:   c_bg_pixel = {r_attr_shft_H[14], r_attr_shft_L[14], r_patt_shft_H[14], r_patt_shft_L[14]};
        3'h2:   c_bg_pixel = {r_attr_shft_H[13], r_attr_shft_L[13], r_patt_shft_H[13], r_patt_shft_L[13]};
        3'h3:   c_bg_pixel = {r_attr_shft_H[12], r_attr_shft_L[12], r_patt_shft_H[12], r_patt_shft_L[12]};
        3'h4:   c_bg_pixel = {r_attr_shft_H[11], r_attr_shft_L[11], r_patt_shft_H[11], r_patt_shft_L[11]};
        3'h5:   c_bg_pixel = {r_attr_shft_H[10], r_attr_shft_L[10], r_patt_shft_H[10], r_patt_shft_L[10]};
        3'h6:   c_bg_pixel = {r_attr_shft_H[ 9], r_attr_shft_L[ 9], r_patt_shft_H[ 9], r_patt_shft_L[ 9]};
     default:   c_bg_pixel = {r_attr_shft_H[ 8], r_attr_shft_L[ 8], r_patt_shft_H[ 8], r_patt_shft_L[ 8]};
    endcase
end



endmodule
