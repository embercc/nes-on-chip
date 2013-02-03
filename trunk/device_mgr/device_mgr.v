`timescale 10ns/1ns

module device_mgr(
    input           i_rstn_sync_cpu ,
    input           i_rstn_sync_ppu ,
    input           i_cpu_clk       ,
    input           i_ppu_clk       ,
    
    input           i_ps2_clk       ,
    input           i_ps2_data      ,
    output          o_ps2_txclk     ,
    output          o_ps2_txclk_e   ,
    output          o_ps2_txdata    ,
    output          o_ps2_txdata_e  ,
    
    input           i_ps2_clk2       ,
    input           i_ps2_data2      ,
    output          o_ps2_txclk2     ,
    output          o_ps2_txclk2_e   ,
    output          o_ps2_txdata2    ,
    output          o_ps2_txdata2_e  ,
    
    output  [22:0]  o_fl_addr       ,
    input   [7:0]   i_fl_rdata      ,
    output  [19:0]  o_sram_addr     ,
    output  [15:0]  o_sram_wdata    ,
    input   [15:0]  i_sram_rdata    ,
    output          o_sram_oe_n     ,
    output          o_sram_we_n     ,
    output          o_sram_ub_n     ,
    output          o_sram_lb_n     ,
    
    output  [9:0]   o_jp_vector_1p  ,
    output  [9:0]   o_jp_vector_2p  ,
    
    output          o_init_done     ,
    output reg      o_nes_rstn      
);

wire [9:0] c_jp_vector_1p;
wire [9:0] c_jp_vector_2p;
wire  c_chr_loader_done;

assign o_init_done = c_chr_loader_done;
always @ ( posedge i_cpu_clk or negedge i_rstn_sync_cpu) begin
    if(~i_rstn_sync_cpu) begin
        o_nes_rstn <= 1'b0;
    end
    else begin
        if(o_init_done) begin
            o_nes_rstn <= 1'b1;
        end
    end
end 

assign o_jp_vector_1p = c_jp_vector_1p;
assign o_jp_vector_2p = c_jp_vector_2p;
ps2_scanner ps2_scanner_1p(
    .i_clk           (i_cpu_clk),//input           
    .i_rstn          (i_rstn_sync_cpu),//input           
    .i_ps2_clk       (i_ps2_clk      ),//input           
    .i_ps2_data      (i_ps2_data     ),//input           
    .o_ps2_txclk     (o_ps2_txclk    ),//output          
    .o_ps2_txclk_e   (o_ps2_txclk_e  ),//output          
    .o_ps2_txdata    (o_ps2_txdata   ),//output          
    .o_ps2_txdata_e  (o_ps2_txdata_e ),//output          
    .o_jp_vector     (c_jp_vector_1p),//output  [9:0]   
    .o_initdone      () //output          
);

ps2_scanner ps2_scanner_2p(
    .i_clk           (i_cpu_clk),//input           
    .i_rstn          (i_rstn_sync_cpu),//input           
    .i_ps2_clk       (i_ps2_clk2     ),//input           
    .i_ps2_data      (i_ps2_data2    ),//input           
    .o_ps2_txclk     (o_ps2_txclk2   ),//output          
    .o_ps2_txclk_e   (o_ps2_txclk2_e ),//output          
    .o_ps2_txdata    (o_ps2_txdata2  ),//output          
    .o_ps2_txdata_e  (o_ps2_txdata2_e),//output          
    .o_jp_vector     (c_jp_vector_2p),//output  [9:0]   
    .o_initdone      () //output          
);

chr_loader chr_loader(
    .i_clk          (i_ppu_clk),//ppu clk//input           
    .i_rstn         (i_rstn_sync_ppu),         //input           
    .o_done         (c_chr_loader_done),         //output          
    .o_fl_addr      (o_fl_addr),         //output [22:0]   
    .i_fl_rdata     (i_fl_rdata),         //input  [7:0]    
    .o_sram_addr    (o_sram_addr ),         //output  [19:0]  
    .o_sram_wdata   (o_sram_wdata),         //output  [15:0]  
    .i_sram_rdata   (i_sram_rdata),         //input   [15:0]  
    .o_sram_oe_n    (o_sram_oe_n ),         //output          
    .o_sram_we_n    (o_sram_we_n ),         //output          
    .o_sram_ub_n    (o_sram_ub_n ),         //output          
    .o_sram_lb_n    (o_sram_lb_n )          //output          
);

endmodule
