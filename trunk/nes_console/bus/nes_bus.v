module nes_bus(
    input           i_clk           ,
    input           i_rstn          ,
    //mst devices
    output          o_cpu_pause     ,
    input   [15:0]  i_cpu_addr      ,
    input           i_cpu_r_wn      ,//1 read, 0 write
    output  [7:0]   o_cpu_rdata     ,
    input   [7:0]   i_cpu_wdata     ,
        
    input           i_dmc_req       ,
    output          o_dmc_gnt       ,
    input   [15:0]  i_dmc_addr      ,
    output          o_dmc_rdata     ,

    input           i_spr_req       ,
    output          o_spr_gnt       ,
    input   [15:0]  i_spr_addr      ,
    input           i_spr_wn        ,//1 read, 0 write
    input           i_spr_wdata     ,
    output          i_spr_rdata     ,
    
    //slv devices
    //write
    output  [15:0]  o_bus_addr      ,
    output  [7:0]   o_bus_wdata     ,
    output          o_bus_wn        ,
    //read
    input   [7:0]   i_ram_rdata     ,
    input   [7:0]   i_mmc_rdata     ,
    input   [7:0]   i_apu_rdata     ,
    input   [7:0]   i_jpd_rdata     ,
    input   [7:0]   i_ppu_rdata       
);

reg [15:0]  c_bus_addr  ;
reg [7:0]   c_bus_wdata ;
reg         c_bus_wn    ;
wire[7:0]   c_bus_rdata ;

wire c_apu_dma_jp_hit;
wire c_ram_rhit;
wire c_mmc_rhit;
wire c_apu_rhit;
wire c_jpd_rhit;
wire c_ppu_rhit;    

assign  c_ram_rhit = c_bus_addr[15:13]==3'b000;
assign  c_mmc_rhit = c_bus_addr[15]==1'b1;
assign  c_apu_dma_jp_hit    = c_bus_addr[15:5]==11'h200                     ;
assign  c_apu_rhit          = c_apu_dma_jp_hit & (c_bus_addr[4:0]==5'h15)   ;
assign  c_jpd_rhit          = c_apu_dma_jp_hit & (c_bus_addr[4:1]==4'hb)    ;
assign  c_ppu_rhit          = c_bus_addr[15:12]==4'h2;

assign  c_bus_rdata =   c_ram_rhit ? i_ram_rdata    : 
                        c_mmc_rhit ? i_mmc_rdata    :
                        c_apu_rhit ? i_apu_rdata    :
                        c_jpd_rhit ? i_jpd_rdata    :
                        c_ppu_rhit ? i_ppu_rdata    :
                        8'h0;

/*
bus master arbitor
*/

always @ ( * ) begin
    if(i_dmc_req) begin
        c_bus_addr = i_dmc_addr;
        c_bus_wdata = 16'h0;
        c_bus_wn = 1'b1;
    end
    else if(i_spr_req) begin
        c_bus_addr = i_spr_addr;
        c_bus_wdata = i_spr_wdata;
        c_bus_wn = i_spr_wn;
    end
    else begin
        c_bus_addr = i_cpu_addr;
        c_bus_wdata = i_cpu_wdata;
        c_bus_wn = i_cpu_r_wn;
    end
end

assign  o_dmc_gnt = i_dmc_req;
assign  o_spr_gnt = i_spr_req & ~i_dmc_req;
         
assign  o_bus_addr = c_bus_addr;
assign  o_bus_wdata = c_bus_wdata;
assign  o_bus_wn = c_bus_wn;

assign  o_cpu_rdata = c_bus_rdata;
assign  o_dmc_rdata = c_bus_rdata;
assign  o_spr_rdata = c_bus_rdata;
assign  o_cpu_pause = i_dmc_req | i_spr_req;


endmodule
