module ppu_2C02(
    input           i_cpu_clk   ,
    input           i_cpu_rstn  ,
    input           i_ppu_clk   ,
    input           i_ppu_rstn  ,
    input           i_lcd_clk   ,
    input           i_lcd_rstn  ,
    //slave port
    input   [15:0]  i_bus_addr  ,
    input           i_bus_wn    ,
    input   [7:0]   i_bus_wdata ,
    output  [7:0]   o_ppu_rdata ,
    //master port
    output          o_spr_req   ,
    input           i_spr_gnt   ,
    output  [15:0]  o_spr_addr  ,
    output          o_spr_wn    ,
    output  [7:0]   o_spr_wdata ,
    input   [7:0]   i_spr_rdata ,
    
    output          o_nmi_n     ,
    
    output [7:0]    o_lcd_r     ,
    output [7:0]    o_lcd_g     ,
    output [7:0]    o_lcd_b     ,
    output          o_lcd_hsd   ,
    output          o_lcd_vsd   ,
    
    input  [9:0]    i_jp_vec_1p ,
    input  [9:0]    i_jp_vec_2p
);


wire[16:0]  c_vbuf_addr;
wire[7:0]   c_vbuf_hsv;
wire        c_vblank;

wire[7:0]   c_oam_cfg_addr  ;
wire        c_oam_cfg_we    ;
wire[7:0]   c_oam_cfg_wdata ;
wire[7:0]   c_oam_cfg_rdata ;
wire[5:0]   c_oam_addr      ;
wire[31:0]  c_oam_rdata     ;

wire[23:0]  c_rom_q;
wire[14:0]  c_rom_addr;


/*
assign c_rom_addr = {c_vbuf_addr[15:9], c_vbuf_addr[7:0]};
assign c_vbuf_hsv = c_rom_q[7:0];
*/
//assign o_nmi_n = 1'b1;



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
    .o_vram_addr    (),//output  [15:0]  
    .o_vram_we      (),//output          
    .o_vram_wdata   (),//output  [7:0]   
    .i_vram_rdata   (),//input   [7:0]   
    .i_spr_ovfl     (),//input
    .i_spr_0hit     (),//input
    .i_vblank       (c_vblank),//input
    .o_nmi_n        (o_nmi_n) //output
);



dpram_oam_256x8_64x32	oam_inst (
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
    .i_waddr        (),//input   [16:0]  
    .i_we           (),//input           
    .i_wdata        (),//input   [7:0]   
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
