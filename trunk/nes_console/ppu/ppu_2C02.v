module ppu_2C02(
    input           i_cpu_clk       ,
    input           i_cpu_rstn      ,
    input           i_ppu_clk       ,
    input           i_ppu_rstn      ,
    input           i_lcd_clk       ,
    input           i_lcd_rstn      ,
    //slave port
    input   [15:0]  i_bus_addr      ,
    input           i_bus_wn        ,
    input   [7:0]   i_bus_wdata     ,
    output  [7:0]   o_ppu_rdata     ,
    //master port
    output          o_spr_req       ,
    input           i_spr_gnt       ,
    output  [15:0]  o_spr_addr      ,
    output          o_spr_wn        ,
    output  [7:0]   o_spr_wdata     ,
    input   [7:0]   i_spr_rdata     ,
    
    output          o_nmi_n         ,
    input   [2:0]   i_mirror_mode   ,
    
    output  [11:0]  o_sram_addr     ,
    output  [15:0]  o_sram_wdata    ,
    input   [15:0]  i_sram_rdata    ,
    output          o_sram_we_n     ,
    output          o_sram_oe_n     ,
    output          o_sram_ub_n     ,
    output          o_sram_lb_n     ,
    
    output [7:0]    o_lcd_r         ,
    output [7:0]    o_lcd_g         ,
    output [7:0]    o_lcd_b         ,
    output          o_lcd_hsd       ,
    output          o_lcd_vsd       ,
    
    input  [9:0]    i_jp_vec_1p     ,
    input  [9:0]    i_jp_vec_2p
);


wire[16:0]  c_vbuf_addr;
wire[7:0]   c_vbuf_hsv;
wire[16:0]  c_vbuf_waddr    ;
wire        c_vbuf_we       ;
wire[7:0]   c_vbuf_wdata    ;
wire        c_vblank;


wire[7:0]   c_oam_cfg_addr  ;
wire        c_oam_cfg_we    ;
wire[7:0]   c_oam_cfg_wdata ;
wire[7:0]   c_oam_cfg_rdata ;
wire[5:0]   c_oam_addr      ;
wire[31:0]  c_oam_rdata     ;

wire[15:0]  c_vram_addr     ;
wire        c_vram_we       ;
wire[7:0]   c_vram_wdata    ;
wire[7:0]   c_vram_rdata    ;
wire        c_2007_visit    ;

wire[5:0]   c_ppuctrl       ;    
wire[7:0]   c_ppumask       ;
wire[7:0]   c_ppuscrollX    ;
wire[7:0]   c_ppuscrollY    ;
wire        c_spr_ovfl      ;
wire        c_spr_0hit      ;

wire[11:0]  c_pt_addr       ;
wire[15:0]  c_pt_rdata      ;
wire[11:0]  c_nt_addr       ;
wire[7:0]   c_nt_rdata      ;
wire[4:0]   c_plt_addr      ;
wire[7:0]   c_plt_rdata     ;


/*
wire[23:0]  c_rom_q;
wire[14:0]  c_rom_addr;
*/

/*
assign c_rom_addr = {c_vbuf_addr[15:9], c_vbuf_addr[7:0]};
assign c_vbuf_hsv = c_rom_q[7:0];
*/
//assign o_nmi_n = 1'b1;

ppu_dma ppu_dma(
    .i_clk          (i_cpu_clk),//input           
    .i_rstn         (i_cpu_rstn),//input          
    .i_bus_addr     (i_bus_addr),//input   [15:0]  
    .i_bus_wn       (i_bus_wn),//input           
    .i_bus_wdata    (i_bus_wdata),//input   [7:0]   
    .o_spr_req      (o_spr_req),//output          
    .i_spr_gnt      (i_spr_gnt),//input           
    .o_spr_addr     (o_spr_addr),//output  [15:0]  
    .o_spr_wn       (o_spr_wn),//output          
    .o_spr_wdata    (o_spr_wdata),//output  [7:0]   
    .i_spr_rdata    (i_spr_rdata) //input   [7:0]   
);


ppu_cfg ppu_cfg(
    .i_cpu_clk      (i_cpu_clk),//input           
    .i_cpu_rstn     (i_cpu_rstn),//input           
    .i_bus_addr     (i_bus_addr),//input   [15:0]  
    .i_bus_wn       (i_bus_wn),//input           
    .i_bus_wdata    (i_bus_wdata),//input   [7:0]   
    .o_ppu_rdata    (o_ppu_rdata),//output  [7:0]   
    .o_oam_addr     (c_oam_cfg_addr ),//output  [7:0]   
    .o_oam_we       (c_oam_cfg_we   ),//output          
    .o_oam_wdata    (c_oam_cfg_wdata),//output  [7:0]   
    .i_oam_rdata    (c_oam_cfg_rdata),//input   [7:0]   
    .o_vram_addr    (c_vram_addr),//output  [15:0]  
    .o_vram_we      (c_vram_we),//output          
    .o_vram_wdata   (c_vram_wdata),//output  [7:0]   
    .i_vram_rdata   (c_vram_rdata),//input   [7:0]   
    .o_2007_visit   (c_2007_visit),//output
    .o_ppuctrl      (c_ppuctrl),//output  [5:0]   
    .o_ppumask      (c_ppumask),//output  [7:0]   
    .o_ppuscrollX   (c_ppuscrollX),//output  [7:0]   
    .o_ppuscrollY   (c_ppuscrollY),//output  [7:0]   
    .i_spr_ovfl     (c_spr_ovfl),//input
    .i_spr_0hit     (c_spr_0hit),//input
    .i_vblank       (c_vblank),//input
    .o_nmi_n        (o_nmi_n) //output
);

ppu_rde ppu_rde(
    .i_clk          (i_ppu_clk),//input           
    .i_rstn         (i_ppu_rstn),//input           
    .i_ppuctrl      (c_ppuctrl   ),//input   [5:0]       
    .i_ppumask      (c_ppumask   ),//input   [7:0]   
    .i_ppuscrollX   (c_ppuscrollX),//input   [7:0]   
    .i_ppuscrollY   (c_ppuscrollY),//input   [7:0]   
    .i_vblank       (c_vblank),//input
    .o_spr_ovfl     (c_spr_ovfl  ),//output          
    .o_spr_0hit     (c_spr_0hit  ),//output          
    .o_pt_addr      (c_pt_addr  ),//output  [11:0]  
    .i_pt_rdata     (c_pt_rdata ),//input   [15:0]  
    .o_nt_addr      (c_nt_addr  ),//output  [11:0]  
    .i_nt_rdata     (c_nt_rdata ),//input   [7:0]   
    .o_plt_addr     (c_plt_addr ),//output  [4:0]   
    .i_plt_rdata    (c_plt_rdata),//input   [7:0]   
    .o_vbuf_addr    (c_vbuf_waddr),//output  [16:0]  
    .o_vbuf_we      (c_vbuf_we   ),//output          
    .o_vbuf_wdata   (c_vbuf_wdata) //output  [7:0]   
);


ppu_vram ppu_vram(
    .i_cpu_clk          (i_cpu_clk), //input               
    .i_cpu_rstn         (i_cpu_rstn), //input               
    .i_ppu_clk          (i_ppu_clk), //input               
    .i_ppu_rstn         (i_ppu_rstn), //input               
    .i_vram_addr        (c_vram_addr), //input       [15:0]  
    .i_vram_we          (c_vram_we), //input               
    .i_vram_wdata       (c_vram_wdata), //input       [7:0]   
    .o_vram_rdata       (c_vram_rdata), //output      [7:0]   
    .i_2007_visit       (c_2007_visit), //input               
    .i_mirror_mode      (i_mirror_mode), //input       [2:0]   
    .i_pt_addr          (c_pt_addr  ), //input       [11:0]  
    .o_pt_rdata         (c_pt_rdata ), //output reg  [15:0]  
    .i_nt_addr          (c_nt_addr  ), //input       [11:0]  
    .o_nt_rdata         (c_nt_rdata ), //output      [7:0]   
    .i_plt_addr         (c_plt_addr ), //input       [4:0]   
    .o_plt_rdata        (c_plt_rdata), //output      [7:0]   
    .o_sram_addr        (o_sram_addr), //output      [11:0]  
    .o_sram_wdata       (o_sram_wdata), //output      [15:0]  
    .i_sram_rdata       (i_sram_rdata), //input       [15:0]  
    .o_sram_we_n        (o_sram_we_n), //output              
    .o_sram_oe_n        (o_sram_oe_n), //output              
    .o_sram_ub_n        (o_sram_ub_n), //output              
    .o_sram_lb_n        (o_sram_lb_n)  //output              
    
);


ppu_lcd_vout ppu_lcd_vout(
    .i_lcd_rstn     (i_lcd_rstn),//input           
    .i_lcd_clk      (i_lcd_clk),//input           
    .o_vbuf_addr    (c_vbuf_addr),//output [16:0]   
    .i_vbuf_hsv     (c_vbuf_hsv),//input  [7:0]    
    .o_lcd_r        (o_lcd_r),//output [7:0]    
    .o_lcd_g        (o_lcd_g),//output [7:0]    
    .o_lcd_b        (o_lcd_b),//output [7:0]    
    .o_lcd_hsd      (o_lcd_hsd),//output          
    .o_lcd_vsd      (o_lcd_vsd),//output          
    .o_vblank       (c_vblank),//output          
    .i_jp_vec_1p    (i_jp_vec_1p),//input  [9:0]    
    .i_jp_vec_2p    (i_jp_vec_2p) //input  [9:0]    
);


dpram_oam_256x8_64x32	ppu_oam (
	.address_a  (c_oam_cfg_addr  ),
	.address_b  (c_oam_addr  ),
	.clock_a    (i_cpu_clk  ),
	.clock_b    (i_ppu_clk  ),
	.data_a     (c_oam_cfg_wdata  ),
	.data_b     (32'b0),
	.wren_a     (c_oam_cfg_we  ),
	.wren_b     (1'b0),
	.q_a        (c_oam_cfg_rdata  ),
	.q_b        (c_oam_rdata  )
);


ppu_vbuf ppu_vbuf(
    .i_ppu_clk      (i_ppu_clk),//input           
    .i_lcd_clk      (i_lcd_clk),//input           
    .i_waddr        (c_vbuf_waddr),//input   [16:0]  
    .i_we           (c_vbuf_we   ),//input           
    .i_wdata        (c_vbuf_wdata),//input   [7:0]   
    .i_raddr        (c_vbuf_addr),//input   [16:0]  
    .o_rdata        (c_vbuf_hsv) //output  [7:0]   
);




















/*
rom_256x128x24	rom_256x128x24_inst (
	.address    ( c_rom_addr ),
	.clock      ( i_lcd_clk ),
	.q          ( c_rom_q )
);
*/

endmodule
