module tb_nes_player();

import "DPI-C" function void set_pixel(input int x, input int y, input int rgb);
import "DPI-C" function void dump_file();

//////////// CLOCK //////////
wire 		          		CLOCK_50;

//////////// LED //////////
wire		     [8:0]		LEDG;
wire		    [17:0]		LEDR;

//////////// KEY //////////
reg 		     [3:0]		KEY;

//////////// SW //////////
wire 		    [17:0]		SW;

//////////// SEG7 //////////
wire		     [6:0]		HEX0;
wire		     [6:0]		HEX1;
wire		     [6:0]		HEX2;
wire		     [6:0]		HEX3;
wire		     [6:0]		HEX4;
wire		     [6:0]		HEX5;
wire		     [6:0]		HEX6;
wire		     [6:0]		HEX7;

//////////// LCD //////////
wire		          		LCD_BLON;
wire 		     [7:0]		LCD_DATA;
wire		          		LCD_EN  ;
wire		          		LCD_ON  ;
wire		          		LCD_RS  ;
wire		          		LCD_RW  ;

//////////// PS2 for Keyboard and Mouse //////////
wire 		          		PS2_CLK ;
wire 		          		PS2_CLK2;
wire 		          		PS2_DAT ;
wire 		          		PS2_DAT2;

//////////// SDCARD //////////
wire		          		SD_CLK  ;
wire 		          		SD_CMD  ;
wire 		     [3:0]		SD_DAT  ;
reg 		          		SD_WP_N ;

//////////// Audio //////////
wire 		          		AUD_ADCDAT  ;
wire 		          		AUD_ADCLRCK ;
wire 		          		AUD_BCLK    ;
wire		          		AUD_DACDAT  ;
wire 		          		AUD_DACLRCK ;
wire		          		AUD_XCK     ;

//////////// I2C for Audio  //////////
wire		          		I2C_SCLK;
wire 		          		I2C_SDAT;

//////////// SRAM //////////
wire	        [19:0]		SRAM_ADDR   ;
wire		          		SRAM_CE_N   ;
wire 		    [15:0]		SRAM_DQ     ;
wire		          		SRAM_LB_N   ;
wire		          		SRAM_OE_N   ;
wire		          		SRAM_UB_N   ;
wire		          		SRAM_WE_N   ;

//////////// Flash //////////
wire		    [22:0]		FL_ADDR ;
wire		          		FL_CE_N ;
wire 		     [7:0]		FL_DQ   ;
wire		          		FL_OE_N ;
wire		          		FL_RST_N;
reg 		          		FL_RY   ;
wire		          		FL_WE_N ;
wire		          		FL_WP_N ;

//////////// GPIO, GPIO connect to MTL - Multi-Touch LCD Panel //////////
wire		     [7:0]		MTL_B               ;
wire		          		MTL_DCLK            ;
wire		     [7:0]		MTL_G               ;
wire		          		MTL_HSD             ;
wire		     [7:0]		MTL_R               ;
wire		          		MTL_TOUCH_I2C_SCL   ;
wire 		          		MTL_TOUCH_I2C_SDA   ;
reg 		          		MTL_TOUCH_INT_n     ;
wire		          		MTL_VSD             ;


reg [10:0]  r_xcnt;
reg [9:0]   r_line;
reg         r_hsd;
reg         r_vsd;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
`ifdef DUMP_WAVE
initial begin
    $shm_open("waves.shm", , , ,1024, );
    $shm_probe("AS");
end
`endif

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


assign  LCD_DATA        = 8'hz;
assign  PS2_CLK         = 1'hz;
assign  PS2_CLK2        = 1'hz;
assign  PS2_DAT         = 1'hz;
assign  PS2_DAT2        = 1'hz;
assign  SD_CMD          = 1'hz;
assign  SD_DAT          = 4'hz;
assign  AUD_ADCLRCK     = 1'hz;
assign  AUD_BCLK        = 1'hz;
assign  AUD_DACLRCK     = 1'hz;
assign  I2C_SDAT        = 1'hz;

assign SW = 18'h0;

clk_gen #( .HALFCYCLE(10ns)) BOARD_CLK(
    .clk(CLOCK_50)
);

initial begin
    reset_system;
    idle_for_20s;
    $display("simulation end,");
    $finish;
end

//frame counter
integer frame_counter;
initial begin
    frame_counter = 0;
    forever begin
        @(posedge dut.nes_console.ppu_2C02.c_vblank);
        $display("-------- vblank: %d @ %d --------", frame_counter, $time);
        frame_counter = frame_counter + 1;
    end
end

//////////////////DUMP BMP/////////////////////////
//////////////////DUMP BMP/////////////////////////
//////////////////DUMP BMP/////////////////////////
always @(posedge MTL_DCLK) begin
    r_hsd <= MTL_HSD;
    r_vsd <= MTL_VSD;
end

always @(posedge MTL_DCLK or negedge dut.nes_console.c_rstn_lcd) begin
    if(~dut.nes_console.i_rstn_nes) begin
        r_xcnt <= 0;
        r_line <= 0;
    end
    else begin
        if(r_xcnt == 11'd1055) begin
            r_xcnt <= 11'h0;
        end
        else begin
            r_xcnt <= r_xcnt + 11'h1;
        end
        
        if(r_xcnt == 11'd1055) begin
            if(r_line==10'd524) begin
                r_line <= 10'h0;
            end
            else begin    
                r_line <= r_line + 10'h1;
            end
        end
    end
end

int xxxx;
int yyyy;
int rgb;
always @(posedge MTL_DCLK) begin
    if(r_xcnt>=50 && r_xcnt<850 && r_line >=23 && r_line<503) begin
        xxxx = {21'h0, r_xcnt} - 50;
        yyyy = {22'h0, r_line} - 23;
        rgb = {8'h0, MTL_R, MTL_G, MTL_B};
        set_pixel(xxxx, yyyy, rgb);
    end
end

always @ (posedge MTL_DCLK) begin
    if(~MTL_VSD & r_vsd) begin
        dump_file();
    end
end
///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////


task idle_for_20s;
    #20s;
endtask

task joypad_sequence;
    #100_000_000ns;
    #60_000_000ns;
    $display("branch test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    
    //#100_000_000ns;
    //flag tests
    $display("flag test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    
    //#100_000_000ns;
    //immediate test
    $display("immediate test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    
    //#100_000_000ns;
    //implied test
    $display("implied test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    
    $display("stack test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    
    $display("accumulator test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    
    $display("(indirect,x) test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    
    $display("zeropage test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    
    $display("absolute test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    
    $display("(indirect),y test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    
    $display("absolute,y test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    
    $display("zeropage,x test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    
    $display("absolute,x test @ %d", $time);
    press_down;
    release_all;
    press_start;
    release_all;
    #100_000_000ns;
    
    $display("all test @ %d", $time);                         
    press_start; 
    release_all; 
    #400_000_000ns;
    #10s;
endtask

task press_down();
    force dut.c_jp_vec_1p[9:0] = 10'b0100_0000_00;
    #60_000_000ns;
endtask

task press_up();
    force dut.c_jp_vec_1p[9:0] = 10'b1000_0000_00;
    #60_000_000ns;
endtask

task press_start();
    force dut.c_jp_vec_1p[9:0] = 10'b0000_0000_01;
    #60_000_000ns;
endtask

task release_all();
    force dut.c_jp_vec_1p[9:0] = 10'b0000_0000_00;
    #40_000_000ns;
endtask

task reset_system();
    KEY = 4'h0;
    #10000ns;
    KEY = 4'h1;
    $display("reset done.");
endtask

sram_bhv chr_ram(
    .i_addr     (SRAM_ADDR),//input   [19 : 0]    
    .i_ce_n     (SRAM_CE_N),//input               
    .io_dq      (SRAM_DQ  ),//inout   [15 : 0]    
    .i_lb_n     (SRAM_LB_N),//input               
    .i_oe_n     (SRAM_OE_N),//input               
    .i_ub_n     (SRAM_UB_N),//input               
    .i_we_n     (SRAM_WE_N) //input               
);


/*
flash_bhv #(
    .PRG_INITVEC("/workspace/nesdev/nes_project/roms/nestest.nes.prg.txt"),
    .CHR_INITVEC("/workspace/nesdev/nes_project/roms/nestest.nes.chr.txt")
)
prg_chr_rom(
    .i_addr     (FL_ADDR),//input   [22:0] 
    .o_q        (FL_DQ)   //output  [7:0]  
);
*/

flash_bhv #(
    .PRG_INITVEC("/workspace/nesdev/nes_project/roms/S_mario_2.nes.prg.txt"),
    .CHR_INITVEC("/workspace/nesdev/nes_project/roms/S_mario_2.nes.chr.txt")
)
prg_chr_rom(
    .i_addr     (FL_ADDR),//input   [22:0] 
    .o_q        (FL_DQ)   //output  [7:0]  
);


nes_player dut(
	.CLOCK_50               (CLOCK_50),
	.CLOCK2_50              (1'b0),
	.CLOCK3_50              (1'b0),
	.LEDG                   (LEDG),
	.LEDR                   (LEDR),
	.KEY                    (KEY),
	.SW                     (SW),
	.HEX0                   (HEX0),
	.HEX1                   (HEX1),
	.HEX2                   (HEX2),
	.HEX3                   (HEX3),
	.HEX4                   (HEX4),
	.HEX5                   (HEX5),
	.HEX6                   (HEX6),
	.HEX7                   (HEX7),
	.LCD_BLON               (LCD_BLON),
	.LCD_DATA               (LCD_DATA),
	.LCD_EN                 (LCD_EN  ),
	.LCD_ON                 (LCD_ON  ),
	.LCD_RS                 (LCD_RS  ),
	.LCD_RW                 (LCD_RW  ),
	.PS2_CLK                (PS2_CLK ),
	.PS2_CLK2               (PS2_CLK2),
	.PS2_DAT                (PS2_DAT ),
	.PS2_DAT2               (PS2_DAT2),
	.SD_CLK                 (SD_CLK ),
	.SD_CMD                 (SD_CMD ),
	.SD_DAT                 (SD_DAT ),
	.SD_WP_N                (SD_WP_N),
	.AUD_ADCDAT             (AUD_ADCDAT ),
	.AUD_ADCLRCK            (AUD_ADCLRCK),
	.AUD_BCLK               (AUD_BCLK   ),
	.AUD_DACDAT             (AUD_DACDAT ),
	.AUD_DACLRCK            (AUD_DACLRCK),
	.AUD_XCK                (AUD_XCK    ),
	.I2C_SCLK               (I2C_SCLK),
	.I2C_SDAT               (I2C_SDAT),
	.SRAM_ADDR              (SRAM_ADDR),
	.SRAM_CE_N              (SRAM_CE_N),
	.SRAM_DQ                (SRAM_DQ  ),
	.SRAM_LB_N              (SRAM_LB_N),
	.SRAM_OE_N              (SRAM_OE_N),
	.SRAM_UB_N              (SRAM_UB_N),
	.SRAM_WE_N              (SRAM_WE_N),
	.FL_ADDR                (FL_ADDR ),
	.FL_CE_N                (FL_CE_N ),
	.FL_DQ                  (FL_DQ   ),
	.FL_OE_N                (FL_OE_N ),
	.FL_RST_N               (FL_RST_N),
	.FL_RY                  (FL_RY   ),
	.FL_WE_N                (FL_WE_N ),
	.FL_WP_N                (FL_WP_N ),
	.MTL_B                  (MTL_B            ),
	.MTL_DCLK               (MTL_DCLK         ),
	.MTL_G                  (MTL_G            ),
	.MTL_HSD                (MTL_HSD          ),
	.MTL_R                  (MTL_R            ),
	.MTL_TOUCH_I2C_SCL      (MTL_TOUCH_I2C_SCL),
	.MTL_TOUCH_I2C_SDA      (MTL_TOUCH_I2C_SDA),
	.MTL_TOUCH_INT_n        (MTL_TOUCH_INT_n  ),
	.MTL_VSD                (MTL_VSD          )
);

endmodule
