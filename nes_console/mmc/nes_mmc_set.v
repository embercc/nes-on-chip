//no mapper now.
module nes_mmc_set(
    input           i_clk           ,
    input           i_rstn          ,
                                    
    input [15:0]    i_bus_addr      ,
    input [7:0]     i_bus_wdata     ,
    input           i_bus_r_wn      ,
    output[7:0]     o_mmc_rdata     ,
    
    output[22:0]    o_fl_addr       ,
    input [7:0]     i_fl_rdata      ,
    
    output[19:12]   o_sram_addr_ext ,
    
    output          o_irq_n
);
    parameter MMC_FUNC = 8'h00;

    wire        c_mmc_hit;
    wire        c_mmc_regw;
    reg [22:15] r_addr_ext;
    reg [19:12] r_sram_addr_ext;
    assign  c_mmc_hit = i_bus_addr[15];
    assign  c_mmc_regw = c_mmc_hit & ~i_bus_r_wn;
    //the shit always-block below is just for test right now.
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn) begin
            r_addr_ext <= 8'h0;
        end
        else begin
            r_addr_ext <= 8'h0;
        end
    end
    
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn) begin
            r_sram_addr_ext <= 8'h0;
        end
        else begin
            r_sram_addr_ext <= 8'h0;
        end
    end
    
    assign  o_mmc_rdata = c_mmc_hit ? i_fl_rdata[7:0] : 8'h0;
    assign  o_fl_addr = c_mmc_hit ? {r_addr_ext, i_bus_addr[14:0]} : 23'h0;
    assign  o_irq_n = 1'b1;
endmodule
