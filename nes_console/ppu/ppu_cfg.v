module ppu_cfg(
    input           i_cpu_clk   ,
    input           i_cpu_rstn  ,
    
    input   [15:0]  i_bus_addr  ,
    input           i_bus_wn    ,
    input   [7:0]   i_bus_wdata ,
    output  [7:0]   o_ppu_rdata ,
    
    output  [7:0]   o_oam_addr  ,
    output          o_oam_we    ,
    output  [7:0]   o_oam_wdata ,
    input   [7:0]   i_oam_rdata ,
    
    output  [15:0]  o_vram_addr ,//vram write port, for addr $0000-$FFFF
    output          o_vram_we   ,
    output  [7:0]   o_vram_wdata,
    input   [7:0]   i_vram_rdata,
    output          o_2007_visit,
    //ppu cfg
    output  [5:0]   o_ppuctrl   ,//LoopyT[11:10]
    output  [7:0]   o_ppumask   ,
    output  [7:0]   o_ppuscrollX,//LoopyT[4:0] and fineX
    output  [7:0]   o_ppuscrollY,//LoopyT[9:5] and fineY
    output          o_force_rld ,
    input           i_spr_ovfl  ,
    input           i_spr_0hit  ,
    input           i_vblank    ,
    output          o_nmi_n     
);

wire        c_is_ppu;
wire [2:0]  c_ppu_reg;

reg [7:0]   r_ppuctrl;
reg [7:0]   r_ppumask   ;

reg [7:0]   r_oamaddr   ;
reg [7:0]   r_ppuscrollx;
reg [7:0]   r_ppuscrolly;
reg [15:0]  r_ppuaddr;      //LoopyV for VRAM Config, for cpu access
reg [7:0]   r_vram_rbuf;

reg [15:0]  r_loopyT;      //LoopyT
reg [2:0]   r_fineX;
reg [2:0]   r_fineY;

reg         r_nmi_n     ;
reg         r_vblank;
wire        c_vblank_pos;

wire        c_vr_incmode;
wire        c_nmi_ena   ;

reg         r_wcnt;
wire        c_is_palette;
reg [4:0]   r_lastwrite;

assign c_is_ppu = i_bus_addr[15:13]==3'b001;
assign c_ppu_reg = i_bus_addr[2:0];


//PPUCTRL $2000 Write
always @ ( posedge i_cpu_clk or negedge i_cpu_rstn) begin
    if(~i_cpu_rstn) begin
        r_ppuctrl <= 8'h0;
    end
    else begin
        if(c_is_ppu & (c_ppu_reg==3'h0) & ~i_bus_wn) begin
            r_ppuctrl <= i_bus_wdata;
        end
    end
end

assign c_nmi_ena    = r_ppuctrl[7];
assign c_vr_incmode = r_ppuctrl[2];


//PPUMASK $2001 Write
always @ ( posedge i_cpu_clk or negedge i_cpu_rstn) begin
    if(~i_cpu_rstn) begin
        r_ppumask <= 8'h0;
    end
    else begin
        if(c_is_ppu & (c_ppu_reg==3'h1) & ~i_bus_wn) begin
            r_ppumask <= i_bus_wdata;
        end
    end
end

//OAMADDR $2003 Write
always @ ( posedge i_cpu_clk or negedge i_cpu_rstn) begin
    if(~i_cpu_rstn) begin
        r_oamaddr <= 8'h00;
    end
    else begin
        if(c_is_ppu & (c_ppu_reg==3'h3) & ~i_bus_wn) begin
            r_oamaddr <= i_bus_wdata;
        end
        else if(c_is_ppu & (c_ppu_reg==3'h4) & ~i_bus_wn) begin
            r_oamaddr <= r_oamaddr + 8'h1;
        end
    end
end

//write counter, for $2005 and $2006
always @ ( posedge i_cpu_clk or negedge i_cpu_rstn) begin
    if(~i_cpu_rstn) begin
        r_wcnt <= 1'b0;
    end
    else begin
        if(c_is_ppu & (c_ppu_reg==3'h2) & i_bus_wn)
            r_wcnt <= 1'b0;
        else if (c_is_ppu & (c_ppu_reg==3'h5) & ~i_bus_wn)
            r_wcnt <= ~r_wcnt;
        else if (c_is_ppu & (c_ppu_reg==3'h6) & ~i_bus_wn)
            r_wcnt <= ~r_wcnt;
    end
end

//PPUSCROLL $2005
always @ ( posedge i_cpu_clk or negedge i_cpu_rstn) begin
    if(~i_cpu_rstn) begin
        r_ppuscrollx <= 8'h0;
        r_ppuscrolly <= 8'h0;
    end
    else begin
        if(c_is_ppu & (c_ppu_reg==3'h5) & ~i_bus_wn) begin
            if(r_wcnt)
                r_ppuscrolly <= i_bus_wdata;
            else
                r_ppuscrollx <= i_bus_wdata;
        end
    end
end

//PPUADDR $2006
always @ ( posedge i_cpu_clk or negedge i_cpu_rstn) begin
    if(~i_cpu_rstn) begin
        r_ppuaddr <= 16'h0;
    end
    else begin
        if(c_is_ppu & (c_ppu_reg==3'h6) & ~i_bus_wn) begin
            if(r_wcnt) begin
                r_ppuaddr[7:0] <= i_bus_wdata;
                r_ppuaddr[15:8] <= r_loopyT[15:8];
            end
            else begin
                //r_ppuaddr[15:8] <= i_bus_wdata;
            end
        end
        else if(c_is_ppu & (c_ppu_reg==3'h7)) begin //access $2007 will increase PPUADDR(LoopyV for cpu access)
            if (c_vr_incmode)
                r_ppuaddr <= r_ppuaddr + 16'h20;
            else
                r_ppuaddr <= r_ppuaddr + 16'h1;
        end
    end
end

//LoopyT
always @( posedge i_cpu_clk or negedge i_cpu_rstn) begin
    if(~i_cpu_rstn) begin
        r_loopyT <= 16'h0;
        r_fineX <= 3'h0;
        r_fineY <= 3'h0;
    end
    else begin
        if(c_is_ppu & ~i_bus_wn) begin
            if(c_ppu_reg==3'h0) begin
                r_loopyT[11:10]<= i_bus_wdata[1:0];
            end
            else if (c_ppu_reg==3'h5) begin
                if(r_wcnt) begin
                    r_loopyT[9:5] <= i_bus_wdata[7:3];
                    r_fineY <= i_bus_wdata[2:0];
                end
                else begin
                    r_loopyT[4:0] <= i_bus_wdata[7:3];
                    r_fineX <= i_bus_wdata[2:0];
                end
            end
            else if (c_ppu_reg==3'h6) begin
                if(r_wcnt) begin
                    r_loopyT[7:0] <= i_bus_wdata;
                end
                else begin
                    r_loopyT[15:8] <= {2'b00,i_bus_wdata[5:0]};
                end
            end
        end
    end
end
















assign c_is_palette = r_ppuaddr[13:8]==6'b11_1111;

//PPUDATA $2007 Read will update the internal buffer.
always @ ( posedge i_cpu_clk or negedge i_cpu_rstn) begin
    if(~i_cpu_rstn) begin
        r_vram_rbuf <= 8'h0;
    end
    else begin
        if(c_is_ppu & (c_ppu_reg==3'h7) & i_bus_wn)
            r_vram_rbuf <= i_vram_rdata;
    end
end


//NMI Generator
always @ ( posedge i_cpu_clk or negedge i_cpu_rstn) begin
    if(~i_cpu_rstn) begin
        r_vblank <= 1'b0;
    end
    else begin
        r_vblank <= i_vblank;
    end
end
assign c_vblank_pos = i_vblank & ~r_vblank;
always @ ( posedge i_cpu_clk or negedge i_cpu_rstn) begin
    if(~i_cpu_rstn) begin
        r_nmi_n <= 1'b1;
    end
    else begin
        if (c_vblank_pos)
            r_nmi_n <= 1'b0;
        else if (c_is_ppu & (c_ppu_reg==3'h2) & i_bus_wn)   //reading $2002 clears NMI
            r_nmi_n <= 1'b1;
        else if(~i_vblank)
            r_nmi_n <= 1'b1;
    end
end


always @ ( posedge i_cpu_clk or negedge i_cpu_rstn) begin
    if(~i_cpu_rstn) begin
        r_lastwrite <= 5'h0;
    end
    else begin
        if (c_is_ppu & ~i_bus_wn)
            r_lastwrite <= i_bus_wdata[4:0];
    end
end


//OAMDATA $2004, WRITE
assign o_oam_addr = r_oamaddr;
assign o_oam_we = c_is_ppu & (c_ppu_reg==3'h4) & ~i_bus_wn;
assign o_oam_wdata = i_bus_wdata;

//PPUDATA $2007 WRITE
assign o_vram_addr = r_ppuaddr; //the data will be valid or witten after posedge.
assign o_vram_we = c_is_ppu & (c_ppu_reg==3'h7) & ~i_bus_wn;
assign o_vram_wdata = i_bus_wdata;
assign o_2007_visit = c_is_ppu & (c_ppu_reg==3'h7);

//read
assign o_ppu_rdata =    ~c_is_ppu         ? 8'h0 :
                        (c_ppu_reg==3'h2) ? {~r_nmi_n, i_spr_0hit, i_spr_ovfl, r_lastwrite} :
                        (c_ppu_reg==3'h4) ? i_oam_rdata :
                        (c_ppu_reg==3'h7) ? (c_is_palette ? i_vram_rdata : r_vram_rbuf) :
                        8'h0;

assign o_nmi_n = c_nmi_ena ? r_nmi_n : 1'b1;
//PPU CFG
assign o_ppuctrl = {r_ppuctrl[5:2], r_loopyT[11:10]};
assign o_ppumask = r_ppumask[7:0];
//assign o_ppuscrollX = r_ppuscrollx;
//assign o_ppuscrollY = r_ppuscrolly;
assign  o_ppuscrollX = {r_loopyT[4:0], r_fineX};
assign  o_ppuscrollY = {r_loopyT[9:5], r_fineY};
assign  o_force_rld = c_is_ppu & (c_ppu_reg==3'h6) & ~i_bus_wn & r_wcnt;

endmodule
