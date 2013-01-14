module ppu_2C02(
    input           i_cpu_clk   ,
    input           i_cpu_rstn  ,
    input           i_ppu_clk   ,
    input           i_ppu_rstn  ,
    input           i_lcd_clk   ,
    input           i_lcd_rstn  ,
        
    input  [15:0]   i_bus_addr  ,
    input   [7:0]   i_bus_wdata ,
    input           i_bus_wn    ,
    output  [7:0]   o_reg_rdata ,
    
    
    output          o_nmi_n     ,
    
    output [7:0]    o_lcd_r     ,
    output [7:0]    o_lcd_g     ,
    output [7:0]    o_lcd_b     ,
    output          o_lcd_hsd   ,
    output          o_lcd_vsd   ,
    
    input  [9:0]    i_jp_vec_1p ,
    input  [9:0]    i_jp_vec_2p
);


wire [16:0] c_vbuf_addr;
wire [7:0]  c_vbuf_hsv;

wire[23:0]  c_rom_q;
wire[14:0]  c_rom_addr;

assign c_rom_addr = {c_vbuf_addr[15:9], c_vbuf_addr[7:0]};
assign c_vbuf_hsv = c_rom_q[7:0];

assign o_nmi_n = 1'b1;

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
    .o_vblank       (),//output          
    .i_jp_vec_1p    (i_jp_vec_1p),//input  [9:0]    
    .i_jp_vec_2p    (i_jp_vec_2p) //input  [9:0]    
);


rom_256x128x24	rom_256x128x24_inst (
	.address    ( c_rom_addr ),
	.clock      ( i_lcd_clk ),
	.q          ( c_rom_q )
);
endmodule
