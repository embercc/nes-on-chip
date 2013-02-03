`timescale 10ns/1ns

module ram_2k_adpt(
    input   [15:0]  i_bus_addr  ,
    input   [7:0]   i_bus_wdata ,
    input           i_bus_wn    ,
    output  [7:0]   o_ram_rdata ,
    
    output  [10:0]  o_ram_addr  ,
    output  [7:0]   o_ram_din ,
    output          o_ram_r_wn  ,
    input   [7:0]   i_ram_q
);

//addr
assign  o_ram_addr  = (i_bus_addr[15:13]==3'b000) ? i_bus_addr[10:0]: 11'h0;
//read
assign  o_ram_rdata = i_ram_q;
//write
assign  o_ram_r_wn  = (i_bus_addr[15:13]==3'b000) ? i_bus_wn        : 1'b1;
assign  o_ram_din   = (i_bus_addr[15:13]==3'b000) ? i_bus_wdata     : 8'h0;

endmodule
