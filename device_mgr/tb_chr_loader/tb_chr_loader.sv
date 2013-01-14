module tb_chr_loader();
    wire i_clk;
    wire i_cpu_clk;
    reg  i_rstn;
    wire o_done;
    wire [22:0] o_fl_addr;
    wire  [7:0] i_fl_rdata;
    wire [19:0] o_sram_addr;
    wire [15:0] o_sram_wdata;
    reg [15:0]  i_sram_rdata;
    wire        o_sram_oe_n;
    wire        o_sram_we_n;
    wire        o_sram_ub_n;
    wire        o_sram_lb_n;
      
    clk_gen #( .HALFCYCLE(50ns)) ppu_clk(
        .clk(i_clk)
    );
      
    clk_gen # (.HALFCYCLE(150ns)) cpu_clk(
        .clk(i_cpu_clk)
    );
    
    ram_bhv #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(20)
    ) flash_model(
        .i_clk(i_clk),
        .i_addr(o_fl_addr[19:0]),
        .i_data(8'h0),
        .i_w_n(1'b1),
        .o_q(i_fl_rdata)
    );
    
    initial begin
        i_rstn <= 1'b1;
        @(posedge i_clk);
        i_rstn <= 1'b0;
        repeat(10) @(posedge i_clk);
        i_rstn <= 1'b1;
        wait(o_done);
        repeat(10) @(posedge i_clk);
        $stop();
    end
    
    
    
    
    
    
    
    
    
       
      
    chr_loader dut(
        .i_clk          (i_clk),//ppu clk //input           
        //.i_cpu_clk      (i_cpu_clk),          //input           
        .i_rstn         (i_rstn),          //input           
        .o_done    (o_done),          //output          
        .o_fl_addr      (o_fl_addr),          //output [22:0]   
        .i_fl_rdata     (i_fl_rdata),          //input  [7:0]    
        .o_sram_addr    (o_sram_addr),          //output  [19:0]  
        .o_sram_wdata   (o_sram_wdata),          //output  [15:0]  
        .i_sram_rdata   (i_sram_rdata),          //input           
        .o_sram_oe_n    (o_sram_oe_n),          //output          
        .o_sram_we_n    (o_sram_we_n),          //output          
        .o_sram_ub_n    (o_sram_ub_n),          //output          
        .o_sram_lb_n    (o_sram_lb_n)           //output          
    );
endmodule
