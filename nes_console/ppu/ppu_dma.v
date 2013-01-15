module ppu_dma(
    input           i_clk       ,
    input           i_rstn      ,
    //slave
    input   [15:0]  i_bus_addr  ,
    input           i_bus_wn    ,
    input   [7:0]   i_bus_wdata ,
    //master
    output          o_spr_req   ,
    input           i_spr_gnt   ,
    output  [15:0]  o_spr_addr  ,
    output          o_spr_wn    ,
    output  [7:0]   o_spr_wdata ,
    input   [7:0]   i_spr_rdata
);

endmodule
