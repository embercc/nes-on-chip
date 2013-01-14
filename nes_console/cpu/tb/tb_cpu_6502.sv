`timescale 1ns/1ps

module tb_cpu_6502(
);
`include "Driver.sv"

logic clk;
M_BUS m_bus(clk);
M_INT m_int(clk);

clk_gen clk_source(
    .clk(clk)
);

cpu_6502 dut(
    .i_CLK       (clk),   //input               //1.79MHz
    .o_ADDR      (m_bus.DUT_PORT.ADDR),   //output  reg [15:0]  
    .i_DATA      (m_bus.DUT_PORT.iDATA),   //input       [7:0]   
    .o_DATA      (m_bus.DUT_PORT.oDATA),   //output      [7:0]   
    .o_R_WN      (m_bus.DUT_PORT.R_WN),   //output              
    .i_NMI_N     (m_int.DUT_PORT.NMI_N),   //input               
    .i_IRQ_N     (m_int.DUT_PORT.IRQ_N),   //input               
    .i_RST_N     (m_int.DUT_PORT.RST_N)    //input               
);

ram_bhv ram_ext(
    .i_clk      (clk),
    .i_addr     (m_bus.RAM_PORT.ADDR    ),
    .i_data     (m_bus.RAM_PORT.oDATA   ),
    .i_w_n      (m_bus.RAM_PORT.R_WN    ),
    .o_q        (m_bus.RAM_PORT.iDATA   )
);
//tb_top tb_top(m_bus, m_int);

Driver driver;
   
initial begin
    driver = new(/*m_bus.TB_PORT, */m_int.TB_PORT);
    driver.init();
    driver.run();
end


endmodule

