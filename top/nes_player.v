
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module nes_player(

	//////////// CLOCK //////////
	CLOCK_50,
	CLOCK2_50,
	CLOCK3_50,

	//////////// LED //////////
	LEDG,
	LEDR,

	//////////// KEY //////////
	KEY,

	//////////// SW //////////
	SW,

	//////////// SEG7 //////////
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7,

	//////////// LCD //////////
	LCD_BLON,
	LCD_DATA,
	LCD_EN,
	LCD_ON,
	LCD_RS,
	LCD_RW,

	//////////// PS2 for Keyboard and Mouse //////////
	PS2_CLK,
	PS2_CLK2,
	PS2_DAT,
	PS2_DAT2,

	//////////// SDCARD //////////
	SD_CLK,
	SD_CMD,
	SD_DAT,
	SD_WP_N,

	//////////// Audio //////////
	AUD_ADCDAT,
	AUD_ADCLRCK,
	AUD_BCLK,
	AUD_DACDAT,
	AUD_DACLRCK,
	AUD_XCK,

	//////////// I2C for Audio  //////////
	I2C_SCLK,
	I2C_SDAT,

	//////////// SRAM //////////
	SRAM_ADDR,
	SRAM_CE_N,
	SRAM_DQ,
	SRAM_LB_N,
	SRAM_OE_N,
	SRAM_UB_N,
	SRAM_WE_N,

	//////////// Flash //////////
	FL_ADDR,
	FL_CE_N,
	FL_DQ,
	FL_OE_N,
	FL_RST_N,
	FL_RY,
	FL_WE_N,
	FL_WP_N,

	//////////// GPIO, GPIO connect to MTL - Multi-Touch LCD Panel //////////
	MTL_B,
	MTL_DCLK,
	MTL_G,
	MTL_HSD,
	MTL_R,
	MTL_TOUCH_I2C_SCL,
	MTL_TOUCH_I2C_SDA,
	MTL_TOUCH_INT_n,
	MTL_VSD 
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input 		          		CLOCK_50;
input 		          		CLOCK2_50;
input 		          		CLOCK3_50;

//////////// LED //////////
output		     [8:0]		LEDG;
output		    [17:0]		LEDR;

//////////// KEY //////////
input 		     [3:0]		KEY;

//////////// SW //////////
input 		    [17:0]		SW;

//////////// SEG7 //////////
output		     [6:0]		HEX0;
output		     [6:0]		HEX1;
output		     [6:0]		HEX2;
output		     [6:0]		HEX3;
output		     [6:0]		HEX4;
output		     [6:0]		HEX5;
output		     [6:0]		HEX6;
output		     [6:0]		HEX7;

//////////// LCD //////////
output		          		LCD_BLON;
inout 		     [7:0]		LCD_DATA;
output		          		LCD_EN;
output		          		LCD_ON;
output		          		LCD_RS;
output		          		LCD_RW;

//////////// PS2 for Keyboard and Mouse //////////
inout 		          		PS2_CLK;
inout 		          		PS2_CLK2;
inout 		          		PS2_DAT;
inout 		          		PS2_DAT2;

//////////// SDCARD //////////
output		          		SD_CLK;
inout 		          		SD_CMD;
inout 		     [3:0]		SD_DAT;
input 		          		SD_WP_N;

//////////// Audio //////////
input 		          		AUD_ADCDAT;
inout 		          		AUD_ADCLRCK;
inout 		          		AUD_BCLK;
output		          		AUD_DACDAT;
inout 		          		AUD_DACLRCK;
output		          		AUD_XCK;

//////////// I2C for Audio  //////////
output		          		I2C_SCLK;
inout 		          		I2C_SDAT;

//////////// SRAM //////////
output	reg     [19:0]		SRAM_ADDR;
output		          		SRAM_CE_N;
inout 		    [15:0]		SRAM_DQ;
output		          		SRAM_LB_N;
output		          		SRAM_OE_N;
output		          		SRAM_UB_N;
output		          		SRAM_WE_N;

//////////// Flash //////////
output		    [22:0]		FL_ADDR;
output		          		FL_CE_N;
inout 		     [7:0]		FL_DQ;
output		          		FL_OE_N;
output		          		FL_RST_N;
input 		          		FL_RY;
output		          		FL_WE_N;
output		          		FL_WP_N;

//////////// GPIO, GPIO connect to MTL - Multi-Touch LCD Panel //////////
output		     [7:0]		MTL_B;
output		          		MTL_DCLK;
output		     [7:0]		MTL_G;
output		          		MTL_HSD;
output		     [7:0]		MTL_R;
output		          		MTL_TOUCH_I2C_SCL;
inout 		          		MTL_TOUCH_I2C_SDA;
input 		          		MTL_TOUCH_INT_n;
output		          		MTL_VSD;


//=======================================================
//  REG/WIRE declarations
//=======================================================
wire    i_rstn;
wire	clk_33m_p;	//33m use
wire    clk_33m_out;	//33m output
wire    c_clk_cpu;
wire    c_clk_ppu;
wire    c_clk_ppu_sram;
wire    c_rstn_sync_cpu;
wire    c_rstn_sync_ppu;
reg  [7:0] r_pwup_cnt;
    
wire  [15:0]  c_nes_cpu_pc        ;
wire  [7:0]   c_nes_cpu_sp        ;
wire  [7:0]   c_nes_cpu_ir        ;
wire  [7:0]   c_nes_cpu_p         ;

wire[15:0]  c_sram_rdata;
wire[15:0]  c_sram_wdata;
wire[19:0]  c_sram_addr;
wire        c_sram_we_n;
wire        c_sram_oe_n;
wire        c_sram_ub_n;
wire        c_sram_lb_n;

wire[15:0]  c_nes_sram_wdata;
wire[19:0]  c_nes_sram_addr;
wire        c_nes_sram_we_n;
wire        c_nes_sram_oe_n;
wire        c_nes_sram_ub_n;
wire        c_nes_sram_lb_n;

wire[15:0]  c_mgr_sram_wdata;
wire[19:0]  c_mgr_sram_addr;
wire        c_mgr_sram_we_n;
wire        c_mgr_sram_oe_n;
wire        c_mgr_sram_ub_n;
wire        c_mgr_sram_lb_n;

wire[22:0]  c_nes_fl_addr;
wire[22:0]  c_mgr_fl_addr;
wire[7:0]   c_fl_q;

wire        c_ps2_rxclk;
wire        c_ps2_rxdata;
wire        c_ps2_txclk;
wire        c_ps2_txclk_e;
wire        c_ps2_txdata;
wire        c_ps2_txdata_e;

wire        c_ps2_rxclk2;
wire        c_ps2_rxdata2;
wire        c_ps2_txclk2;
wire        c_ps2_txclk2_e;
wire        c_ps2_txdata2;
wire        c_ps2_txdata2_e;

wire [9:0]  c_jp_vec_1p;
wire [9:0]  c_jp_vec_2p;

wire    c_nes_rstn;
wire    c_mgr_initdone;

//=======================================================
//  Structural coding
//=======================================================
/*
reset signal generate
*/
always @(posedge c_clk_cpu) begin
    if(r_pwup_cnt==8'hff)
        r_pwup_cnt<=8'hff;
    else
        r_pwup_cnt <= r_pwup_cnt + 8'h1;
end
assign i_rstn = KEY[0] & r_pwup_cnt[7];


/*
Video Output
*/
assign MTL_DCLK = clk_33m_out;


/*
SRAM Interface
*/
assign c_sram_rdata = SRAM_DQ;
assign SRAM_CE_N = 1'b0;
assign SRAM_WE_N = c_mgr_initdone ? c_nes_sram_we_n : c_mgr_sram_we_n;
assign SRAM_OE_N = c_mgr_initdone ? c_nes_sram_oe_n : c_mgr_sram_oe_n;
assign SRAM_LB_N = c_mgr_initdone ? c_nes_sram_lb_n : c_mgr_sram_lb_n;
assign SRAM_UB_N = c_mgr_initdone ? c_nes_sram_ub_n : c_mgr_sram_ub_n;
assign c_sram_addr  = c_mgr_initdone ? c_nes_sram_addr : c_mgr_sram_addr;
always @ ( posedge c_clk_ppu_sram) SRAM_ADDR <= c_sram_addr;
assign c_sram_wdata = c_mgr_initdone ? c_nes_sram_wdata : c_mgr_sram_wdata;
assign SRAM_DQ[15:8] = (SRAM_WE_N | SRAM_UB_N)? {8{1'bz}} : c_sram_wdata[15:8];
assign SRAM_DQ[7:0]  = (SRAM_WE_N | SRAM_LB_N)? {8{1'bz}} : c_sram_wdata[7:0];

/*
FLASH Interface
*/
assign  FL_RST_N = i_rstn;
assign  FL_CE_N = 1'b0;
assign  FL_OE_N = 1'b0;     //read only
assign  FL_WE_N = 1'b1;     //read only
assign  FL_WP_N = 1'b1;     //write protection off
assign  FL_ADDR = c_mgr_initdone ? c_nes_fl_addr : c_mgr_fl_addr;
assign  c_fl_q = FL_DQ;


/*
PS2
*/
assign c_ps2_rxclk = PS2_CLK;
assign c_ps2_rxdata = PS2_DAT;
assign PS2_CLK = c_ps2_txclk_e ? c_ps2_txclk : 1'bz;
assign PS2_DAT = c_ps2_txdata_e ? c_ps2_txdata : 1'bz;
assign c_ps2_rxclk2 = PS2_CLK2;
assign c_ps2_rxdata2 = PS2_DAT2;
assign PS2_CLK2 = c_ps2_txclk2_e ? c_ps2_txclk2 : 1'bz;   
assign PS2_DAT2 = c_ps2_txdata2_e ? c_ps2_txdata2 : 1'bz;


pll_video	pll_video(
	.inclk0 ( CLOCK_50 ),
	.c0 ( clk_33m_p ),
	.c1 ( clk_33m_out ) //120 degree
);

pll_sys	pll_sys(
	.inclk0 ( CLOCK_50 ),
	.c0 ( c_clk_cpu ),    //1.8MHz
	.c1 ( c_clk_ppu ),    //5.4MHz
	.c2 ( c_clk_ppu_sram) //5.4MHz, 60 degree
);


rstn_sync rstn_sync_cpu(
    .i_clk      (c_clk_cpu),
    .i_rstn     (i_rstn),
    .o_srstn    (c_rstn_sync_cpu)
);

rstn_sync rstn_sync_ppu(
    .i_clk      (c_clk_ppu),
    .i_rstn     (i_rstn),
    .o_srstn    (c_rstn_sync_ppu)
);


nes_console nes_console(
    .i_rstn_nes      (c_nes_rstn),//input           
    .i_clk_cpu       (c_clk_cpu),//input           
    .i_clk_ppu       (c_clk_ppu),//input
    .i_clk_lcd       (clk_33m_p),//input
    .o_sram_addr     (c_nes_sram_addr),//output  [19:0]  
    .o_sram_wdata    (c_nes_sram_wdata),//output  [15:0]  
    .i_sram_rdata    (c_sram_rdata),//input   [15:0]  
    .o_sram_we_n     (c_nes_sram_we_n),//output          
    .o_sram_oe_n     (c_nes_sram_oe_n),//output          
    .o_sram_ub_n     (c_nes_sram_ub_n),//output          
    .o_sram_lb_n     (c_nes_sram_lb_n),//output          
    .o_fl_addr       (c_nes_fl_addr),//output  [22:0]  
    .i_fl_rdata      (c_fl_q),//input   [7:0]   
    .o_lcd_pixel     ({MTL_R, MTL_G, MTL_B}),
    .o_lcd_hsd       (MTL_HSD),
    .o_lcd_vsd       (MTL_VSD),
    .o_cpu_pc        (c_nes_cpu_pc),//output  [15:0]  
    .o_cpu_sp        (c_nes_cpu_sp),//output  [7:0]   
    .o_cpu_ir        (c_nes_cpu_ir),//output  [7:0]   
    .o_cpu_p         (c_nes_cpu_p), //output  [7:0]   
    .i_jp_vec_1p     (c_jp_vec_1p),
    .i_jp_vec_2p     (c_jp_vec_2p)
);

board_lights board_lights(
    .i_rstn          (c_nes_rstn),//input           
    .i_clk           (c_clk_cpu),//input           
    .i_nes_cpu_pc    (c_nes_cpu_pc),//input   [15:0]  
    .i_nes_cpu_sp    (c_nes_cpu_sp),//input   [7:0]   
    .i_nes_cpu_ir    (c_nes_cpu_ir),//input   [7:0]   
    .i_nes_cpu_p     (c_nes_cpu_p),//input   [7:0]   
    .i_fl_ry         (FL_RY),//input           
    .o_LEDG          (LEDG),//output  [8:0]   
    .o_LEDR          (LEDR),//output  [17:0]  
    .o_HEX0          (HEX0),//output  [6:0]   
    .o_HEX1          (HEX1),//output  [6:0]   
    .o_HEX2          (HEX2),//output  [6:0]   
    .o_HEX3          (HEX3),//output  [6:0]   
    .o_HEX4          (HEX4),//output  [6:0]   
    .o_HEX5          (HEX5),//output  [6:0]   
    .o_HEX6          (HEX6),//output  [6:0]   
    .o_HEX7          (HEX7) //output  [6:0]   
);

device_mgr device_mgr(
    .i_rstn_sync_cpu    (c_rstn_sync_cpu),//input           
    .i_rstn_sync_ppu    (c_rstn_sync_ppu),//input           
    .i_cpu_clk          (c_clk_cpu),//input           
    .i_ppu_clk          (c_clk_ppu),//input           
    .i_ps2_clk          (c_ps2_rxclk),//input           
    .i_ps2_data         (c_ps2_rxdata),//input           
    .o_ps2_txclk        (c_ps2_txclk),//output          
    .o_ps2_txclk_e      (c_ps2_txclk_e),//output          
    .o_ps2_txdata       (c_ps2_txdata),//output          
    .o_ps2_txdata_e     (c_ps2_txdata_e),//output          
    .i_ps2_clk2         (c_ps2_rxclk2),//input           
    .i_ps2_data2        (c_ps2_rxdata2),//input           
    .o_ps2_txclk2       (c_ps2_txclk2),//output          
    .o_ps2_txclk2_e     (c_ps2_txclk2_e),//output          
    .o_ps2_txdata2      (c_ps2_txdata2),//output          
    .o_ps2_txdata2_e    (c_ps2_txdata2_e),//output          
    .o_fl_addr          (c_mgr_fl_addr),//output  [22:0]  
    .i_fl_rdata         (c_fl_q),//input   [7:0]   
    .o_sram_addr        (c_mgr_sram_addr),//output  [19:0]  
    .o_sram_wdata       (c_mgr_sram_wdata),//output  [15:0]  
    .i_sram_rdata       (c_sram_rdata),//input   [15:0]  
    .o_sram_oe_n        (c_mgr_sram_oe_n),//output          
    .o_sram_we_n        (c_mgr_sram_we_n),//output          
    .o_sram_ub_n        (c_mgr_sram_ub_n),//output          
    .o_sram_lb_n        (c_mgr_sram_lb_n),//output          
    .o_jp_vector_1p     (c_jp_vec_1p),//output  [9:0]   
    .o_jp_vector_2p     (c_jp_vec_2p),//output  [9:0]   
    .o_init_done        (c_mgr_initdone),//output          
    .o_nes_rstn         (c_nes_rstn) //output reg      
);



endmodule
