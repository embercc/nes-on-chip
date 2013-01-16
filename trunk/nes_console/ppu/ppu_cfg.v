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
    
    
    input           i_spr_ovfl  ,
    input           i_spr_0hit  ,
    input           i_vblank    ,
    output          o_nmi_n     
);

wire        c_is_ppu;
wire [2:0]  c_ppu_reg;

reg [7:0]   r_ppuctrl;
    
reg [7:0]   r_ppumask   ;

//reg [7:0]   r_ppustat   ;      //TODO: probably this reg does not exist.
reg [7:0]   r_oamaddr   ;
reg [7:0]   r_ppuscrollx;
reg [7:0]   r_ppuscrolly;
reg [15:0]  r_ppuaddr;
reg [7:0]   r_vram_rbuf;

reg         r_nmi_n     ;
reg         r_vblank;
wire        c_vblank_pos;

wire[1:0]   c_nt_base   ;
wire        c_vr_incmode;
wire        c_spr_pt_sel;
wire        c_bg_pt_sel ;
wire        c_patt_sz   ;
wire        c_nmi_ena   ;
wire        c_gray      ;
wire        c_bg_clip   ;
wire        c_spr_clip  ;
wire        c_bg_ena    ;
wire        c_spr_ena   ;
wire        c_high_r    ;
wire        c_high_g    ;
wire        c_high_b    ;

reg         r_wcnt;
wire        c_is_palette;
reg [4:0]   r_lastwrite;

assign c_is_ppu = i_bus_addr[13];
assign c_ppu_reg = i_bus_addr[2:0];

always @ ( posedge i_cpu_clk or negedge i_cpu_rstn) begin
    if(~i_cpu_rstn) begin
    end
    else begin
    end
end

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
assign c_nt_base    = r_ppuctrl[1:0];
assign c_vr_incmode = r_ppuctrl[2];
assign c_spr_pt_sel = r_ppuctrl[3];
assign c_bg_pt_sel  = r_ppuctrl[4];
assign c_patt_sz    = r_ppuctrl[5];
assign c_nmi_ena    = r_ppuctrl[7];

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
assign {c_high_b, c_high_g, c_high_r, c_spr_ena, c_bg_ena, c_spr_clip, c_bg_clip, c_gray} = r_ppumask;

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
            if(r_wcnt)
                r_ppuaddr[7:0] <= i_bus_wdata;
            else
                r_ppuaddr[15:8] <= i_bus_wdata;
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


//read
assign o_ppu_rdata =    ~c_is_ppu         ? 8'h0 :
                        (c_ppu_reg==3'h2) ? {o_nmi_n, i_spr_0hit, i_spr_ovfl, r_lastwrite} :
                        (c_ppu_reg==3'h4) ? i_oam_rdata :
                        (c_ppu_reg==3'h7) ? (c_is_palette ? i_vram_rdata : r_vram_rbuf) :
                        8'h0;

assign o_nmi_n = c_nmi_ena ? r_nmi_n : 1'b1;
endmodule
