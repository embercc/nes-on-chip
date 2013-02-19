module chr_loader(
    input           i_clk       ,//ppu clk
    input           i_rstn      ,
    //cpu
    output          o_done      ,
    //flash
    output [22:0]   o_fl_addr   , 
    input  [7:0]    i_fl_rdata  ,
   
    //sram
    output  [19:0]  o_sram_addr ,
    output  [15:0]  o_sram_wdata,
    input   [15:0]  i_sram_rdata,
    output          o_sram_oe_n ,
    output          o_sram_we_n ,
    output          o_sram_ub_n ,
    output          o_sram_lb_n 
    
);
`ifdef FAST_INIT
    parameter [20:0] MAX_ROM_ADDR = 20'h01FFF;
`else
    parameter [20:0] MAX_ROM_ADDR = 20'hfffff;
`endif
    
    reg     r_done;
    
    reg     [19:0] r_fl_addr;
    wire    [1:0] c_rom_base;
    
    reg  [2:0]   r_state;
    reg  [2:0]   c_state_next;
    parameter [2:0] STATE_START     = 3'b000;
    parameter [2:0] STATE_PRE_LOAD  = 3'b001;
    parameter [2:0] STATE_LOADING   = 3'b010;
    parameter [2:0] STATE_LOADED    = 3'b011;
    parameter [2:0] STATE_PRE_FINISH= 3'b100;
    parameter [2:0] STATE_FINISH    = 3'b111;
    reg [4:0] r_counter;
    reg       r_cnt_1;
    reg [1:0] r_cnt_4;
    reg [7:0]   r_sram_wdata;
    reg [18:0]  r_sram_addr;
    reg         r_sram_oe_n;
    reg         r_sram_we_n;
    reg         r_sram_ub_n;
    reg         r_sram_lb_n;
    
    always @ ( * ) begin
        case(r_state)
        STATE_START:
            begin
                c_state_next = STATE_PRE_LOAD;
            end
        STATE_PRE_LOAD:
            begin
                if(r_counter==4'hf)
                    c_state_next = STATE_LOADING;
                else
                    c_state_next = STATE_PRE_LOAD;
            end
        STATE_LOADING:
            begin
                if(r_fl_addr==MAX_ROM_ADDR && r_cnt_4==2'h3)
                    c_state_next = STATE_LOADED;
                else
                    c_state_next = STATE_LOADING;
            end
        STATE_LOADED:
            begin
                c_state_next = STATE_PRE_FINISH;
            end
        STATE_PRE_FINISH:
            begin
                if(r_counter==4'hf)
                    c_state_next = STATE_FINISH;
                else 
                    c_state_next = STATE_PRE_FINISH;
            end
        STATE_FINISH:
            begin
                c_state_next = STATE_FINISH;
            end
        endcase
    end
    
    always @ ( posedge i_clk or negedge i_rstn ) begin
        if(~i_rstn) begin
            r_state <= STATE_START;
        end
        else begin
            r_state <= c_state_next;
        end
    end
    
    always @ ( posedge i_clk or negedge i_rstn ) begin
        if(~i_rstn) begin
            r_counter <= 4'h0;
            r_cnt_4 <= 1'b0;
        end
        else begin
            if(r_state==STATE_START || r_state==STATE_LOADED) begin
                r_counter <= 4'h0;
            end
            else if(r_counter==4'hf) begin
                r_counter <= 4'hf;
            end
            else begin
                r_counter <= r_counter + 5'h1;
            end
            
            if(r_state==STATE_LOADING) begin
                r_cnt_4 <= r_cnt_4 + 2'h1;
            end
        end
    end
    
    
    always @ ( posedge i_clk or negedge i_rstn ) begin
        if(~i_rstn) begin
            r_done <= 1'b0;
        end
        else begin
            if(r_state==STATE_FINISH) begin
                r_done <= 1'b1;
            end
        end
    end

    always @ ( posedge i_clk or negedge i_rstn ) begin
        if(~i_rstn) begin
            r_fl_addr <= 20'h00000;
        end
        else begin
            if (r_state==STATE_LOADING && r_fl_addr!=MAX_ROM_ADDR) begin
                r_fl_addr <= r_fl_addr + {19'h0, {r_cnt_4==2'h3}};
            end
        end
    end

    always @ ( posedge i_clk or negedge i_rstn ) begin
        if(~i_rstn) begin
            r_sram_wdata <= 8'h00;
        end
        else begin
            if(r_cnt_4==4'h0) begin
                r_sram_wdata <= i_fl_rdata;
            end
        end
    end
    
    always @ (posedge i_clk or negedge i_rstn ) begin
        if(~i_rstn) begin
            r_sram_addr <= 19'h0;
            r_sram_oe_n <= 1'b1;
            r_sram_ub_n <= 1'b1;
            r_sram_lb_n <= 1'b1;
            r_sram_we_n <= 1'b1;
        end
        else begin
            if(r_state==STATE_LOADING) begin
                if(r_cnt_4==2'h0) begin
                    r_sram_ub_n <= ~r_fl_addr[3];
                    r_sram_lb_n <= r_fl_addr[3];
                    r_sram_addr <= {r_fl_addr[19:4], r_fl_addr[2:0]};
                end
                else if(r_cnt_4==2'h3) begin
                    r_sram_ub_n <= 1'b1;
                    r_sram_lb_n <= 1'b1;
                    r_sram_addr <= 19'h0;
                end
            end
            else if(r_state==STATE_LOADED) begin
                r_sram_ub_n <= 1'b1;
                r_sram_lb_n <= 1'b1;
                
                r_sram_addr <= 19'h0;
            end
            
            if(r_state==STATE_LOADED) begin
                r_sram_oe_n <= 1'b0;
            end
            
            if(r_state==STATE_LOADING) begin
                if(r_cnt_4==2'h1)
                    r_sram_we_n <= 1'b0;
                else if(r_cnt_4==2'h2)
                    r_sram_we_n <= 1'b1;
            end
        end    
    end

    /*
    OUTPUT: cpu pause
    */
    
    assign o_done = r_done;

    /*
    OUTPUT: flash
    */
    assign c_rom_base = 2'b00;
    assign o_fl_addr = {1'b1, c_rom_base, r_fl_addr};
    
    /*
    OUTPUT: sram
    */
    assign o_sram_addr = {1'b0, r_sram_addr};
    assign o_sram_wdata[15:8] = r_sram_ub_n ? 8'h0 : r_sram_wdata;
    assign o_sram_wdata[7:0]  = r_sram_lb_n ? 8'h0 : r_sram_wdata;
    assign o_sram_oe_n = r_sram_oe_n;
    assign o_sram_we_n = r_sram_we_n;//(r_state==STATE_LOADING) ? ~r_cnt_1 : 1'b1;
    assign o_sram_ub_n = r_sram_ub_n;
    assign o_sram_lb_n = r_sram_lb_n;
    
endmodule
