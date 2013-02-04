module ppu_dma(
    input           i_clk       ,
    input           i_rstn      ,
    //slave
    input   [15:0]  i_bus_addr  ,
    input           i_bus_wn    ,
    input   [7:0]   i_bus_wdata ,
    //master
    output          o_spr_req   ,
    input           i_spr_gnt   ,
    output  [15:0]  o_spr_addr  ,
    output          o_spr_wn    ,
    output  [7:0]   o_spr_wdata ,
    input   [7:0]   i_spr_rdata
);

reg [1:0] r_dma_state;
reg [1:0] c_dma_next;
parameter [1:0] DMA_IDLE    = 2'b00;
parameter [1:0] DMA_RD_MEM   = 2'b01;
parameter [1:0] DMA_WR_OAM   = 2'b10;
reg [7:0]   r_dma_cnt;
reg [7:0]   r_bus_buf;
reg [15:8]  r_spr_addr_h;

//cfg port
always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_spr_addr_h <= 8'h0;
    end
    else begin
        if((i_bus_addr==16'h4014) & (~i_bus_wn))
            r_spr_addr_h <= i_bus_wdata;
    end
end 

//state machine
always @ ( * ) begin
    case (r_dma_state)
        DMA_IDLE:
            if((i_bus_addr==16'h4014) & (~i_bus_wn))
                c_dma_next = DMA_RD_MEM;
            else
                c_dma_next = DMA_IDLE;
        DMA_RD_MEM:
            if(i_spr_gnt)
                c_dma_next = DMA_WR_OAM;
            else
                c_dma_next = DMA_RD_MEM;
        DMA_WR_OAM:
            if(i_spr_gnt) begin
                if(r_dma_cnt==8'hff)
                    c_dma_next = DMA_IDLE;
                else
                    c_dma_next = DMA_RD_MEM;
            end
            else
                c_dma_next = DMA_WR_OAM;
        default:
            c_dma_next = DMA_IDLE;
    endcase
end

always @ (posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_dma_state <= DMA_IDLE;
    end
    else begin
        r_dma_state <= c_dma_next;
    end
end

always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_dma_cnt <= 8'hff;
    end
    else begin
        if(r_dma_state==DMA_IDLE)
            r_dma_cnt <= 8'hff;
        else if((r_dma_state==DMA_RD_MEM) & i_spr_gnt)
            r_dma_cnt <= r_dma_cnt + 8'h1;
    end
end

always @(posedge i_clk or negedge i_rstn) begin
    if(~i_rstn) begin
        r_bus_buf <= 8'h0;
    end
    else begin
        if((r_dma_state==DMA_RD_MEM) & i_spr_gnt)
            r_bus_buf <= i_spr_rdata;
    end
end 



assign o_spr_req = (r_dma_state==DMA_RD_MEM) | (r_dma_state==DMA_WR_OAM);
assign o_spr_addr = (r_dma_state==DMA_RD_MEM) ?{r_spr_addr_h, r_dma_cnt} :
                    (r_dma_state==DMA_WR_OAM) ? 16'h2004 :
                    16'h0;
assign o_spr_wn = (r_dma_state==DMA_WR_OAM) ? 1'b0 : 1'b1;
assign o_spr_wdata = r_bus_buf;



endmodule
