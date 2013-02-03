`timescale 10ns/1ns

module ppu_vram(
    input               i_cpu_clk       ,
    input               i_cpu_rstn      ,
    input               i_ppu_clk       ,
    input               i_ppu_rstn      ,
    //cfg port
    input       [15:0]  i_vram_addr     ,
    input               i_vram_we       ,
    input       [7:0]   i_vram_wdata    ,
    output      [7:0]   o_vram_rdata    ,
    input               i_2007_visit    ,
    input       [2:0]   i_mirror_mode   ,
    input               i_gray          ,
    //ppu port
    input       [11:0]  i_pt_addr       ,
    output reg  [15:0]  o_pt_rdata      ,
    input       [11:0]  i_nt_addr       ,
    output      [7:0]   o_nt_rdata      ,
    input       [4:0]   i_plt_addr      ,
    output      [7:0]   o_plt_rdata     ,
    //chr-ram port
    output      [11:0]  o_sram_addr     ,
    output      [15:0]  o_sram_wdata    ,
    input       [15:0]  i_sram_rdata    ,
    output              o_sram_we_n     ,
    output              o_sram_oe_n     ,
    output              o_sram_ub_n     ,
    output              o_sram_lb_n     
    
);

wire[9:0]   c_nt0_addr_a    ;
wire        c_nt0_wren_a    ;
wire[7:0]   c_nt0_data_a    ;
wire[7:0]   c_nt0_q_a       ;
wire[9:0]   c_nt0_addr_b    ;
wire[7:0]   c_nt0_q_b       ;
                            
wire[9:0]   c_nt1_addr_a    ;
wire        c_nt1_wren_a    ;
wire[7:0]   c_nt1_data_a    ;
wire[7:0]   c_nt1_q_a       ;
wire[9:0]   c_nt1_addr_b    ;
wire[7:0]   c_nt1_q_b       ;
                            
wire[9:0]   c_nt2_addr_a    ;
wire        c_nt2_wren_a    ;
wire[7:0]   c_nt2_data_a    ;
wire[7:0]   c_nt2_q_a       ;
wire[9:0]   c_nt2_addr_b    ;
wire[7:0]   c_nt2_q_b       ;
                            
wire[9:0]   c_nt3_addr_a    ;
wire        c_nt3_wren_a    ;
wire[7:0]   c_nt3_data_a    ;
wire[7:0]   c_nt3_q_a       ;
wire[9:0]   c_nt3_addr_b    ;
wire[7:0]   c_nt3_q_b       ;

reg [1:0]   c_nt_sel        ;
reg [1:0]   r_nt_sel        ;

wire        c_cfg_pltt_hit  ;
wire[4:0]   c_cfg_pltt_addr_a   ;
wire[7:0]   c_cfg_pltt_data_a   ;
wire        c_cfg_pltt_wren_a   ;
wire[7:0]   c_cfg_pltt_q_a      ;

wire        c_cfg_nt_hit    ;
wire[11:0]  c_cfg_nt_addr   ;
wire        c_cfg_nt_we     ;
wire[7:0]   c_cfg_nt_wdata  ;
wire[7:0]   c_cfg_nt_rdata  ;
reg [1:0]   c_cfg_nt_sel    ;


wire        c_cfg_pt_hit    ;
wire[11:0]  c_cfg_pt_addr   ;
wire[15:0]  c_cfg_pt_wdata  ;
wire[7:0]   c_cfg_pt_rdata  ;
wire        c_cfg_pt_we_n   ;
wire        c_cfg_pt_oe_n   ;
wire        c_cfg_pt_ub_n   ;
wire        c_cfg_pt_lb_n   ;

wire[7:0]   c_plt_rdata     ;

//chr-ram(pt/sram) cfg write port
assign c_cfg_pt_hit = i_vram_addr[13] == 1'b0;
assign c_cfg_pt_addr = c_cfg_pt_hit ? {i_vram_addr[12:4], i_vram_addr[2:0]} : 12'h0;
assign c_cfg_pt_we_n = c_cfg_pt_hit ? ~i_vram_we : 1'b1;
assign c_cfg_pt_oe_n = c_cfg_pt_hit ? i_vram_we : 1'b0;
assign c_cfg_pt_ub_n = c_cfg_pt_hit ? ~i_vram_addr[3] : 1'b1;
assign c_cfg_pt_lb_n = c_cfg_pt_hit ? i_vram_addr[3] : 1'b1;
assign c_cfg_pt_wdata[15:8] = c_cfg_pt_ub_n ? 8'h0 : i_vram_wdata;
assign c_cfg_pt_wdata[7:0] = c_cfg_pt_lb_n ? 8'h0 : i_vram_wdata;


//nt cfg write port
assign c_cfg_nt_hit = i_vram_addr[13:8]>=6'h20 && i_vram_addr[13:8]<=6'h3E;
assign c_cfg_nt_addr    = c_cfg_nt_hit ? i_vram_addr[11:0] : 12'h0;
assign c_cfg_nt_we      = c_cfg_nt_hit ? i_vram_we : 1'b0;
assign c_cfg_nt_wdata   = c_cfg_nt_hit ? i_vram_wdata : 8'h0;

//palette cfg write port
assign c_cfg_pltt_hit = i_vram_addr[13:8]==6'h3F;
assign c_cfg_pltt_addr_a = c_cfg_pltt_hit ? i_vram_addr[4:0] : 5'h0;
assign c_cfg_pltt_wren_a = c_cfg_pltt_hit ? i_vram_we : 1'b0;
assign c_cfg_pltt_data_a = c_cfg_pltt_hit ? i_vram_wdata : 8'h0;

//cfg read port
assign c_cfg_pt_rdata = ~c_cfg_pt_ub_n ? i_sram_rdata[15:8] :
                        ~c_cfg_pt_lb_n ? i_sram_rdata[7:0]  :
                        8'h0;
assign o_vram_rdata =   c_cfg_nt_hit   ? c_cfg_nt_rdata  :
                        c_cfg_pt_hit   ? c_cfg_pt_rdata  :
                        c_cfg_pltt_hit ? c_cfg_pltt_q_a  :
                        8'h0;


//chr-ram(pt/sram) ppu read port
always @(posedge i_ppu_clk) begin
    o_pt_rdata <= i_sram_rdata;
end


/*
chr-ram cpu/ppu mux
it's considerred that cfg read/write has the highest priority.
cfg reading/writing PatternTable during ppu renderring will cause gliches: the 
ppu read will return wrong data.
the other rams are dprams, the cfg-rw and ppu-rw are via seperate logics.
*/
assign o_sram_addr  = i_2007_visit ? c_cfg_pt_addr  : i_pt_addr ;
assign o_sram_wdata = i_2007_visit ? c_cfg_pt_wdata : 16'h0;
assign o_sram_we_n  = i_2007_visit ? c_cfg_pt_we_n  : 1'b1 ;
assign o_sram_oe_n  = i_2007_visit ? c_cfg_pt_oe_n  : 1'b0 ;
assign o_sram_ub_n  = i_2007_visit ? c_cfg_pt_ub_n  : 1'b0 ;
assign o_sram_lb_n  = i_2007_visit ? c_cfg_pt_lb_n  : 1'b0 ;

/*
NameTable/AttrTable Mirror
*/
//ppu port
always @ ( * ) begin
    case ({i_mirror_mode, i_nt_addr[11:10]})
        5'b00000:   c_nt_sel = 2'h0;
        5'b00001:   c_nt_sel = 2'h0;
        5'b00010:   c_nt_sel = 2'h1;
        5'b00011:   c_nt_sel = 2'h1;
        5'b00100:   c_nt_sel = 2'h0;
        5'b00101:   c_nt_sel = 2'h1;
        5'b00110:   c_nt_sel = 2'h0;
        5'b00111:   c_nt_sel = 2'h1;
        5'b01000:   c_nt_sel = 2'h0;
        5'b01001:   c_nt_sel = 2'h0;
        5'b01010:   c_nt_sel = 2'h0;
        5'b01011:   c_nt_sel = 2'h0;
        5'b01100:   c_nt_sel = 2'h1;
        5'b01101:   c_nt_sel = 2'h1;
        5'b01110:   c_nt_sel = 2'h1;
        5'b01111:   c_nt_sel = 2'h1;
        5'b10000:   c_nt_sel = 2'h0;
        5'b10001:   c_nt_sel = 2'h1;
        5'b10010:   c_nt_sel = 2'h2;
        5'b10011:   c_nt_sel = 2'h3;
        5'b10100:   c_nt_sel = 2'h0;
        5'b10101:   c_nt_sel = 2'h1;
        5'b10110:   c_nt_sel = 2'h1;
        5'b10111:   c_nt_sel = 2'h0;
        5'b11000:   c_nt_sel = 2'h0;
        5'b11001:   c_nt_sel = 2'h1;
        5'b11010:   c_nt_sel = 2'h2;
        5'b11011:   c_nt_sel = 2'h2;
        5'b11100:   c_nt_sel = 2'h0;
        5'b11101:   c_nt_sel = 2'h2;
        5'b11110:   c_nt_sel = 2'h1;
        5'b11111:   c_nt_sel = 2'h2;
    endcase
end
always @ (posedge i_ppu_clk or negedge i_ppu_rstn) begin
    if(~i_ppu_rstn) begin
        r_nt_sel <= 2'h0;
    end
    else begin
        r_nt_sel <= c_nt_sel;
    end
end

assign c_nt0_addr_b = c_nt_sel==2'h0 ? i_nt_addr[9:0] : 10'h0;
assign c_nt1_addr_b = c_nt_sel==2'h1 ? i_nt_addr[9:0] : 10'h0;
assign c_nt2_addr_b = c_nt_sel==2'h2 ? i_nt_addr[9:0] : 10'h0;
assign c_nt3_addr_b = c_nt_sel==2'h3 ? i_nt_addr[9:0] : 10'h0;

assign o_nt_rdata = r_nt_sel==2'h0 ? c_nt0_q_b :
                    r_nt_sel==2'h1 ? c_nt1_q_b :
                    r_nt_sel==2'h2 ? c_nt2_q_b :
                    c_nt3_q_b;

//cfg port
always @ ( * ) begin
    case ({i_mirror_mode, c_cfg_nt_addr[11:10]})
        5'b00000:   c_cfg_nt_sel = 2'h0;
        5'b00001:   c_cfg_nt_sel = 2'h0;
        5'b00010:   c_cfg_nt_sel = 2'h1;
        5'b00011:   c_cfg_nt_sel = 2'h1;
        5'b00100:   c_cfg_nt_sel = 2'h0;
        5'b00101:   c_cfg_nt_sel = 2'h1;
        5'b00110:   c_cfg_nt_sel = 2'h0;
        5'b00111:   c_cfg_nt_sel = 2'h1;
        5'b01000:   c_cfg_nt_sel = 2'h0;
        5'b01001:   c_cfg_nt_sel = 2'h0;
        5'b01010:   c_cfg_nt_sel = 2'h0;
        5'b01011:   c_cfg_nt_sel = 2'h0;
        5'b01100:   c_cfg_nt_sel = 2'h1;
        5'b01101:   c_cfg_nt_sel = 2'h1;
        5'b01110:   c_cfg_nt_sel = 2'h1;
        5'b01111:   c_cfg_nt_sel = 2'h1;
        5'b10000:   c_cfg_nt_sel = 2'h0;
        5'b10001:   c_cfg_nt_sel = 2'h1;
        5'b10010:   c_cfg_nt_sel = 2'h2;
        5'b10011:   c_cfg_nt_sel = 2'h3;
        5'b10100:   c_cfg_nt_sel = 2'h0;
        5'b10101:   c_cfg_nt_sel = 2'h1;
        5'b10110:   c_cfg_nt_sel = 2'h1;
        5'b10111:   c_cfg_nt_sel = 2'h0;
        5'b11000:   c_cfg_nt_sel = 2'h0;
        5'b11001:   c_cfg_nt_sel = 2'h1;
        5'b11010:   c_cfg_nt_sel = 2'h2;
        5'b11011:   c_cfg_nt_sel = 2'h2;
        5'b11100:   c_cfg_nt_sel = 2'h0;
        5'b11101:   c_cfg_nt_sel = 2'h2;
        5'b11110:   c_cfg_nt_sel = 2'h1;
        5'b11111:   c_cfg_nt_sel = 2'h2;
    endcase
end

assign c_nt0_addr_a = c_cfg_nt_sel==2'h0 ? c_cfg_nt_addr[9:0] : 10'h0;
assign c_nt1_addr_a = c_cfg_nt_sel==2'h1 ? c_cfg_nt_addr[9:0] : 10'h0;
assign c_nt2_addr_a = c_cfg_nt_sel==2'h2 ? c_cfg_nt_addr[9:0] : 10'h0;
assign c_nt3_addr_a = c_cfg_nt_sel==2'h3 ? c_cfg_nt_addr[9:0] : 10'h0;

assign c_nt0_wren_a = c_cfg_nt_sel==2'h0 ? c_cfg_nt_we : 1'b0;
assign c_nt1_wren_a = c_cfg_nt_sel==2'h1 ? c_cfg_nt_we : 1'b0;
assign c_nt2_wren_a = c_cfg_nt_sel==2'h2 ? c_cfg_nt_we : 1'b0;
assign c_nt3_wren_a = c_cfg_nt_sel==2'h3 ? c_cfg_nt_we : 1'b0;

assign c_nt0_data_a = c_cfg_nt_sel==2'h0 ? c_cfg_nt_wdata : 8'h0;
assign c_nt1_data_a = c_cfg_nt_sel==2'h1 ? c_cfg_nt_wdata : 8'h0;
assign c_nt2_data_a = c_cfg_nt_sel==2'h2 ? c_cfg_nt_wdata : 8'h0;
assign c_nt3_data_a = c_cfg_nt_sel==2'h3 ? c_cfg_nt_wdata : 8'h0;

assign c_cfg_nt_rdata = c_cfg_nt_sel==2'h0 ? c_nt0_q_a :
                        c_cfg_nt_sel==2'h1 ? c_nt1_q_a :
                        c_cfg_nt_sel==2'h2 ? c_nt2_q_a :
                        c_nt3_q_a;

//palette ppu port with gray mask
assign o_plt_rdata = c_plt_rdata & (i_gray ? 8'h30 : 8'hff);


dpram_vram_1kx8 name_table_0(
	.address_a  (c_nt0_addr_a),
	.address_b  (c_nt0_addr_b),
	.clock_a    (i_cpu_clk),
	.clock_b    (i_ppu_clk),
	.data_a     (c_nt0_data_a),
	.data_b     (8'h0),
	.wren_a     (c_nt0_wren_a),
	.wren_b     (1'b0),
	.q_a        (c_nt0_q_a),
	.q_b        (c_nt0_q_b)
);


dpram_vram_1kx8 name_table_1(
	.address_a  (c_nt1_addr_a),
	.address_b  (c_nt1_addr_b),
	.clock_a    (i_cpu_clk),
	.clock_b    (i_ppu_clk),
	.data_a     (c_nt1_data_a),
	.data_b     (8'h0),
	.wren_a     (c_nt1_wren_a),
	.wren_b     (1'b0),
	.q_a        (c_nt1_q_a),
	.q_b        (c_nt1_q_b)
);

dpram_vram_1kx8 name_table_2(
	.address_a  (c_nt2_addr_a),
	.address_b  (c_nt2_addr_b),
	.clock_a    (i_cpu_clk),
	.clock_b    (i_ppu_clk),
	.data_a     (c_nt2_data_a),
	.data_b     (8'h0),
	.wren_a     (c_nt2_wren_a),
	.wren_b     (1'b0),
	.q_a        (c_nt2_q_a),
	.q_b        (c_nt2_q_b)
);
	
dpram_vram_1kx8 name_table_3(
	.address_a  (c_nt3_addr_a),
	.address_b  (c_nt3_addr_b),
	.clock_a    (i_cpu_clk),
	.clock_b    (i_ppu_clk),
	.data_a     (c_nt3_data_a),
	.data_b     (8'h0),
	.wren_a     (c_nt3_wren_a),
	.wren_b     (1'b0),
	.q_a        (c_nt3_q_a),
	.q_b        (c_nt3_q_b)
);

dpram_pltt_32x8 palette_table(
	.address_a  (c_cfg_pltt_addr_a),
	.address_b  (i_plt_addr),
	.clock_a    (i_cpu_clk),
	.clock_b    (i_ppu_clk),
	.data_a     (c_cfg_pltt_data_a),
	.data_b     (8'h0),
	.wren_a     (c_cfg_pltt_wren_a),
	.wren_b     (1'b0),
	.q_a        (c_cfg_pltt_q_a),
	.q_b        (c_plt_rdata)
);



endmodule
