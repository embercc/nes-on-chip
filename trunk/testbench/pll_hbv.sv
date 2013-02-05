`timescale 1ns/1ns
module pll_video_bhv(
	input       inclk0  ,//( CLOCK_50 ),
	output      c0      ,//( clk_33m_p ),
	output reg  c1       //( clk_33m_out ) //120 degree
);

clk_gen #( .HALFCYCLE(15ns)) video_clk_osc(
    .clk(c0)
);

always @ ( * ) begin
    c1 = #10ns c0;
end

endmodule



`timescale 1ns/1ns
module pll_sys_bhv(
	input           inclk0  ,//( CLOCK_50 ),
	output          c0      ,//( c_clk_cpu ),    //1.8MHz               
	output          c1      ,//( c_clk_ppu ),    //5.4MHz               );
	output reg      c2       //( c_clk_ppu_sram) //5.4MHz, 60 degree    
);

clk_gen #( .HALFCYCLE(279ns)) cpu_clk_osc(
    .clk(c0)
);

clk_gen #( .HALFCYCLE(93ns)) ppu_clk_osc(
    .clk(c1)
);

always @( * ) begin
    c2 = #30ns c1;
end

endmodule
