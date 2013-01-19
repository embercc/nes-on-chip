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
    output  [11:0]  o_pt_addr       ,
    input   [15:0]  i_pt_rdata      ,
    output  [11:0]  o_nt_addr       ,
    input   [7:0]   i_nt_rdata      ,
    output  [4:0]   o_plt_addr      ,
    input   [7:0]   i_plt_rdata     ,
    //vout port                     
    output  [16:0]  o_vbuf_addr     ,
    output          o_vbuf_we       ,
    output  [7:0]   o_vbuf_wdata    
);

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

endmodule
