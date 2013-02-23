module nes_console(
    input           i_rstn_nes      ,
    input           i_clk_cpu       ,
    input           i_clk_ppu       ,
    input           i_clk_lcd       ,
    
//chr-ram, drived by ppu
    output  [19:0]  o_sram_addr     ,
    output  [15:0]  o_sram_wdata    ,
    input   [15:0]  i_sram_rdata    ,
    output          o_sram_we_n     ,
    output          o_sram_oe_n     ,
    output          o_sram_ub_n     ,
    output          o_sram_lb_n     ,
//prg_rom, drived by cpu
    input   [1:0]   i_flash_bank    ,
    input   [2:0]   i_nrom_mirrmode ,
    input   [1:0]   i_nrom_gamesel  ,
    output  [22:0]  o_fl_addr       ,
    input   [7:0]   i_fl_rdata      ,
//LCD output
    output  [23:0]  o_lcd_pixel     ,//{r8, g8, b8}
    output          o_lcd_hsd       ,
    output          o_lcd_vsd       ,

//debug signals
    output  [15:0]  o_cpu_pc        ,
    output  [7:0]   o_cpu_sp        ,
    output  [7:0]   o_cpu_ir        ,
    output  [7:0]   o_cpu_p         ,
    input   [9:0]   i_jp_vec_1p     ,
    input   [9:0]   i_jp_vec_2p
);

wire[15:0]  c_cpu_addr;
wire        c_cpu_r_wn;
wire[7:0]   c_cpu_wdata;
wire[7:0]   c_cpu_rdata;
wire        c_cpu_pause;

wire[15:0]  c_bus_addr  ;
wire[7:0]   c_bus_wdata ;
wire        c_bus_r_wn  ;

wire[7:0]   c_ram_rdata ;
wire[7:0]   c_mmc_rdata;
wire[7:0]   c_apu_rdata;
wire[7:0]   c_jpd_rdata;
wire[7:0]   c_ppu_rdata;

wire[10:0]  c_ram_addr;
wire[7:0]   c_ram_din;
wire[7:0]   c_ram_q;
wire        c_ram_r_wn;

wire        c_dmc_req      ;
wire        c_dmc_gnt      ;
wire[15:0]  c_dmc_addr     ;
wire[7:0]   c_dmc_rdata    ;
wire        c_irq_apu_n;


wire        c_spr_req   ;
wire        c_spr_gnt   ;
wire[15:0]  c_spr_addr  ;
wire        c_spr_wn    ;
wire[7:0]   c_spr_wdata ;
wire[7:0]   c_spr_rdata ;

wire[2:0]   c_mirror_mode;

wire c_rstn_cpu;
wire c_rstn_ppu;
wire c_rstn_lcd;

wire c_irq_n;
wire c_irq_mmc_n;
wire c_nmi_n;
wire c_sram_wp;

/*
IRQ open collector
*/
assign c_irq_n = c_irq_mmc_n & c_irq_apu_n;


rstn_sync rsync_lcd(
    .i_clk      (i_clk_lcd),
    .i_rstn     (i_rstn_nes),
    .o_srstn    (c_rstn_lcd)
);
rstn_sync rsync_cpu(
    .i_clk      (i_clk_cpu),
    .i_rstn     (i_rstn_nes),
    .o_srstn    (c_rstn_cpu)
);
rstn_sync rsync_ppu(
    .i_clk      (i_clk_ppu),
    .i_rstn     (i_rstn_nes),
    .o_srstn    (c_rstn_ppu)
);
    
    
cpu_6502 cpu(                      
    .i_CLK       (i_clk_cpu), //input              
    .i_PAUSE     (c_cpu_pause), //input              
    
    .o_ADDR      (c_cpu_addr), //output  reg [15:0] 
    .i_DATA      (c_cpu_rdata), //input       [7:0]  
    .o_DATA      (c_cpu_wdata), //output      [7:0]  
    .o_R_WN      (c_cpu_r_wn), //output             
    
    .i_NMI_N     (c_nmi_n), ////////////////////////////////////////TO_DO
    .i_IRQ_N     (c_irq_n), ////////////////////////////////////////TO_DO
    .i_RST_N     (c_rstn_cpu),  //input              
    
    .o_PC        (o_cpu_pc),
    .o_SP        (o_cpu_sp),
    .o_IR        (o_cpu_ir),
    .o_P         (o_cpu_p)
);


nes_bus nes_bus(
    .i_clk          (i_clk_cpu),
    .i_rstn         (c_rstn_cpu),
    
    .o_cpu_pause    (c_cpu_pause),
    .i_cpu_addr     (c_cpu_addr),      //input [15:0]    
    .i_cpu_r_wn     (c_cpu_r_wn),      //input           
    .i_cpu_wdata    (c_cpu_wdata),     //cpu_write
    .o_cpu_rdata    (c_cpu_rdata),     //cpu read
            
    .i_dmc_req      (c_dmc_req  ),//input           
    .o_dmc_gnt      (c_dmc_gnt  ),//output          
    .i_dmc_addr     (c_dmc_addr ),//input   [15:0]  
    .o_dmc_rdata    (c_dmc_rdata),//output          
    
    .i_spr_req      (c_spr_req),//input           
    .o_spr_gnt      (c_spr_gnt),//output          
    .i_spr_addr     (c_spr_addr),//input   [15:0]  
    .i_spr_wn       (c_spr_wn),//input
    .i_spr_wdata    (c_spr_wdata),//input           
    .o_spr_rdata    (c_spr_rdata),//output          

    .o_bus_addr     (c_bus_addr),//output  [15:0]  
    .o_bus_wdata    (c_bus_wdata),//output  [7:0]               
    .o_bus_wn       (c_bus_r_wn),//output          
    
    
    .i_ram_rdata    (c_ram_rdata),//input   [7:0]   
    .i_mmc_rdata    (c_mmc_rdata),//input   [7:0]   
    .i_apu_rdata    (c_apu_rdata),//input   [7:0]   
    .i_jpd_rdata    (c_jpd_rdata),//input   [7:0]   
    .i_ppu_rdata    (c_ppu_rdata) //input   [7:0]

);


nes_mmc_set mmc_cart(
    .i_clk          (i_clk_cpu),//input           
    .i_rstn         (c_rstn_cpu),//input           
    
    .i_bus_addr     (c_bus_addr),//input [15:0]    
    .i_bus_wdata    (c_bus_wdata),//input [7:0]     
    .i_bus_r_wn     (c_bus_r_wn),//input           
    .o_mmc_rdata    (c_mmc_rdata),//output[7:0]     
    
    .i_flash_bank       (i_flash_bank   ),
    .i_nrom_mirrmode    (i_nrom_mirrmode),
    .i_nrom_gamesel     (i_nrom_gamesel ), 
    .o_fl_addr      (o_fl_addr), //output[22:0]
    .i_fl_rdata     (i_fl_rdata),//input [7:0]     
    
    .o_sram_addr_ext(o_sram_addr[19:12]),
    .o_sram_wp      (c_sram_wp),
    .o_mirror_mode  (c_mirror_mode),//output[2:0]     
    .o_irq_n        (c_irq_mmc_n)
);


ram_2k_adpt ram_2k_adpt(
    .i_bus_addr     (c_bus_addr),//input   [15:0]  
    .i_bus_wdata    (c_bus_wdata),//input   [7:0]   
    .i_bus_wn       (c_bus_r_wn),//input           
    .o_ram_rdata    (c_ram_rdata),//output [7:0]
    .o_ram_addr     (c_ram_addr),//output  [10:0]  
    .o_ram_din      (c_ram_din),//output  [7:0]   
    .o_ram_r_wn     (c_ram_r_wn),//output     
    .i_ram_q        (c_ram_q)      
);
    
    
ppu_2C02 ppu_2C02(
    .i_cpu_clk      (i_clk_cpu),//input            
    .i_cpu_rstn     (c_rstn_cpu),//input
    .i_ppu_clk      (i_clk_ppu),//input           
    .i_ppu_rstn     (c_rstn_ppu),//input          
    .i_lcd_clk      (i_clk_lcd),//input           
    .i_lcd_rstn     (c_rstn_lcd),//input           

    .i_bus_addr     (c_bus_addr),//input  [15:0]   
    .i_bus_wn       (c_bus_r_wn),//input           
    .i_bus_wdata    (c_bus_wdata),//input   [7:0]   
    .o_ppu_rdata    (c_ppu_rdata),//output  [7:0]   
    
    .o_spr_req      (c_spr_req),//    output          
    .i_spr_gnt      (c_spr_gnt),//    input           
    .o_spr_addr     (c_spr_addr),//    output  [15:0]  
    .o_spr_wn       (c_spr_wn),//    output          
    .o_spr_wdata    (c_spr_wdata),//    output  [7:0]   
    .i_spr_rdata    (c_spr_rdata),//    input   [7:0]   
    
    .o_nmi_n        (c_nmi_n),//input
    .i_mirror_mode  (c_mirror_mode),//input
    
    .i_sram_wp      (c_sram_wp),
    .o_sram_addr     (o_sram_addr[11:0]),//output  [11:0]  
    .o_sram_wdata    (o_sram_wdata),//output  [15:0]  
    .i_sram_rdata    (i_sram_rdata),//input   [15:0]  
    .o_sram_we_n     (o_sram_we_n),//output          
    .o_sram_oe_n     (o_sram_oe_n),//output          
    .o_sram_ub_n     (o_sram_ub_n),//output          
    .o_sram_lb_n     (o_sram_lb_n),//output          
    
    .o_lcd_r        (o_lcd_pixel[23:16]),//output [7:0]    
    .o_lcd_g        (o_lcd_pixel[15:8]),//output [7:0]    
    .o_lcd_b        (o_lcd_pixel[7:0]),//output [7:0]    
    .o_lcd_hsd      (o_lcd_hsd),//output          
    .o_lcd_vsd      (o_lcd_vsd),//output     
    
    .i_jp_vec_1p    (i_jp_vec_1p),//input  [9:0]    
    .i_jp_vec_2p    (i_jp_vec_2p) //input  [9:0]    
);


apu_2A03_pseudo apu_2A03_pseudo(
    .i_clk       (i_clk_cpu),//input           
    .i_rstn      (c_rstn_cpu),//input           
    .i_reg_addr  (c_bus_addr),//input   [15:0]  
    .i_reg_wn    (c_bus_r_wn),//input           
    .i_reg_wdata (c_bus_wdata),//input   [7:0]   
    .o_reg_rdata (c_apu_rdata),//output  [7:0]   
    .o_dmc_req   (c_dmc_req  ),//output          
    .i_dmc_gnt   (c_dmc_gnt  ),//input           
    .o_dmc_addr  (c_dmc_addr ),//output  [15:0]  
    .i_dmc_smpl  (c_dmc_rdata),//input   [7:0]   
    .o_irq_n     (c_irq_apu_n) //output          
);

joypad_ctrl joypad_ctrl(
    .i_clk           (i_clk_cpu),//input           
    .i_rstn          (c_rstn_cpu),//input           
    .i_jpd_1p        (i_jp_vec_1p),//input [9:0]     
    .i_jpd_2p        (i_jp_vec_2p),//input [9:0]     
    .i_bus_addr      (c_bus_addr),//input   [15:0]  
    .i_bus_wn        (c_bus_r_wn),//input           
    .i_bus_wdata     (c_bus_wdata),//input   [7:0]   
    .o_jpd_rdata     (c_jpd_rdata) //output  [7:0]   
);


ram_2k	ram_internal (
    .address    ( c_ram_addr ),
    .data       ( c_ram_din ),
    .inclock    ( ~i_clk_cpu ),
    .wren       ( ~c_ram_r_wn ),
    .q          ( c_ram_q )
);

endmodule
