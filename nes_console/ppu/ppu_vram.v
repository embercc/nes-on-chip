module ppu_vram(
    input           i_cpu_clk       ,
    input           i_cpu_rstn      ,
    input           i_ppu_clk       ,
    input           i_ppu_rstn      ,
    //cfg port
    input   [15:0]  i_vram_addr     ,
    input           i_vram_we       ,
    input   [7:0]   i_vram_wdata    ,
    output  [7:0]   o_vram_rdata    ,
    //ppu port
    input   [11:0]  i_pt_addr       ,
    output  [15:0]  o_pt_rdata      ,
    input   [11:0]  i_nt_addr       ,
    output  [7:0]   o_nt_rdata      ,
    input   [4:0]   i_plt_addr      ,
    output  [7:0]   o_plt_rdata     ,
    //chr-ram port
    output  [11:0]  o_sram_addr     ,
    output  [15:0]  o_sram_wdata    ,
    input   [15:0]  i_sram_rdata    ,
    output          o_sram_we_n     ,
    output          o_sram_oe_n     ,
    output          o_sram_ub_n     ,
    output          o_sram_le_n     ,
    
);

/*
it's considerred that cfg read/write has the highest priority.
read/write datas during ppu renderring will cause gliches: the 
ppu read will return wrong data.
*/
//chr-ram(pt/sram) cfg read/write port

//nt cfg read/write port

//plt cfg read/write port


endmodule
