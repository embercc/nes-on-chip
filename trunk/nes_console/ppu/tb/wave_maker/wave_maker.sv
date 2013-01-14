`timescale 10ns/1ns

`define GO_CLK @posedge(clk)

module wave_maker(
);

reg clk;
reg [15:0]pattern_shift_L;
reg [15:0]pattern_shift_H;
reg [15:0]attr_shift_L;
reg [15:0]attr_shift_H;
reg [8:0] scanline_x;
reg [8:0] scanline_y;
reg [7:0] scroll_x;
reg [7:0] scroll_y;
reg [4:0] nt_x;
reg [4:0] nt_y;
reg [4:0] nt_x_1;
reg [4:0] nt_x_2;
reg [7:0] nt_out;
reg [15:0] patt_out;
reg [7:0] attr_out;
initial begin
    clk = 0;
    forever #100ns clk = ~clk;
end




initial begin
    #1000;
    GO_CLK;
    scanline_y <= -1;
    scanline_x <= 340;
    pattern_shift_H <= 8'h35;
    pattern_shift_H <= 8'h36;
    
end

endmodule
