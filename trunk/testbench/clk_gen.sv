`timescale 1ns/1ps

module clk_gen#(
    parameter HALFCYCLE = 250ns
)(
    output reg clk
);
    initial begin
        clk = 0;
        forever #HALFCYCLE clk = ~clk;
    end
    
endmodule