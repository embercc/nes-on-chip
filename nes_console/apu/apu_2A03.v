`timescale 10ns/1ns

module apu_2A03_pseudo(
    input           i_clk       ,
    input           i_rstn      ,
    //control port
    input   [15:0]  i_reg_addr  ,
    input           i_reg_wn    ,
    input   [7:0]   i_reg_wdata ,
    output  [7:0]   o_reg_rdata ,
    //master port
    output          o_dmc_req   ,
    input           i_dmc_gnt   ,
    output  [15:0]  o_dmc_addr  ,
    input   [7:0]   i_dmc_smpl  ,
    
    output          o_irq_n    
);
    
    
    reg r_ena_dmc;
    reg r_ena_noi;
    reg r_ena_tri;
    reg r_ena_pul2;
    reg r_ena_pul1;
    
    reg r_frm_mode;
    reg r_dis_frm_irq;
    
    wire c_dmc_irq;
    wire c_frm_irq;
    
    
    
    assign c_dmc_irq = 1'b1;
    assign c_frm_irq = 1'b1;
    
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn) begin
            {r_ena_dmc, r_ena_noi, r_ena_tri, r_ena_pul2, r_ena_pul1} <= 5'h0;
        end
        else begin
            if(i_reg_addr==16'h4015 && ~i_reg_wn) begin
                {r_ena_dmc, r_ena_noi, r_ena_tri, r_ena_pul2, r_ena_pul1} <= i_reg_wdata[4:0];
            end
        end
    end
    
    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn) begin
            {r_frm_mode, r_dis_frm_irq} <= 2'h0;
        end
        else begin
            if(i_reg_addr==16'h4017 && ~i_reg_wn) begin
                {r_frm_mode, r_dis_frm_irq} <= i_reg_wdata[7:6];
            end
        end
    end
    
    assign o_reg_rdata = ~i_reg_wn ?  8'h0 :
                         (i_reg_addr==16'h4015) ? {c_dmc_irq, c_frm_irq, 6'b0} :
                         8'h0;
    
    
    assign o_irq_n = c_dmc_irq & c_frm_irq;
    assign o_dmc_req = 1'b0;
    assign o_dmc_addr = 16'h0;
endmodule
