`timescale 10ns/1ns

module board_lights(
    input           i_rstn          ,
    input           i_clk           ,
    input   [15:0]  i_nes_cpu_pc    ,
    input   [7:0]   i_nes_cpu_sp    ,
    input   [7:0]   i_nes_cpu_ir    ,
    input   [7:0]   i_nes_cpu_p     ,
    input           i_fl_ry         ,
    output  [8:0]   o_LEDG          ,
    output  [17:0]  o_LEDR          ,
    output  [6:0]   o_HEX0          ,
    output  [6:0]   o_HEX1          ,
    output  [6:0]   o_HEX2          ,
    output  [6:0]   o_HEX3          ,
    output  [6:0]   o_HEX4          ,
    output  [6:0]   o_HEX5          ,
    output  [6:0]   o_HEX6          ,
    output  [6:0]   o_HEX7          
);
    assign o_LEDG[7:0] = {i_nes_cpu_p[0], 
                        i_nes_cpu_p[1],
                        i_nes_cpu_p[2],
                        i_nes_cpu_p[3],
                        i_nes_cpu_p[4],
                        i_nes_cpu_p[5],
                        i_nes_cpu_p[6],
                        i_nes_cpu_p[7]};
    assign o_LEDG[8] = i_fl_ry;
    
    breath_led breath_led(
        .i_clk  (i_clk),
        .i_rstn (i_rstn),
        .o_led  (o_LEDR[0])
    );



    hex2sig_rotate sig0(
        .i_hex          (i_nes_cpu_pc[15:12]),
        .o_sig          (o_HEX0)
    );
    hex2sig_rotate sig1(
        .i_hex          (i_nes_cpu_pc[11:8]),
        .o_sig          (o_HEX1)
    );
    hex2sig_rotate sig2(
        .i_hex          (i_nes_cpu_pc[7:4]),
        .o_sig          (o_HEX2)
    );
    hex2sig_rotate sig3(
        .i_hex          (i_nes_cpu_pc[3:0]),
        .o_sig          (o_HEX3)
    );
    
    hex2sig_rotate sig4(
        .i_hex          (i_nes_cpu_sp[7:4]),
        .o_sig          (o_HEX4)
    );
    hex2sig_rotate sig5(
        .i_hex          (i_nes_cpu_sp[3:0]),
        .o_sig          (o_HEX5)
    );
    
    hex2sig_rotate sig6(
        .i_hex          (i_nes_cpu_ir[7:4]),
        .o_sig          (o_HEX6)
    );
    hex2sig_rotate sig7(
        .i_hex          (i_nes_cpu_ir[3:0]),
        .o_sig          (o_HEX7)
    );
    
endmodule
