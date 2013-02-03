`timescale 1ns/1ps

module ppu_vbuf(
    input           i_ppu_clk   ,
    input           i_lcd_clk   ,
    input   [16:0]  i_waddr     ,
    input           i_we        ,
    input   [7:0]   i_wdata     ,
    input   [16:0]  i_raddr     ,
    output  [7:0]   o_rdata
);

wire[15:0]  c_rdaddress_vbuf0;
wire[15:0]  c_rdaddress_vbuf1;
wire[7:0]   c_q_vbuf0;
wire[7:0]   c_q_vbuf1;
wire[15:0]  c_wraddress;
wire        c_wren_vbuf0;
wire        c_wren_vbuf1;


assign c_wraddress = i_waddr[15:0];
assign c_wren_vbuf0 = i_waddr[16] ? 1'b0 : i_we;
assign c_wren_vbuf1 = i_waddr[16] ? i_we : 1'b0;
assign c_rdaddress_vbuf0 = i_raddr[16] ? 16'h0 : i_raddr[15:0];
assign c_rdaddress_vbuf1 = i_raddr[16] ? i_raddr[15:0] : 16'h0;
assign o_rdata = i_raddr[16] ? c_q_vbuf1 : c_q_vbuf0;

dpram_vbuf_64kx8 vbuf_0(
	.data       (i_wdata),
	.rdaddress  (c_rdaddress_vbuf0),
	.rdclock    (i_lcd_clk),
	.wraddress  (c_wraddress),
	.wrclock    (i_ppu_clk),
	.wren       (c_wren_vbuf0),
	.q          (c_q_vbuf0)
);


dpram_vbuf_64kx8 vbuf_1(
	.data       (i_wdata),
	.rdaddress  (c_rdaddress_vbuf1),
	.rdclock    (i_lcd_clk),
	.wraddress  (c_wraddress),
	.wrclock    (i_ppu_clk),
	.wren       (c_wren_vbuf1),
	.q          (c_q_vbuf1)
);

endmodule
